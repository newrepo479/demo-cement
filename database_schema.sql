-- ============================================================================
-- SOHOsoft B2B Portal - Database Schema
-- System zarządzania zamówieniami, klientami i CRM dla cementowni
-- ============================================================================
-- Wersja: 1.0
-- Data: 2026-01-15
-- ============================================================================

-- ============================================================================
-- 1. UŻYTKOWNICY I AUTENTYKACJA
-- ============================================================================

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('client', 'carrier', 'admin', 'sales_rep')),
    is_active BOOLEAN DEFAULT TRUE,
    last_login_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);

-- ============================================================================
-- 2. KLIENCI I FIRMY
-- ============================================================================

CREATE TABLE companies (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    nip VARCHAR(20) UNIQUE NOT NULL,
    regon VARCHAR(20),
    street VARCHAR(255),
    city VARCHAR(100),
    postal_code VARCHAR(10),
    country VARCHAR(100) DEFAULT 'Polska',
    phone VARCHAR(20),
    email VARCHAR(255),
    website VARCHAR(255),
    credit_limit DECIMAL(15,2) DEFAULT 0,
    current_balance DECIMAL(15,2) DEFAULT 0,
    payment_terms_days INTEGER DEFAULT 30,
    assigned_sales_rep_id INTEGER,
    status VARCHAR(50) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'blocked', 'premium')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (assigned_sales_rep_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE INDEX idx_companies_nip ON companies(nip);
CREATE INDEX idx_companies_sales_rep ON companies(assigned_sales_rep_id);
CREATE INDEX idx_companies_status ON companies(status);

-- Relacja użytkownik-klient
CREATE TABLE user_companies (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    company_id INTEGER NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    UNIQUE(user_id, company_id)
);

-- ============================================================================
-- 3. PUNKTY ODBIORU (Delivery Locations)
-- ============================================================================

CREATE TABLE delivery_locations (
    id SERIAL PRIMARY KEY,
    company_id INTEGER NOT NULL,
    name VARCHAR(255) NOT NULL,
    street VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    postal_code VARCHAR(10) NOT NULL,
    country VARCHAR(100) DEFAULT 'Polska',
    contact_person VARCHAR(255),
    contact_phone VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    available_products TEXT[], -- Array of product IDs available at this location
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
);

CREATE INDEX idx_delivery_locations_company ON delivery_locations(company_id);

-- ============================================================================
-- 4. PRODUKTY
-- ============================================================================

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    code VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    unit VARCHAR(50) DEFAULT 'ton' CHECK (unit IN ('ton', 'bag', 'pallet', 'truck')),
    price_per_ton DECIMAL(10,2) NOT NULL,
    price_per_bag DECIMAL(10,2), -- 25kg bag
    price_per_pallet DECIMAL(10,2), -- 40 bags = 1 ton
    price_per_truck DECIMAL(10,2), -- 20-32 tons
    stock_quantity DECIMAL(10,2) DEFAULT 0,
    min_order_quantity DECIMAL(10,2) DEFAULT 1,
    certification VARCHAR(255), -- e.g., PN-EN 197-1
    delivery_time_hours INTEGER DEFAULT 48,
    is_active BOOLEAN DEFAULT TRUE,
    image_url VARCHAR(500),
    technical_specs JSONB, -- JSON with technical parameters
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_products_code ON products(code);
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_active ON products(is_active);

-- ============================================================================
-- 5. ZAMÓWIENIA
-- ============================================================================

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    company_id INTEGER NOT NULL,
    delivery_location_id INTEGER NOT NULL,
    sales_rep_id INTEGER,
    status VARCHAR(50) DEFAULT 'draft' CHECK (status IN (
        'draft', 'pending', 'confirmed', 'processing', 
        'ready_for_delivery', 'in_transit', 'delivered', 
        'cancelled', 'completed'
    )),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    requested_delivery_date DATE,
    delivery_method VARCHAR(50) CHECK (delivery_method IN ('own_transport', 'carrier', 'pickup')),
    carrier_id INTEGER, -- If using carrier
    total_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
    total_quantity DECIMAL(10,2) NOT NULL DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE RESTRICT,
    FOREIGN KEY (delivery_location_id) REFERENCES delivery_locations(id) ON DELETE RESTRICT,
    FOREIGN KEY (sales_rep_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (carrier_id) REFERENCES companies(id) ON DELETE SET NULL
);

CREATE INDEX idx_orders_company ON orders(company_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_sales_rep ON orders(sales_rep_id);
CREATE INDEX idx_orders_number ON orders(order_number);

-- Pozycje zamówienia
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    unit VARCHAR(50) NOT NULL CHECK (unit IN ('ton', 'bag', 'pallet', 'truck')),
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(15,2) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT
);

CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);

-- ============================================================================
-- 6. FAKTURY I PŁATNOŚCI
-- ============================================================================

CREATE TABLE invoices (
    id SERIAL PRIMARY KEY,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    order_id INTEGER,
    company_id INTEGER NOT NULL,
    issue_date DATE NOT NULL,
    due_date DATE NOT NULL,
    total_amount DECIMAL(15,2) NOT NULL,
    paid_amount DECIMAL(15,2) DEFAULT 0,
    vat_amount DECIMAL(15,2) DEFAULT 0,
    status VARCHAR(50) DEFAULT 'unpaid' CHECK (status IN ('unpaid', 'partially_paid', 'paid', 'overdue', 'cancelled')),
    pdf_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE SET NULL,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE RESTRICT
);

CREATE INDEX idx_invoices_company ON invoices(company_id);
CREATE INDEX idx_invoices_status ON invoices(status);
CREATE INDEX idx_invoices_due_date ON invoices(due_date);
CREATE INDEX idx_invoices_order ON invoices(order_id);

-- Płatności
CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    invoice_id INTEGER NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    payment_date DATE NOT NULL,
    payment_method VARCHAR(50) CHECK (payment_method IN ('bank_transfer', 'cash', 'card', 'credit')),
    reference_number VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE
);

CREATE INDEX idx_payments_invoice ON payments(invoice_id);
CREATE INDEX idx_payments_date ON payments(payment_date);

-- ============================================================================
-- 7. TRANSPORT - PRZEWOŹNICY, KIEROWCY, POJAZDY
-- ============================================================================

-- Przewoźnicy (to są też companies z role='carrier')
-- Używamy tabeli companies z dodatkową tabelą dla szczegółów przewoźnika

CREATE TABLE carriers (
    id SERIAL PRIMARY KEY,
    company_id INTEGER NOT NULL UNIQUE,
    license_number VARCHAR(100),
    rating DECIMAL(3,2) DEFAULT 0, -- 0.00 - 5.00
    total_deliveries INTEGER DEFAULT 0,
    loyalty_points INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
);

-- Kierowcy przewoźników
CREATE TABLE drivers (
    id SERIAL PRIMARY KEY,
    carrier_id INTEGER NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(255),
    license_number VARCHAR(100),
    license_expiry_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (carrier_id) REFERENCES carriers(company_id) ON DELETE CASCADE
);

CREATE INDEX idx_drivers_carrier ON drivers(carrier_id);

-- Pojazdy przewoźników
CREATE TABLE vehicles (
    id SERIAL PRIMARY KEY,
    carrier_id INTEGER NOT NULL,
    registration_number VARCHAR(20) UNIQUE NOT NULL,
    brand VARCHAR(100),
    model VARCHAR(100),
    capacity_tons DECIMAL(5,2), -- Pojemność w tonach
    vehicle_type VARCHAR(50) CHECK (vehicle_type IN ('truck', 'semi_truck', 'tank_truck')),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (carrier_id) REFERENCES carriers(company_id) ON DELETE CASCADE
);

CREATE INDEX idx_vehicles_carrier ON vehicles(carrier_id);
CREATE INDEX idx_vehicles_registration ON vehicles(registration_number);

-- Samochody i kierowcy klientów (dla własnego transportu)
CREATE TABLE client_vehicles (
    id SERIAL PRIMARY KEY,
    company_id INTEGER NOT NULL,
    registration_number VARCHAR(20) NOT NULL,
    brand VARCHAR(100),
    model VARCHAR(100),
    capacity_tons DECIMAL(5,2),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
);

CREATE TABLE client_drivers (
    id SERIAL PRIMARY KEY,
    company_id INTEGER NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(255),
    license_number VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
);

CREATE INDEX idx_client_vehicles_company ON client_vehicles(company_id);
CREATE INDEX idx_client_drivers_company ON client_drivers(company_id);

-- Zlecenia transportowe
CREATE TABLE transport_orders (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    carrier_id INTEGER,
    driver_id INTEGER,
    vehicle_id INTEGER,
    status VARCHAR(50) DEFAULT 'assigned' CHECK (status IN (
        'assigned', 'confirmed', 'in_transit', 'delivered', 'cancelled'
    )),
    estimated_delivery_date TIMESTAMP,
    actual_delivery_date TIMESTAMP,
    tracking_url VARCHAR(500),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (carrier_id) REFERENCES carriers(company_id) ON DELETE SET NULL,
    FOREIGN KEY (driver_id) REFERENCES drivers(id) ON DELETE SET NULL,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE SET NULL
);

CREATE INDEX idx_transport_orders_order ON transport_orders(order_id);
CREATE INDEX idx_transport_orders_carrier ON transport_orders(carrier_id);
CREATE INDEX idx_transport_orders_status ON transport_orders(status);

-- ============================================================================
-- 8. AKTYWNOŚCI KLIENTÓW (Client Activities Tracking)
-- ============================================================================

CREATE TABLE client_activities (
    id SERIAL PRIMARY KEY,
    company_id INTEGER NOT NULL,
    user_id INTEGER, -- User who performed the activity
    activity_type VARCHAR(50) NOT NULL CHECK (activity_type IN (
        'login', 'logout',
        'product_view', 'product_search',
        'order_created', 'order_updated', 'order_cancelled',
        'invoice_downloaded', 'invoice_viewed',
        'driver_added', 'driver_updated', 'driver_deleted',
        'vehicle_added', 'vehicle_updated', 'vehicle_deleted',
        'delivery_location_added', 'delivery_location_updated',
        'company_data_updated',
        'complaint_created', 'complaint_updated'
    )),
    activity_data JSONB, -- Flexible JSON to store activity-specific data
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE INDEX idx_client_activities_company ON client_activities(company_id);
CREATE INDEX idx_client_activities_type ON client_activities(activity_type);
CREATE INDEX idx_client_activities_date ON client_activities(created_at);
CREATE INDEX idx_client_activities_user ON client_activities(user_id);

-- ============================================================================
-- 9. PANEL HANDLOWCA - CELE, ZADANIA, WIZYTY
-- ============================================================================

-- Cele handlowca
CREATE TABLE sales_goals (
    id SERIAL PRIMARY KEY,
    sales_rep_id INTEGER NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    goal_type VARCHAR(50) NOT NULL CHECK (goal_type IN ('quantitative', 'qualitative')),
    target_value DECIMAL(15,2), -- For quantitative goals
    current_value DECIMAL(15,2) DEFAULT 0,
    unit VARCHAR(50), -- e.g., 'PLN', 'orders', 'clients'
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(50) DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled', 'paused')),
    progress_percentage DECIMAL(5,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sales_rep_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_sales_goals_sales_rep ON sales_goals(sales_rep_id);
CREATE INDEX idx_sales_goals_status ON sales_goals(status);
CREATE INDEX idx_sales_goals_dates ON sales_goals(start_date, end_date);

-- Zadania handlowca
CREATE TABLE sales_tasks (
    id SERIAL PRIMARY KEY,
    sales_rep_id INTEGER NOT NULL,
    company_id INTEGER,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    priority VARCHAR(50) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
    due_date DATE,
    completed_at TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sales_rep_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE SET NULL
);

CREATE INDEX idx_sales_tasks_sales_rep ON sales_tasks(sales_rep_id);
CREATE INDEX idx_sales_tasks_company ON sales_tasks(company_id);
CREATE INDEX idx_sales_tasks_status ON sales_tasks(status);
CREATE INDEX idx_sales_tasks_due_date ON sales_tasks(due_date);

-- Wizyty handlowca
CREATE TABLE sales_visits (
    id SERIAL PRIMARY KEY,
    sales_rep_id INTEGER NOT NULL,
    company_id INTEGER NOT NULL,
    visit_date TIMESTAMP NOT NULL,
    visit_type VARCHAR(50) CHECK (visit_type IN ('planned', 'ad_hoc', 'follow_up', 'presentation')),
    status VARCHAR(50) DEFAULT 'planned' CHECK (status IN ('planned', 'completed', 'cancelled', 'postponed')),
    location VARCHAR(255),
    notes TEXT,
    outcome TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sales_rep_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
);

CREATE INDEX idx_sales_visits_sales_rep ON sales_visits(sales_rep_id);
CREATE INDEX idx_sales_visits_company ON sales_visits(company_id);
CREATE INDEX idx_sales_visits_date ON sales_visits(visit_date);
CREATE INDEX idx_sales_visits_status ON sales_visits(status);

-- Notatki handlowca o klientach
CREATE TABLE sales_notes (
    id SERIAL PRIMARY KEY,
    sales_rep_id INTEGER NOT NULL,
    company_id INTEGER NOT NULL,
    note_type VARCHAR(50) CHECK (note_type IN ('call', 'visit', 'email', 'meeting', 'other')),
    title VARCHAR(255),
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sales_rep_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
);

CREATE INDEX idx_sales_notes_sales_rep ON sales_notes(sales_rep_id);
CREATE INDEX idx_sales_notes_company ON sales_notes(company_id);
CREATE INDEX idx_sales_notes_date ON sales_notes(created_at);

-- ============================================================================
-- 10. REKLAMACJE I ZGŁOSZENIA
-- ============================================================================

CREATE TABLE complaints (
    id SERIAL PRIMARY KEY,
    complaint_number VARCHAR(50) UNIQUE NOT NULL,
    company_id INTEGER NOT NULL,
    order_id INTEGER,
    invoice_id INTEGER,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(50) CHECK (category IN ('quality', 'delivery', 'invoice', 'service', 'other')),
    priority VARCHAR(50) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    status VARCHAR(50) DEFAULT 'new' CHECK (status IN ('new', 'in_progress', 'resolved', 'closed', 'rejected')),
    assigned_to INTEGER, -- Sales rep or admin
    resolution TEXT,
    resolved_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE SET NULL,
    FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE SET NULL,
    FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL
);

CREATE INDEX idx_complaints_company ON complaints(company_id);
CREATE INDEX idx_complaints_status ON complaints(status);
CREATE INDEX idx_complaints_assigned ON complaints(assigned_to);
CREATE INDEX idx_complaints_date ON complaints(created_at);

-- ============================================================================
-- 11. POWIADOMIENIA
-- ============================================================================

CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) CHECK (type IN ('info', 'warning', 'success', 'error', 'alert')),
    related_entity_type VARCHAR(50), -- 'order', 'invoice', 'complaint', etc.
    related_entity_id INTEGER,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(is_read);
CREATE INDEX idx_notifications_created ON notifications(created_at);

-- ============================================================================
-- 12. TRIGGERY I FUNKCJE AUTOMATYCZNE
-- ============================================================================

-- Funkcja do aktualizacji postępu celów handlowca na podstawie zamówień
CREATE OR REPLACE FUNCTION update_sales_goal_progress()
RETURNS TRIGGER AS $$
BEGIN
    -- Aktualizuj cele ilościowe (przychód) na podstawie zamówień
    IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
        UPDATE sales_goals
        SET current_value = current_value + NEW.total_amount,
            progress_percentage = CASE 
                WHEN target_value > 0 THEN LEAST(100, (current_value + NEW.total_amount) / target_value * 100)
                ELSE 0
            END,
            updated_at = CURRENT_TIMESTAMP
        WHERE sales_rep_id = NEW.sales_rep_id
          AND goal_type = 'quantitative'
          AND unit = 'PLN'
          AND status = 'active'
          AND NEW.order_date BETWEEN start_date AND end_date;
        
        -- Aktualizuj cele ilościowe (liczba zamówień)
        UPDATE sales_goals
        SET current_value = current_value + 1,
            progress_percentage = CASE 
                WHEN target_value > 0 THEN LEAST(100, (current_value + 1) / target_value * 100)
                ELSE 0
            END,
            updated_at = CURRENT_TIMESTAMP
        WHERE sales_rep_id = NEW.sales_rep_id
          AND goal_type = 'quantitative'
          AND unit = 'orders'
          AND status = 'active'
          AND NEW.order_date BETWEEN start_date AND end_date;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_sales_goal_on_order
    AFTER UPDATE ON orders
    FOR EACH ROW
    WHEN (NEW.status = 'completed' AND OLD.status != 'completed')
    EXECUTE FUNCTION update_sales_goal_progress();

-- Funkcja do automatycznego generowania numeru zamówienia
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.order_number IS NULL OR NEW.order_number = '' THEN
        NEW.order_number := 'ZAM-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '-' || 
                           LPAD(NEXTVAL('orders_id_seq')::TEXT, 6, '0');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_generate_order_number
    BEFORE INSERT ON orders
    FOR EACH ROW
    EXECUTE FUNCTION generate_order_number();

-- Funkcja do automatycznego generowania numeru faktury
CREATE OR REPLACE FUNCTION generate_invoice_number()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.invoice_number IS NULL OR NEW.invoice_number = '' THEN
        NEW.invoice_number := 'FV/' || TO_CHAR(CURRENT_DATE, 'YYYY/MM') || '/' || 
                             LPAD(NEXTVAL('invoices_id_seq')::TEXT, 6, '0');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_generate_invoice_number
    BEFORE INSERT ON invoices
    FOR EACH ROW
    EXECUTE FUNCTION generate_invoice_number();

-- Funkcja do aktualizacji salda klienta przy płatnościach
CREATE OR REPLACE FUNCTION update_company_balance()
RETURNS TRIGGER AS $$
DECLARE
    invoice_amount DECIMAL(15,2);
    total_paid DECIMAL(15,2);
BEGIN
    -- Pobierz kwotę faktury
    SELECT total_amount INTO invoice_amount
    FROM invoices
    WHERE id = NEW.invoice_id;
    
    -- Oblicz sumę wszystkich płatności dla faktury
    SELECT COALESCE(SUM(amount), 0) INTO total_paid
    FROM payments
    WHERE invoice_id = NEW.invoice_id;
    
    -- Aktualizuj status faktury
    UPDATE invoices
    SET status = CASE
        WHEN total_paid >= invoice_amount THEN 'paid'
        WHEN total_paid > 0 THEN 'partially_paid'
        ELSE 'unpaid'
    END,
    paid_amount = total_paid,
    updated_at = CURRENT_TIMESTAMP
    WHERE id = NEW.invoice_id;
    
    -- Aktualizuj saldo firmy
    UPDATE companies
    SET current_balance = (
        SELECT COALESCE(SUM(i.total_amount - COALESCE(SUM(p.amount), 0)), 0)
        FROM invoices i
        LEFT JOIN payments p ON p.invoice_id = i.id
        WHERE i.company_id = (SELECT company_id FROM invoices WHERE id = NEW.invoice_id)
        GROUP BY i.id
    )
    WHERE id = (SELECT company_id FROM invoices WHERE id = NEW.invoice_id);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_company_balance
    AFTER INSERT OR UPDATE OR DELETE ON payments
    FOR EACH ROW
    EXECUTE FUNCTION update_company_balance();

-- Funkcja do automatycznego rejestrowania aktywności przy zmianach
CREATE OR REPLACE FUNCTION log_client_activity()
RETURNS TRIGGER AS $$
DECLARE
    activity_type_val VARCHAR(50);
    activity_data_val JSONB;
BEGIN
    -- Określ typ aktywności na podstawie tabeli
    IF TG_TABLE_NAME = 'orders' THEN
        IF TG_OP = 'INSERT' THEN
            activity_type_val := 'order_created';
            activity_data_val := jsonb_build_object(
                'order_id', NEW.id,
                'order_number', NEW.order_number,
                'total_amount', NEW.total_amount
            );
        ELSIF TG_OP = 'UPDATE' THEN
            activity_type_val := 'order_updated';
            activity_data_val := jsonb_build_object(
                'order_id', NEW.id,
                'order_number', NEW.order_number,
                'status', NEW.status
            );
        END IF;
        
        INSERT INTO client_activities (company_id, activity_type, activity_data)
        VALUES (NEW.company_id, activity_type_val, activity_data_val);
        
    ELSIF TG_TABLE_NAME = 'client_drivers' THEN
        IF TG_OP = 'INSERT' THEN
            activity_type_val := 'driver_added';
        ELSIF TG_OP = 'UPDATE' THEN
            activity_type_val := 'driver_updated';
        ELSIF TG_OP = 'DELETE' THEN
            activity_type_val := 'driver_deleted';
        END IF;
        
        INSERT INTO client_activities (company_id, activity_type, activity_data)
        VALUES (
            COALESCE(NEW.company_id, OLD.company_id),
            activity_type_val,
            jsonb_build_object('driver_id', COALESCE(NEW.id, OLD.id))
        );
        
    ELSIF TG_TABLE_NAME = 'client_vehicles' THEN
        IF TG_OP = 'INSERT' THEN
            activity_type_val := 'vehicle_added';
        ELSIF TG_OP = 'UPDATE' THEN
            activity_type_val := 'vehicle_updated';
        ELSIF TG_OP = 'DELETE' THEN
            activity_type_val := 'vehicle_deleted';
        END IF;
        
        INSERT INTO client_activities (company_id, activity_type, activity_data)
        VALUES (
            COALESCE(NEW.company_id, OLD.company_id),
            activity_type_val,
            jsonb_build_object('vehicle_id', COALESCE(NEW.id, OLD.id))
        );
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Triggery dla logowania aktywności
CREATE TRIGGER trigger_log_order_activity
    AFTER INSERT OR UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION log_client_activity();

CREATE TRIGGER trigger_log_driver_activity
    AFTER INSERT OR UPDATE OR DELETE ON client_drivers
    FOR EACH ROW
    EXECUTE FUNCTION log_client_activity();

CREATE TRIGGER trigger_log_vehicle_activity
    AFTER INSERT OR UPDATE OR DELETE ON client_vehicles
    FOR EACH ROW
    EXECUTE FUNCTION log_client_activity();

-- ============================================================================
-- 13. WIDOKI (VIEWS) DLA RAPORTOWANIA
-- ============================================================================

-- Widok aktywności klientów dla handlowca
CREATE VIEW v_client_activities_summary AS
SELECT 
    ca.id,
    ca.company_id,
    c.name AS company_name,
    ca.activity_type,
    ca.activity_data,
    ca.created_at,
    u.email AS user_email
FROM client_activities ca
JOIN companies c ON c.id = ca.company_id
LEFT JOIN users u ON u.id = ca.user_id
ORDER BY ca.created_at DESC;

-- Widok postępu celów handlowca
CREATE VIEW v_sales_goals_progress AS
SELECT 
    sg.id,
    sg.sales_rep_id,
    u.email AS sales_rep_email,
    sg.title,
    sg.goal_type,
    sg.target_value,
    sg.current_value,
    sg.progress_percentage,
    sg.start_date,
    sg.end_date,
    sg.status,
    CASE 
        WHEN sg.end_date < CURRENT_DATE AND sg.status = 'active' THEN 'overdue'
        ELSE sg.status
    END AS effective_status
FROM sales_goals sg
JOIN users u ON u.id = sg.sales_rep_id;

-- Widok zamówień z pełnymi danymi
CREATE VIEW v_orders_full AS
SELECT 
    o.id,
    o.order_number,
    o.company_id,
    c.name AS company_name,
    o.delivery_location_id,
    dl.name AS delivery_location_name,
    o.sales_rep_id,
    u.email AS sales_rep_email,
    o.status,
    o.order_date,
    o.requested_delivery_date,
    o.delivery_method,
    o.total_amount,
    o.total_quantity,
    COUNT(oi.id) AS items_count
FROM orders o
JOIN companies c ON c.id = o.company_id
JOIN delivery_locations dl ON dl.id = o.delivery_location_id
LEFT JOIN users u ON u.id = o.sales_rep_id
LEFT JOIN order_items oi ON oi.order_id = o.id
GROUP BY o.id, c.name, dl.name, u.email;

-- ============================================================================
-- KONIEC SCHEMATU
-- ============================================================================

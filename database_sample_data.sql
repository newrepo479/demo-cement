-- ============================================================================
-- SOHOsoft B2B Portal - Sample Data
-- Przykładowe dane testowe do prezentacji funkcjonalności
-- ============================================================================

-- ============================================================================
-- 1. UŻYTKOWNICY
-- ============================================================================

INSERT INTO users (email, password_hash, role, is_active) VALUES
-- Klienci
('demo@klient.pl', '$2b$10$example_hash', 'client', TRUE),
('kontakt@firmabudowlana.pl', '$2b$10$example_hash', 'client', TRUE),
('biuro@autobud.pl', '$2b$10$example_hash', 'client', TRUE),

-- Przewoźnicy
('demo@przewoznik.pl', '$2b$10$example_hash', 'carrier', TRUE),
('kontakt@autoall.pl', '$2b$10$example_hash', 'carrier', TRUE),
('info@transbud.pl', '$2b$10$example_hash', 'carrier', TRUE),

-- Handlowcy
('demo@handlowiec.pl', '$2b$10$example_hash', 'sales_rep', TRUE),
('jan.kowalski@sohosoft.pl', '$2b$10$example_hash', 'sales_rep', TRUE),
('anna.nowak@sohosoft.pl', '$2b$10$example_hash', 'sales_rep', TRUE),

-- Admin
('demo@admin.pl', '$2b$10$example_hash', 'admin', TRUE);

-- ============================================================================
-- 2. FIRMY (KLIENCI)
-- ============================================================================

INSERT INTO companies (name, nip, regon, street, city, postal_code, phone, email, credit_limit, current_balance, assigned_sales_rep_id, status) VALUES
('Firma Budowlana Budowa Sp. z o.o.', '1234567890', '123456789', 'ul. Przykładowa 123', 'Warszawa', '00-000', '+48 123 456 789', 'kontakt@firmabudowlana.pl', 100000.00, 45230.00, 
 (SELECT id FROM users WHERE email = 'jan.kowalski@sohosoft.pl'), 'active'),

('Auto-All Magazynowa Sp. z o.o.', '2345678901', '234567890', 'ul. Magazynowa 45', 'Kraków', '30-001', '+48 234 567 890', 'biuro@autobud.pl', 150000.00, 78900.00,
 (SELECT id FROM users WHERE email = 'jan.kowalski@sohosoft.pl'), 'active'),

('Elmas Pawlak S.J.', '3456789012', '345678901', 'ul. Budowlana 67', 'Wrocław', '50-001', '+48 345 678 901', 'elmas@example.pl', 50000.00, 12000.00,
 (SELECT id FROM users WHERE email = 'anna.nowak@sohosoft.pl'), 'active'),

('Skład Regionalny Sp. z o.o.', '4567890123', '456789012', 'ul. Przemysłowa 89', 'Poznań', '60-001', '+48 456 789 012', 'sklad@example.pl', 75000.00, 25000.00,
 (SELECT id FROM users WHERE email = 'anna.nowak@sohosoft.pl'), 'active'),

('Budowa Plus Sp. z o.o.', '5678901234', '567890123', 'ul. Cementowa 12', 'Gdańsk', '80-001', '+48 567 890 123', 'budowaplus@example.pl', 200000.00, 156000.00,
 (SELECT id FROM users WHERE email = 'jan.kowalski@sohosoft.pl'), 'premium');

-- ============================================================================
-- 3. FIRMY (PRZEWOŹNICY)
-- ============================================================================

INSERT INTO companies (name, nip, regon, street, city, postal_code, phone, email, status) VALUES
('Auto-All Transport Sp. z o.o.', '6789012345', '678901234', 'ul. Transportowa 1', 'Warszawa', '00-100', '+48 678 901 234', 'kontakt@autoall.pl', 'active'),
('Trans-Bud Sp. z o.o.', '7890123456', '789012345', 'ul. Logistyczna 5', 'Kraków', '30-200', '+48 789 012 345', 'info@transbud.pl', 'active');

-- Dodaj do tabeli carriers
INSERT INTO carriers (company_id, license_number, rating, total_deliveries, loyalty_points) VALUES
((SELECT id FROM companies WHERE name = 'Auto-All Transport Sp. z o.o.'), 'LIC-001', 4.8, 245, 1250),
((SELECT id FROM companies WHERE name = 'Trans-Bud Sp. z o.o.'), 'LIC-002', 4.5, 189, 890);

-- ============================================================================
-- 4. PUNKTY ODBIORU
-- ============================================================================

INSERT INTO delivery_locations (company_id, name, street, city, postal_code, available_products) VALUES
((SELECT id FROM companies WHERE name = 'Firma Budowlana Budowa Sp. z o.o.'), 
 'Magazyn Centralny', 'ul. Przemysłowa 45', 'Warszawa', '00-001', ARRAY['1', '2', '3']),

((SELECT id FROM companies WHERE name = 'Firma Budowlana Budowa Sp. z o.o.'), 
 'Punkt Odbioru Południe', 'ul. Budowlana 12', 'Kraków', '30-001', ARRAY['1', '4']),

((SELECT id FROM companies WHERE name = 'Auto-All Magazynowa Sp. z o.o.'), 
 'Skład Regionalny', 'ul. Magazynowa 88', 'Wrocław', '50-001', ARRAY['1', '2', '3', '4', '5']);

-- ============================================================================
-- 5. PRODUKTY
-- ============================================================================

INSERT INTO products (code, name, description, category, price_per_ton, price_per_bag, price_per_pallet, price_per_truck, stock_quantity, min_order_quantity, certification, delivery_time_hours, technical_specs) VALUES
('CEM-I-42.5R', 'CEM I 42,5R', 'Cement portlandzki o wysokiej wytrzymałości wczesnej', 'Cement Portlandzki', 410.00, 10.25, 410.00, 12300.00, 5000.00, 1.00, 'PN-EN 197-1', 48,
 '{"strength_2d": "≥20 MPa", "strength_28d": "≥42.5 MPa", "setting_start": "≥60 min", "setting_end": "≤600 min"}'::jsonb),

('CEM-II-B-S-42.5N', 'CEM II/B-S 42,5N', 'Cement portlandzki z dodatkiem żużla', 'Cement Portlandzki', 395.00, 9.88, 395.00, 11850.00, 3500.00, 1.00, 'PN-EN 197-1', 48,
 '{"strength_2d": "≥10 MPa", "strength_28d": "≥42.5 MPa", "slag_content": "21-35%"}'::jsonb),

('CEM-II-A-LL-42.5R', 'CEM II/A-LL 42,5R', 'Cement portlandzki z dodatkiem wapienia', 'Cement Portlandzki', 400.00, 10.00, 400.00, 12000.00, 4200.00, 1.00, 'PN-EN 197-1', 48,
 '{"strength_2d": "≥20 MPa", "strength_28d": "≥42.5 MPa", "limestone_content": "6-20%"}'::jsonb),

('CEM-II-A-S-42.5N', 'CEM II/A-S 42,5N', 'Cement portlandzki z dodatkiem żużla', 'Cement Portlandzki', 390.00, 9.75, 390.00, 11700.00, 2800.00, 1.00, 'PN-EN 197-1', 48,
 '{"strength_2d": "≥10 MPa", "strength_28d": "≥42.5 MPa", "slag_content": "6-20%"}'::jsonb),

('CEM-V-A-S-32.5N', 'CEM V/A-S 32,5N', 'Cement wieloskładnikowy', 'Cement Wieloskładnikowy', 380.00, 9.50, 380.00, 11400.00, 1500.00, 1.00, 'PN-EN 197-1', 48,
 '{"strength_2d": "≥10 MPa", "strength_28d": "≥32.5 MPa"}'::jsonb);

-- ============================================================================
-- 6. ZAMÓWIENIA
-- ============================================================================

-- Zamówienie 1: Firma Budowlana Budowa
INSERT INTO orders (order_number, company_id, delivery_location_id, sales_rep_id, status, order_date, requested_delivery_date, delivery_method, total_amount, total_quantity) VALUES
('ZAM-2026-000001', 
 (SELECT id FROM companies WHERE name = 'Firma Budowlana Budowa Sp. z o.o.'),
 (SELECT id FROM delivery_locations WHERE name = 'Magazyn Centralny'),
 (SELECT id FROM users WHERE email = 'jan.kowalski@sohosoft.pl'),
 'completed', '2026-01-05 10:30:00', '2026-01-07', 'carrier', 12350.00, 30.00);

INSERT INTO order_items (order_id, product_id, quantity, unit, unit_price, total_price) VALUES
((SELECT id FROM orders WHERE order_number = 'ZAM-2026-000001'),
 (SELECT id FROM products WHERE code = 'CEM-I-42.5R'), 30.00, 'ton', 410.00, 12300.00);

-- Zamówienie 2: Auto-All Magazynowa
INSERT INTO orders (order_number, company_id, delivery_location_id, sales_rep_id, status, order_date, requested_delivery_date, delivery_method, carrier_id, total_amount, total_quantity) VALUES
('ZAM-2026-000002',
 (SELECT id FROM companies WHERE name = 'Auto-All Magazynowa Sp. z o.o.'),
 (SELECT id FROM delivery_locations WHERE name = 'Skład Regionalny'),
 (SELECT id FROM users WHERE email = 'jan.kowalski@sohosoft.pl'),
 'in_transit', '2026-01-10 14:20:00', '2026-01-12', 'carrier',
 (SELECT id FROM companies WHERE name = 'Auto-All Transport Sp. z o.o.'), 15800.00, 40.00);

INSERT INTO order_items (order_id, product_id, quantity, unit, unit_price, total_price) VALUES
((SELECT id FROM orders WHERE order_number = 'ZAM-2026-000002'),
 (SELECT id FROM products WHERE code = 'CEM-II-B-S-42.5N'), 40.00, 'ton', 395.00, 15800.00);

-- Zamówienie 3: Elmas Pawlak (w trakcie)
INSERT INTO orders (order_number, company_id, delivery_location_id, sales_rep_id, status, order_date, requested_delivery_date, delivery_method, total_amount, total_quantity) VALUES
('ZAM-2026-000003',
 (SELECT id FROM companies WHERE name = 'Elmas Pawlak S.J.'),
 (SELECT id FROM delivery_locations LIMIT 1),
 (SELECT id FROM users WHERE email = 'anna.nowak@sohosoft.pl'),
 'processing', '2026-01-12 09:15:00', '2026-01-15', 'own_transport', 8200.00, 20.00);

INSERT INTO order_items (order_id, product_id, quantity, unit, unit_price, total_price) VALUES
((SELECT id FROM orders WHERE order_number = 'ZAM-2026-000003'),
 (SELECT id FROM products WHERE code = 'CEM-II-A-LL-42.5R'), 20.00, 'ton', 410.00, 8200.00);

-- ============================================================================
-- 7. FAKTURY
-- ============================================================================

INSERT INTO invoices (invoice_number, order_id, company_id, issue_date, due_date, total_amount, vat_amount, status, paid_amount) VALUES
('FV/2026/01/000001',
 (SELECT id FROM orders WHERE order_number = 'ZAM-2026-000001'),
 (SELECT id FROM companies WHERE name = 'Firma Budowlana Budowa Sp. z o.o.'),
 '2026-01-06', '2026-02-05', 15190.50, 2840.50, 'partially_paid', 10000.00),

('FV/2026/01/000002',
 (SELECT id FROM orders WHERE order_number = 'ZAM-2026-000002'),
 (SELECT id FROM companies WHERE name = 'Auto-All Magazynowa Sp. z o.o.'),
 '2026-01-11', '2026-02-10', 19434.00, 3634.00, 'unpaid', 0.00);

-- Płatności
INSERT INTO payments (invoice_id, amount, payment_date, payment_method, reference_number) VALUES
((SELECT id FROM invoices WHERE invoice_number = 'FV/2026/01/000001'),
 10000.00, '2026-01-15', 'bank_transfer', 'REF-001-2026');

-- ============================================================================
-- 8. KIEROWCY I POJAZDY PRZEWOŹNIKÓW
-- ============================================================================

INSERT INTO drivers (carrier_id, first_name, last_name, phone, email, license_number, license_expiry_date) VALUES
((SELECT company_id FROM carriers WHERE license_number = 'LIC-001'), 'Jan', 'Kowalski', '+48 600 100 200', 'jan.kowalski@autoall.pl', 'PRAWO-001', '2027-12-31'),
((SELECT company_id FROM carriers WHERE license_number = 'LIC-001'), 'Piotr', 'Nowak', '+48 600 200 300', 'piotr.nowak@autoall.pl', 'PRAWO-002', '2028-06-30'),
((SELECT company_id FROM carriers WHERE license_number = 'LIC-002'), 'Marek', 'Wiśniewski', '+48 600 300 400', 'marek.wisniewski@transbud.pl', 'PRAWO-003', '2027-09-15');

INSERT INTO vehicles (carrier_id, registration_number, brand, model, capacity_tons, vehicle_type) VALUES
((SELECT company_id FROM carriers WHERE license_number = 'LIC-001'), 'WA 12345', 'Volvo', 'FH16', 32.00, 'tank_truck'),
((SELECT company_id FROM carriers WHERE license_number = 'LIC-001'), 'WA 67890', 'Scania', 'R450', 28.00, 'tank_truck'),
((SELECT company_id FROM carriers WHERE license_number = 'LIC-002'), 'KR 11111', 'Mercedes', 'Actros', 30.00, 'tank_truck');

-- ============================================================================
-- 9. POJAZDY I KIEROWCY KLIENTÓW
-- ============================================================================

INSERT INTO client_vehicles (company_id, registration_number, brand, model, capacity_tons) VALUES
((SELECT id FROM companies WHERE name = 'Firma Budowlana Budowa Sp. z o.o.'), 'WZ 99999', 'MAN', 'TGX', 25.00),
((SELECT id FROM companies WHERE name = 'Auto-All Magazynowa Sp. z o.o.'), 'KR 88888', 'DAF', 'XF', 28.00);

INSERT INTO client_drivers (company_id, first_name, last_name, phone, email, license_number) VALUES
((SELECT id FROM companies WHERE name = 'Firma Budowlana Budowa Sp. z o.o.'), 'Tomasz', 'Kowalczyk', '+48 500 100 200', 'tomasz.kowalczyk@firmabudowlana.pl', 'PRAWO-CLIENT-001'),
((SELECT id FROM companies WHERE name = 'Auto-All Magazynowa Sp. z o.o.'), 'Adam', 'Zieliński', '+48 500 200 300', 'adam.zielinski@autobud.pl', 'PRAWO-CLIENT-002');

-- ============================================================================
-- 10. ZLECENIA TRANSPORTOWE
-- ============================================================================

INSERT INTO transport_orders (order_id, carrier_id, driver_id, vehicle_id, status, estimated_delivery_date) VALUES
((SELECT id FROM orders WHERE order_number = 'ZAM-2026-000002'),
 (SELECT company_id FROM carriers WHERE license_number = 'LIC-001'),
 (SELECT id FROM drivers WHERE license_number = 'PRAWO-001'),
 (SELECT id FROM vehicles WHERE registration_number = 'WA 12345'),
 'in_transit', '2026-01-12 12:00:00');

-- ============================================================================
-- 11. CELE HANDLOWCA
-- ============================================================================

INSERT INTO sales_goals (sales_rep_id, title, description, goal_type, target_value, current_value, unit, start_date, end_date, status, progress_percentage) VALUES
((SELECT id FROM users WHERE email = 'jan.kowalski@sohosoft.pl'),
 'Przychód Styczeń 2026', 'Cel przychodowy na styczeń 2026', 'quantitative', 200000.00, 28150.00, 'PLN',
 '2026-01-01', '2026-01-31', 'active', 14.08),

((SELECT id FROM users WHERE email = 'jan.kowalski@sohosoft.pl'),
 'Nowe rejestracje Q1 2026', 'Rejestracja nowych klientów w Q1', 'quantitative', 10.00, 2.00, 'clients',
 '2026-01-01', '2026-03-31', 'active', 20.00),

((SELECT id FROM users WHERE email = 'jan.kowalski@sohosoft.pl'),
 'Jakość prowadzenia CRM', 'Aktualizacja notatek i dokumentacji', 'qualitative', NULL, NULL, NULL,
 '2026-01-01', '2026-12-31', 'active', 88.00),

((SELECT id FROM users WHERE email = 'anna.nowak@sohosoft.pl'),
 'Przychód Styczeń 2026', 'Cel przychodowy na styczeń 2026', 'quantitative', 150000.00, 8200.00, 'PLN',
 '2026-01-01', '2026-01-31', 'active', 5.47);

-- ============================================================================
-- 12. ZADANIA HANDLOWCA
-- ============================================================================

INSERT INTO sales_tasks (sales_rep_id, company_id, title, description, priority, status, due_date) VALUES
((SELECT id FROM users WHERE email = 'jan.kowalski@sohosoft.pl'),
 (SELECT id FROM companies WHERE name = 'Firma Budowlana Budowa Sp. z o.o.'),
 'Kontakt z nieaktywnymi klientami', '3 klientów bez zamówienia >30 dni', 'high', 'pending', '2026-01-20'),

((SELECT id FROM users WHERE email = 'jan.kowalski@sohosoft.pl'),
 (SELECT id FROM companies WHERE name = 'Auto-All Magazynowa Sp. z o.o.'),
 'Oferta dla porzuconych koszyków', '2 klientów z wartością >800 PLN', 'medium', 'pending', '2026-01-18'),

((SELECT id FROM users WHERE email = 'anna.nowak@sohosoft.pl'),
 (SELECT id FROM companies WHERE name = 'Elmas Pawlak S.J.'),
 'Odpowiedź na zapytanie', 'Zapytanie o CEM II/B-S 42,5N', 'low', 'in_progress', '2026-01-16');

-- ============================================================================
-- 13. WIZYTY HANDLOWCA
-- ============================================================================

INSERT INTO sales_visits (sales_rep_id, company_id, visit_date, visit_type, status, location, notes) VALUES
((SELECT id FROM users WHERE email = 'jan.kowalski@sohosoft.pl'),
 (SELECT id FROM companies WHERE name = 'Firma Budowlana Budowa Sp. z o.o.'),
 '2026-01-20 10:00:00', 'planned', 'planned', 'ul. Przykładowa 123, Warszawa',
 'Prezentacja nowych produktów cementowych'),

((SELECT id FROM users WHERE email = 'jan.kowalski@sohosoft.pl'),
 (SELECT id FROM companies WHERE name = 'Auto-All Magazynowa Sp. z o.o.'),
 '2026-01-15 14:00:00', 'follow_up', 'completed', 'ul. Magazynowa 45, Kraków',
 'Omówienie współpracy długoterminowej');

-- ============================================================================
-- 14. NOTATKI HANDLOWCA
-- ============================================================================

INSERT INTO sales_notes (sales_rep_id, company_id, note_type, title, content) VALUES
((SELECT id FROM users WHERE email = 'jan.kowalski@sohosoft.pl'),
 (SELECT id FROM companies WHERE name = 'Firma Budowlana Budowa Sp. z o.o.'),
 'call', 'Kontakt telefoniczny - 2026-01-10',
 'Klient zainteresowany nowymi produktami cementowymi. Wysłać ofertę do końca tygodnia.'),

((SELECT id FROM users WHERE email = 'jan.kowalski@sohosoft.pl'),
 (SELECT id FROM companies WHERE name = 'Auto-All Magazynowa Sp. z o.o.'),
 'visit', 'Spotkanie biznesowe - 2026-01-15',
 'Spotkanie przebiegło bardzo dobrze. Klient rozważa zwiększenie zamówienia o 30%.');

-- ============================================================================
-- 15. AKTYWNOŚCI KLIENTÓW (Przykładowe)
-- ============================================================================

-- Logowanie
INSERT INTO client_activities (company_id, user_id, activity_type, activity_data, created_at) VALUES
((SELECT id FROM companies WHERE name = 'Firma Budowlana Budowa Sp. z o.o.'),
 (SELECT id FROM users WHERE email = 'demo@klient.pl'),
 'login', '{"ip": "192.168.1.1"}'::jsonb, '2026-01-15 08:30:00'),

-- Przeglądanie produktu
((SELECT id FROM companies WHERE name = 'Firma Budowlana Budowa Sp. z o.o.'),
 (SELECT id FROM users WHERE email = 'demo@klient.pl'),
 'product_view', '{"product_id": 1, "product_code": "CEM-I-42.5R", "product_name": "CEM I 42,5R"}'::jsonb, '2026-01-15 09:15:00'),

-- Utworzenie zamówienia (automatycznie przez trigger, ale dodajemy przykładowe)
((SELECT id FROM companies WHERE name = 'Firma Budowlana Budowa Sp. z o.o.'),
 (SELECT id FROM users WHERE email = 'demo@klient.pl'),
 'order_created', '{"order_id": 1, "order_number": "ZAM-2026-000001", "total_amount": 12350.00}'::jsonb, '2026-01-05 10:30:00'),

-- Pobranie faktury
((SELECT id FROM companies WHERE name = 'Firma Budowlana Budowa Sp. z o.o.'),
 (SELECT id FROM users WHERE email = 'demo@klient.pl'),
 'invoice_downloaded', '{"invoice_id": 1, "invoice_number": "FV/2026/01/000001"}'::jsonb, '2026-01-06 11:20:00'),

-- Dodanie kierowcy (automatycznie przez trigger, ale dodajemy przykładowe)
((SELECT id FROM companies WHERE name = 'Firma Budowlana Budowa Sp. z o.o.'),
 (SELECT id FROM users WHERE email = 'demo@klient.pl'),
 'driver_added', '{"driver_id": 1, "driver_name": "Tomasz Kowalczyk"}'::jsonb, '2026-01-08 14:00:00'),

-- Dodanie pojazdu (automatycznie przez trigger, ale dodajemy przykładowe)
((SELECT id FROM companies WHERE name = 'Firma Budowlana Budowa Sp. z o.o.'),
 (SELECT id FROM users WHERE email = 'demo@klient.pl'),
 'vehicle_added', '{"vehicle_id": 1, "registration": "WZ 99999"}'::jsonb, '2026-01-08 14:30:00');

-- ============================================================================
-- 16. REKLAMACJE
-- ============================================================================

INSERT INTO complaints (complaint_number, company_id, order_id, title, description, category, priority, status, assigned_to) VALUES
('REK-2026-000001',
 (SELECT id FROM companies WHERE name = 'Firma Budowlana Budowa Sp. z o.o.'),
 (SELECT id FROM orders WHERE order_number = 'ZAM-2026-000001'),
 'Problem z jakością dostarczonego cementu', 'Cement miał nieprawidłową konsystencję', 'quality', 'high', 'in_progress',
 (SELECT id FROM users WHERE email = 'jan.kowalski@sohosoft.pl')),

('REK-2026-000002',
 (SELECT id FROM companies WHERE name = 'Auto-All Magazynowa Sp. z o.o.'),
 NULL,
 'Opóźnienie w dostawie', 'Dostawa spóźniona o 2 dni', 'delivery', 'medium', 'new',
 (SELECT id FROM users WHERE email = 'jan.kowalski@sohosoft.pl'));

-- ============================================================================
-- 17. POWIADOMIENIA
-- ============================================================================

INSERT INTO notifications (user_id, title, message, type, related_entity_type, related_entity_id) VALUES
((SELECT id FROM users WHERE email = 'jan.kowalski@sohosoft.pl'),
 'Nowe zamówienie', 'Firma Budowlana Budowa złożyła nowe zamówienie #ZAM-2026-000001', 'success', 'order',
 (SELECT id FROM orders WHERE order_number = 'ZAM-2026-000001')),

((SELECT id FROM users WHERE email = 'jan.kowalski@sohosoft.pl'),
 'Alert CRM', '3 klientów bez zamówienia >30 dni', 'warning', NULL, NULL),

((SELECT id FROM users WHERE email = 'demo@klient.pl'),
 'Zamówienie w drodze', 'Twoje zamówienie #ZAM-2026-000002 jest w drodze', 'info', 'order',
 (SELECT id FROM orders WHERE order_number = 'ZAM-2026-000002'));

-- ============================================================================
-- KONIEC PRZYKŁADOWYCH DANYCH
-- ============================================================================

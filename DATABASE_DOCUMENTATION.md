# 📊 Dokumentacja Bazy Danych - SOHOsoft B2B Portal

## 🎯 Przegląd

Baza danych została zaprojektowana do obsługi pełnego cyklu życia zamówień B2B w systemie dla cementowni, z integracją CRM, śledzeniem aktywności klientów i zarządzaniem transportem.

## 📋 Spis Treści

1. [Struktura Bazy Danych](#struktura-bazy-danych)
2. [Główne Funkcjonalności](#główne-funkcjonalności)
3. [Relacje i Zależności](#relacje-i-zależności)
4. [Automatyzacja i Triggery](#automatyzacja-i-triggery)
5. [Przykłady Zapytań](#przykłady-zapytań)

---

## 🗄️ Struktura Bazy Danych

### 1. **Użytkownicy i Autentykacja**

#### `users`
- **Cel**: Zarządzanie użytkownikami systemu (klienci, przewoźnicy, admini, handlowcy)
- **Kluczowe pola**:
  - `email` - unikalny identyfikator logowania
  - `role` - rola użytkownika (client, carrier, admin, sales_rep)
  - `last_login_at` - ostatnie logowanie (używane do aktywności)

#### `user_companies`
- **Cel**: Relacja wiele-do-wielu między użytkownikami a firmami
- **Użycie**: Jeden użytkownik może mieć dostęp do wielu firm

---

### 2. **Klienci i Firmy**

#### `companies`
- **Cel**: Dane firm klientów i przewoźników
- **Kluczowe pola**:
  - `credit_limit` - limit kredytowy
  - `current_balance` - aktualne saldo (aktualizowane automatycznie)
  - `assigned_sales_rep_id` - przypisany handlowiec
  - `status` - status firmy (active, inactive, blocked, premium)

#### `delivery_locations`
- **Cel**: Punkty odbioru/dostawy dla każdego klienta
- **Użycie**: W wizardzie zamówienia klient wybiera punkt odbioru
- **Pole specjalne**: `available_products` - array produktów dostępnych w danym punkcie

---

### 3. **Produkty**

#### `products`
- **Cel**: Katalog produktów cementowych
- **Kluczowe pola**:
  - `price_per_ton`, `price_per_bag`, `price_per_pallet`, `price_per_truck` - różne jednostki
  - `technical_specs` - JSONB z parametrami technicznymi
  - `stock_quantity` - stan magazynowy

---

### 4. **Zamówienia**

#### `orders`
- **Cel**: Główna tabela zamówień
- **Statusy**: draft → pending → confirmed → processing → ready_for_delivery → in_transit → delivered → completed
- **Kluczowe pola**:
  - `order_number` - automatycznie generowany (ZAM-YYYY-XXXXXX)
  - `delivery_method` - own_transport, carrier, pickup
  - `sales_rep_id` - przypisany handlowiec (dla celów CRM)

#### `order_items`
- **Cel**: Pozycje zamówienia
- **Jednostki**: ton, bag, pallet, truck
- **Automatyczna konwersja**: System obsługuje różne jednostki

---

### 5. **Faktury i Płatności**

#### `invoices`
- **Cel**: Faktury VAT
- **Statusy**: unpaid → partially_paid → paid (lub overdue)
- **Automatyzacja**: Status aktualizowany na podstawie płatności

#### `payments`
- **Cel**: Rejestr płatności
- **Efekt**: Automatyczna aktualizacja salda klienta i statusu faktury

---

### 6. **Transport**

#### `carriers`
- **Cel**: Szczegóły przewoźników (rozszerzenie tabeli `companies`)
- **Pola specjalne**:
  - `rating` - ocena przewoźnika
  - `loyalty_points` - program lojalnościowy

#### `drivers` (przewoźników)
- **Cel**: Kierowcy przewoźników
- **Użycie**: Przypisywanie do zleceń transportowych

#### `vehicles` (przewoźników)
- **Cel**: Pojazdy przewoźników
- **Pole**: `capacity_tons` - pojemność w tonach

#### `client_vehicles` i `client_drivers`
- **Cel**: Samochody i kierowcy klientów (dla własnego transportu)
- **Śledzenie**: Każda zmiana logowana w `client_activities`

#### `transport_orders`
- **Cel**: Zlecenia transportowe powiązane z zamówieniami
- **Statusy**: assigned → confirmed → in_transit → delivered

---

### 7. **Aktywności Klientów** ⭐

#### `client_activities`
- **Cel**: Kompleksowe śledzenie wszystkich działań klientów w systemie
- **Typy aktywności**:
  - `login`, `logout` - logowanie do panelu
  - `product_view`, `product_search` - przeglądanie produktów
  - `order_created`, `order_updated`, `order_cancelled` - operacje na zamówieniach
  - `invoice_downloaded`, `invoice_viewed` - pobieranie/przeglądanie faktur
  - `driver_added`, `driver_updated`, `driver_deleted` - zarządzanie kierowcami
  - `vehicle_added`, `vehicle_updated`, `vehicle_deleted` - zarządzanie pojazdami
  - `delivery_location_added`, `delivery_location_updated` - zarządzanie punktami odbioru
  - `company_data_updated` - aktualizacja danych firmy
  - `complaint_created`, `complaint_updated` - reklamacje

- **Pole `activity_data` (JSONB)**: Elastyczne przechowywanie danych specyficznych dla aktywności
  ```json
  {
    "order_id": 123,
    "order_number": "ZAM-2026-000123",
    "total_amount": 12350.00
  }
  ```

- **Automatyczne logowanie**: Triggery automatycznie rejestrują aktywności przy:
  - Tworzeniu/aktualizacji zamówień
  - Dodawaniu/edycji/usuwaniu kierowców
  - Dodawaniu/edycji/usuwaniu pojazdów

---

### 8. **Panel Handlowca (CRM)**

#### `sales_goals`
- **Cel**: Cele handlowca (liczbowe i jakościowe)
- **Typy**:
  - `quantitative` - cele liczbowe (przychód, liczba zamówień)
  - `qualitative` - cele jakościowe (jakość prowadzenia CRM)
- **Automatyczna aktualizacja**: Postęp aktualizowany automatycznie przy zakończeniu zamówień

#### `sales_tasks`
- **Cel**: Zadania handlowca
- **Priorytety**: low, medium, high, urgent
- **Statusy**: pending → in_progress → completed

#### `sales_visits`
- **Cel**: Wizyty handlowca u klientów
- **Typy**: planned, ad_hoc, follow_up, presentation
- **Statusy**: planned → completed, cancelled, postponed

#### `sales_notes`
- **Cel**: Notatki handlowca o klientach
- **Typy**: call, visit, email, meeting, other

---

### 9. **Reklamacje**

#### `complaints`
- **Cel**: Reklamacje i zgłoszenia klientów
- **Kategorie**: quality, delivery, invoice, service, other
- **Priorytety**: low, medium, high, urgent
- **Statusy**: new → in_progress → resolved → closed

---

### 10. **Powiadomienia**

#### `notifications`
- **Cel**: Powiadomienia dla użytkowników
- **Typy**: info, warning, success, error, alert
- **Powiązania**: Możliwość powiązania z zamówieniem, fakturą, reklamacją

---

## 🔗 Relacje i Zależności

### Główne Relacje:

```
users (sales_rep) ──┐
                    ├──> companies (assigned_sales_rep_id)
                    │
companies ──────────┼──> delivery_locations
                    │
                    ├──> orders ───> order_items ───> products
                    │                │
                    │                └──> invoices ───> payments
                    │
                    ├──> client_vehicles
                    ├──> client_drivers
                    └──> client_activities

orders ────────────> transport_orders ───> carriers ───> drivers
                                              └──> vehicles

sales_goals ───────> (aktualizowane przez zamówienia)
sales_tasks ───────> companies
sales_visits ──────> companies
sales_notes ───────> companies
```

---

## ⚙️ Automatyzacja i Triggery

### 1. **Aktualizacja Postępu Celów Handlowca**

**Trigger**: `trigger_update_sales_goal_on_order`
- **Wyzwalacz**: Zmiana statusu zamówienia na `completed`
- **Działanie**:
  - Aktualizuje cele ilościowe typu "przychód" (PLN)
  - Aktualizuje cele ilościowe typu "liczba zamówień"
  - Oblicza procent postępu
  - Działa tylko dla aktywnych celów w danym okresie

**Przykład**:
```sql
-- Gdy zamówienie zostanie zakończone, automatycznie:
-- 1. Zwiększa current_value o wartość zamówienia
-- 2. Aktualizuje progress_percentage
-- 3. Jeśli cel osiągnięty (100%), można oznaczyć jako completed
```

### 2. **Generowanie Numerów Zamówień i Faktur**

**Triggery**: 
- `trigger_generate_order_number` - format: `ZAM-YYYY-XXXXXX`
- `trigger_generate_invoice_number` - format: `FV/YYYY/MM/XXXXXX`

### 3. **Aktualizacja Salda Klienta**

**Trigger**: `trigger_update_company_balance`
- **Wyzwalacz**: Wstawienie/aktualizacja/usunięcie płatności
- **Działanie**:
  - Aktualizuje `paid_amount` w fakturze
  - Zmienia status faktury (unpaid → partially_paid → paid)
  - Przelicza `current_balance` firmy (suma niezapłaconych faktur)

### 4. **Logowanie Aktywności Klientów**

**Triggery**:
- `trigger_log_order_activity` - loguje tworzenie/aktualizację zamówień
- `trigger_log_driver_activity` - loguje zmiany w kierowcach
- `trigger_log_vehicle_activity` - loguje zmiany w pojazdach

**Dane zapisywane**:
- Typ aktywności
- Dane w formacie JSONB
- Timestamp
- ID użytkownika (jeśli dostępne)

---

## 📊 Przykłady Zapytań

### 1. **Aktywności Klienta dla Handlowca**

```sql
-- Wszystkie aktywności klienta w ostatnim miesiącu
SELECT 
    activity_type,
    activity_data,
    created_at
FROM client_activities
WHERE company_id = 123
  AND created_at >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY created_at DESC;
```

### 2. **Postęp Realizacji Celu Handlowca**

```sql
-- Cele handlowca z aktualnym postępem
SELECT 
    title,
    goal_type,
    target_value,
    current_value,
    progress_percentage,
    CASE 
        WHEN progress_percentage >= 100 THEN 'Osiągnięty'
        WHEN end_date < CURRENT_DATE THEN 'Przeterminowany'
        ELSE 'W trakcie'
    END AS status_info
FROM sales_goals
WHERE sales_rep_id = 5
  AND status = 'active'
ORDER BY end_date ASC;
```

### 3. **Zamówienia Klienta z Postępem Celu**

```sql
-- Zamówienia klienta i ich wpływ na cele handlowca
SELECT 
    o.order_number,
    o.total_amount,
    o.status,
    o.order_date,
    sg.title AS goal_title,
    sg.progress_percentage AS goal_progress
FROM orders o
JOIN companies c ON c.id = o.company_id
LEFT JOIN sales_goals sg ON sg.sales_rep_id = c.assigned_sales_rep_id
  AND sg.goal_type = 'quantitative'
  AND sg.unit = 'PLN'
  AND o.order_date BETWEEN sg.start_date AND sg.end_date
WHERE o.company_id = 123
ORDER BY o.order_date DESC;
```

### 4. **Historia Aktywności Klienta (360° View)**

```sql
-- Pełna historia aktywności klienta dla panelu handlowca
SELECT 
    ca.activity_type,
    ca.activity_data,
    ca.created_at,
    u.email AS user_email,
    CASE ca.activity_type
        WHEN 'login' THEN '🔐 Logowanie'
        WHEN 'product_view' THEN '👁️ Przeglądanie produktu'
        WHEN 'order_created' THEN '🛒 Utworzenie zamówienia'
        WHEN 'invoice_downloaded' THEN '📄 Pobranie faktury'
        WHEN 'driver_added' THEN '👤 Dodanie kierowcy'
        WHEN 'vehicle_added' THEN '🚚 Dodanie pojazdu'
        ELSE ca.activity_type
    END AS activity_label
FROM client_activities ca
LEFT JOIN users u ON u.id = ca.user_id
WHERE ca.company_id = 123
ORDER BY ca.created_at DESC
LIMIT 50;
```

### 5. **Statystyki Aktywności Klienta**

```sql
-- Statystyki aktywności klienta (dla alertów CRM)
SELECT 
    activity_type,
    COUNT(*) AS count,
    MAX(created_at) AS last_occurrence
FROM client_activities
WHERE company_id = 123
  AND created_at >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY activity_type
ORDER BY count DESC;
```

### 6. **Klienci Wymagający Uwagi (CRM Alerts)**

```sql
-- Klienci bez aktywności >30 dni (ryzyko utraty)
SELECT 
    c.id,
    c.name,
    MAX(ca.created_at) AS last_activity,
    CURRENT_DATE - MAX(ca.created_at)::DATE AS days_inactive
FROM companies c
LEFT JOIN client_activities ca ON ca.company_id = c.id
WHERE c.assigned_sales_rep_id = 5
  AND c.status = 'active'
GROUP BY c.id, c.name
HAVING MAX(ca.created_at) < CURRENT_DATE - INTERVAL '30 days'
   OR MAX(ca.created_at) IS NULL
ORDER BY days_inactive DESC;
```

### 7. **Wpływ Zamówień na Cele**

```sql
-- Jak zamówienia wpływają na realizację celów
SELECT 
    sg.title,
    sg.target_value,
    sg.current_value,
    sg.progress_percentage,
    COUNT(o.id) AS orders_count,
    SUM(o.total_amount) AS orders_total
FROM sales_goals sg
LEFT JOIN orders o ON o.sales_rep_id = sg.sales_rep_id
  AND o.status = 'completed'
  AND o.order_date BETWEEN sg.start_date AND sg.end_date
WHERE sg.sales_rep_id = 5
  AND sg.status = 'active'
GROUP BY sg.id, sg.title, sg.target_value, sg.current_value, sg.progress_percentage;
```

---

## 🎯 Implementacja Funkcjonalności

### ✅ Realne Składanie Zamówień

1. **Proces Wizard**:
   - Krok 1: Wybór `delivery_location_id`
   - Krok 2: Dodanie `order_items` (produkty, ilości, jednostki)
   - Krok 3: Wybór transportu (`delivery_method`, `carrier_id`, `client_vehicle_id`)
   - Krok 4: Zapisanie `order` ze statusem `pending`

2. **Automatyzacja**:
   - Generowanie `order_number`
   - Logowanie aktywności `order_created`
   - Aktualizacja celów handlowca (po zakończeniu)

### ✅ Dodawanie Samochodów i Kierowców

1. **Samochody Klienta** (`client_vehicles`):
   - Tabela: `client_vehicles`
   - Trigger: Automatyczne logowanie w `client_activities`

2. **Kierowcy Klienta** (`client_drivers`):
   - Tabela: `client_drivers`
   - Trigger: Automatyczne logowanie w `client_activities`

### ✅ Śledzenie Aktywności Klientów

**Wszystkie aktywności rejestrowane w `client_activities`**:

1. **Logowanie**: Ręczne logowanie przy autentykacji
2. **Przeglądanie produktów**: Logowanie przy każdym wyświetleniu produktu
3. **Pobieranie faktur**: Logowanie przy pobraniu PDF
4. **Składanie zamówień**: Automatyczne przez trigger
5. **Dodawanie kierowców/pojazdów**: Automatyczne przez trigger

**Wyświetlanie w panelu handlowca**:
```sql
-- Query używane w panelu handlowca
SELECT * FROM v_client_activities_summary
WHERE company_id = ?
ORDER BY created_at DESC;
```

### ✅ Postęp Realizacji Celów

**Automatyczna aktualizacja**:
- Trigger `trigger_update_sales_goal_on_order` uruchamiany przy zmianie statusu zamówienia na `completed`
- Aktualizuje `current_value` i `progress_percentage`
- Działa dla celów ilościowych (przychód, liczba zamówień)

**Wyświetlanie**:
```sql
-- Użycie widoku v_sales_goals_progress
SELECT * FROM v_sales_goals_progress
WHERE sales_rep_id = ?
ORDER BY end_date ASC;
```

### ✅ Cele, Zadania, Wizyty Handlowca

1. **Cele** (`sales_goals`):
   - Ręczne tworzenie przez handlowca
   - Automatyczna aktualizacja postępu

2. **Zadania** (`sales_tasks`):
   - Ręczne tworzenie/edycja
   - Powiązanie z klientem (opcjonalne)

3. **Wizyty** (`sales_visits`):
   - Planowanie wizyt
   - Statusy: planned → completed

---

## 📈 Widoki (Views)

### `v_client_activities_summary`
- Podsumowanie aktywności klientów z danymi firmy i użytkownika
- Używane w panelu handlowca do wyświetlania historii

### `v_sales_goals_progress`
- Cele handlowca z obliczonym statusem (uwzględnia przeterminowanie)
- Używane do dashboardu celów

### `v_orders_full`
- Pełne dane zamówień z informacjami o firmie, lokalizacji, handlowcu
- Używane do raportów i list zamówień

---

## 🔒 Bezpieczeństwo i Optymalizacja

### Indeksy
- Wszystkie klucze obce mają indeksy
- Indeksy na często używanych polach (status, data, email)
- Indeksy na polach używanych w WHERE i JOIN

### Ograniczenia
- CHECK constraints na statusy (zapewniają poprawność danych)
- UNIQUE constraints na kluczowe pola (email, NIP, numery zamówień)
- FOREIGN KEY constraints (zapewniają integralność referencyjną)

### Wydajność
- JSONB dla elastycznych danych (szybsze niż JSON)
- Indeksy GIN dla JSONB (jeśli potrzebne)
- Widoki materializowane (można dodać dla często używanych raportów)

---

## 🚀 Następne Kroki

1. **Dodanie indeksów GIN dla JSONB** (jeśli potrzebne):
```sql
CREATE INDEX idx_client_activities_data ON client_activities USING GIN (activity_data);
```

2. **Materializowane widoki** dla raportów:
```sql
CREATE MATERIALIZED VIEW mv_sales_stats AS
SELECT ...;
```

3. **Partitioning** dla dużych tabel (np. `client_activities`):
```sql
-- Partycjonowanie po dacie dla lepszej wydajności
```

4. **Backup i archiwizacja**:
   - Strategia backupu dla danych historycznych
   - Archiwizacja starych aktywności

---

## 📝 Notatki Implementacyjne

- **Baza danych**: PostgreSQL (zalecana) lub MySQL 8.0+
- **Wersjonowanie**: Użyj migracji (np. Flyway, Liquibase)
- **Testy**: Przygotuj dane testowe dla wszystkich scenariuszy
- **Monitoring**: Monitoruj wydajność triggerów i widoków

---

**Wersja**: 1.0  
**Data**: 2026-01-15  
**Autor**: SOHOsoft Development Team

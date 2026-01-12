# 🗄️ Instrukcja Instalacji Bazy Danych

## 📋 Pliki

1. **`database_schema.sql`** - Pełny schemat bazy danych (tabele, indeksy, triggery, widoki)
2. **`database_sample_data.sql`** - Przykładowe dane testowe
3. **`DATABASE_DOCUMENTATION.md`** - Szczegółowa dokumentacja
4. **`RAILWAY_SETUP.md`** - Przewodnik krok po kroku dla Railway (cloud)

## 🚀 Szybki Start

### ☁️ Railway (Cloud - Zalecane dla szybkiego startu)

**Najszybszy sposób na uruchomienie bazy danych w chmurze!**

📖 **Szczegółowy przewodnik**: Zobacz plik [`RAILWAY_SETUP.md`](./RAILWAY_SETUP.md)

**Krótka wersja**:
```bash
# 1. Zainstaluj Railway CLI
brew install railway  # macOS
# lub curl -fsSL https://railway.app/install.sh | sh

# 2. Zaloguj się
railway login

# 3. W Railway Dashboard: Utwórz projekt → Dodaj PostgreSQL

# 4. Połącz z projektem
railway link

# 5. Połącz z bazą i zaimportuj
railway connect
cat database_schema.sql | psql
cat database_sample_data.sql | psql
```

### 🖥️ PostgreSQL (Lokalnie)

```bash
# 1. Utwórz bazę danych
createdb sohosoft_b2b

# 2. Zaimportuj schemat
psql -d sohosoft_b2b -f database_schema.sql

# 3. Zaimportuj przykładowe dane
psql -d sohosoft_b2b -f database_sample_data.sql
```

### MySQL 8.0+

```bash
# 1. Utwórz bazę danych
mysql -u root -p -e "CREATE DATABASE sohosoft_b2b;"

# 2. Zaimportuj schemat (wymaga drobnych modyfikacji dla MySQL)
mysql -u root -p sohosoft_b2b < database_schema.sql

# 3. Zaimportuj przykładowe dane
mysql -u root -p sohosoft_b2b < database_sample_data.sql
```

## ⚠️ Uwagi

- **Railway** - Najłatwiejszy sposób na uruchomienie w chmurze (darmowy plan dostępny)
- **PostgreSQL** jest zalecaną bazą danych (wsparcie dla JSONB, lepsze triggery)
- **MySQL** wymaga drobnych modyfikacji (np. `SERIAL` → `AUTO_INCREMENT`)
- Przed importem sprawdź czy wszystkie zależności są spełnione

## ✅ Weryfikacja Instalacji

```sql
-- Sprawdź liczbę tabel
SELECT COUNT(*) FROM information_schema.tables 
WHERE table_schema = 'public';

-- Sprawdź przykładowe dane
SELECT COUNT(*) FROM companies;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM client_activities;
```

## 📊 Test Funkcjonalności

### 1. Test automatycznej aktualizacji celów

```sql
-- Zakończ zamówienie
UPDATE orders SET status = 'completed' WHERE order_number = 'ZAM-2026-000003';

-- Sprawdź aktualizację celu
SELECT * FROM sales_goals WHERE sales_rep_id = 
  (SELECT sales_rep_id FROM orders WHERE order_number = 'ZAM-2026-000003');
```

### 2. Test logowania aktywności

```sql
-- Dodaj nowego kierowcę
INSERT INTO client_drivers (company_id, first_name, last_name, phone, license_number)
VALUES (1, 'Test', 'Kierowca', '+48 123 456 789', 'TEST-001');

-- Sprawdź czy aktywność została zalogowana
SELECT * FROM client_activities 
WHERE activity_type = 'driver_added' 
ORDER BY created_at DESC LIMIT 1;
```

### 3. Test widoków

```sql
-- Sprawdź widok aktywności
SELECT * FROM v_client_activities_summary LIMIT 10;

-- Sprawdź widok celów
SELECT * FROM v_sales_goals_progress;
```

## 🔧 Konfiguracja Backendu

### Przykładowe połączenie (Node.js + pg)

**Lokalnie**:
```javascript
const { Pool } = require('pg');
const pool = new Pool({
  host: 'localhost',
  database: 'sohosoft_b2b',
  user: 'postgres',
  password: 'password',
  port: 5432,
});
```

**Railway (Cloud)**:
```javascript
const { Pool } = require('pg');
const pool = new Pool({
  connectionString: process.env.DATABASE_URL, // Railway automatycznie ustawia
  ssl: { rejectUnauthorized: false }
});
```

### Przykładowe połączenie (Python + psycopg2)

**Lokalnie**:
```python
import psycopg2
conn = psycopg2.connect(
    host="localhost",
    database="sohosoft_b2b",
    user="postgres",
    password="password"
)
```

**Railway (Cloud)**:
```python
import os
import psycopg2
conn = psycopg2.connect(os.environ['DATABASE_URL'])
```

## 📝 Następne Kroki

1. Skonfiguruj backend API
2. Zintegruj z frontendem
3. Dodaj migracje (Flyway/Liquibase)
4. Skonfiguruj backup
5. Dodaj monitoring

---

**Wersja**: 1.0  
**Data**: 2026-01-15

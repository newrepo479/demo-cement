# 🚂 Uruchomienie Bazy Danych w Railway - Przewodnik Krok po Kroku

## 📋 Wymagania

- Konto na [Railway.app](https://railway.app) (darmowe konto wystarczy)
- Pliki bazy danych: `database_schema.sql` i `database_sample_data.sql`

---

## 🚀 Krok 1: Utworzenie Projektu w Railway

1. **Zaloguj się** do Railway:
   - Wejdź na [railway.app](https://railway.app)
   - Zaloguj się przez GitHub, Google lub Email

2. **Utwórz nowy projekt**:
   - Kliknij **"New Project"** (lub **"Create Project"**)
   - Wybierz **"Empty Project"** lub **"Deploy from GitHub"** (jeśli masz repo)

---

## 🗄️ Krok 2: Dodanie Bazy Danych PostgreSQL

1. **Dodaj PostgreSQL**:
   - W projekcie kliknij **"+ New"** (lub **"Add Service"**)
   - Wybierz **"Database"** → **"Add PostgreSQL"**
   - Railway automatycznie utworzy bazę danych PostgreSQL

2. **Zapisz dane połączenia**:
   - Railway wygeneruje automatycznie:
     - `DATABASE_URL` (pełny connection string)
     - `PGHOST` (host)
     - `PGPORT` (port)
     - `PGDATABASE` (nazwa bazy)
     - `PGUSER` (użytkownik)
     - `PGPASSWORD` (hasło)
   - Kliknij na bazę danych → zakładka **"Variables"** → skopiuj wszystkie wartości

---

## 🔧 Krok 3: Połączenie z Bazą Danych

### Opcja A: Railway CLI (Zalecane)

1. **Zainstaluj Railway CLI**:
   ```bash
   # macOS
   brew install railway
   
   # Windows (PowerShell)
   iwr https://railway.app/install.sh | iex
   
   # Linux
   curl -fsSL https://railway.app/install.sh | sh
   ```

2. **Zaloguj się**:
   ```bash
   railway login
   ```

3. **Połącz z projektem**:
   ```bash
   railway link
   # Wybierz swój projekt z listy
   ```

4. **Połącz z bazą danych**:
   ```bash
   railway connect
   # Wybierz PostgreSQL service
   ```

### Opcja B: Zewnętrzny Klient (pgAdmin, DBeaver, etc.)

1. **Pobierz dane połączenia** z Railway:
   - W projekcie → PostgreSQL service → **"Variables"**
   - Skopiuj wartości: `PGHOST`, `PGPORT`, `PGDATABASE`, `PGUSER`, `PGPASSWORD`

2. **Połącz się używając**:
   - **Host**: wartość z `PGHOST`
   - **Port**: wartość z `PGPORT` (zwykle `5432`)
   - **Database**: wartość z `PGDATABASE`
   - **Username**: wartość z `PGUSER`
   - **Password**: wartość z `PGPASSWORD`

---

## 📥 Krok 4: Import Schematu Bazy Danych

### Metoda 1: Railway CLI + psql

1. **Połącz się przez Railway CLI**:
   ```bash
   railway connect
   ```

2. **Zaimportuj schemat**:
   ```bash
   # W katalogu z plikami database_schema.sql
   psql < database_schema.sql
   ```

   **LUB** jeśli masz plik lokalnie:
   ```bash
   railway run psql < database_schema.sql
   ```

### Metoda 2: Railway CLI + cat

```bash
# Połącz z bazą
railway connect

# Zaimportuj schemat
cat database_schema.sql | psql

# Zaimportuj przykładowe dane
cat database_sample_data.sql | psql
```

### Metoda 3: Zewnętrzny Klient (pgAdmin/DBeaver)

1. **Otwórz Query Tool** w pgAdmin lub DBeaver
2. **Otwórz plik** `database_schema.sql`
3. **Wykonaj zapytanie** (F5 lub Execute)
4. **Powtórz** dla `database_sample_data.sql`

### Metoda 4: Railway Web Terminal

1. W Railway → PostgreSQL service → zakładka **"Data"**
2. Kliknij **"Open in Browser"** lub **"Query"**
3. Skopiuj zawartość `database_schema.sql` i wklej do terminala
4. Wykonaj (Enter)

---

## ✅ Krok 5: Weryfikacja Instalacji

### Sprawdź czy tabele zostały utworzone:

```sql
-- Połącz się z bazą
railway connect

-- Sprawdź tabele
psql -c "\dt"

-- Lub w psql:
\dt
```

### Sprawdź przykładowe dane:

```sql
-- Liczba firm
SELECT COUNT(*) FROM companies;

-- Liczba zamówień
SELECT COUNT(*) FROM orders;

-- Liczba aktywności
SELECT COUNT(*) FROM client_activities;

-- Sprawdź przykładowe zamówienie
SELECT order_number, total_amount, status 
FROM orders 
LIMIT 5;
```

---

## 🔐 Krok 6: Konfiguracja Zmiennych Środowiskowych (Dla Backendu)

Jeśli chcesz użyć bazy danych w aplikacji backendowej:

1. **W Railway** → Twój projekt → **"Variables"**
2. **Dodaj zmienne** (jeśli nie są automatycznie):
   - `DATABASE_URL` - pełny connection string
   - `PGHOST`, `PGPORT`, `PGDATABASE`, `PGUSER`, `PGPASSWORD`

3. **W aplikacji backendowej** użyj:

   **Node.js (pg)**:
   ```javascript
   const { Pool } = require('pg');
   const pool = new Pool({
     connectionString: process.env.DATABASE_URL,
     ssl: { rejectUnauthorized: false }
   });
   ```

   **Python (psycopg2)**:
   ```python
   import os
   import psycopg2
   conn = psycopg2.connect(os.environ['DATABASE_URL'])
   ```

---

## 🛠️ Krok 7: Użyteczne Komendy Railway CLI

```bash
# Zaloguj się
railway login

# Lista projektów
railway list

# Połącz z projektem
railway link

# Połącz z bazą danych
railway connect

# Uruchom komendę w środowisku Railway
railway run <komenda>

# Otwórz logi
railway logs

# Otwórz dashboard w przeglądarce
railway open
```

---

## 🔍 Rozwiązywanie Problemów

### Problem: "Connection refused"

**Rozwiązanie**:
- Sprawdź czy baza danych jest uruchomiona w Railway
- Zweryfikuj dane połączenia w zakładce "Variables"
- Upewnij się, że używasz poprawnego portu

### Problem: "Permission denied"

**Rozwiązanie**:
- Sprawdź czy użytkownik ma uprawnienia do bazy
- Railway automatycznie tworzy użytkownika z pełnymi uprawnieniami

### Problem: "Database does not exist"

**Rozwiązanie**:
- Railway automatycznie tworzy bazę danych
- Sprawdź nazwę bazy w zmiennej `PGDATABASE`

### Problem: Błąd przy importowaniu schematu

**Rozwiązanie**:
- Sprawdź czy plik `database_schema.sql` jest w formacie UTF-8
- Upewnij się, że używasz PostgreSQL (nie MySQL)
- Sprawdź logi w Railway → PostgreSQL service → "Logs"

---

## 📊 Krok 8: Dostęp do Bazy Danych z Aplikacji

### Railway automatycznie udostępnia:

1. **Connection String** w zmiennej `DATABASE_URL`
2. **Osobne zmienne**: `PGHOST`, `PGPORT`, `PGDATABASE`, `PGUSER`, `PGPASSWORD`

### Przykład użycia w Node.js:

```javascript
// .env (lokalnie) lub Railway Variables (produkcja)
DATABASE_URL=postgresql://user:password@host:port/database

// app.js
const { Pool } = require('pg');
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' 
    ? { rejectUnauthorized: false } 
    : false
});

// Test połączenia
pool.query('SELECT NOW()', (err, res) => {
  if (err) console.error('Błąd połączenia:', err);
  else console.log('Połączono z bazą:', res.rows[0]);
});
```

---

## 💰 Koszty Railway

- **Darmowy plan**: 
  - $5 darmowych kredytów miesięcznie
  - Wystarczy na małą bazę danych PostgreSQL
  - Automatyczne wyłączenie po wyczerpaniu kredytów

- **Płatny plan**:
   - Od $5/miesiąc
   - Więcej zasobów i brak automatycznego wyłączenia

---

## 📝 Podsumowanie - Szybki Start

```bash
# 1. Zainstaluj Railway CLI
brew install railway  # macOS
# lub curl -fsSL https://railway.app/install.sh | sh  # Linux

# 2. Zaloguj się
railway login

# 3. Utwórz projekt w Railway (przez web UI)
# 4. Dodaj PostgreSQL service

# 5. Połącz z projektem
railway link

# 6. Połącz z bazą
railway connect

# 7. Zaimportuj schemat
cat database_schema.sql | psql
cat database_sample_data.sql | psql

# 8. Sprawdź
psql -c "SELECT COUNT(*) FROM companies;"
```

---

## 🔗 Przydatne Linki

- [Railway Dashboard](https://railway.app/dashboard)
- [Railway Documentation](https://docs.railway.app)
- [Railway CLI Docs](https://docs.railway.app/develop/cli)

---

**Gotowe!** 🎉 Twoja baza danych jest teraz dostępna w chmurze Railway.

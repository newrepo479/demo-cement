# SOHOsoft B2B Portal - Demo System

## 📦 Pakiet zawiera 6 kompletnych widoków HTML:

### 1️⃣ **index.html** - Strona Logowania
- Uniwersalny portal logowania dla wszystkich ról użytkowników
- Role: Klient, Przewoźnik, Administrator, Handlowiec
- Responsywny design z gradientowym tłem
- Demo credentials w interfejsie

### 2️⃣ **dashboard-klient.html** - Dashboard Klienta
- **Funkcje kluczowe:**
  - Szybkie statystyki (zamówienia, faktury, należności)
  - Kafelki nawigacyjne do głównych funkcji
  - System rekomendacji produktów (cross-selling)
  - Moduł reklamacji i zgłoszeń
  - News feed i powiadomienia
- **Integracja z SAP:** Dane finansowe, statusy zamówień
- **Target:** Klienci B2B (budownictwo, deweloperzy)

### 3️⃣ **zamowienie-wizard.html** - Wizard Zamówienia
- **Proces wieloetapowy:**
  - Krok 1: Wybór metody dostawy
  - Krok 2: Wybór produktów (z podpowiedziami)
  - Krok 3: Konfiguracja transportu (przewoźnik/samodzielny)
  - Krok 4: Podsumowanie i walidacja
- **Live validation** danych zamówienia
- **Sugestie podobnych produktów**
- Zapisywanie wersji roboczych

### 4️⃣ **panel-przewoznik.html** - Panel Przewoźnika/Spedytora
- **Funkcje:**
  - Lista zleceń transportowych z filtrowaniem
  - Zarządzanie kierowcami i pojazdami
  - Akcje masowe (przypisywanie, potwierdzanie)
  - **NOWOŚĆ:** Program lojalnościowy dla przewoźników
  - Statystyki dostaw
- **Target:** 75% użytkowników systemu!

### 5️⃣ **panel-admin.html** - Panel Administracyjny/Analityczny
- **KPI Dashboard:**
  - Przychody, zamówienia, klienci, przewoźnicy
  - Trendy sprzedażowe (ostatnie 6 miesięcy)
  - Top 10 klientów i produktów
- **Sekcje analityczne:**
  - Wykresy sprzedaży (placeholder dla Chart.js)
  - Tabele danych z sortowaniem
  - System alertów biznesowych
- **Filtry zaawansowane:** okres, oddział, segment klientów

### 6️⃣ **panel-handlowiec.html** - Panel Handlowca (CRM)
- **Integracja z CRM (zgodnie z soho_crm_presentation.pdf):**
  - Cele sprzedażowe i progress tracking
  - Alerty CRM: ryzyko odejścia, cross-selling, follow-up
  - **Client 360°:** pełny profil klienta z historią aktywności
  - Timeline portalu i działań handlowca
  - Kalendarz spotkań i harmonogram
- **Wsparcie sprzedaży:**
  - Hot leads identyfikacja
  - Zachowania w portalu → akcje handlowe
  - Quick actions: call, email, visit, notes

---

## 🎨 Specyfikacja Techniczna

### Stack Technologiczny:
- **HTML5** - struktura semantyczna
- **CSS3** - nowoczesny styling, animacje, gradients
- **Vanilla JavaScript** - logika biznesowa (bez zależności)
- **Responsywność:** Mobile-first approach, breakpoints 768px i 1200px

### Branding:
- **Kolory główne:**
  - Logowanie: `#667eea` → `#764ba2` (fioletowy gradient)
  - Klient: `#6a11cb` → `#2575fc` (niebieski)
  - Przewoźnik: `#f093fb` → `#f5576c` (różowy)
  - Admin: `#667eea` → `#764ba2` (fioletowy)
  - Handlowiec: `#11998e` → `#38ef7d` (zielony)
- **Typografia:** Segoe UI, Tahoma, sans-serif
- **Ikonki:** Unicode emoji (natywne)

### Struktura plików:
```
sohosoft-demo/
│
├── index.html                  # 1. Strona logowania
├── dashboard-klient.html       # 2. Dashboard klienta
├── zamowienie-wizard.html      # 3. Wizard zamówienia
├── panel-przewoznik.html       # 4. Panel przewoźnika
├── panel-admin.html            # 5. Panel administratora
├── panel-handlowiec.html       # 6. Panel handlowca (CRM)
└── README.md                   # Ten plik
```

---

## 🚀 Instalacja i Uruchomienie

### Frontend (HTML)

**Opcja 1: Bezpośrednie otwarcie w przeglądarce**
1. Wypakuj archiwum ZIP
2. Kliknij dwukrotnie na `index.html`
3. Wybierz rolę użytkownika i zaloguj się

**Opcja 2: Lokalny serwer HTTP (zalecane)**
```bash
# Python 3
python -m http.server 8000

# Node.js (npx http-server)
npx http-server -p 8000

# PHP
php -S localhost:8000
```
Otwórz w przeglądarce: `http://localhost:8000`

### Backend API (Node.js)

**📖 Szczegółowy przewodnik**: Zobacz [`BACKEND_API_GUIDE.md`](./BACKEND_API_GUIDE.md)

**Szybki start**:
```bash
cd backend-example
npm install
cp .env.example .env  # Ustaw DATABASE_URL
npm run dev
```

### Baza Danych

**📖 Przewodnik instalacji**: Zobacz [`DATABASE_README.md`](./DATABASE_README.md)  
**☁️ Railway (Cloud)**: Zobacz [`RAILWAY_SETUP.md`](./RAILWAY_SETUP.md)

---

## 🔐 Demo Credentials

Wszystkie widoki działają bez backendu - dane są symulowane w JavaScript:

| Rola          | Login Demo           | Hasło      |
|---------------|----------------------|------------|
| Klient        | demo@klient.pl       | (dowolne)  |
| Przewoźnik    | demo@przewoznik.pl   | (dowolne)  |
| Administrator | demo@admin.pl        | (dowolne)  |
| Handlowiec    | demo@handlowiec.pl   | (dowolne)  |

---

## 💡 Kluczowe Funkcje Do Prezentacji

### Dla Katarzyny (Customer Experience):
✅ **dashboard-klient.html** - nowoczesny UX, intuicyjne kafelki
✅ **zamowienie-wizard.html** - prosty proces zamówienia
✅ Moduł reklamacji i zgłoszeń

### Dla Kamila (CRM & Integration):
✅ **panel-handlowiec.html** - pełna integracja CRM
✅ Alerty sprzedażowe z portalu
✅ Client 360° z historią aktywności

### Dla Roberta (IT & Architecture):
✅ **panel-admin.html** - dashboard analityczny
✅ Wszystkie widoki: responsywne, skalowalne
✅ Gotowe do integracji z API (fetch placeholders)

---

## 🔧 Roadmap Wdrożenia

### Faza 1: MVP (4-6 tygodni)
- [x] Baza danych (PostgreSQL) - ✅ **GOTOWE** (zobacz `database_schema.sql`)
- [x] Backend API (Node.js/Express) - ✅ **GOTOWE** (zobacz `backend-example/` i `BACKEND_API_GUIDE.md`)
- [ ] Integracja frontend z backendem
- [ ] Integracja SAP (zamówienia, faktury)
- [ ] Autentykacja użytkowników (OAuth2/JWT)

### Faza 2: Rozszerzenia (2-3 miesiące)
- [ ] System rekomendacji AI
- [ ] Tracking GPS dla przewoźników
- [ ] Integracja mini-CRM
- [ ] Moduł analityczny (Chart.js/D3.js)

### Faza 3: Optymalizacje (ongoing)
- [ ] Notyfikacje push/email
- [ ] Aplikacja mobilna (React Native/Flutter)
- [ ] Raportowanie zaawansowane (Power BI)
- [ ] Program lojalnościowy

---

## 📊 Mapowanie z Transkryptu Spotkania

| Funkcja z transkryptu | Widok HTML | Status |
|------------------------|------------|--------|
| Składanie zamówień | `zamowienie-wizard.html` | ✅ Gotowe |
| Panel klienta | `dashboard-klient.html` | ✅ Gotowe |
| Zarządzanie przewoźnikami | `panel-przewoznik.html` | ✅ Gotowe |
| Dane finansowe | `dashboard-klient.html` (tabele) | ✅ Gotowe |
| Rekomendacje produktów | `dashboard-klient.html` (cross-sell) | ✅ Gotowe |
| Reklamacje online | `dashboard-klient.html` (moduł) | ✅ Gotowe |
| Panel handlowca CRM | `panel-handlowiec.html` | ✅ Gotowe |
| Analytics dashboard | `panel-admin.html` | ✅ Gotowe |
| Integracja SAP | Wszystkie widoki (API ready) | 🔄 Do wdrożenia |
| SMS/tracking | `panel-przewoznik.html` | 🔄 Do wdrożenia |

---

## 📞 Kontakt & Wsparcie

**SOHOsoft - Twój Partner w Transformacji Cyfrowej**

🌐 **Doświadczenie:** 15+ lat w B2B, przemysł ciężki, e-commerce
🏆 **Realizacje:** 100+ projektów integracyjnych z SAP, CRM, ERP
🚀 **Podejście:** Ewolucyjne wdrożenia, MVP w 6 tygodni

**Ten prototyp to dopiero początek!**

---

## 📄 Licencja

© 2025 SOHOsoft. Wszystkie prawa zastrzeżone.
Prototyp stworzony na potrzeby prezentacji dla Cementozarow.

---

**Wersja:** 1.0  
**Data:** 10 stycznia 2025  
**Autor:** SOHOsoft Design Team  
**Kontekst:** Spotkanie z Cementozarow (Katarzyna, Kamil, Robert)

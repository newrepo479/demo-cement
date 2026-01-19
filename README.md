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

## 🎯 Ścieżka Demo - Prezentacja Priorytetów

### Przygotowanie:
1. Otwórz `index.html` w przeglądarce
2. Przygotuj dwa okna/karty do porównania

### PRIORYTET 1: Bonusy i Rabaty

**Krok 1: Panel Klienta**
1. Na stronie logowania kliknij **"Pełny dostęp"** (w sekcji Klient)
2. Na dashboardzie od razu widoczna jest sekcja **"Bonusy i rabaty"**:
   - Saldo bonusu: **47 500 zł**
   - Poziom: **Złoty** (progress 74%)
   - Progi rabatowe: Srebrny 3%, Złoty 5%, Platynowy 8%
   - Aktywne rabaty klienta

**Krok 2: Panel Handlowca (podgląd bonusów klienta)**
1. Wróć do `index.html` → kliknij **"Handlowiec"**
2. Na liście klientów kliknij ikonę profilu dowolnego klienta
3. W modalu "Profil klienta" widoczna sekcja **Bonusy i rabaty** z danymi klienta

### PRIORYTET 2: Tony zamiast złotówek

**Krok 1: Dashboard Klienta - KPI**
1. Zaloguj jako Klient (Pełny dostęp)
2. W sekcji Quick Stats widoczne metryki w tonach:
   - Zamówiono YTD: **1 847 t**
   - W tym miesiącu: **342 t**
   - Średnie zamówienie: **38 t**
3. PLN pozostaje tylko w:
   - "Do zapłaty netto" (saldo należności)
   - Sekcja Bonusy (47 500 zł)

**Krok 2: Tabela zamówień**
1. Kliknij "Moje zamówienia" w menu
2. Kolumna "Ilość (t)" pokazuje wolumen: 21 t, 28 t, 56 t, 120 t

### PRIORYTET 4: Dwa typy kont klienta

**Krok 1: Porównanie na stronie logowania**
1. Otwórz `index.html`
2. W sekcji "Klient" widoczne dwa przyciski:
   - **Pełny dostęp** - faktury, bonusy, raporty
   - **Zamawiający** - tylko zamówienia

**Krok 2: Widok Zamawiającego**
1. Kliknij **"Zamawiający"**
2. Widok uproszczony zawiera:
   - Duży przycisk CTA "Złóż zamówienie"
   - Status ostatniego zamówienia
   - Mini-lista zamówień (tylko ilości, BEZ cen)
3. **NIE MA**: bonusów, faktur, reklamacji, pełnej historii

**Krok 3: Porównanie z Pełnym dostępem**
1. Otwórz nową kartę → `index.html` → **"Pełny dostęp"**
2. Pokaż pełny dashboard z wszystkimi funkcjami

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

---
name: integracja-zamowienia-faktury-reklamacje
overview: Spójny przepływ danych Zamówienia ↔ Faktury ↔ Reklamacje w 100% po stronie frontu (localStorage), tak aby nowe zamówienia automatycznie zasilały listy (zamówienia, faktury/pending, reklamacje), a liczniki/dzwonek aktualizowały się bez psucia istniejącego UI.
todos:
  - id: analyze-current-ui-hooks
    content: "Zidentyfikować i oznaczyć w HTML stałe badge (dzwonek, reklamacje) oraz miejsca na: pending invoices + invoice select + order details box."
    status: completed
  - id: data-layer-contract
    content: Ustalić kontrakt danych w localStorage (orders/complaints/invoices/notifications) + bezpieczny seed/merge z danymi statycznymi z DOM.
    status: completed
  - id: dashboard-orders-invoices-complaints-wiring
    content: "Podpiąć: dynamiczny select zamówień w reklamacji, powiązany select faktur, render pending invoices w Fakturach, oraz poprawne updateBadges/renderNotifications."
    status: completed
  - id: wizard-notification-on-order
    content: Dodać zapis powiadomienia po utworzeniu zamówienia w wizardzie, kompatybilnie ze stylem istniejącego JS.
    status: completed
  - id: manual-check
    content: "Ręcznie przejść flow: nowe zamówienie → widoczne w zamówieniach/fakturach(re: pending)/reklamacjach; złożenie reklamacji → aktualizacja badge/dzwonka."
    status: completed
---

## Założenia i stan obecny (co już działa)

- `zamowienie-wizard.html` zapisuje nowe zamówienia do `localStorage` pod kluczem `app:shared:orders`.
- `dashboard-klient.html` już **renderuje** zamówienia z `app:shared:orders` do tabel (dashboard + “Moje zamówienia”).
- Reklamacje są zapisywane przez helper z prefixem `app:shared:` (`storageGet('complaints')` → `app:shared:complaints`), ale **select zamówienia w modalu reklamacji jest na sztywno**.
- Faktury są dziś statycznymi wierszami HTML w tabeli (brak powiązania z `app:shared:orders`).
- Dzwonek i badge w menu są statyczne, a aktualizacja reklamacji robi `document.querySelector('.menu-badge')` (ryzyko: łapie nie ten badge, bo w sidebar są co najmniej 2).

Punkty „do spięcia” w kodzie:

- Hardcode w modalu reklamacji:
```2502:2509:/Users/lduda/Sites/sohosoft/demo-cement/dashboard-klient.html
                    <div class="form-group">
                        <label class="form-label" for="orderRef">Zamówienie (opcjonalnie)</label>
                        <select id="orderRef" class="form-select">
                            <option value="">Wybierz zamówienie...</option>
                            <option value="ZAM-1234">#ZAM-1234 - CEM I 42,5R (09.01.2026)</option>
                            <option value="ZAM-1233">#ZAM-1233 - CEM II/B-S (05.01.2026)</option>
                        </select>
                    </div>
```

- Wspólny prefix storage w dashboardzie:
```2634:2649:/Users/lduda/Sites/sohosoft/demo-cement/dashboard-klient.html
        const STORAGE_PREFIX = 'app:shared:';

        function storageGet(key, defaultValue = []) {
            try {
                const data = localStorage.getItem(STORAGE_PREFIX + key);
                return data ? JSON.parse(data) : defaultValue;
            } catch (e) {
                console.error('Error reading from localStorage:', e);
                return defaultValue;
            }
        }

        function storageSet(key, value) {
            try {
                localStorage.setItem(STORAGE_PREFIX + key, JSON.stringify(value));
                return true;
            } catch (e) {
                console.error('Error writing to localStorage:', e);
                return false;
            }
        }
```

- Render zamówień z localStorage już istnieje:
```2818:2827:/Users/lduda/Sites/sohosoft/demo-cement/dashboard-klient.html
        function renderSharedOrders() {
            const orders = JSON.parse(localStorage.getItem('app:shared:orders') || '[]');
            // ... render do tabel ...
            if (orders.length === 0) return;
```

- Aktualizacja badge reklamacji jest dziś zbyt ogólna:
```3541:3546:/Users/lduda/Sites/sohosoft/demo-cement/dashboard-klient.html
            const badge = document.querySelector('.menu-badge');
            if (badge) {
                const currentCount = parseInt(badge.textContent) || 0;
                badge.textContent = currentCount + 1;
            }
```


## Docelowy model danych (localStorage)

Będziemy trzymać **spójne, linkowalne rekordy**:

- `app:shared:orders` (już jest): `[{ id, number, date, product, quantity, unit, tons, priceNet, deliveryDate, ... }]`
- `app:shared:complaints`: `[{ id, number, type, priority, title, description, status, dateAttr, orderId?, orderNumber?, invoiceNumber?, createdAt }]`
- `app:shared:invoices` (nowe): `[{ id, invoiceNumber, issueDate, dueDate, amount, status, orderNumber? , orderId? }]`
- `app:shared:notifications` (nowe): `[{ id, kind, title, desc, createdAt, isUnread, linkTab? , orderId?, complaintId? }]`

Dodatkowo: bezpieczny znacznik seedowania (żeby nie dublować): `app:shared:seed:v1 = true`.

## Zmiany funkcjonalne (flow)

### a) Zamówienie → Faktura

- **Po złożeniu zamówienia** w `zamowienie-wizard.html` dopiszemy (obok zapisu do `app:shared:orders`) wpis do `app:shared:notifications` typu `order_created`.
- W `dashboard-klient.html` w zakładce Faktury:
  - Dodamy dynamiczną sekcję „**Zamówienia oczekujące na fakturę**” wyliczaną z: `orders - orders_z_powiązaną_fakturą`.
  - Każde nowe zamówienie pojawi się tam automatycznie jako „Oczekuje na fakturę” (z akcją typu „Powiadom o fakturze” albo obecnym `downloadInvoice` z komunikatem “będzie po realizacji”).
  - (Opcjonalnie, jeśli chcesz mocniejszą symulację) dodamy przycisk „Wygeneruj fakturę (demo)” dla zamówień o statusie `Dostarczone`, który tworzy rekord w `app:shared:invoices`.

### b) Zamówienie → Reklamacja

- W `dashboard-klient.html`:
  - Zastąpimy hardcoded `<option>` w `#orderRef` generowaniem listy z:
    - zamówień z `app:shared:orders` **+** zamówień „statycznych” z tabeli (parsowanych z DOM, żeby nie dublować danych w kodzie).
  - Dodamy listener `change` na `#orderRef`, który:
    - automatycznie pokazuje podsumowanie zamówienia (data, produkt, ilość, transport/lokalizacja jeśli dostępne),
    - może podpowiedzieć tytuł (np. `Reklamacja do #ZAM-...`) bez nadpisywania, jeśli użytkownik już coś wpisał.
  - Usuniemy „5 stycznia / 9 stycznia” na stałe (czyli nie będą już na sztywno w HTML).

### c) Faktura ↔ Reklamacja

- W modalu reklamacji dodamy pole `select` „Faktura (opcjonalnie)” – domyślnie ukryte.
- Po wyborze zamówienia:
  - wylistujemy faktury powiązane (z `app:shared:invoices` + parsowane statyczne wiersze faktur z tabeli, powiązane po `orderNumber`),
  - jeśli brak faktur – pokażemy „Brak (oczekuje na fakturę)”.
- W rekordzie reklamacji zapisujemy `orderId/orderNumber` oraz `invoiceNumber` (jeśli wybrano).

## Powiadomienia i liczniki (dzwonek + badge)

- `dashboard-klient.html`:
  - Dodamy `renderNotifications()` – wstrzykuje wpisy z `app:shared:notifications` nad statycznymi elementami dropdown.
  - Zmienimy badge dzwonka (`.notification-badge`) na wartość: `staticCount + unreadFromStorage` (staticCount trzymamy w `data-static-count`).
  - Zmienimy badge reklamacji w sidebar na wartość: `staticCount + complaintsNoweFromStorage` i damy mu **unikalny selektor** (np. `id="complaintsBadge"`), zamiast `querySelector('.menu-badge')`.

## Minimalny zakres zmian w plikach

- [`/Users/lduda/Sites/sohosoft/demo-cement/zamowienie-wizard.html`](/Users/lduda/Sites/sohosoft/demo-cement/zamowienie-wizard.html)
  - dopisać tworzenie powiadomienia po `saveOrderToStorage()` (bez zmian w istniejącym obiekcie zamówienia).
- [`/Users/lduda/Sites/sohosoft/demo-cement/dashboard-klient.html`](/Users/lduda/Sites/sohosoft/demo-cement/dashboard-klient.html)
  - UI: dodać `select` faktury + box z danymi zamówienia w modalu reklamacji; dodać sekcję “pending invoices” w zakładce faktur; nadać id/dataset licznikom.
  - JS: dodać funkcje:
    - `getAllOrdersForSelectors()` (merge: localStorage + DOM)
    - `getAllInvoicesForSelectors()` (merge: localStorage + DOM)
    - `populateOrderSelect()` + `populateInvoiceSelectForOrder()`
    - `renderPendingInvoices()`
    - `renderNotifications()` + `updateBadges()`
  - zmienić `submitComplaint()` tak, by zapisywał `orderId/orderNumber/invoiceNumber` oraz wywoływał `updateBadges()` zamiast `querySelector('.menu-badge')++`.

## Test plan (manualny, 5 minut)

- Otwórz `dashboard-klient.html` → sprawdź, że nadal widzisz istniejące tabele (bez regresji).
- Wejdź w `zamowienie-wizard.html` → złóż zamówienie → wróć do dashboardu:
  - `Moje zamówienia`: nowe zamówienie jest na liście.
  - `Faktury`: nowe zamówienie jest w sekcji „oczekujące na fakturę”.
  - `Reklamacje`: w modalu „Nowe zgłoszenie” select zamówień zawiera nowo złożone zamówienie.
  - `Dzwonek` i `Reklamacje` badge: wartości wzrosły zgodnie z nowymi wpisami.
- Złóż reklamację z wybranym zamówieniem:
  - lista reklamacji pokazuje powiązanie z zamówieniem,
  - jeśli są faktury powiązane – możesz je wybrać.
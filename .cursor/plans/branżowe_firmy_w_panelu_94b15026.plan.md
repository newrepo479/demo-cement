---
name: Branżowe firmy w panelu
overview: Podmienimy w `panel-handlowiec.html` wyłącznie ewidentnie niebranżowe nazwy firm (gastronomia + `Auto-All Magazynowa` + `R. Italiana`) na spójne nazwy z branży budowlano-cementowej, we wszystkich miejscach gdzie te stringi występują (tabele, zadania, kalendarz, selecty, podsumowania).
todos:
  - id: inventory
    content: Zidentyfikować wszystkie wystąpienia 8 niebranżowych nazw w `panel-handlowiec.html` (tabela, kalendarz, zadania, aktywności, selecty, podsumowania).
    status: completed
  - id: replace
    content: Wprowadzić podmiany stringów wg mapy (dokładne dopasowanie całych nazw), tak aby ta sama firma miała identyczną nazwę w całym pliku.
    status: completed
  - id: verify
    content: Zweryfikować brak starych nazw przez wyszukiwanie oraz szybki sanity-check kluczowych sekcji UI w HTML.
    status: completed
---

## Zakres

- Edytujemy tylko: [`/Users/lduda/Sites/sohosoft/demo-cement/panel-handlowiec.html`](/Users/lduda/Sites/sohosoft/demo-cement/panel-handlowiec.html)
- Podmieniamy tylko te nazwy (pozostałe firmy zostają bez zmian):
  - `Pizzeria Bella`
  - `Sushi Bar Tokyo`
  - `Kawiarnia Retro`
  - `Bar Mleczny`
  - `Steakhouse Prime`
  - `Food Truck Smaki`
  - `Auto-All Magazynowa` (ma **18** wystąpień w pliku)
  - `R. Italiana` (2 wystąpienia w kalendarzu)

## Miejsca, gdzie to siedzi (przykłady w pliku)

- **Tabela klientów** (tu są wpisy gastronomiczne):
```2365:2502:/Users/lduda/Sites/sohosoft/demo-cement/panel-handlowiec.html
                        <!-- Dodatkowi klienci -->
                        <tr>
                            <td>
                                <div class="customer-name">Michał Krawczyk</div>
                                <div class="customer-company">Pizzeria Bella</div>
                            </td>
                            ...
                        </tr>
                        <tr>
                            <td>
                                <div class="customer-name">Agnieszka Wójcik</div>
                                <div class="customer-company">Sushi Bar Tokyo</div>
                            </td>
                            ...
                        </tr>
                        ...
                                <div class="customer-company">Steakhouse Prime</div>
                        ...
                                <div class="customer-company">Food Truck Smaki</div>
```

- **Zadania na dziś / aktywności / podsumowania / modale** (wielokrotne użycie `Auto-All Magazynowa`):
```1792:1802:/Users/lduda/Sites/sohosoft/demo-cement/panel-handlowiec.html
                    <div class="task-item" draggable="true">
                        ...
                        <div class="task-details">
                            <div class="task-title">Wysłanie oferty - Auto-All Magazynowa
                                <span class="task-priority low">Niski</span>
                            </div>
                            <div class="task-meta">18:00 • Nowa oferta produktów cementowych</div>
                        </div>
                        ...
                    </div>
```
```3288:3320:/Users/lduda/Sites/sohosoft/demo-cement/panel-handlowiec.html
                <div class="form-group">
                    <label class="form-label">Klient</label>
                    <select class="form-select">
                        <option>Wybierz klienta</option>
                        <option>Firma Budowlana Budowa</option>
                        <option>Budowa Plus Sp. z o.o.</option>
                        <option>Auto-All Magazynowa</option>
                    </select>
                </div>
```

- **Kalendarz** (tu jest `R. Italiana`):
```2559:2602:/Users/lduda/Sites/sohosoft/demo-cement/panel-handlowiec.html
                    <div class="calendar-day">
                        <div class="calendar-day-number">5</div>
                        <div class="calendar-event visit">🚗 10:00 Wizyta - R. Italiana</div>
                        <div class="calendar-event visit">🚗 14:30 Wizyta - Przykładowa Firma Budowlana Sp. z o.o.</div>
                    </div>
                    ...
                    <div class="calendar-day">
                        <div class="calendar-day-number">15</div>
                        <div class="calendar-event">📞 09:00 Tel. follow-up R. Italiana</div>
                    </div>
```


## Proponowana mapa podmian (branżowe, neutralne, PL)

- `Pizzeria Bella` → `Deweloper Centrum Sp. z o.o.`
- `Sushi Bar Tokyo` → `Konstruktornia Sp. z o.o.`
- `Kawiarnia Retro` → `Roboty Budowlane XYZ`
- `Bar Mleczny` → `Budowa Mieszkaniowa ABC`
- `Steakhouse Prime` → `PrimeBeton Sp. z o.o.`
- `Food Truck Smaki` → `SMAK-BUD Sp. z o.o.`
- `Auto-All Magazynowa` → `Prefabrykaty MAG-BUD Sp. z o.o.`
- `R. Italiana` → `R. Inwestycje`

## Weryfikacja

- Po zmianach wykonamy wyszukiwanie w pliku, aby potwierdzić, że **0** wystąpień mają: `Pizzeria Bella`, `Sushi Bar Tokyo`, `Kawiarnia Retro`, `Bar Mleczny`, `Steakhouse Prime`, `Food Truck Smaki`, `Auto-All Magazynowa`, `R. Italiana`.
- Szybkie sprawdzenie kluczowych widoków w pliku: tabela klientów, zakładka kalendarza, formularze/modal z wyborem klienta (czy wyświetlają nowe, branżowe nazwy).
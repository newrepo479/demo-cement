---
name: ai-chat-demo-rag
overview: Dodanie nowej zakładki „AI Chat” w `dashboard-klient.html` oraz stworzenie `chat.html` z prostym czatem LLM (OpenAI) i ultra-lekkim RAG na bazie treści `produkt-cem-ii.html` (bez backendu – demo).
todos:
  - id: nav-ai-chat
    content: Dodać pozycję „AI Chat” w `dashboard-klient.html` (top-nav i sidebar) kierującą do `chat.html`.
    status: pending
  - id: create-chat-html
    content: Utworzyć `chat.html` z UI czatu + obsługą historii + input + quick prompts.
    status: pending
  - id: rag-from-product-html
    content: W `chat.html` zaimplementować pobieranie `produkt-cem-ii.html`, ekstrakcję tekstu i proste wyszukiwanie fragmentów (RAG).
    status: pending
  - id: openai-call
    content: W `chat.html` dodać wywołanie OpenAI Chat Completions z kluczem podanym przez użytkownika i wstrzykiwanym kontekstem.
    status: pending
  - id: products-json
    content: (Opcjonalnie) dodać `products.json` i dropdown wyboru produktu, żeby łatwo skalować na wiele produktów.
    status: pending
---

## Założenia (demo)

- Integracja **frontend-only**: użytkownik wpisuje klucz OpenAI w `chat.html` (np. trzymany w `sessionStorage`). To jest najszybsze do demo, ale **nie jest bezpieczne** na produkcji.
- RAG “mega prosty”: `chat.html` **pobiera** `produkt-cem-ii.html`, **wyciąga tekst** z `.main-content`, dzieli na akapity i wybiera najbardziej trafne fragmenty (prosty scoring po słowach kluczowych). Te fragmenty są doklejane do promptu jako kontekst.

## Zmiany w UI / nawigacji

- Wpiąć link do czatu w `dashboard-klient.html`:
- W top-nav (menu `nav-menu`) obok/ zamiast “Pomoc” dodać pozycję `AI Chat` prowadzącą do `chat.html`.
- W sidebar (`.sidebar-menu`) dodać pozycję `AI Chat` (spójny styl z resztą).
- Punkt zaczepienia w pliku jest tu: `nav-menu` i `sidebar-menu` (okolice linii ~1276+), oraz logika aktywacji zakładek jest w `showTab(...)` – tu **nie musimy** dodawać nowej `tab-content`, bo `AI Chat` będzie osobną stroną.

## Nowy plik: `chat.html`

- Zbudować prosty, ładny layout (spójny wizualnie z resztą demo):
- nagłówek “AI Chat (Produkty)” + link “Źródło: CEM II/A-LL 42,5R” kierujący do `produkt-cem-ii.html`
- panel ustawień: pole `OpenAI API Key` (type password), model (domyślnie `gpt-4o-mini`), przycisk “Wyczyść rozmowę”
- okno rozmowy (messages)
- input + przycisk “Wyślij” + obsługa Enter
- 3 szybkie przyciski (prompt chips): “cement do fundamentów”, “dostępność i cena”, “porównaj opakowania”
- Logika RAG w przeglądarce:
- `fetch('produkt-cem-ii.html')`
- `DOMParser().parseFromString(html, 'text/html')`
- usunąć `script/style`, pobrać tekst z `doc.querySelector('.main-content')?.innerText` (fallback: `doc.body.innerText`)
- podział na fragmenty (np. akapity / listy) i scoring względem pytania (tokenizacja, usunięcie stop-słów PL, overlap)
- wybrać top N fragmentów (np. 6) i skleić jako `CONTEXT`.
- Wywołanie OpenAI:
- `POST https://api.openai.com/v1/chat/completions`
- `Authorization: Bearer <key>`
- wiadomości:
- `system`: instrukcja roli “asystent produktowy”, zasady (odpowiadaj tylko na bazie kontekstu, ceny/dostępność mogą być symulowane, jeśli brak w kontekście – jasno oznacz), język PL.
- `system`/`user`: dołączony `CONTEXT` (wybrane fragmenty)
- historia rozmowy + bieżące pytanie
- render odpowiedzi do UI, plus mały “Źródła: produkt-cem-ii” pod odpowiedzią.

## (Opcjonalnie) Minimalna „baza produktów”

- Dodać mały plik `products.json` z listą produktów (na start 1 wpis do `produkt-cem-ii.html`), żeby łatwo dołożyć kolejne linki od Krzysztofa.
- `chat.html` pobiera `products.json`, pozwala wybrać produkt z dropdownu i odpytuje w kontekście wybranego produktu.

## Test plan (manual)

- Otwórz `dashboard-klient.html` i kliknij `AI Chat` → przenosi do `chat.html`.
- W `chat.html` wklej klucz, zapytaj: „Jaki cement polecacie do fundamentów?” → odpowiedź powinna odwołać się do treści z `produkt-cem-ii.html` (zastosowanie/fundamenty, parametry, opakowania) i podać cenę/dostępność zgodnie z kartą (lub jasno oznaczyć symulację).
- Sprawdź pytania o: dostępność, opakowania (25 kg / luzem / paleta), czas dostawy.

## Uwaga techniczna (ważna)

- Frontend-only wystawia klucz w przeglądarce i może się zderzyć z ograniczeniami CORS/bezpieczeństwa. Do demo zwykle ok, ale do produkcji rekomenduję proxy backend/serverless.
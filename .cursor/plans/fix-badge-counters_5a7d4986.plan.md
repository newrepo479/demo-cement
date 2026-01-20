---
name: fix-badge-counters
overview: Naprawic liczniki badge'ow (dzwonek, reklamacje) tak, aby dynamicznie liczyly elementy z DOM zamiast polegac na zahardcodowanym data-static-count.
todos:
  - id: fix-update-badges
    content: Zmienic logike updateBadges() na dynamiczne liczenie z DOM zamiast data-static-count
    status: completed
---

# Naprawa licznikow badge (dzwonek + reklamacje)

## Problem

- `data-static-count` jest zahardcodowane w HTML i nie odpowiada rzeczywistej liczbie statycznych elementow
- Przy dodawaniu rekordow z localStorage liczby sie rozjezdzaja

## Rozwiazanie

Zamiast polegac na `data-static-count`, policzyc statyczne elementy bezposrednio z DOM przy kazdym wywolaniu `updateBadges()`.

## Zmiany w [`dashboard-klient.html`](dashboard-klient.html)

### 1. Zaktualizowac funkcje `updateBadges()` (ok. linia 3093)

**Obecna logika:**

```javascript
const staticCount = parseInt(complaintsBadge.dataset.staticCount) || 0;
const newComplaintsCount = complaints.filter(c => c.status === 'nowe').length;
complaintsBadge.textContent = staticCount + newComplaintsCount;
```

**Nowa logika:**

```javascript
// Complaints badge - policz statyczne wiersze z DOM + localStorage
const staticComplaintRows = document.querySelectorAll('#complaints-tbody tr:not([data-storage-id])').length;
const storageComplaintsCount = complaints.length;
complaintsBadge.textContent = staticComplaintRows + storageComplaintsCount;

// Notification badge - policz statyczne elementy z DOM + unread z localStorage  
const staticNotifCount = document.querySelectorAll('#notificationList .notification-item[data-static="true"]').length;
const unreadCount = notifications.filter(n => n.isUnread).length;
notifBadge.textContent = staticNotifCount + unreadCount;
```

### 2. Usunac zbedne atrybuty `data-static-count` (opcjonalnie)

Linie do uproszczenia:

- Linia 1287: `<span class="notification-badge" id="notificationBadge" data-static-count="3">3</span>`
- Linia 1352: `<span class="menu-badge" id="complaintsBadge" data-static-count="2">2</span>`

Mozna usunac `data-static-count` bo juz nie bedzie uzywany.

## Efekt

- Badge reklamacji bedzie pokazywal: (statyczne wiersze z tabeli) + (wszystkie rekordy z localStorage)
- Badge powiadomien bedzie pokazywal: (statyczne powiadomienia) + (nieprzeczytane z localStorage)
- Liczby beda zawsze zgodne z tym, co widac w UI
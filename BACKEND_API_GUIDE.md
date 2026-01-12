# 🔌 Przewodnik Backend API - Integracja Frontend z Bazą Danych

## 📋 Obecny Stan

**Ważne**: Obecne pliki HTML to tylko **frontend** - nie ma backendu, który obsługiwałby zapisy do bazy danych.

- ✅ HTML/CSS/JavaScript - gotowe
- ✅ Baza danych PostgreSQL - gotowa
- ❌ **Backend API - BRAK** (trzeba zbudować)

---

## 🏗️ Architektura Systemu

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│   Frontend  │  HTTP   │   Backend    │   SQL   │   Database  │
│   (HTML)    │ ──────> │    API       │ ──────> │ (PostgreSQL)│
│             │ <────── │  (Node.js/   │ <────── │             │
│             │  JSON   │   Python)    │  Data   │             │
└─────────────┘         └──────────────┘         └─────────────┘
```

---

## 🚀 Rozwiązania Backend

### Opcja 1: Node.js + Express (Zalecane)

**Dlaczego Node.js?**
- ✅ Łatwa integracja z frontendem JavaScript
- ✅ Szybki rozwój
- ✅ Duża społeczność
- ✅ Dobra dokumentacja

### Opcja 2: Python + FastAPI/Flask

**Dlaczego Python?**
- ✅ Prosty w użyciu
- ✅ Dobra integracja z PostgreSQL
- ✅ Szybki prototyp

### Opcja 3: PHP

**Dlaczego PHP?**
- ✅ Łatwe wdrożenie
- ✅ Duże wsparcie hostingowe

---

## 📦 Node.js + Express - Kompletny Przykład

### Struktura Projektu

```
backend/
├── package.json
├── server.js
├── routes/
│   ├── orders.js
│   ├── products.js
│   ├── companies.js
│   └── activities.js
├── db/
│   └── connection.js
└── .env
```

### 1. Instalacja

```bash
mkdir backend
cd backend
npm init -y
npm install express pg cors dotenv
npm install --save-dev nodemon
```

### 2. package.json

```json
{
  "name": "sohosoft-backend",
  "version": "1.0.0",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "pg": "^8.11.0",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1"
  }
}
```

### 3. db/connection.js

```javascript
const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' 
    ? { rejectUnauthorized: false } 
    : false
});

// Test połączenia
pool.on('connect', () => {
  console.log('✅ Połączono z bazą danych PostgreSQL');
});

pool.on('error', (err) => {
  console.error('❌ Błąd połączenia z bazą:', err);
});

module.exports = pool;
```

### 4. .env

```env
# Railway lub lokalna baza
DATABASE_URL=postgresql://user:password@host:port/database

# Lub osobne zmienne
PGHOST=localhost
PGPORT=5432
PGDATABASE=sohosoft_b2b
PGUSER=postgres
PGPASSWORD=password

PORT=3000
NODE_ENV=development
```

### 5. server.js

```javascript
const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/orders', require('./routes/orders'));
app.use('/api/products', require('./routes/products'));
app.use('/api/companies', require('./routes/companies'));
app.use('/api/activities', require('./routes/activities'));

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'SOHOsoft API działa' });
});

app.listen(PORT, () => {
  console.log(`🚀 Server działa na porcie ${PORT}`);
  console.log(`📡 API dostępne: http://localhost:${PORT}/api`);
});
```

### 6. routes/orders.js

```javascript
const express = require('express');
const router = express.Router();
const pool = require('../db/connection');

// GET - Lista zamówień klienta
router.get('/:companyId', async (req, res) => {
  try {
    const { companyId } = req.params;
    const result = await pool.query(
      `SELECT o.*, 
              c.name AS company_name,
              dl.name AS delivery_location_name,
              COUNT(oi.id) AS items_count
       FROM orders o
       JOIN companies c ON c.id = o.company_id
       JOIN delivery_locations dl ON dl.id = o.delivery_location_id
       LEFT JOIN order_items oi ON oi.order_id = o.id
       WHERE o.company_id = $1
       GROUP BY o.id, c.name, dl.name
       ORDER BY o.order_date DESC`,
      [companyId]
    );
    res.json(result.rows);
  } catch (error) {
    console.error('Błąd pobierania zamówień:', error);
    res.status(500).json({ error: 'Błąd serwera' });
  }
});

// POST - Utworzenie nowego zamówienia
router.post('/', async (req, res) => {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    const {
      company_id,
      delivery_location_id,
      requested_delivery_date,
      delivery_method,
      carrier_id,
      items, // Array of {product_id, quantity, unit}
      notes
    } = req.body;
    
    // 1. Utwórz zamówienie
    const orderResult = await client.query(
      `INSERT INTO orders 
       (company_id, delivery_location_id, requested_delivery_date, 
        delivery_method, carrier_id, status, notes)
       VALUES ($1, $2, $3, $4, $5, 'pending', $6)
       RETURNING *`,
      [company_id, delivery_location_id, requested_delivery_date, 
       delivery_method, carrier_id, notes]
    );
    
    const order = orderResult.rows[0];
    let totalAmount = 0;
    let totalQuantity = 0;
    
    // 2. Dodaj pozycje zamówienia
    for (const item of items) {
      // Pobierz cenę produktu
      const productResult = await client.query(
        'SELECT price_per_ton, price_per_bag, price_per_pallet, price_per_truck FROM products WHERE id = $1',
        [item.product_id]
      );
      
      if (productResult.rows.length === 0) {
        throw new Error(`Produkt o ID ${item.product_id} nie istnieje`);
      }
      
      const product = productResult.rows[0];
      let unitPrice = 0;
      
      // Wybierz cenę w zależności od jednostki
      switch (item.unit) {
        case 'ton':
          unitPrice = product.price_per_ton;
          totalQuantity += parseFloat(item.quantity);
          break;
        case 'bag':
          unitPrice = product.price_per_bag;
          totalQuantity += parseFloat(item.quantity) * 0.025; // 25kg = 0.025 ton
          break;
        case 'pallet':
          unitPrice = product.price_per_pallet;
          totalQuantity += parseFloat(item.quantity); // 1 paleta = 1 tona
          break;
        case 'truck':
          unitPrice = product.price_per_truck;
          totalQuantity += parseFloat(item.quantity) * 30; // 1 samochód = ~30 ton
          break;
      }
      
      const totalPrice = unitPrice * parseFloat(item.quantity);
      totalAmount += totalPrice;
      
      await client.query(
        `INSERT INTO order_items 
         (order_id, product_id, quantity, unit, unit_price, total_price)
         VALUES ($1, $2, $3, $4, $5, $6)`,
        [order.id, item.product_id, item.quantity, item.unit, unitPrice, totalPrice]
      );
    }
    
    // 3. Aktualizuj sumę zamówienia
    await client.query(
      'UPDATE orders SET total_amount = $1, total_quantity = $2 WHERE id = $3',
      [totalAmount, totalQuantity, order.id]
    );
    
    // 4. Zaloguj aktywność
    await client.query(
      `INSERT INTO client_activities 
       (company_id, activity_type, activity_data)
       VALUES ($1, 'order_created', $2)`,
      [
        company_id,
        JSON.stringify({
          order_id: order.id,
          order_number: order.order_number,
          total_amount: totalAmount
        })
      ]
    );
    
    await client.query('COMMIT');
    
    // Pobierz pełne dane zamówienia
    const fullOrderResult = await client.query(
      `SELECT o.*, 
              c.name AS company_name,
              dl.name AS delivery_location_name
       FROM orders o
       JOIN companies c ON c.id = o.company_id
       JOIN delivery_locations dl ON dl.id = o.delivery_location_id
       WHERE o.id = $1`,
      [order.id]
    );
    
    res.status(201).json({
      success: true,
      order: fullOrderResult.rows[0],
      message: 'Zamówienie zostało utworzone'
    });
    
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Błąd tworzenia zamówienia:', error);
    res.status(500).json({ 
      success: false,
      error: 'Błąd tworzenia zamówienia',
      details: error.message 
    });
  } finally {
    client.release();
  }
});

module.exports = router;
```

### 7. routes/products.js

```javascript
const express = require('express');
const router = express.Router();
const pool = require('../db/connection');

// GET - Lista produktów
router.get('/', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM products WHERE is_active = true ORDER BY name'
    );
    res.json(result.rows);
  } catch (error) {
    console.error('Błąd pobierania produktów:', error);
    res.status(500).json({ error: 'Błąd serwera' });
  }
});

// GET - Pojedynczy produkt
router.get('/:id', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM products WHERE id = $1',
      [req.params.id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Produkt nie znaleziony' });
    }
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Błąd pobierania produktu:', error);
    res.status(500).json({ error: 'Błąd serwera' });
  }
});

module.exports = router;
```

### 8. routes/activities.js

```javascript
const express = require('express');
const router = express.Router();
const pool = require('../db/connection');

// POST - Logowanie aktywności klienta
router.post('/', async (req, res) => {
  try {
    const {
      company_id,
      user_id,
      activity_type,
      activity_data,
      ip_address,
      user_agent
    } = req.body;
    
    const result = await pool.query(
      `INSERT INTO client_activities 
       (company_id, user_id, activity_type, activity_data, ip_address, user_agent)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [company_id, user_id, activity_type, JSON.stringify(activity_data), ip_address, user_agent]
    );
    
    res.status(201).json({
      success: true,
      activity: result.rows[0]
    });
  } catch (error) {
    console.error('Błąd logowania aktywności:', error);
    res.status(500).json({ error: 'Błąd serwera' });
  }
});

// GET - Historia aktywności klienta
router.get('/company/:companyId', async (req, res) => {
  try {
    const { companyId } = req.params;
    const limit = parseInt(req.query.limit) || 50;
    
    const result = await pool.query(
      `SELECT ca.*, u.email AS user_email
       FROM client_activities ca
       LEFT JOIN users u ON u.id = ca.user_id
       WHERE ca.company_id = $1
       ORDER BY ca.created_at DESC
       LIMIT $2`,
      [companyId, limit]
    );
    
    res.json(result.rows);
  } catch (error) {
    console.error('Błąd pobierania aktywności:', error);
    res.status(500).json({ error: 'Błąd serwera' });
  }
});

module.exports = router;
```

---

## 🔗 Integracja z Frontendem

### Modyfikacja zamowienie-wizard.html

**Zamiast**:
```javascript
// Submit order
document.getElementById('successModal').classList.add('active');
```

**Użyj**:
```javascript
async function submitOrder() {
  const orderData = {
    company_id: getCurrentCompanyId(), // Z sesji/logowania
    delivery_location_id: selectedLocationId,
    requested_delivery_date: document.getElementById('deliveryDate').value,
    delivery_method: selectedDeliveryMethod, // 'own_transport', 'carrier', 'pickup'
    carrier_id: selectedCarrierId || null,
    items: [
      {
        product_id: selectedProductId,
        quantity: parseFloat(document.getElementById('quantity').value),
        unit: selectedUnit // 'ton', 'bag', 'pallet', 'truck'
      }
    ],
    notes: document.getElementById('notes').value || ''
  };
  
  try {
    const response = await fetch('http://localhost:3000/api/orders', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${getAuthToken()}` // Jeśli używasz JWT
      },
      body: JSON.stringify(orderData)
    });
    
    const result = await response.json();
    
    if (result.success) {
      // Sukces
      document.getElementById('successModal').classList.add('active');
      console.log('Zamówienie utworzone:', result.order);
    } else {
      // Błąd
      alert('Błąd tworzenia zamówienia: ' + result.error);
    }
  } catch (error) {
    console.error('Błąd:', error);
    alert('Błąd połączenia z serwerem');
  }
}

// W funkcji nextStep():
function nextStep() {
  if (currentStep === totalSteps) {
    updateSummary();
    submitOrder(); // Zamiast tylko pokazania modala
  } else {
    // ...
  }
}
```

### Logowanie aktywności (przeglądanie produktów)

```javascript
// W produkt-cem-ii.html, gdy użytkownik ogląda produkt:
async function logProductView(productId) {
  try {
    await fetch('http://localhost:3000/api/activities', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${getAuthToken()}`
      },
      body: JSON.stringify({
        company_id: getCurrentCompanyId(),
        user_id: getCurrentUserId(),
        activity_type: 'product_view',
        activity_data: {
          product_id: productId,
          product_code: 'CEM-II-A-LL-42.5R',
          product_name: 'CEM II/A-LL 42,5R'
        },
        ip_address: await getClientIP(),
        user_agent: navigator.userAgent
      })
    });
  } catch (error) {
    console.error('Błąd logowania aktywności:', error);
  }
}

// Wywołaj przy załadowaniu strony produktu
document.addEventListener('DOMContentLoaded', () => {
  const productId = getProductIdFromURL(); // Z URL lub danych
  logProductView(productId);
});
```

---

## 🚀 Uruchomienie

### Lokalnie

```bash
cd backend
npm install
npm run dev
```

### W Railway

1. **Dodaj backend service** w Railway
2. **Połącz z bazą danych** (Railway automatycznie ustawi `DATABASE_URL`)
3. **Deploy**:
   ```bash
   railway up
   ```

---

## 📝 Przykładowe Endpointy API

### Zamówienia

- `GET /api/orders/:companyId` - Lista zamówień klienta
- `POST /api/orders` - Utworzenie zamówienia
- `GET /api/orders/:id` - Szczegóły zamówienia
- `PUT /api/orders/:id` - Aktualizacja zamówienia

### Produkty

- `GET /api/products` - Lista produktów
- `GET /api/products/:id` - Szczegóły produktu

### Aktywności

- `POST /api/activities` - Logowanie aktywności
- `GET /api/activities/company/:companyId` - Historia aktywności

### Firmy

- `GET /api/companies/:id` - Dane firmy
- `PUT /api/companies/:id` - Aktualizacja danych firmy

---

## 🔐 Autentykacja (Opcjonalne)

### JWT Token

```javascript
// middleware/auth.js
const jwt = require('jsonwebtoken');

function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ error: 'Brak tokenu autoryzacji' });
  }
  
  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Nieprawidłowy token' });
    }
    req.user = user;
    next();
  });
}

// Użycie w routes:
router.post('/', authenticateToken, async (req, res) => {
  // req.user zawiera dane użytkownika
});
```

---

## 🐍 Python + FastAPI - Alternatywa

Jeśli wolisz Python:

```python
# main.py
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import psycopg2
import os
from dotenv import load_dotenv

load_dotenv()

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def get_db_connection():
    return psycopg2.connect(os.environ['DATABASE_URL'])

@app.post("/api/orders")
async def create_order(order_data: dict):
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        cursor.execute(
            """INSERT INTO orders 
               (company_id, delivery_location_id, status)
               VALUES (%s, %s, 'pending')
               RETURNING id, order_number""",
            (order_data['company_id'], order_data['delivery_location_id'])
        )
        order = cursor.fetchone()
        conn.commit()
        return {"success": True, "order_id": order[0]}
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()
        conn.close()
```

---

## 📚 Dodatkowe Zasoby

- [Express.js Dokumentacja](https://expressjs.com/)
- [node-postgres Dokumentacja](https://node-postgres.com/)
- [FastAPI Dokumentacja](https://fastapi.tiangolo.com/)

---

**Gotowe!** Teraz masz pełny backend API do obsługi zapisów do bazy danych! 🎉

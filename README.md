# Pisto App

> Financial management and sales ERP for small and medium businesses (SMBs).

Monorepo with a Flutter mobile/web frontend and a Hono + Bun REST API backed by SQL Server 2022.

---

## Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter 3.x + Dart 3.x |
| State management | Riverpod 3 (code generation) |
| Router | GoRouter |
| HTTP client | Dio + JWT interceptor (auto-refresh) |
| Backend | Hono 4 on Bun |
| Database | SQL Server 2022 (Docker) |
| ORM | Drizzle ORM (mssql experimental branch) |
| Validation | Valibot |
| Auth | JWT — access token 15 min + refresh token 7 d |
| Exports | pdf-lib · excel-builder-vanilla · fast-csv |

---

## Repository structure

```
pisto-app/
├── pisto-api/        # Hono + Bun REST API
│   ├── src/
│   │   ├── config/       # Database connection, env vars
│   │   ├── db/
│   │   │   ├── schema/   # Drizzle table definitions
│   │   │   ├── setup.ts  # CREATE TABLE script (run once)
│   │   │   └── seed.ts   # Demo data
│   │   ├── modules/      # auth · inventory · sales · collections · purchases · reports · exports
│   │   └── shared/       # Errors, pagination, correlatives, utils
│   ├── .env.example
│   └── package.json
│
└── pisto_app/        # Flutter app
    └── lib/
        ├── config/       # ApiClient, GoRouter, AppTheme, constants
        ├── core/         # Models (Freezed), providers, services
        ├── features/     # auth · dashboard · inventory · sales · collections · purchases · reports
        └── shared/       # Layouts, widgets
```

---

## Modules

| Module | Base route | Description |
|--------|-----------|-------------|
| Auth | `/api/v1/auth` | Login, register, token refresh |
| Inventory | `/api/v1/inventory` | Products, categories, warehouses, units, movements, transfers, low-stock alerts |
| Sales | `/api/v1/sales` | Customers, invoices, credit notes |
| Collections | `/api/v1/collections` | Accounts receivable, payments, aging report |
| Purchases | `/api/v1/purchases` | Suppliers, purchase orders, goods receipt, accounts payable |
| Reports | `/api/v1/reports` | Dashboard KPIs, sales summary, top products, gross profit, inventory valuation |
| Exports | `/api/v1/exports` | Download data as Excel, CSV, or PDF |

---

## Getting started

### Prerequisites

- [Bun](https://bun.sh) ≥ 1.1
- [Docker](https://www.docker.com) (for SQL Server)
- [Flutter](https://flutter.dev) ≥ 3.x

### 1 — Start SQL Server

```bash
docker run -d --name pisto-mssql \
  -e ACCEPT_EULA=Y \
  -e MSSQL_SA_PASSWORD=YourPassword123! \
  -p 1433:1433 \
  mcr.microsoft.com/mssql/server:2022-latest
```

### 2 — Configure the API

```bash
cd pisto-api
cp .env.example .env   # fill in your secrets
```

`.env` variables:

```env
DB_SERVER=localhost
DB_PORT=1433
DB_NAME=pisto_app
DB_USER=sa
DB_PASSWORD=YourPassword123!
DB_ENCRYPT=false
DB_TRUST_SERVER_CERTIFICATE=true

JWT_ACCESS_SECRET=change_me_at_least_10_chars
JWT_REFRESH_SECRET=change_me_at_least_10_chars

PORT=3000
CORS_ORIGIN=*
RATE_LIMIT_ENABLED=false
```

### 3 — Create tables and seed demo data

```bash
bun run src/db/setup.ts   # creates all tables
bun run db:seed           # inserts demo business + products
```

### 4 — Run the API

```bash
bun run dev   # hot reload at http://localhost:3000
```

### 5 — Run the Flutter app

```bash
cd pisto_app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d web-server --web-port=5000 --web-hostname=0.0.0.0
```

Open `http://localhost:5000` in any browser.

**Demo credentials** (after seeding):

| Field | Value |
|-------|-------|
| Email | `admin@pistoapp.com` |
| Password | `Admin1234!` |

---

## Development

```bash
# API — type check
cd pisto-api && bunx tsc --noEmit

# Flutter — analyze
cd pisto_app && flutter analyze

# Drizzle Studio (DB browser)
cd pisto-api && bun run db:studio
```

---

## License

MIT

# Pisto App

> Financial management and sales ERP for small and medium businesses (SMBs).

Monorepo with a Flutter mobile/web frontend and a Hono REST API on Cloudflare
Workers, backed by PostgreSQL. Includes an AI assistant that answers questions
about your own books in plain Spanish.

---

## Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter 3.x + Dart 3.x |
| State management | Riverpod 3 (code generation) |
| Router | GoRouter |
| HTTP client | Dio + JWT interceptor (auto-refresh) |
| Backend | Hono 4 on Cloudflare Workers |
| Database | PostgreSQL (Supabase) |
| ORM | Drizzle ORM + postgres-js |
| Validation | Valibot |
| Auth | JWT, access token 15 min + refresh token 7 d |
| AI | OpenAI-compatible API, configurable model |
| Exports | pdf-lib, excel-builder-vanilla, fast-csv |

---

## Repository structure

```
pisto-app/
├── pisto-api/        # Hono REST API on Cloudflare Workers
│   ├── src/
│   │   ├── config/       # Database connection, env vars
│   │   ├── db/
│   │   │   ├── schema/   # Drizzle table definitions
│   │   │   └── seed.ts   # Demo data
│   │   ├── modules/      # auth · inventory · sales · collections · purchases
│   │   │                 # reports · exports · expenses · ai · settings · uploads
│   │   └── shared/       # Errors, pagination, correlatives, utils
│   ├── migrate.ts
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
| Expenses | `/api/v1/expenses` | Operating expenses and categories |
| AI | `/api/v1/ai` | Chat over your own books, receipt scanning, expense categorization, sales forecast, anomaly detection |
| Settings | `/api/v1/settings` | Business profile and preferences |
| Uploads | `/api/v1/uploads` | File and receipt uploads |

---

## Getting started

### Prerequisites

- [Bun](https://bun.sh) ≥ 1.1
- A PostgreSQL database. Any will do; the project is developed against
  [Supabase](https://supabase.com).
- [Flutter](https://flutter.dev) ≥ 3.x

### 1 — Configure the API

```bash
cd pisto-api
bun install
cp .env.example .env   # fill in your secrets
```

`.env` variables:

```env
DATABASE_URL=postgresql://user:password@host:6543/postgres
DATABASE_URL_DIRECT=postgresql://user:password@host:5432/postgres

JWT_ACCESS_SECRET=at_least_32_characters
JWT_REFRESH_SECRET=at_least_32_characters

NODE_ENV=development
CORS_ORIGIN=*
RATE_LIMIT_ENABLED=false

# Optional: enables the /api/v1/ai module
AI_API_KEY=
AI_BASE_URL=
AI_MODEL=gpt-4o
```

`DATABASE_URL` uses the pooled connection (port 6543) for the Worker runtime;
`DATABASE_URL_DIRECT` uses the direct one (port 5432) for migrations.

### 2 — Run migrations and seed demo data

```bash
bun run db:migrate   # applies Drizzle migrations
bun run db:seed      # inserts demo business + products
```

### 3 — Run the API

```bash
bun run dev   # wrangler dev, at http://localhost:8787
```

To deploy it: `bun run deploy`.

### 4 — Run the Flutter app

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

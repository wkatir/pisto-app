# Pisto

> **Las cuentas claras de tu negocio.** Sales, inventory, receivables and purchases for
> Salvadoran small businesses, with an AI assistant that queries the books in plain Spanish.

Most SME owners in El Salvador run their business on a notebook and a WhatsApp thread. Pisto
replaces that without asking them to learn accounting: they type *"¿cuánto vendí este mes?"*
and get a real answer computed from their own data, not a chart they have to interpret.

Monorepo: Flutter app (web · Android · iOS) + Hono REST API on PostgreSQL.

![Dashboard](docs/screenshots/dashboard.png)

---

## What it does

| | |
|---|---|
| **Sales** | Invoices with tax and discounts, credit notes, cancellations, customers, cash or credit terms |
| **Receivables** | Aging buckets, partial payments, account statements, WhatsApp payment reminders |
| **Inventory** | Products, categories, warehouses, stock movements, transfers, low-stock alerts |
| **Purchases** | Purchase orders → approval → goods receipt → payables, suppliers and supplier prices |
| **Expenses** | Categorised spending with receipt photos |
| **Reports** | Gross profit, sales trend and category mix, top products, inventory valuation |
| **Exports** | Any report to PDF, Excel or CSV; invoices to PDF |
| **AI** | Chat over your own data (function calling), cash-flow forecast, anomaly detection, expense categorisation, receipt scanning |

Money is `numeric(12,2)` in the database, `string` in TypeScript, and arithmetic runs through
`decimal.js`, never floats. Every query is scoped by the `business_id` in the JWT.

---

## The interface

Editorial and numbers-first: warm paper, one dominant figure per screen, hairline structure
instead of boxes. The full system (palette with contrast ratios, type scale, primitives) is
in [docs/DESIGN.md](docs/DESIGN.md), and the reasoning behind every rule, quoted from Material,
WCAG and Apple, is in [docs/RATIONALE.md](docs/RATIONALE.md).

| Sign in | AI assistant |
|---|---|
| ![Login](docs/screenshots/login.png) | ![AI chat](docs/screenshots/ai-chat.png) |

| Sales | Inventory |
|---|---|
| ![Sales](docs/screenshots/sales.png) | ![Inventory](docs/screenshots/inventory.png) |

| Receivables | Reports |
|---|---|
| ![Receivables](docs/screenshots/collections.png) | ![Reports](docs/screenshots/reports.png) |

| Purchases | Expenses |
|---|---|
| ![Purchases](docs/screenshots/purchases.png) | ![Expenses](docs/screenshots/expenses.png) |

Light and dark are both first-class; dark is a warm brown-charcoal (`#1C1916`), not grey.

---

## Read this first

| Doc | What it is |
|-----|-----------|
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | **Normative.** Backend vertical slices, frontend repository + Riverpod layers. Code that violates it is wrong even if it works. |
| [docs/CONVENTIONS.md](docs/CONVENTIONS.md) | **Normative.** Lean-code rules, language policy, design constraints. |
| [docs/DESIGN.md](docs/DESIGN.md) | **Normative.** Palette, typography, radii, surfaces, shared primitives. |
| [docs/RATIONALE.md](docs/RATIONALE.md) | Why every rule exists, with primary sources quoted, and an explicit list of the rules that are product decisions with **no** official backing. |
| [docs/DESIGN-VOICE.md](docs/DESIGN-VOICE.md) | The "de-slop" plan: what makes a UI read as generated, and the voice that replaces it. |
| [docs/PLAN.md](docs/PLAN.md) | Strategy: market validation, AI-native roadmap, DTE wedge. |
| [docs/DTE.md](docs/DTE.md) | Electronic invoicing (Factura Electrónica) design. |

---

## Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter 3.41 · Riverpod 3 (codegen) · GoRouter · Dio (JWT auto-refresh) · Freezed · FlexColorScheme · fl_chart |
| Backend | Hono 4 on Cloudflare Workers (Bun on a VPS planned: PLAN F0) |
| Database | PostgreSQL · Drizzle ORM · postgres.js, reached through Hyperdrive |
| Storage | Cloudflare R2, served through an authorising Worker route (keys are namespaced per business) |
| Validation | Valibot at the route boundary (`@hono/valibot-validator`) |
| Auth | JWT: access 15 min / refresh 7 d · PBKDF2 via WebCrypto |
| AI | Any OpenAI-compatible provider · function calling · **strict structured outputs** |
| Exports | pdf-lib · excel-builder-vanilla · fast-csv |

### A note on the AI provider

Structured output is required, never JSON mode: OpenAI's own docs say *"only Structured
Outputs ensure schema adherence"*. Providers expose it differently: OpenAI via
`response_format: json_schema`, DeepSeek only via strict tool calling against its `/beta`
endpoint. The client handles both. Receipt scanning additionally needs a **vision** model:
DeepSeek V4 is text-only and will return a clear 502 rather than pretend to work. See
[docs/RATIONALE.md](docs/RATIONALE.md) §7-8.

---

## Repository structure

```
pisto-app/
├── docs/                 # Normative docs: read before coding
│   └── screenshots/
├── pisto-api/            # Hono API
│   └── src/
│       ├── config/       # env, per-request database connection
│       ├── db/schema/    # Drizzle tables
│       ├── middleware/   # auth guard, rate limit
│       ├── modules/      # auth · inventory · sales · collections · purchases · expenses
│       │                 # reports · exports · settings · uploads · notifications · ai
│       └── shared/       # crud factory, pagination, errors, common schemas
└── pisto_app/            # Flutter app
    └── lib/
        ├── config/       # ApiClient, router, theme, tokens
        ├── core/         # models, providers, services
        ├── features/     # one folder per domain: screens · providers · data · models
        └── shared/       # shell layout, design-system widgets, form kit
```

---

## Getting started

Prerequisites: [Bun](https://bun.sh) ≥ 1.1, [Flutter](https://flutter.dev) ≥ 3.41, and a
PostgreSQL database (Supabase, Neon, or local Docker).

### API

```bash
cd pisto-api
cp .env.example .dev.vars     # DATABASE_URL, JWT secrets, AI_API_KEY, AI_BASE_URL, AI_MODEL
bun install
bun run db:migrate
bun run db:seed
bun run dev                   # → http://localhost:8787
```

The seed prints a generated admin password **once**. Save it. To reset it later:

```bash
bun run src/db/reset-admin.ts
```

> **Local Hyperdrive.** In production the database is reached through a Hyperdrive binding.
> `wrangler dev` does not know your local database unless you tell it, so export the
> connection string before starting, otherwise every request fails at the first query:
>
> ```bash
> export CLOUDFLARE_HYPERDRIVE_LOCAL_CONNECTION_STRING_HYPERDRIVE="postgres://user:pass@localhost:5432/pisto"
> ```
>
> Alternatively set `localConnectionString` in the `[[hyperdrive]]` block of `wrangler.toml`.

### Flutter app

```bash
cd pisto_app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d chrome
```

The app defaults to `http://127.0.0.1:3000/api/v1` on web and `http://10.0.2.2:3000/api/v1` on
the Android emulator. Either start the API on that port (`wrangler dev --port 3000`) or point
the app somewhere else:

```bash
flutter run -d chrome --dart-define=API_BASE_URL_WEB=https://your-api.workers.dev/api/v1
```

---

## Development

```bash
cd pisto-api && bunx tsc --noEmit        # type check
cd pisto-api && bun run db:studio        # database browser
cd pisto_app && flutter analyze          # lint, must be clean
cd pisto_app && flutter build web        # release build
```

House rules, in short (the full versions are normative in `docs/`):

- **Fail loud.** No fallback that hides a bug. `catch { return [] }` on a contract we own turns
  a clear crash into a silently wrong number, and money is involved.
- **Comments explain WHY**, never what. If a comment explains what, rename instead.
- **English** for code, comments, identifiers, commits and PRs. **Spanish** for anything a user
  reads.
- **No `Colors.*` or hex** in widgets: the theme is the only source of colour.
- A change that alters architecture updates its doc in the same PR.

---

## License

Proprietary. Copyright (c) 2026 Wilmer Henrry Salazar Martinez. All rights reserved.

The source is public so it can be read, evaluated and learned from. That does not make it
open source: no permission is granted to use, copy, modify or distribute it, commercially
or otherwise. See [LICENSE](LICENSE). For commercial licensing, contact the author.

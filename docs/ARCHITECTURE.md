# Pisto — Architecture

This document is normative. Any code (human or AI generated) that does not follow it is wrong,
even if it works. Read `docs/CONVENTIONS.md` for style rules.

## Monorepo

```
pisto-api/    Hono API (Cloudflare Workers today → Bun on a VPS, see docs/PLAN.md F0)
pisto_app/    Flutter app (web + mobile; desktop postponed)
docs/         Normative docs (this file, CONVENTIONS, PLAN, DTE)
```

The marketing/landing page is NOT part of this repo. The Flutter app starts at `/login`.

---

## Backend: modular monolith with vertical slices

One deployable, one database, modules split by business domain. Each module is a vertical
slice that owns its routes, service, and validation schemas. Modules do not import from each
other's services; cross-domain reads go through the DB (it is one schema) and cross-domain
writes go through the owning service.

```
pisto-api/src/
  app.ts                  Hono app assembly: middleware + module mounting. Nothing else.
  index.ts                Entry point (runtime-specific).
  config/                 env, database. No business logic.
  db/
    schema/               Drizzle schema, one file per domain (core, sales, inventory, ...)
    seed.ts
  middleware/             auth guard, rate limit, error handler
  modules/<domain>/
    <domain>.routes.ts    HTTP layer: parse/validate input, call service, shape response.
    <entity>.service.ts   Business logic + DB access. One service per aggregate.
    <domain>.schemas.ts   Valibot schemas (shared by routes and AI tools).
  shared/
    crud.ts               Generic CRUD service/route factories (see below)
    utils/                pagination, errors, lookups
    schemas/              cross-module Valibot schemas
  types/                  AppEnv, shared types
```

### Rules

1. **Routes are thin.** A route handler does: read `businessId` from context → validate with
   `vValidator` → call one service function → `c.json(...)`. No queries, no branching logic.
2. **Services own the data.** All Drizzle access lives in services. A service function takes
   plain typed args (always `businessId` first) and returns plain data or throws `AppError`.
3. **Standard CRUD goes through the factory.** `shared/crud.ts` provides `crudService(table,
   opts)` / `crudRoutes(service, schemas)` covering list (search + pagination + count), get,
   create, update, soft-delete. A module only writes bespoke code for what is genuinely
   bespoke (invoice posting, goods receipt, aging). If you are hand-writing
   `Promise.all([select…offset…limit, count])`, stop and use the factory.
4. **One pagination contract.** `shared/utils/pagination.ts` is the single source for the
   query schema (`page`, `limit`, `search`) and `paginatedResponse` shape
   `{ data, meta: { page, limit, total, totalPages } }`. Never define another.
5. **Multi-tenancy is non-negotiable.** Every table has `business_id`; every query filters by
   it; the value always comes from the JWT via `c.get('businessId')`, never from the request
   body.
6. **Errors:** throw `AppError(status, message)`; the error middleware is the only place that
   turns errors into HTTP responses. Never `try/catch`-and-continue in a service (lean-code:
   fail loud).
7. **AI module:** LLM calls go through `ai-client.ts` (OpenAI-compatible). Model JSON output
   MUST use structured outputs (`response_format: json_schema`), never fence-stripping +
   `JSON.parse`. Agent write-tools follow draft-then-confirm (see docs/PLAN.md §2): they
   create `draft` rows, take an idempotency key, and log to the audit table.
8. **Money** is `numeric(12,2)` in Postgres, `string` in TS, `decimal.js` for arithmetic.
   Never `number` math on money.

## Frontend: feature-first + repository pattern (Riverpod)

Layers, strictly one-directional. A screen never touches Dio; a repository never touches
widgets.

```
UI (screens/widgets)  →  Providers (Riverpod Notifier/AsyncNotifier)  →  Repositories  →  ApiClient (Dio)
                                        ↑ models (Freezed) flow back up
```

```
pisto_app/lib/
  config/                 api_client, app_router, app_theme, constants
  core/
    models/               Freezed DTOs shared across features (user, paginated<T>)
    providers/            apiClient, repositories, theme
  features/<feature>/
    models/               Freezed DTOs owned by this feature (Product, Invoice, ...)
    data/                 <feature>_repository.dart — typed API access, returns models
    providers/            AsyncNotifier / FutureProvider per screen or aggregate
    screens/              ConsumerWidget screens, thin
    widgets/              feature-private widgets
  shared/
    layouts/              shell_layout
    widgets/              design-system widgets (page_header, list_row, form kit, ...)
    forms/                schema-driven form kit (see below)
```

### Rules

1. **Everything typed.** No `Map<String, dynamic>` past the repository boundary. Every API
   entity has a Freezed model with `fromJson`. Lists come back as
   `Paginated<T>` (`core/models/paginated.dart`). Stringly-typed access
   (`data['meta']?['totalPages']`) is a defect.
2. **State lives in providers, not in `setState`.** Screens read
   `ref.watch(xProvider)` and render the three states through the shared `AsyncValueWidget`
   (data / loading / error with retry). The `bool _loading` + `try/catch` + snackbar pattern
   is banned. Local `setState` is fine only for pure-UI state (tab index, text visibility).
3. **Mutations** go through the provider (`ref.read(xProvider.notifier).create(...)`), which
   calls the repository and invalidates what it changed. User feedback via `AppToast`.
4. **Forms use the form kit** (`shared/forms/`): declare fields
   (`PText`, `PMoney`, `PSelect`, `PDate`…) and get dialog/page scaffolding, controllers,
   validation, submit state, and dispose for free. Hand-rolled
   `TextEditingController` lifecycles in screens are banned for standard forms.
5. **Error surfacing:** repositories let Dio errors propagate; `ApiClient.parseError` is
   called in exactly one place (the shared error widgets/toast), not 89 times.
6. **Design system:** colors only via `Theme.of(context).colorScheme` / AppTheme tokens.
   Follow the visual rules in CONVENTIONS.md ("no AI slop" section). Both themes must work
   on every screen.
7. **Codegen:** `dart run build_runner build --delete-conflicting-outputs` after touching
   models/providers. Never edit `.g.dart` / `.freezed.dart`.

### Why these architectures

- Vertical-slice monolith: one solo dev, one deploy, low ceremony; modules map 1:1 to
  business domains and to future AI-agent tools. Microservices/hexagonal ceremony buys
  nothing at this scale.
- Repository + Riverpod (the standard "Flutter App Architecture" pattern): testable layers,
  models as the single contract with the API, and providers as the single owner of async
  state — which is exactly the surface the AI assistant will drive later.

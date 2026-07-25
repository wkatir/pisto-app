# Pisto App

Sistema de gestión financiera AI-native para PYMES salvadoreñas. Monorepo:

```
pisto_app/    → Flutter app (frontend)
pisto-api/    → Hono API (backend)
docs/         → Docs normativos — LEER ANTES DE ESCRIBIR CÓDIGO
```

**Normativo:** `docs/ARCHITECTURE.md` (estructura de capas y módulos) y
`docs/CONVENTIONS.md` (lean code, idioma, design system). Si el código que vas a generar
contradice esos docs, el código está mal. `docs/PLAN.md` tiene la estrategia y roadmap.

## Backend: pisto-api

- **Runtime:** Cloudflare Workers (`wrangler dev`/`deploy`); migración a Bun en VPS planeada (PLAN F0)
- **Framework:** Hono 4 (AppEnv en src/types/app-env.ts)
- **DB:** PostgreSQL (Supabase) via Hyperdrive · Drizzle ORM (`pg-core`) · postgres.js
- **Storage:** R2 (`UPLOADS_BUCKET`) para imágenes
- **Validación:** Valibot + @hono/valibot-validator en el borde de rutas
- **Auth:** JWT (hono/jwt) access 15min + refresh 7d; passwords PBKDF2 (WebCrypto)
- **AI:** cliente OpenAI-compatible (`AI_BASE_URL`/`AI_MODEL`); chat con function-calling,
  scan de recibos (visión), forecast, anomalías. JSON del modelo SIEMPRE con structured outputs.
- **Exports:** pdf-lib, excel-builder-vanilla, fast-csv
- **Ruta base:** `/api/v1` — módulos: auth (pública), inventory, sales, collections,
  purchases, expenses, reports, exports, settings, uploads, ai
- **Dinero:** `numeric(12,2)` en DB, `string` en TS, aritmética con decimal.js
- **Multi-tenant:** todo query filtra por `business_id` del JWT (`c.get('businessId')`)
- CRUD estándar via factory en `shared/crud.ts`; paginación única en `shared/utils/pagination.ts`

### Comandos

```bash
cd pisto-api
bun run dev          # wrangler dev
bun run db:generate  # drizzle-kit generate
bun run db:migrate   # tsx migrate.ts (DATABASE_URL_DIRECT en .dev.vars)
bun run db:seed
bunx tsc --noEmit    # type check
```

### Env (.dev.vars + bindings en wrangler.toml)

`DATABASE_URL` / `DATABASE_URL_DIRECT` (Supabase), `JWT_ACCESS_SECRET`, `JWT_REFRESH_SECRET`,
`AI_API_KEY`, `AI_BASE_URL`, `AI_MODEL`, `CORS_ORIGIN`, `RATE_LIMIT_ENABLED`; bindings
`HYPERDRIVE`, `UPLOADS_BUCKET`.

## Frontend: pisto_app

- **Framework:** Flutter 3.x + Dart 3.x — targets: web + android + ios (desktop pospuesto)
- **Arquitectura:** feature-first + repository pattern (ver docs/ARCHITECTURE.md):
  screens → providers (Riverpod 3 AsyncNotifier, codegen) → repositories (typed) → ApiClient (Dio)
- **Modelos:** Freezed + json_serializable. NADA de `Map<String,dynamic>` fuera de repositories.
- **Async UI:** `AsyncValueWidget` compartido; el patrón `bool _loading` + setState está prohibido
- **Forms:** form kit en `shared/forms/` (schema-driven); no TextEditingController a mano
- **Router:** GoRouter con auth redirect; la app arranca en `/login` (no hay landing en la app)
- **Theme:** FlexColorScheme light+dark, paleta cálida cream/pastel; Figtree + Spline Sans Mono; Lucide icons (ver docs/DESIGN.md)
- **Storage:** flutter_secure_storage (tokens + theme)
- **i18n:** slang — strings de UI en español

### Flujo de auth

1. Login/Register → `{ accessToken, refreshToken, user }`
2. Tokens en memoria (ApiClient) + flutter_secure_storage
3. Interceptor Dio agrega Bearer; en 401 refresh automático (anti-race); si falla → login
4. Al iniciar, restaura tokens de storage

### Comandos

```bash
cd pisto_app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d chrome
flutter analyze
```

### Convenciones (resumen — el detalle vive en docs/CONVENTIONS.md)

- Código/commits/identificadores en inglés; UI en español
- Lean code: fail loud, sin fallbacks que escondan bugs, comentarios solo para WHY no obvio
- Colores SOLO via `Theme.of(context).colorScheme` / tokens AppTheme — nunca Colors.* ni hex
- NO AI slop: sin stagger animations, glassmorphism, gradientes, shadows decorativos, emoji en UI
- Cards radius 18 / chips 20 / buttons 14; dark mode cálido (#1C1916) funcional en TODA pantalla
- Paquetes via CLI (`flutter pub add` / `bun add`), no editar pubspec.yaml a mano
- Providers generados `.g.dart` / `.freezed.dart`: no editar manualmente

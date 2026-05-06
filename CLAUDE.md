# Pisto App

Sistema de gestion financiera y ventas para PYMES. Monorepo con dos proyectos:

```
pisto_app/    → Flutter app (frontend)
pisto-api/    → Hono + Bun API (backend)
```

## Backend: pisto-api

- **Runtime:** Bun
- **Framework:** Hono (con AppEnv type en src/types/app-env.ts)
- **DB:** SQL Server 2022 (Docker, puerto 1433)
- **ORM:** Drizzle ORM + mssql driver (branch experimental mssql)
- **Validacion:** Valibot + @hono/valibot-validator
- **Auth:** JWT (hono/jwt) con access token (15min) + refresh token (7d)
- **Exports:** pdf-lib (PDF), excel-builder-vanilla (Excel), fast-csv (CSV)
- **Ruta base:** `/api/v1`
- **CORS:** Configurable via env CORS_ORIGIN (default '*')

### Modulos

| Modulo | Ruta | Descripcion |
|--------|------|-------------|
| auth | `/auth` | Login, register, refresh (publica) |
| inventory | `/inventory` | Productos, categorias, bodegas, unidades, movimientos, transferencias, alertas |
| sales | `/sales` | Clientes, facturas, notas de credito |
| collections | `/collections` | Cuentas por cobrar, pagos, antiguedad |
| purchases | `/purchases` | Proveedores, ordenes de compra, recepcion, cuentas por pagar |
| reports | `/reports` | Dashboard KPIs, resumen ventas, top productos, utilidad bruta, valuacion inventario |
| exports | `/exports` | Generadores Excel, CSV, PDF |

### Comandos

```bash
cd pisto-api
bun run dev          # Servidor con hot reload
bun run db:seed      # Seed datos demo
bun run db:studio    # Drizzle Studio
```

### Variables de entorno (.env)

```
DB_SERVER=localhost
DB_PORT=1433
DB_NAME=pisto_app
DB_USER=sa
DB_PASSWORD=YourPassword123!
DB_ENCRYPT=false
DB_TRUST_SERVER_CERTIFICATE=true
JWT_ACCESS_SECRET=...
JWT_REFRESH_SECRET=...
CORS_ORIGIN=*
PORT=3000
RATE_LIMIT_ENABLED=false
```

### Docker (SQL Server)

```bash
docker run -d --name pisto-mssql \
  -e ACCEPT_EULA=Y \
  -e MSSQL_SA_PASSWORD=YourPassword123! \
  -p 1433:1433 \
  mcr.microsoft.com/mssql/server:2022-latest
```

## Frontend: pisto_app

- **Framework:** Flutter 3.x + Dart 3.x
- **State:** Riverpod 3 con code generation (@riverpod)
- **Router:** GoRouter con auth redirect
- **HTTP:** Dio con interceptor JWT (auto-refresh con anti-race condition)
- **Theme:** FlexColorScheme (light + dark + toggle), colores chart en AppTheme
- **Fonts:** Google Fonts (Inter)
- **Icons:** Lucide Icons
- **Storage:** flutter_secure_storage (tokens + theme preference)
- **Models:** Freezed + json_serializable (sealed class, Dart 3)

### Arquitectura

```
lib/
  config/         → api_client, app_router, app_theme, constants
  core/
    models/       → user_model (freezed)
    providers/    → core_providers (apiClient, authService), service_providers, theme_provider
    services/     → auth, inventory, sales, collections, purchases, reports
  features/
    auth/         → login_screen, register_screen, auth_provider
    dashboard/    → dashboard_screen (KPIs)
    inventory/    → inventory_screen (productos, categorias, bodegas)
    sales/        → sales_screen, create_sale_screen, customer_form_screen
    collections/  → collections_screen (cuentas por cobrar, antiguedad)
    purchases/    → purchases_screen (ordenes, proveedores, cuentas por pagar)
    reports/      → reports_screen (resumen, top productos, margen)
    landing/      → landing_screen (pagina publica)
  shared/
    layouts/      → shell_layout (sidebar responsive + theme toggle)
```

### Flujo de auth

1. Login/Register → API retorna `{ accessToken, refreshToken, user }`
2. Tokens se guardan en memoria (ApiClient) + flutter_secure_storage
3. Interceptor Dio agrega `Authorization: Bearer` a cada request
4. En 401, intenta refresh automatico; si falla, redirige a login
5. Al iniciar app, restaura tokens de storage y marca sesion activa

### Comandos

```bash
cd pisto_app
flutter pub get
dart run build_runner build --delete-conflicting-outputs  # Code gen (riverpod, freezed)
flutter run -d chrome    # Web
flutter run              # Mobile
flutter analyze          # Lint
```

### Convenciones

- ConsumerWidget/ConsumerStatefulWidget para widgets con state
- Theme colors via `Theme.of(context).colorScheme` o AppTheme constants (nunca hardcodear colores)
- Errores de API se parsean con `ApiClient.parseError()` para mostrar mensajes amigables
- Idioma de UI: Espanol
- Providers generados: archivos `.g.dart` (no editar manualmente)
- NO AI slop: sin stagger animations, gradient cards, glassmorphism, over-engineering
- Estilo: Linear/Notion/Stripe Dashboard. Limpio, profesional, minimalista
- Instalar paquetes via CLI, no editar pubspec.yaml manualmente

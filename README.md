# Pisto App

Sistema de gestión financiera y ventas para PYMES. Monorepo con frontend Flutter y backend Hono/Bun.

[English](#english) | [Español](#español)

---

## English

### Overview

Pisto is a financial and sales management system designed for small and medium businesses (SMBs). It provides modules for inventory management, sales, purchases, collections, and reporting with export capabilities.

### Architecture

```
pisto_app/    → Flutter 3 + Riverpod 3 + GoRouter (frontend)
pisto-api/    → Hono + Bun + Drizzle ORM + PostgreSQL (backend)
```

### Tech Stack

**Frontend (Flutter)**
- Flutter 3.x + Dart 3.x
- State Management: Riverpod 3 with code generation
- Routing: GoRouter with auth redirect
- HTTP: Dio with JWT interceptor
- Theming: FlexColorScheme (light/dark/system)
- Charts: fl_chart
- Icons: Lucide Icons
- i18n: **Slang** (English/Spanish)

**Backend (Hono/Bun)**
- Runtime: Bun
- Framework: Hono
- Database: PostgreSQL 16
- ORM: Drizzle ORM + postgres.js
- Validation: Valibot + @hono/valibot-validator
- Auth: JWT (access token 15min, refresh token 7d)
- Rate Limiting: hono-rate-limiter (100 req/min per IP)
- Exports: pdf-lib, excel-builder-vanilla, fast-csv

### Features

| Module | Description |
|--------|-------------|
| Dashboard | KPIs, sales trends, top products, category breakdown |
| Inventory | Products, categories, warehouses, units, stock movements, transfers, alerts |
| Sales | Customers, invoices, credit notes |
| Collections | Accounts receivable, payments, aging reports |
| Purchases | Suppliers, purchase orders, receiving, accounts payable |
| Reports | Sales summary, top products, gross margin, inventory valuation |
| Exports | Excel, CSV, PDF generation |

### Internationalization (i18n)

The app uses **Slang** for type-safe internationalization supporting **English** and **Spanish**.

**Changing language:**
- Use the globe icon in the navigation rail/footer to toggle between EN/ES
- Language preference is persisted in secure storage

**Translation files:**
- `lib/i18n/en.i18n.json` - English translations
- `lib/i18n/es.i18n.json` - Spanish translations

**Adding new translations:**
1. Add new keys to both JSON files using `$variable` syntax for parameters
2. Run `dart run slang` to regenerate the translation code
3. Use `context.t.yourKey` or `t.yourKey` in widgets

**API Usage:**
```dart
// Simple translation
Text(t.dashboard);

// With parameters
Text(t.welcome(name: 'John'));

// Pluralization
Text(t.invoicesCount(count: 5));
```

### Setup

#### Prerequisites

- [Bun](https://bun.sh) >= 1.3
- [Flutter](https://flutter.dev) >= 3.x
- Docker (for PostgreSQL)

#### Backend Setup

```bash
cd pisto-api

# 1. Copy environment variables
cp .env.example .env

# 2. Start PostgreSQL database
docker run -d --name pisto-db \
  -e POSTGRES_USER=pisto \
  -e POSTGRES_PASSWORD=pisto_dev_2026 \
  -e POSTGRES_DB=pisto_app \
  -p 5433:5432 \
  postgres:16-alpine

# 3. Install dependencies
bun install

# 4. Apply schema to database
bun run db:push

# 5. (Optional) Seed demo data
bun run db:seed

# 6. Start development server
bun run dev
```

#### Frontend Setup

```bash
cd pisto_app

# Install dependencies
flutter pub get

# Generate code (Riverpod, Freezed, Slang translations)
dart run build_runner build --delete-conflicting-outputs
dart run slang

# Run on Chrome (web)
flutter run -d chrome

# Run on mobile
flutter run
```

#### Environment Variables (Backend)

| Variable | Description |
|----------|-------------|
| `DATABASE_URL` | PostgreSQL connection string |
| `JWT_ACCESS_SECRET` | Secret for access tokens (15 min expiry) |
| `JWT_REFRESH_SECRET` | Secret for refresh tokens (7 day expiry) |
| `PORT` | HTTP port (default: 3000) |
| `CORS_ORIGIN` | Allowed CORS origin (default: *) |

### API Endpoints

Base path: `/api/v1`

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/auth/login` | POST | Login, returns access + refresh tokens |
| `/auth/register` | POST | User registration |
| `/auth/refresh` | POST | Refresh access token |
| `/inventory/*` | - | Products, categories, warehouses, movements |
| `/sales/*` | - | Customers, invoices, credit notes |
| `/collections/*` | - | Accounts receivable, payments |
| `/purchases/*` | - | Suppliers, purchase orders |
| `/reports/*` | - | KPIs, sales summary, margins |
| `/exports/*` | - | Excel, CSV, PDF generation |

### Commands Reference

**Backend:**
```bash
cd pisto-api
bun run dev          # Dev server with hot reload
bun run db:push      # Apply schema to database
bun run db:generate  # Generate migrations
bun run db:migrate   # Run migrations
bun run db:seed      # Seed demo data
```

**Frontend:**
```bash
cd pisto_app
flutter pub get                                    # Install dependencies
dart run build_runner build --delete-conflicting-outputs  # Code generation
dart run slang                                    # Regenerate translations
flutter run -d chrome                              # Web
flutter run                                        # Mobile
flutter analyze                                    # Lint
```

---

## Español

### Descripción

Pisto es un sistema de gestión financiera y ventas diseñado para pequeñas y medianas empresas (PYMES). Incluye módulos para gestión de inventario, ventas, compras, cobranza y reportes con capacidades de exportación.

### Arquitectura

```
pisto_app/    → Flutter 3 + Riverpod 3 + GoRouter (frontend)
pisto-api/    → Hono + Bun + Drizzle ORM + PostgreSQL (backend)
```

### Stack Tecnológico

**Frontend (Flutter)**
- Flutter 3.x + Dart 3.x
- Estado: Riverpod 3 con code generation
- Enrutamiento: GoRouter con redirect de auth
- HTTP: Dio con interceptor JWT
- Temas: FlexColorScheme (light/dark/system)
- Gráficos: fl_chart
- Iconos: Lucide Icons
- i18n: **Slang** (Inglés/Español)

**Backend (Hono/Bun)**
- Runtime: Bun
- Framework: Hono
- Base de datos: PostgreSQL 16
- ORM: Drizzle ORM + postgres.js
- Validación: Valibot + @hono/valibot-validator
- Auth: JWT (token acceso 15min, refresh 7d)
- Rate Limiting: hono-rate-limiter (100 req/min por IP)
- Exportación: pdf-lib, excel-builder-vanilla, fast-csv

### Módulos

| Módulo | Descripción |
|--------|-------------|
| Dashboard | KPIs, tendencias de ventas, productos top, desglose por categoría |
| Inventario | Productos, categorías, bodegas, unidades, movimientos, transferencias, alertas |
| Ventas | Clientes, facturas, notas de crédito |
| Cobranza | Cuentas por cobrar, pagos, reportes de antigüedad |
| Compras | Proveedores, órdenes de compra, recepción, cuentas por pagar |
| Reportes | Resumen de ventas, productos top, margen bruto, valuación de inventario |
| Exportación | Generación de Excel, CSV, PDF |

### Internacionalización (i18n)

La app usa **Slang** para internacionalización type-safe, soportando **Inglés** y **Español**.

**Cambiar idioma:**
- Usa el icono de globo en el navigation rail/footer para alternar entre EN/ES
- La preferencia de idioma se guarda en almacenamiento seguro

**Archivos de traducción:**
- `lib/i18n/en.i18n.json` - Traducciones al inglés
- `lib/i18n/es.i18n.json` - Traducciones al español

**Agregar nuevas traducciones:**
1. Agrega nuevas claves a ambos archivos JSON usando sintaxis `$variable` para parámetros
2. Ejecuta `dart run slang` para regenerar el código
3. Usa `context.t.tuClave` o `t.tuClave` en los widgets

**Uso de la API:**
```dart
// Traducción simple
Text(t.dashboard);

// Con parámetros
Text(t.welcome(name: 'Juan'));

// Pluralización
Text(t.invoicesCount(count: 5));
```

### Configuración

#### Requisitos

- [Bun](https://bun.sh) >= 1.3
- [Flutter](https://flutter.dev) >= 3.x
- Docker (para PostgreSQL)

#### Configuración del Backend

```bash
cd pisto-api

# 1. Copiar variables de entorno
cp .env.example .env

# 2. Iniciar base de datos PostgreSQL
docker run -d --name pisto-db \
  -e POSTGRES_USER=pisto \
  -e POSTGRES_PASSWORD=pisto_dev_2026 \
  -e POSTGRES_DB=pisto_app \
  -p 5433:5432 \
  postgres:16-alpine

# 3. Instalar dependencias
bun install

# 4. Aplicar schema a la base de datos
bun run db:push

# 5. (Opcional) Poblar con datos demo
bun run db:seed

# 6. Iniciar servidor de desarrollo
bun run dev
```

#### Configuración del Frontend

```bash
cd pisto_app

# Instalar dependencias
flutter pub get

# Generar código (Riverpod, Freezed, Traducciones Slang)
dart run build_runner build --delete-conflicting-outputs
dart run slang

# Ejecutar en Chrome (web)
flutter run -d chrome

# Ejecutar en móvil
flutter run
```

#### Variables de Entorno (Backend)

| Variable | Descripción |
|----------|-------------|
| `DATABASE_URL` | Cadena de conexión PostgreSQL |
| `JWT_ACCESS_SECRET` | Secreto para tokens de acceso (15 min) |
| `JWT_REFRESH_SECRET` | Secreto para tokens de refresh (7 días) |
| `PORT` | Puerto HTTP (default: 3000) |
| `CORS_ORIGIN` | Origen permitido para CORS (default: *) |

### Endpoints de la API

Ruta base: `/api/v1`

| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/auth/login` | POST | Login, retorna access + refresh tokens |
| `/auth/register` | POST | Registro de usuario |
| `/auth/refresh` | POST | Renovar access token |
| `/inventory/*` | - | Productos, categorías, bodegas, movimientos |
| `/sales/*` | - | Clientes, facturas, notas de crédito |
| `/collections/*` | - | Cuentas por cobrar, pagos |
| `/purchases/*` | - | Proveedores, órdenes de compra |
| `/reports/*` | - | KPIs, resumen de ventas, márgenes |
| `/exports/*` | - | Generación de Excel, CSV, PDF |

### Referencia de Comandos

**Backend:**
```bash
cd pisto-api
bun run dev          # Servidor con hot reload
bun run db:push      # Aplicar schema a la DB
bun run db:generate  # Generar migraciones
bun run db:migrate   # Correr migraciones
bun run db:seed      # Poblar datos demo
```

**Frontend:**
```bash
cd pisto_app
flutter pub get                                    # Instalar dependencias
dart run build_runner build --delete-conflicting-outputs  # Generación de código
dart run slang                                    # Regenerar traducciones
flutter run -d chrome                              # Web
flutter run                                        # Móvil
flutter analyze                                    # Lint
```

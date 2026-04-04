# pisto-api

Backend REST API para Pisto App. Construido con Bun + Hono + Drizzle ORM + PostgreSQL.

## Requisitos

- [Bun](https://bun.sh) >= 1.3
- Docker (para PostgreSQL)

## Setup

```bash
# 1. Copiar variables de entorno
cp .env.example .env

# 2. Levantar base de datos
docker run -d --name pisto-db \
  -e POSTGRES_USER=pisto \
  -e POSTGRES_PASSWORD=pisto_dev_2026 \
  -e POSTGRES_DB=pisto_app \
  -p 5433:5432 \
  postgres:16-alpine

# 3. Instalar dependencias
bun install

# 4. Aplicar schema
bun run db:push

# 5. (Opcional) Seed de datos demo
bun run db:seed

# 6. Iniciar servidor
bun run dev
```

## Comandos

| Comando | Descripcion |
|---------|-------------|
| `bun run dev` | Servidor con hot reload |
| `bun run db:push` | Aplicar schema a la DB |
| `bun run db:generate` | Generar migraciones |
| `bun run db:migrate` | Correr migraciones |

## Variables de entorno

Ver `.env.example` para la lista completa. Claves requeridas:

- `DATABASE_URL` — cadena de conexion PostgreSQL
- `JWT_ACCESS_SECRET` — secreto para access tokens (15 min)
- `JWT_REFRESH_SECRET` — secreto para refresh tokens (7 dias)
- `PORT` — puerto HTTP (default: 3000)
- `CORS_ORIGIN` — origen permitido en CORS (default: `*`)

## Modulos

| Ruta | Descripcion |
|------|-------------|
| `POST /api/v1/auth/login` | Login, retorna access + refresh tokens |
| `POST /api/v1/auth/register` | Registro de usuario |
| `POST /api/v1/auth/refresh` | Renovar access token |
| `/api/v1/inventory/*` | Productos, categorias, bodegas, movimientos |
| `/api/v1/sales/*` | Clientes, facturas, notas de credito |
| `/api/v1/collections/*` | Cuentas por cobrar, pagos |
| `/api/v1/purchases/*` | Proveedores, ordenes de compra |
| `/api/v1/reports/*` | KPIs, resumen ventas, margen bruto |
| `/api/v1/exports/*` | Excel, CSV, PDF |

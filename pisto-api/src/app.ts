import { Hono } from 'hono'
import { cors } from 'hono/cors'
import { logger } from 'hono/logger'
import { secureHeaders } from 'hono/secure-headers'
import { HTTPException } from 'hono/http-exception'
import { rateLimitMiddleware, authRateLimitMiddleware } from './middleware/rate-limit'
import { auth } from './modules/auth/auth.routes'
import { inventory } from './modules/inventory/inventory.routes'
import { sales } from './modules/sales/sales.routes'
import { collections } from './modules/collections/collections.routes'
import { purchases } from './modules/purchases/purchases.routes'
import { reports } from './modules/reports/reports.routes'
import { exports } from './modules/exports/exports.routes'
import { settings } from './modules/settings/settings.routes'
import { expenses } from './modules/expenses/expenses.routes'
import { uploads } from './modules/uploads/uploads.routes'
import { notifications } from './modules/notifications/notifications.routes'
import { aiScan } from './modules/ai/ai-scan.routes'
import { ai } from './modules/ai/ai.routes'
import { aiInsights } from './modules/ai/ai-insights.routes'
import { authGuard } from './middleware/auth.middleware'
import { AppError } from './shared/errors/app-error'
import type { AppEnv } from './types/app-env'
import { runWithDb } from './config/database'
import { initEnv } from './config/env'

export const app = new Hono<AppEnv>().basePath('/api/v1')

// New DB connection per request — Workers can't share sockets across requests.
app.use('*', async (c, next) => {
  initEnv(c.env)
  await runWithDb(c.env.HYPERDRIVE.connectionString, () => next())
})

app.use('*', logger())

app.use('*', async (c, next) => {
  const rawOrigin = c.env.CORS_ORIGIN ?? '*'
  const corsConfig =
    rawOrigin.trim() === '*'
      ? { origin: '*' as const }
      : {
          origin: (origin: string) => {
            const allowed = rawOrigin.split(',').map((o) => o.trim())
            return allowed.includes(origin) ? origin : null
          },
        }

  return cors({
    ...corsConfig,
    allowHeaders: ['Content-Type', 'Authorization'],
    allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    maxAge: 86400,
    credentials: true,
  })(c, next)
})

app.use('*', secureHeaders({ crossOriginResourcePolicy: false, crossOriginOpenerPolicy: false }))

app.get('/health', (c) => c.json({ status: 'ok', timestamp: new Date().toISOString() }))

app.use('/auth/*', async (c, next) => {
  if (c.env.RATE_LIMIT_ENABLED === 'true') {
    return authRateLimitMiddleware(c, next)
  }
  return next()
})

app.route('/auth', auth)

const protectedPaths = ['/inventory', '/sales', '/collections', '/purchases', '/reports', '/exports', '/settings', '/expenses', '/uploads', '/notifications', '/ai']

for (const path of protectedPaths) {
  app.use(`${path}/*`, authGuard)
  app.use(`${path}/*`, async (c, next) => {
    if (c.env.RATE_LIMIT_ENABLED === 'true') {
      return rateLimitMiddleware(c, next)
    }
    return next()
  })
}

app.route('/inventory', inventory)
app.route('/sales', sales)
app.route('/collections', collections)
app.route('/purchases', purchases)
app.route('/reports', reports)
app.route('/exports', exports)
app.route('/settings', settings)
app.route('/expenses', expenses)
app.route('/uploads', uploads)
app.route('/notifications', notifications)
app.route('/ai', aiScan)
app.route('/ai', ai)
app.route('/ai', aiInsights)

app.onError((err, c) => {
  if (err instanceof AppError) {
    return c.json({ error: err.message }, err.statusCode as Parameters<typeof c.json>[1])
  }
  if (err instanceof HTTPException) {
    return c.json({ error: err.message }, err.status)
  }

  // postgres.js sets `.code` on the error it throws; drizzle wraps it in DrizzleQueryError as `.cause`.
  const pgCode = (err as { code?: string; cause?: { code?: string } }).code ?? (err as { cause?: { code?: string } }).cause?.code
  if (pgCode?.startsWith('23')) {
    return c.json({ error: pgIntegrityErrorMessage(pgCode) }, 409)
  }

  console.error('Unhandled error:', err, (err as Error).cause ?? '')
  return c.json({ error: 'Error interno del servidor' }, 500)
})

// SQLSTATE class 23 (integrity constraint violation) — see https://www.postgresql.org/docs/current/errcodes-appendix.html
function pgIntegrityErrorMessage(code: string): string {
  switch (code) {
    case '23505':
      return 'Ya existe un registro con esos datos'
    case '23503':
      return 'La operación hace referencia a un registro que no existe'
    case '23502':
      return 'Falta un dato requerido'
    default:
      return 'Los datos no cumplen una condición requerida'
  }
}

app.notFound((c) => c.json({ error: 'Ruta no encontrada' }, 404))

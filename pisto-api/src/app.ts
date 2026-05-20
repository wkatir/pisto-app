import { Hono } from 'hono'
import { cors } from 'hono/cors'
import { logger } from 'hono/logger'
import { secureHeaders } from 'hono/secure-headers'
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
import { aiScan } from './modules/ai/ai-scan.routes'
import { ai } from './modules/ai/ai.routes'
import { aiInsights } from './modules/ai/ai-insights.routes'
import { authGuard } from './middleware/auth.middleware'
import { AppError } from './shared/errors/app-error'
import type { AppEnv } from './types/app-env'
import { env } from './config/env'

const app = new Hono<AppEnv>().basePath('/api/v1')

const corsOrigin = env.CORS_ORIGIN
const corsConfig =
  corsOrigin === '*'
    ? { origin: '*' as const }
    : Array.isArray(corsOrigin)
      ? {
          origin: (origin: string) => (corsOrigin.includes(origin) ? origin : null),
        }
      : { origin: corsOrigin }

app.use('*', logger())
app.use('*', cors({
  ...corsConfig,
  allowHeaders: ['Content-Type', 'Authorization'],
  allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  maxAge: 86400,
  credentials: true,
}))
app.use('*', secureHeaders({ crossOriginResourcePolicy: false, crossOriginOpenerPolicy: false }))

app.get('/health', (c) => c.json({ status: 'ok', timestamp: new Date().toISOString() }))

if (env.RATE_LIMIT_ENABLED) {
  app.use('/auth/*', authRateLimitMiddleware)
}
app.route('/auth', auth)

const protectedRoutes = ['/inventory', '/sales', '/collections', '/purchases', '/reports', '/exports', '/settings', '/expenses', '/uploads', '/ai']
for (const path of protectedRoutes) {
  if (env.RATE_LIMIT_ENABLED) {
    app.use(`${path}/*`, authGuard, rateLimitMiddleware)
  } else {
    app.use(`${path}/*`, authGuard)
  }
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
app.route('/ai', aiScan)
app.route('/ai', ai)
app.route('/ai', aiInsights)

app.onError((err, c) => {
  if (err instanceof AppError) {
    const status = err.statusCode
    return c.json({ error: err.message }, status as Parameters<typeof c.json>[1])
  }
  console.error('Unhandled error:', err)
  return c.json({ error: 'Error interno del servidor' }, 500)
})

app.notFound((c) => c.json({ error: 'Ruta no encontrada' }, 404))

export { app }

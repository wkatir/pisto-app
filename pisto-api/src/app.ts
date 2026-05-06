import { Hono } from 'hono'
import { cors } from 'hono/cors'
import { logger } from 'hono/logger'
import { secureHeaders } from 'hono/secure-headers'
import { rateLimitMiddleware } from './middleware/rate-limit'
import { auth } from './modules/auth/auth.routes'
import { inventory } from './modules/inventory/inventory.routes'
import { sales } from './modules/sales/sales.routes'
import { collections } from './modules/collections/collections.routes'
import { purchases } from './modules/purchases/purchases.routes'
import { reports } from './modules/reports/reports.routes'
import { exports } from './modules/exports/exports.routes'
import { authGuard } from './middleware/auth.middleware'
import { AppError } from './shared/errors/app-error'
import type { AppEnv } from './types/app-env'
import { env } from './config/env'

const app = new Hono<AppEnv>().basePath('/api/v1')

app.use('*', logger())
app.use('*', cors({
  origin: env.CORS_ORIGIN,
  allowHeaders: ['Content-Type', 'Authorization'],
  allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  maxAge: 86400,
}))
app.use('*', secureHeaders({ crossOriginResourcePolicy: false, crossOriginOpenerPolicy: false }))

app.get('/health', (c) => c.json({ status: 'ok', timestamp: new Date().toISOString() }))

app.route('/auth', auth)

if (env.RATE_LIMIT_ENABLED) {
  app.use('/inventory/*', authGuard, rateLimitMiddleware)
  app.use('/sales/*', authGuard, rateLimitMiddleware)
  app.use('/collections/*', authGuard, rateLimitMiddleware)
  app.use('/purchases/*', authGuard, rateLimitMiddleware)
  app.use('/reports/*', authGuard, rateLimitMiddleware)
  app.use('/exports/*', authGuard, rateLimitMiddleware)
} else {
  app.use('/inventory/*', authGuard)
  app.use('/sales/*', authGuard)
  app.use('/collections/*', authGuard)
  app.use('/purchases/*', authGuard)
  app.use('/reports/*', authGuard)
  app.use('/exports/*', authGuard)
}

app.route('/inventory', inventory)
app.route('/sales', sales)
app.route('/collections', collections)
app.route('/purchases', purchases)
app.route('/reports', reports)
app.route('/exports', exports)

app.onError((err, c) => {
  if (err instanceof AppError) {
    return c.json({ error: err.message }, err.statusCode as 400)
  }
  console.error('Unhandled error:', err)
  return c.json({ error: 'Error interno del servidor' }, 500)
})

app.notFound((c) => c.json({ error: 'Ruta no encontrada' }, 404))

export { app }

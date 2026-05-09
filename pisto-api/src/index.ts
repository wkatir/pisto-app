import { Hono } from 'hono'
import { serveStatic } from 'hono/bun'
import { cors } from 'hono/cors'
import { app } from './app'
import { env } from './config/env'

// Root app que combina la API (montada en /api/v1) con el static server de
// archivos subidos (servidos en /uploads/*). El módulo de uploads guarda los
// archivos en ./uploads/<folder>/<filename> y devuelve URLs públicas
// relativas como /uploads/products/abc.jpg — esas URLs se sirven desde acá.
const root = new Hono()

const corsOrigin = env.CORS_ORIGIN
const corsConfig =
  corsOrigin === '*'
    ? { origin: '*' as const }
    : Array.isArray(corsOrigin)
      ? { origin: (origin: string) => (corsOrigin.includes(origin) ? origin : null) }
      : { origin: corsOrigin }

// CORS también para los archivos estáticos (necesario para que el frontend web
// los pueda mostrar desde un origin distinto).
root.use('/uploads/*', cors({ ...corsConfig, allowMethods: ['GET'] }))
root.use('/uploads/*', serveStatic({ root: './' }))

root.route('/', app)

console.log(`🚀 Pisto API running on http://localhost:${env.PORT}`)

export default {
  port: env.PORT,
  fetch: root.fetch,
}

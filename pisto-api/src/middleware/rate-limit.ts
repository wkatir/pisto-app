import type { MiddlewareHandler } from 'hono'

// hono-rate-limiter usa timers en global scope (incompatible con Workers).
// Rate limiting real debe implementarse con Cloudflare Rate Limiting API binding.
// Por ahora estas son no-ops — RATE_LIMIT_ENABLED=false en producción.
export const rateLimitMiddleware: MiddlewareHandler = (_c, next) => next()
export const authRateLimitMiddleware: MiddlewareHandler = (_c, next) => next()

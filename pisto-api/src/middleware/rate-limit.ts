import type { MiddlewareHandler } from 'hono'

// hono-rate-limiter uses global-scope timers (incompatible with Workers).
// Real rate limiting needs the Cloudflare Rate Limiting API binding instead.
// For now these are no-ops — RATE_LIMIT_ENABLED=false in production.
export const rateLimitMiddleware: MiddlewareHandler = (_c, next) => next()
export const authRateLimitMiddleware: MiddlewareHandler = (_c, next) => next()

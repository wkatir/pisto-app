import { rateLimiter } from 'hono-rate-limiter'

export const rateLimitMiddleware = rateLimiter({
  windowMs: 60 * 1000,
  max: 100,
  keyGenerator: (c) => c.req.header('x-forwarded-for') || 'anonymous',
})

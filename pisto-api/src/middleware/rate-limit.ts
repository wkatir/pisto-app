import { rateLimiter } from 'hono-rate-limiter'
import type { Context } from 'hono'
import { env } from '../config/env'

function getClientKey(c: Context): string {
  if (env.TRUST_PROXY) {
    const xff = c.req.header('x-forwarded-for')
    if (xff) {
      const first = xff.split(',')[0]?.trim()
      if (first) return first
    }
    const realIp = c.req.header('x-real-ip')
    if (realIp) return realIp
  }
  const auth = c.req.header('authorization')
  if (auth?.startsWith('Bearer ')) {
    return `tok:${auth.slice(7, 47)}`
  }
  return `ua:${c.req.header('user-agent') ?? 'unknown'}`
}

export const rateLimitMiddleware = rateLimiter({
  windowMs: 60 * 1000,
  limit: 100,
  standardHeaders: 'draft-7',
  keyGenerator: getClientKey,
})

export const authRateLimitMiddleware = rateLimiter({
  windowMs: 15 * 60 * 1000,
  limit: 20,
  standardHeaders: 'draft-7',
  keyGenerator: getClientKey,
})

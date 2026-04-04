import { createMiddleware } from 'hono/factory'
import { verify } from 'hono/jwt'
import { env } from '../config/env'
import type { AppEnv } from '../types/app-env'

export const authGuard = createMiddleware<AppEnv>(async (c, next) => {
  const header = c.req.header('Authorization')
  if (!header?.startsWith('Bearer ')) {
    return c.json({ error: 'No autorizado' }, 401)
  }

  try {
    const token = header.slice(7)
    const payload = await verify(token, env.JWT_ACCESS_SECRET, 'HS256')
    c.set('userId', payload.sub as string)
    c.set('businessId', payload.businessId as string)
    c.set('roles', payload.roles as string[])
    await next()
  } catch {
    return c.json({ error: 'Token inválido o expirado' }, 401)
  }
})

export const requireRole = (...allowed: string[]) =>
  createMiddleware<AppEnv>(async (c, next) => {
    const roles = c.get('roles')
    if (!allowed.some((r) => roles.includes(r))) {
      return c.json({ error: 'Permiso denegado' }, 403)
    }
    await next()
  })

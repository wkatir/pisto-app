import { Hono } from 'hono'
import { vValidator } from '@hono/valibot-validator'
import { loginSchema, registerSchema, refreshSchema, forgotPasswordSchema, updateProfileSchema, changePasswordSchema } from './auth.schemas'
import { loginUser, registerUser, refreshTokens, getMe, updateProfile, changePassword } from './auth.service'
import { AppError } from '../../shared/errors/app-error'
import { authGuard } from '../../middleware/auth.middleware'
import type { AppEnv } from '../../types/app-env'

const auth = new Hono<AppEnv>()

auth.post('/login', vValidator('json', loginSchema), async (c) => {
  const body = c.req.valid('json')
  try {
    const result = await loginUser(body.email, body.password)
    return c.json(result)
  } catch (e) {
    if (e instanceof AppError) return c.json({ error: e.message }, e.statusCode as 401)
    throw e
  }
})

auth.post('/register', vValidator('json', registerSchema), async (c) => {
  const body = c.req.valid('json')
  try {
    const result = await registerUser(body)
    return c.json(result, 201)
  } catch (e) {
    if (e instanceof AppError) return c.json({ error: e.message }, e.statusCode as 409)
    throw e
  }
})

auth.post('/refresh', vValidator('json', refreshSchema), async (c) => {
  const { refreshToken } = c.req.valid('json')
  try {
    const result = await refreshTokens(refreshToken)
    return c.json(result)
  } catch (e) {
    if (e instanceof AppError) return c.json({ error: e.message }, e.statusCode as 401)
    throw e
  }
})

auth.post('/forgot-password', vValidator('json', forgotPasswordSchema), async (c) => {
  return c.json({ message: 'Si el email existe, recibirás instrucciones.' });
})

auth.get('/me', authGuard, async (c) => {
  const userId = c.get('userId')
  try {
    const me = await getMe(userId)
    return c.json(me)
  } catch (e) {
    if (e instanceof AppError) return c.json({ error: e.message }, e.statusCode as 404)
    throw e
  }
})

auth.patch('/me', authGuard, vValidator('json', updateProfileSchema), async (c) => {
  const userId = c.get('userId')
  const body = c.req.valid('json')
  try {
    const updated = await updateProfile(userId, body)
    return c.json(updated)
  } catch (e) {
    if (e instanceof AppError) return c.json({ error: e.message }, e.statusCode as 409)
    throw e
  }
})

auth.post('/change-password', authGuard, vValidator('json', changePasswordSchema), async (c) => {
  const userId = c.get('userId')
  const body = c.req.valid('json')
  try {
    const result = await changePassword(userId, body.currentPassword, body.newPassword)
    return c.json(result)
  } catch (e) {
    if (e instanceof AppError) return c.json({ error: e.message }, e.statusCode as 401)
    throw e
  }
})

export { auth }

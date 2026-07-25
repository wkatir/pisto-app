import { Hono } from 'hono'
import { vValidator } from '@hono/valibot-validator'
import { loginSchema, registerSchema, refreshSchema, forgotPasswordSchema, updateProfileSchema, changePasswordSchema } from './auth.schemas'
import { loginUser, registerUser, refreshTokens, getMe, updateProfile, changePassword } from './auth.service'
import { authGuard } from '../../middleware/auth.middleware'
import type { AppEnv } from '../../types/app-env'

const auth = new Hono<AppEnv>()

auth.post('/login', vValidator('json', loginSchema), async (c) => {
  const body = c.req.valid('json')
  const result = await loginUser(body.email, body.password)
  return c.json(result)
})

auth.post('/register', vValidator('json', registerSchema), async (c) => {
  const body = c.req.valid('json')
  const result = await registerUser(body)
  return c.json(result, 201)
})

auth.post('/refresh', vValidator('json', refreshSchema), async (c) => {
  const { refreshToken } = c.req.valid('json')
  const result = await refreshTokens(refreshToken)
  return c.json(result)
})

auth.post('/forgot-password', vValidator('json', forgotPasswordSchema), async (c) => {
  return c.json({ message: 'Si el email existe, recibirás instrucciones.' })
})

auth.get('/me', authGuard, async (c) => {
  const userId = c.get('userId')
  const me = await getMe(userId)
  return c.json(me)
})

auth.patch('/me', authGuard, vValidator('json', updateProfileSchema), async (c) => {
  const userId = c.get('userId')
  const body = c.req.valid('json')
  const updated = await updateProfile(userId, body)
  return c.json(updated)
})

auth.post('/change-password', authGuard, vValidator('json', changePasswordSchema), async (c) => {
  const userId = c.get('userId')
  const body = c.req.valid('json')
  const result = await changePassword(userId, body.currentPassword, body.newPassword)
  return c.json(result)
})

export { auth }

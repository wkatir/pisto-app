import { Hono } from 'hono'
import { vValidator } from '@hono/valibot-validator'
import { loginSchema, registerSchema, refreshSchema } from './auth.schemas'
import { loginUser, registerUser, refreshTokens } from './auth.service'
import { AppError } from '../../shared/errors/app-error'

const auth = new Hono()

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

export { auth }

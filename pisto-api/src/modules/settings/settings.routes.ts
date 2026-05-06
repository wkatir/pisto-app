import { Hono } from 'hono'
import { vValidator } from '@hono/valibot-validator'
import type { AppEnv } from '../../types/app-env'
import { updateBusinessSchema, createTaxSchema, createPaymentMethodSchema, toggleActiveSchema } from './settings.schemas'
import * as settingsService from './settings.service'

const settings = new Hono<AppEnv>()

settings.get('/business', async (c) => {
  const businessId = c.get('businessId')
  const data = await settingsService.getBusiness(businessId)
  return c.json({ data })
})

settings.put('/business', vValidator('json', updateBusinessSchema), async (c) => {
  const businessId = c.get('businessId')
  const body = c.req.valid('json')
  const data = await settingsService.updateBusiness(businessId, body)
  return c.json({ data })
})

settings.get('/taxes', async (c) => {
  const businessId = c.get('businessId')
  const data = await settingsService.listTaxes(businessId)
  return c.json({ data })
})

settings.post('/taxes', vValidator('json', createTaxSchema), async (c) => {
  const businessId = c.get('businessId')
  const body = c.req.valid('json')
  const data = await settingsService.createTax(businessId, body)
  return c.json({ data }, 201)
})

settings.put('/taxes/:id/toggle', vValidator('json', toggleActiveSchema), async (c) => {
  const businessId = c.get('businessId')
  const { id } = c.req.param()
  const { isActive } = c.req.valid('json')
  const data = await settingsService.toggleTax(id, businessId, isActive)
  return c.json({ data })
})

settings.get('/payment-methods', async (c) => {
  const businessId = c.get('businessId')
  const data = await settingsService.listPaymentMethods(businessId)
  return c.json({ data })
})

settings.post('/payment-methods', vValidator('json', createPaymentMethodSchema), async (c) => {
  const businessId = c.get('businessId')
  const body = c.req.valid('json')
  const data = await settingsService.createPaymentMethod(businessId, body)
  return c.json({ data }, 201)
})

settings.put('/payment-methods/:id/toggle', vValidator('json', toggleActiveSchema), async (c) => {
  const businessId = c.get('businessId')
  const { id } = c.req.param()
  const { isActive } = c.req.valid('json')
  const data = await settingsService.togglePaymentMethod(id, businessId, isActive)
  return c.json({ data })
})

export { settings }

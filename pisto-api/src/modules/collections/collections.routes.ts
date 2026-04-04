import { Hono } from 'hono'
import { vValidator } from '@hono/valibot-validator'
import { createPaymentSchema } from './collections.schemas'
import * as receivableService from './receivable.service'
import * as paymentService from './payment.service'
import { AppError } from '../../shared/errors/app-error'
import type { AppEnv } from '../../types/app-env'

const collections = new Hono<AppEnv>()

collections.get('/receivables', async (c) => {
  const businessId = c.get('businessId')
  const page = parseInt(c.req.query('page') || '1')
  const limit = parseInt(c.req.query('limit') || '20')
  const result = await receivableService.listReceivables(businessId, page, limit)
  return c.json(result)
})

collections.get('/receivables/aging', async (c) => {
  const businessId = c.get('businessId')
  const report = await receivableService.getAgingReport(businessId)
  return c.json(report)
})

collections.get('/receivables/:id', async (c) => {
  const businessId = c.get('businessId')
  const id = c.req.param('id')
  try {
    const ar = await receivableService.getReceivable(businessId, id)
    return c.json(ar)
  } catch (e) {
    if (e instanceof AppError) return c.json({ error: e.message }, e.statusCode as 404)
    throw e
  }
})

collections.get('/receivables/:id/payments', async (c) => {
  const id = c.req.param('id')
  const payments = await receivableService.getReceivablePayments(id)
  return c.json(payments)
})

collections.post('/receivables/:id/payments', vValidator('json', createPaymentSchema), async (c) => {
  const businessId = c.get('businessId')
  const userId = c.get('userId')
  const id = c.req.param('id')
  const body = c.req.valid('json')
  try {
    const payment = await paymentService.createCollectionPayment(businessId, userId, id, body)
    return c.json(payment, 201)
  } catch (e) {
    if (e instanceof AppError) return c.json({ error: e.message }, e.statusCode as 400)
    throw e
  }
})

collections.get('/customers/:customerId/statement', async (c) => {
  const businessId = c.get('businessId')
  const customerId = c.req.param('customerId')
  const statement = await receivableService.getCustomerStatement(businessId, customerId)
  return c.json(statement)
})

export { collections }

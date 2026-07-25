import { Hono } from 'hono'
import { vValidator } from '@hono/valibot-validator'
import * as v from 'valibot'
import { createPaymentSchema } from './collections.schemas'
import * as receivableService from './receivable.service'
import * as paymentService from './payment.service'
import { intParam, paginationQuerySchema } from '../../shared/utils/pagination'
import { idParamSchema, idSchema } from '../../shared/schemas/common'
import { db } from '../../config/database'
import { collectionPayment } from '../../db/schema'
import { eq, desc } from 'drizzle-orm'
import type { AppEnv } from '../../types/app-env'

const collections = new Hono<AppEnv>()

const paymentsQuerySchema = v.object({ limit: v.optional(intParam(1, 200), '50') })

collections.get('/payments', vValidator('query', paymentsQuerySchema), async (c) => {
  const businessId = c.get('businessId')
  const { limit } = c.req.valid('query')
  const payments = await db.select().from(collectionPayment)
    .where(eq(collectionPayment.businessId, businessId))
    .orderBy(desc(collectionPayment.createdAt))
    .limit(limit)
  return c.json(payments)
})

collections.get('/aging', async (c) => {
  const businessId = c.get('businessId')
  const report = await receivableService.getAgingReport(businessId)
  return c.json(report)
})

collections.get('/receivables', vValidator('query', paginationQuerySchema), async (c) => {
  const businessId = c.get('businessId')
  const { page, limit } = c.req.valid('query')
  const result = await receivableService.listReceivables(businessId, page, limit)
  return c.json(result)
})

collections.get('/receivables/aging', async (c) => {
  const businessId = c.get('businessId')
  const report = await receivableService.getAgingReport(businessId)
  return c.json(report)
})

collections.get('/receivables/:id', vValidator('param', idParamSchema), async (c) => {
  const businessId = c.get('businessId')
  const { id } = c.req.valid('param')
  const ar = await receivableService.getReceivable(businessId, id)
  return c.json(ar)
})

collections.get('/receivables/:id/payments', vValidator('param', idParamSchema), async (c) => {
  const businessId = c.get('businessId')
  const { id } = c.req.valid('param')
  const payments = await receivableService.getReceivablePayments(businessId, id)
  return c.json(payments)
})

collections.post('/receivables/:id/payments', vValidator('param', idParamSchema), vValidator('json', createPaymentSchema), async (c) => {
  const businessId = c.get('businessId')
  const userId = c.get('userId')
  const { id } = c.req.valid('param')
  const body = c.req.valid('json')
  const payment = await paymentService.createCollectionPayment(businessId, userId, id, body)
  return c.json(payment, 201)
})

collections.get('/customers/:customerId/statement', vValidator('param', v.object({ customerId: idSchema })), async (c) => {
  const businessId = c.get('businessId')
  const { customerId } = c.req.valid('param')
  const statement = await receivableService.getCustomerStatement(businessId, customerId)
  return c.json(statement)
})

export { collections }

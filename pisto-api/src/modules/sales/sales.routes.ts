import { Hono } from 'hono'
import { vValidator } from '@hono/valibot-validator'
import { eq, and } from 'drizzle-orm'
import { createCustomerSchema, updateCustomerSchema, customerQuerySchema, createSaleSchema, creditNoteSchema } from './sales.schemas'
import * as customerService from './customer.service'
import * as invoiceService from './invoice.service'
import * as creditNoteService from './credit-note.service'
import { paginationQuerySchema } from '../../shared/schemas/pagination'
import { db } from '../../config/database'
import { paymentMethod, documentType, tax } from '../../db/schema'
import type { AppEnv } from '../../types/app-env'

const sales = new Hono<AppEnv>()

sales.get('/customers', vValidator('query', customerQuerySchema), async (c) => {
  const businessId = c.get('businessId')
  const query = c.req.valid('query')
  const result = await customerService.listCustomers(businessId, query)
  return c.json(result)
})

sales.get('/customers/:id', async (c) => {
  const businessId = c.get('businessId')
  const id = c.req.param('id')
  const customer = await customerService.getCustomer(businessId, id)
  return c.json(customer)
})

sales.post('/customers', vValidator('json', createCustomerSchema), async (c) => {
  const businessId = c.get('businessId')
  const body = c.req.valid('json')
  const customer = await customerService.createCustomer(businessId, body as any)
  return c.json(customer, 201)
})

sales.put('/customers/:id', vValidator('json', updateCustomerSchema), async (c) => {
  const businessId = c.get('businessId')
  const id = c.req.param('id')
  const body = c.req.valid('json')
  const customer = await customerService.updateCustomer(businessId, id, body as any)
  return c.json(customer)
})

sales.get('/invoices', vValidator('query', paginationQuerySchema), async (c) => {
  const businessId = c.get('businessId')
  const { page = 1, limit = 20 } = c.req.valid('query')
  const result = await invoiceService.listSales(businessId, page, limit)
  return c.json(result)
})

sales.get('/invoices/:id', async (c) => {
  const businessId = c.get('businessId')
  const id = c.req.param('id')
  const sale = await invoiceService.getSale(businessId, id)
  return c.json(sale)
})

sales.post('/invoices', vValidator('json', createSaleSchema), async (c) => {
  const businessId = c.get('businessId')
  const userId = c.get('userId')
  const body = c.req.valid('json')
  const sale = await invoiceService.createSale(businessId, userId, body)
  return c.json(sale, 201)
})

sales.post('/invoices/:id/cancel', async (c) => {
  const businessId = c.get('businessId')
  const userId = c.get('userId')
  const id = c.req.param('id')
  const result = await invoiceService.cancelSale(businessId, id, userId)
  return c.json(result)
})

sales.get('/credit-notes', vValidator('query', paginationQuerySchema), async (c) => {
  const businessId = c.get('businessId')
  const { page = 1, limit = 20 } = c.req.valid('query')
  const result = await creditNoteService.listCreditNotes(businessId, page, limit)
  return c.json(result)
})

sales.get('/credit-notes/:id', async (c) => {
  const businessId = c.get('businessId')
  const id = c.req.param('id')
  const note = await creditNoteService.getCreditNote(businessId, id)
  return c.json(note)
})

sales.post('/invoices/:id/credit-note', vValidator('json', creditNoteSchema), async (c) => {
  const businessId = c.get('businessId')
  const userId = c.get('userId')
  const saleId = c.req.param('id')
  const body = c.req.valid('json')
  const note = await creditNoteService.createCreditNote(businessId, userId, saleId, body)
  return c.json(note, 201)
})

sales.get('/payment-methods', async (c) => {
  const businessId = c.get('businessId')
  const result = await db.select().from(paymentMethod)
    .where(and(eq(paymentMethod.businessId, businessId), eq(paymentMethod.isActive, true)))
  return c.json({ data: result })
})

sales.get('/document-types', async (c) => {
  const businessId = c.get('businessId')
  const result = await db.select().from(documentType)
    .where(and(eq(documentType.businessId, businessId), eq(documentType.isActive, true)))
  return c.json({ data: result })
})

sales.get('/taxes', async (c) => {
  const businessId = c.get('businessId')
  const result = await db.select().from(tax)
    .where(and(eq(tax.businessId, businessId), eq(tax.isActive, true)))
  return c.json({ data: result })
})

export { sales }

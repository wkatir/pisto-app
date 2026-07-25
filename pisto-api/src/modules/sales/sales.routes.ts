import { Hono } from 'hono'
import { vValidator } from '@hono/valibot-validator'
import { createCustomerSchema, updateCustomerSchema, createSaleSchema, creditNoteSchema, invoiceQuerySchema } from './sales.schemas'
import * as customerService from './customer.service'
import * as invoiceService from './invoice.service'
import * as creditNoteService from './credit-note.service'
import { paginationQuerySchema } from '../../shared/utils/pagination'
import { idParamSchema } from '../../shared/schemas/common'
import { activeLookup } from '../../shared/utils/lookups'
import { paymentMethod, documentType, tax } from '../../db/schema'
import type { AppEnv } from '../../types/app-env'

const sales = new Hono<AppEnv>()

sales.get('/customers', vValidator('query', paginationQuerySchema), async (c) => {
  const businessId = c.get('businessId')
  const query = c.req.valid('query')
  const result = await customerService.listCustomers(businessId, query)
  return c.json(result)
})

sales.get('/customers/:id', vValidator('param', idParamSchema), async (c) => {
  const businessId = c.get('businessId')
  const { id } = c.req.valid('param')
  const customer = await customerService.getCustomer(businessId, id)
  return c.json(customer)
})

sales.post('/customers', vValidator('json', createCustomerSchema), async (c) => {
  const businessId = c.get('businessId')
  const body = c.req.valid('json')
  const customer = await customerService.createCustomer(businessId, body)
  return c.json(customer, 201)
})

sales.put('/customers/:id', vValidator('param', idParamSchema), vValidator('json', updateCustomerSchema), async (c) => {
  const businessId = c.get('businessId')
  const { id } = c.req.valid('param')
  const body = c.req.valid('json')
  const customer = await customerService.updateCustomer(businessId, id, body)
  return c.json(customer)
})

sales.get('/invoices', vValidator('query', invoiceQuerySchema), async (c) => {
  const businessId = c.get('businessId')
  const { page, limit, customerId } = c.req.valid('query')
  const result = await invoiceService.listSales(businessId, page, limit, customerId)
  return c.json(result)
})

sales.get('/invoices/:id', vValidator('param', idParamSchema), async (c) => {
  const businessId = c.get('businessId')
  const { id } = c.req.valid('param')
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

sales.post('/invoices/:id/cancel', vValidator('param', idParamSchema), async (c) => {
  const businessId = c.get('businessId')
  const userId = c.get('userId')
  const { id } = c.req.valid('param')
  const result = await invoiceService.cancelSale(businessId, id, userId)
  return c.json(result)
})

sales.get('/credit-notes', vValidator('query', paginationQuerySchema), async (c) => {
  const businessId = c.get('businessId')
  const { page, limit } = c.req.valid('query')
  const result = await creditNoteService.listCreditNotes(businessId, page, limit)
  return c.json(result)
})

sales.get('/credit-notes/:id', vValidator('param', idParamSchema), async (c) => {
  const businessId = c.get('businessId')
  const { id } = c.req.valid('param')
  const note = await creditNoteService.getCreditNote(businessId, id)
  return c.json(note)
})

sales.post('/invoices/:id/credit-note', vValidator('param', idParamSchema), vValidator('json', creditNoteSchema), async (c) => {
  const businessId = c.get('businessId')
  const userId = c.get('userId')
  const { id: saleId } = c.req.valid('param')
  const body = c.req.valid('json')
  const note = await creditNoteService.createCreditNote(businessId, userId, saleId, body)
  return c.json(note, 201)
})

sales.get('/payment-methods', async (c) => {
  return c.json({ data: await activeLookup(paymentMethod, c.get('businessId')) })
})

sales.get('/document-types', async (c) => {
  return c.json({ data: await activeLookup(documentType, c.get('businessId')) })
})

sales.get('/taxes', async (c) => {
  return c.json({ data: await activeLookup(tax, c.get('businessId')) })
})

export { sales }

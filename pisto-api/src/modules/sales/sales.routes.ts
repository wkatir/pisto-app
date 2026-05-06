import { Hono } from 'hono'
import { vValidator } from '@hono/valibot-validator'
import { createCustomerSchema, updateCustomerSchema, customerQuerySchema, createSaleSchema, creditNoteSchema } from './sales.schemas'
import * as customerService from './customer.service'
import * as invoiceService from './invoice.service'
import * as creditNoteService from './credit-note.service'
import { AppError } from '../../shared/errors/app-error'
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
  try {
    const customer = await customerService.getCustomer(businessId, id)
    return c.json(customer)
  } catch (e) {
    if (e instanceof AppError) return c.json({ error: e.message }, e.statusCode as 404)
    throw e
  }
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
  try {
    const customer = await customerService.updateCustomer(businessId, id, body as any)
    return c.json(customer)
  } catch (e) {
    if (e instanceof AppError) return c.json({ error: e.message }, e.statusCode as 404)
    throw e
  }
})

sales.get('/invoices', async (c) => {
  const businessId = c.get('businessId')
  const page = parseInt(c.req.query('page') || '1')
  const limit = parseInt(c.req.query('limit') || '20')
  const result = await invoiceService.listSales(businessId, page, limit)
  return c.json(result)
})

sales.get('/invoices/:id', async (c) => {
  const businessId = c.get('businessId')
  const id = c.req.param('id')
  try {
    const sale = await invoiceService.getSale(businessId, id)
    return c.json(sale)
  } catch (e) {
    if (e instanceof AppError) return c.json({ error: e.message }, e.statusCode as 404)
    throw e
  }
})

sales.post('/invoices', vValidator('json', createSaleSchema), async (c) => {
  const businessId = c.get('businessId')
  const userId = c.get('userId')
  const body = c.req.valid('json')
  try {
    const sale = await invoiceService.createSale(businessId, userId, body)
    return c.json(sale, 201)
  } catch (e) {
    if (e instanceof AppError) return c.json({ error: e.message }, e.statusCode as 400)
    throw e
  }
})

sales.post('/invoices/:id/cancel', async (c) => {
  const businessId = c.get('businessId')
  const userId = c.get('userId')
  const id = c.req.param('id')
  try {
    const result = await invoiceService.cancelSale(businessId, id, userId)
    return c.json(result)
  } catch (e) {
    if (e instanceof AppError) return c.json({ error: e.message }, e.statusCode as 400)
    throw e
  }
})

sales.get('/credit-notes', async (c) => {
  const businessId = c.get('businessId')
  const page = parseInt(c.req.query('page') || '1')
  const limit = parseInt(c.req.query('limit') || '20')
  const result = await creditNoteService.listCreditNotes(businessId, page, limit)
  return c.json(result)
})

sales.get('/credit-notes/:id', async (c) => {
  const businessId = c.get('businessId')
  const id = c.req.param('id')
  try {
    const note = await creditNoteService.getCreditNote(businessId, id)
    return c.json(note)
  } catch (e) {
    if (e instanceof AppError) return c.json({ error: e.message }, e.statusCode as 404)
    throw e
  }
})

sales.post('/invoices/:id/credit-note', vValidator('json', creditNoteSchema), async (c) => {
  const businessId = c.get('businessId')
  const userId = c.get('userId')
  const saleId = c.req.param('id')
  const body = c.req.valid('json')
  try {
    const note = await creditNoteService.createCreditNote(businessId, userId, saleId, body)
    return c.json(note, 201)
  } catch (e) {
    if (e instanceof AppError) return c.json({ error: e.message }, e.statusCode as 400)
    throw e
  }
})

export { sales }

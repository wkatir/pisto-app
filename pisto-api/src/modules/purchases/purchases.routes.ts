import { Hono } from 'hono'
import { vValidator } from '@hono/valibot-validator'
import { createSupplierSchema, updateSupplierSchema, createPurchaseOrderSchema, receiveGoodsSchema, supplierPaymentSchema } from './purchases.schemas'
import * as supplierService from './supplier.service'
import * as poService from './purchase-order.service'
import * as grService from './goods-receipt.service'
import * as payableService from './payable.service'
import { AppError } from '../../shared/errors/app-error'
import type { AppEnv } from '../../types/app-env'

const purchases = new Hono<AppEnv>()

purchases.get('/suppliers', async (c) => {
  const businessId = c.get('businessId')
  const suppliers = await supplierService.listSuppliers(businessId)
  return c.json(suppliers)
})

purchases.get('/suppliers/:id', async (c) => {
  const businessId = c.get('businessId')
  const id = c.req.param('id')
  try {
    const s = await supplierService.getSupplier(businessId, id)
    return c.json(s)
  } catch (e) {
    if (e instanceof AppError) return c.json({ error: e.message }, e.statusCode as 404)
    throw e
  }
})

purchases.post('/suppliers', vValidator('json', createSupplierSchema), async (c) => {
  const businessId = c.get('businessId')
  const body = c.req.valid('json')
  const s = await supplierService.createSupplier(businessId, body)
  return c.json(s, 201)
})

purchases.put('/suppliers/:id', vValidator('json', updateSupplierSchema), async (c) => {
  const businessId = c.get('businessId')
  const id = c.req.param('id')
  const body = c.req.valid('json')
  try {
    const s = await supplierService.updateSupplier(businessId, id, body)
    return c.json(s)
  } catch (e) {
    if (e instanceof AppError) return c.json({ error: e.message }, e.statusCode as 404)
    throw e
  }
})

purchases.delete('/suppliers/:id', async (c) => {
  const businessId = c.get('businessId')
  const id = c.req.param('id')
  try {
    await supplierService.deleteSupplier(businessId, id)
    return c.json({ success: true })
  } catch (e) {
    if (e instanceof AppError) return c.json({ error: e.message }, e.statusCode as 404)
    throw e
  }
})

purchases.get('/supplier-products', async (c) => {
  const businessId = c.get('businessId')
  const supplierId = c.req.query('supplierId')
  const products = await supplierService.listSupplierProducts(businessId, supplierId)
  return c.json(products)
})

purchases.post('/supplier-products', async (c) => {
  const businessId = c.get('businessId')
  const body = await c.req.json()
  try {
    const sp = await supplierService.createSupplierProduct(businessId, body)
    return c.json(sp, 201)
  } catch (e) {
    if (e instanceof AppError) return c.json({ error: e.message }, e.statusCode as 400)
    throw e
  }
})

purchases.put('/supplier-products/:id', async (c) => {
  const businessId = c.get('businessId')
  const id = c.req.param('id')
  const body = await c.req.json()
  try {
    const sp = await supplierService.updateSupplierProduct(businessId, id, body)
    return c.json(sp)
  } catch (e) {
    if (e instanceof AppError) return c.json({ error: e.message }, e.statusCode as 400)
    throw e
  }
})

purchases.delete('/supplier-products/:id', async (c) => {
  const businessId = c.get('businessId')
  const id = c.req.param('id')
  try {
    await supplierService.deleteSupplierProduct(businessId, id)
    return c.json({ success: true })
  } catch (e) {
    if (e instanceof AppError) return c.json({ error: e.message }, e.statusCode as 404)
    throw e
  }
})

purchases.get('/orders', async (c) => {
  const businessId = c.get('businessId')
  const page = parseInt(c.req.query('page') || '1')
  const limit = parseInt(c.req.query('limit') || '20')
  const result = await poService.listPurchaseOrders(businessId, page, limit)
  return c.json(result)
})

purchases.get('/orders/:id', async (c) => {
  const businessId = c.get('businessId')
  const id = c.req.param('id')
  try {
    const po = await poService.getPurchaseOrder(businessId, id)
    return c.json(po)
  } catch (e) {
    if (e instanceof AppError) return c.json({ error: e.message }, e.statusCode as 404)
    throw e
  }
})

purchases.post('/orders', vValidator('json', createPurchaseOrderSchema), async (c) => {
  const businessId = c.get('businessId')
  const userId = c.get('userId')
  const body = c.req.valid('json')
  try {
    const po = await poService.createPurchaseOrder(businessId, userId, body)
    return c.json(po, 201)
  } catch (e) {
    if (e instanceof AppError) return c.json({ error: e.message }, e.statusCode as 400)
    throw e
  }
})

purchases.put('/orders/:id', async (c) => {
  const businessId = c.get('businessId')
  const id = c.req.param('id')
  const body = await c.req.json()
  try {
    const po = await poService.updatePurchaseOrder(businessId, id, body)
    return c.json(po)
  } catch (e) {
    if (e instanceof AppError) return c.json({ error: e.message }, e.statusCode as 400)
    throw e
  }
})

purchases.post('/orders/:id/receive', vValidator('json', receiveGoodsSchema), async (c) => {
  const businessId = c.get('businessId')
  const userId = c.get('userId')
  const id = c.req.param('id')
  const body = c.req.valid('json')
  try {
    const receipt = await grService.receiveGoods(businessId, userId, id, body)
    return c.json(receipt, 201)
  } catch (e) {
    if (e instanceof AppError) return c.json({ error: e.message }, e.statusCode as 400)
    throw e
  }
})

purchases.get('/payables', async (c) => {
  const businessId = c.get('businessId')
  const page = parseInt(c.req.query('page') || '1')
  const limit = parseInt(c.req.query('limit') || '20')
  const result = await payableService.listPayables(businessId, page, limit)
  return c.json(result)
})

purchases.post('/payables/:id/payments', vValidator('json', supplierPaymentSchema), async (c) => {
  const businessId = c.get('businessId')
  const userId = c.get('userId')
  const id = c.req.param('id')
  const body = c.req.valid('json')
  try {
    const payment = await payableService.createSupplierPayment(businessId, userId, id, body)
    return c.json(payment, 201)
  } catch (e) {
    if (e instanceof AppError) return c.json({ error: e.message }, e.statusCode as 400)
    throw e
  }
})

export { purchases }

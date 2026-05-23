import { Hono } from 'hono'
import { vValidator } from '@hono/valibot-validator'
import { createSupplierSchema, updateSupplierSchema, createSupplierProductSchema, updateSupplierProductSchema, createPurchaseOrderSchema, receiveGoodsSchema, supplierPaymentSchema } from './purchases.schemas'
import * as supplierService from './supplier.service'
import * as poService from './purchase-order.service'
import * as grService from './goods-receipt.service'
import * as payableService from './payable.service'
import { paginationQuerySchema } from '../../shared/schemas/pagination'
import { db } from '../../config/database'
import { goodsReceipt, purchaseOrder } from '../../db/schema'
import { eq, desc } from 'drizzle-orm'
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
  const s = await supplierService.getSupplier(businessId, id)
  return c.json(s)
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
  const s = await supplierService.updateSupplier(businessId, id, body)
  return c.json(s)
})

purchases.delete('/suppliers/:id', async (c) => {
  const businessId = c.get('businessId')
  const id = c.req.param('id')
  await supplierService.deleteSupplier(businessId, id)
  return c.json({ success: true })
})

purchases.get('/supplier-products', async (c) => {
  const businessId = c.get('businessId')
  const supplierId = c.req.query('supplierId')
  const products = await supplierService.listSupplierProducts(businessId, supplierId)
  return c.json(products)
})

purchases.post('/supplier-products', vValidator('json', createSupplierProductSchema), async (c) => {
  const businessId = c.get('businessId')
  const body = c.req.valid('json')
  const sp = await supplierService.createSupplierProduct(businessId, body)
  return c.json(sp, 201)
})

purchases.put('/supplier-products/:id', vValidator('json', updateSupplierProductSchema), async (c) => {
  const businessId = c.get('businessId')
  const id = c.req.param('id')
  const body = c.req.valid('json')
  const sp = await supplierService.updateSupplierProduct(businessId, id, body)
  return c.json(sp)
})

purchases.delete('/supplier-products/:id', async (c) => {
  const businessId = c.get('businessId')
  const id = c.req.param('id')
  await supplierService.deleteSupplierProduct(businessId, id)
  return c.json({ success: true })
})

purchases.get('/orders', vValidator('query', paginationQuerySchema), async (c) => {
  const businessId = c.get('businessId')
  const { page = 1, limit = 20 } = c.req.valid('query')
  const result = await poService.listPurchaseOrders(businessId, page, limit)
  return c.json(result)
})

purchases.get('/orders/:id', async (c) => {
  const businessId = c.get('businessId')
  const id = c.req.param('id')
  const po = await poService.getPurchaseOrder(businessId, id)
  return c.json(po)
})

purchases.post('/orders', vValidator('json', createPurchaseOrderSchema), async (c) => {
  const businessId = c.get('businessId')
  const userId = c.get('userId')
  const body = c.req.valid('json')
  const po = await poService.createPurchaseOrder(businessId, userId, body)
  return c.json(po, 201)
})

purchases.put('/orders/:id', async (c) => {
  const businessId = c.get('businessId')
  const id = c.req.param('id')
  const body = await c.req.json()
  const po = await poService.updatePurchaseOrder(businessId, id, body)
  return c.json(po)
})

purchases.post('/orders/:id/receive', vValidator('json', receiveGoodsSchema), async (c) => {
  const businessId = c.get('businessId')
  const userId = c.get('userId')
  const id = c.req.param('id')
  const body = c.req.valid('json')
  const receipt = await grService.receiveGoods(businessId, userId, id, body)
  return c.json(receipt, 201)
})

purchases.get('/receipts', vValidator('query', paginationQuerySchema), async (c) => {
  const businessId = c.get('businessId')
  const { page = 1, limit = 20 } = c.req.valid('query')
  const offset = (page - 1) * limit
  const receipts = await db.select({
    receipt: goodsReceipt,
    orderNumber: purchaseOrder.orderNumber,
  })
    .from(goodsReceipt)
    .leftJoin(purchaseOrder, eq(goodsReceipt.purchaseOrderId, purchaseOrder.id))
    .where(eq(purchaseOrder.businessId, businessId))
    .orderBy(desc(goodsReceipt.createdAt))
    .offset(offset)
    .limit(limit)
  return c.json(receipts)
})

purchases.get('/payables', vValidator('query', paginationQuerySchema), async (c) => {
  const businessId = c.get('businessId')
  const { page = 1, limit = 20 } = c.req.valid('query')
  const result = await payableService.listPayables(businessId, page, limit)
  return c.json(result)
})

purchases.post('/payables/:id/payments', vValidator('json', supplierPaymentSchema), async (c) => {
  const businessId = c.get('businessId')
  const userId = c.get('userId')
  const id = c.req.param('id')
  const body = c.req.valid('json')
  const payment = await payableService.createSupplierPayment(businessId, userId, id, body)
  return c.json(payment, 201)
})

export { purchases }

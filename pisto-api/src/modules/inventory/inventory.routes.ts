import { Hono } from 'hono'
import { vValidator } from '@hono/valibot-validator'
import {
  createCategorySchema, updateCategorySchema,
  createWarehouseSchema, updateWarehouseSchema,
  createProductSchema, updateProductSchema, productQuerySchema,
  adjustmentSchema, createTransferSchema,
} from './inventory.schemas'
import * as catService from './category.service'
import * as whService from './warehouse.service'
import * as prodService from './product.service'
import * as movService from './movement.service'
import * as transService from './transfer.service'
import { AppError } from '../../shared/errors/app-error'
import { unitOfMeasure } from '../../db/schema'
import { db } from '../../config/database'
import type { AppEnv } from '../../types/app-env'

const inventory = new Hono<AppEnv>()

inventory.get('/units', async (c) => {
  const units = await db.select().from(unitOfMeasure)
  return c.json(units)
})

inventory.get('/categories', async (c) => {
  const businessId = c.get('businessId')
  const categories = await catService.listCategories(businessId)
  return c.json(categories)
})

inventory.post('/categories', vValidator('json', createCategorySchema), async (c) => {
  const businessId = c.get('businessId')
  const body = c.req.valid('json')
  const cat = await catService.createCategory(businessId, body)
  return c.json(cat, 201)
})

inventory.put('/categories/:id', vValidator('json', updateCategorySchema), async (c) => {
  const businessId = c.get('businessId')
  const id = parseInt(c.req.param('id'))
  const body = c.req.valid('json')
  const cat = await catService.updateCategory(businessId, id, body)
  return c.json(cat)
})

inventory.delete('/categories/:id', async (c) => {
  const businessId = c.get('businessId')
  const id = parseInt(c.req.param('id'))
  await catService.deleteCategory(businessId, id)
  return c.json({ message: 'Categoría eliminada' })
})

inventory.get('/warehouses', async (c) => {
  const businessId = c.get('businessId')
  const warehouses = await whService.listWarehouses(businessId)
  return c.json(warehouses)
})

inventory.post('/warehouses', vValidator('json', createWarehouseSchema), async (c) => {
  const businessId = c.get('businessId')
  const body = c.req.valid('json')
  const wh = await whService.createWarehouse(businessId, body)
  return c.json(wh, 201)
})

inventory.put('/warehouses/:id', vValidator('json', updateWarehouseSchema), async (c) => {
  const businessId = c.get('businessId')
  const id = parseInt(c.req.param('id'))
  const body = c.req.valid('json')
  const wh = await whService.updateWarehouse(businessId, id, body)
  return c.json(wh)
})

inventory.delete('/warehouses/:id', async (c) => {
  const businessId = c.get('businessId')
  const id = parseInt(c.req.param('id'))
  await whService.deleteWarehouse(businessId, id)
  return c.json({ message: 'Bodega eliminada' })
})

inventory.get('/products', vValidator('query', productQuerySchema), async (c) => {
  const businessId = c.get('businessId')
  const query = c.req.valid('query')
  const result = await prodService.listProducts(businessId, query)
  return c.json(result)
})

inventory.get('/products/:id', async (c) => {
  const businessId = c.get('businessId')
  const id = c.req.param('id')
  try {
    const p = await prodService.getProduct(businessId, id)
    return c.json(p)
  } catch (e) {
    if (e instanceof AppError) return c.json({ error: e.message }, e.statusCode as 404)
    throw e
  }
})

inventory.post('/products', vValidator('json', createProductSchema), async (c) => {
  const businessId = c.get('businessId')
  const body = c.req.valid('json')
  const p = await prodService.createProduct(businessId, body)
  return c.json(p, 201)
})

inventory.put('/products/:id', vValidator('json', updateProductSchema), async (c) => {
  const businessId = c.get('businessId')
  const id = c.req.param('id')
  const body = c.req.valid('json')
  try {
    const p = await prodService.updateProduct(businessId, id, body)
    return c.json(p)
  } catch (e) {
    if (e instanceof AppError) return c.json({ error: e.message }, e.statusCode as 404)
    throw e
  }
})

inventory.delete('/products/:id', async (c) => {
  const businessId = c.get('businessId')
  const id = c.req.param('id')
  try {
    await prodService.deleteProduct(businessId, id)
    return c.json({ message: 'Producto eliminado' })
  } catch (e) {
    if (e instanceof AppError) return c.json({ error: e.message }, e.statusCode as 404)
    throw e
  }
})

inventory.get('/products/:id/movements', async (c) => {
  const id = c.req.param('id')
  const movements = await movService.getProductMovements(id)
  return c.json(movements)
})

inventory.post('/adjustments', vValidator('json', adjustmentSchema), async (c) => {
  const businessId = c.get('businessId')
  const userId = c.get('userId')
  const body = c.req.valid('json')
  try {
    const movement = await movService.createAdjustment(businessId, userId, body)
    return c.json(movement, 201)
  } catch (e) {
    if (e instanceof AppError) return c.json({ error: e.message }, e.statusCode as 404)
    throw e
  }
})

inventory.get('/transfers', async (c) => {
  const businessId = c.get('businessId')
  const transfers = await transService.listTransfers(businessId)
  return c.json(transfers)
})

inventory.post('/transfers', vValidator('json', createTransferSchema), async (c) => {
  const businessId = c.get('businessId')
  const userId = c.get('userId')
  const body = c.req.valid('json')
  try {
    const transfer = await transService.createTransfer(businessId, userId, body)
    return c.json(transfer, 201)
  } catch (e) {
    if (e instanceof AppError) return c.json({ error: e.message }, e.statusCode as 400)
    throw e
  }
})

inventory.get('/transfers/:id', async (c) => {
  const businessId = c.get('businessId')
  const id = c.req.param('id')
  try {
    const transfer = await transService.getTransfer(businessId, id)
    return c.json(transfer)
  } catch (e) {
    if (e instanceof AppError) return c.json({ error: e.message }, e.statusCode as 404)
    throw e
  }
})

inventory.get('/alerts', async (c) => {
  const businessId = c.get('businessId')
  const alerts = await prodService.getLowStockAlerts(businessId)
  return c.json(alerts)
})

export { inventory }

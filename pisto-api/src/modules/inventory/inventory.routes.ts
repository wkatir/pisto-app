import { Hono } from 'hono'
import { vValidator } from '@hono/valibot-validator'
import * as v from 'valibot'
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
import { intParam } from '../../shared/utils/pagination'
import { idParamSchema } from '../../shared/schemas/common'
import { unitOfMeasure } from '../../db/schema'
import { db } from '../../config/database'
import type { AppEnv } from '../../types/app-env'

const inventory = new Hono<AppEnv>()

const movementsQuerySchema = v.object({ limit: v.optional(intParam(1, 500), '100') })

inventory.get('/units', async (c) => {
  const units = await db.select().from(unitOfMeasure)
  return c.json({ data: units })
})

inventory.get('/categories', async (c) => {
  const businessId = c.get('businessId')
  const categories = await catService.listCategories(businessId)
  return c.json({ data: categories })
})

inventory.post('/categories', vValidator('json', createCategorySchema), async (c) => {
  const businessId = c.get('businessId')
  const body = c.req.valid('json')
  const cat = await catService.createCategory(businessId, body)
  return c.json(cat, 201)
})

inventory.put('/categories/:id', vValidator('param', idParamSchema), vValidator('json', updateCategorySchema), async (c) => {
  const businessId = c.get('businessId')
  const { id } = c.req.valid('param')
  const body = c.req.valid('json')
  const cat = await catService.updateCategory(businessId, id, body)
  return c.json(cat)
})

inventory.delete('/categories/:id', vValidator('param', idParamSchema), async (c) => {
  const businessId = c.get('businessId')
  const { id } = c.req.valid('param')
  await catService.deleteCategory(businessId, id)
  return c.json({ message: 'Categoría eliminada' })
})

inventory.get('/warehouses', async (c) => {
  const businessId = c.get('businessId')
  const warehouses = await whService.listWarehouses(businessId)
  return c.json({ data: warehouses })
})

inventory.post('/warehouses', vValidator('json', createWarehouseSchema), async (c) => {
  const businessId = c.get('businessId')
  const body = c.req.valid('json')
  const wh = await whService.createWarehouse(businessId, body)
  return c.json(wh, 201)
})

inventory.put('/warehouses/:id', vValidator('param', idParamSchema), vValidator('json', updateWarehouseSchema), async (c) => {
  const businessId = c.get('businessId')
  const { id } = c.req.valid('param')
  const body = c.req.valid('json')
  const wh = await whService.updateWarehouse(businessId, id, body)
  return c.json(wh)
})

inventory.delete('/warehouses/:id', vValidator('param', idParamSchema), async (c) => {
  const businessId = c.get('businessId')
  const { id } = c.req.valid('param')
  await whService.deleteWarehouse(businessId, id)
  return c.json({ message: 'Bodega eliminada' })
})

inventory.get('/products', vValidator('query', productQuerySchema), async (c) => {
  const businessId = c.get('businessId')
  const query = c.req.valid('query')
  const result = await prodService.listProducts(businessId, query)
  return c.json(result)
})

inventory.get('/products/:id', vValidator('param', idParamSchema), async (c) => {
  const businessId = c.get('businessId')
  const { id } = c.req.valid('param')
  const p = await prodService.getProduct(businessId, id)
  return c.json(p)
})

inventory.post('/products', vValidator('json', createProductSchema), async (c) => {
  const businessId = c.get('businessId')
  const body = c.req.valid('json')
  const p = await prodService.createProduct(businessId, body)
  return c.json(p, 201)
})

inventory.put('/products/:id', vValidator('param', idParamSchema), vValidator('json', updateProductSchema), async (c) => {
  const businessId = c.get('businessId')
  const { id } = c.req.valid('param')
  const body = c.req.valid('json')
  const p = await prodService.updateProduct(businessId, id, body)
  return c.json(p)
})

inventory.delete('/products/:id', vValidator('param', idParamSchema), async (c) => {
  const businessId = c.get('businessId')
  const { id } = c.req.valid('param')
  await prodService.deleteProduct(businessId, id)
  return c.json({ message: 'Producto eliminado' })
})

inventory.get('/movements', vValidator('query', movementsQuerySchema), async (c) => {
  const businessId = c.get('businessId')
  const { limit } = c.req.valid('query')
  const movements = await movService.listMovements(businessId, limit)
  return c.json(movements)
})

inventory.get('/products/:id/movements', vValidator('param', idParamSchema), async (c) => {
  const businessId = c.get('businessId')
  const { id } = c.req.valid('param')
  const movements = await movService.getProductMovements(id, businessId)
  return c.json(movements)
})

inventory.post('/adjustments', vValidator('json', adjustmentSchema), async (c) => {
  const businessId = c.get('businessId')
  const userId = c.get('userId')
  const body = c.req.valid('json')
  const movement = await movService.createAdjustment(businessId, userId, body)
  return c.json(movement, 201)
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
  const transfer = await transService.createTransfer(businessId, userId, body)
  return c.json(transfer, 201)
})

inventory.get('/transfers/:id', vValidator('param', idParamSchema), async (c) => {
  const businessId = c.get('businessId')
  const { id } = c.req.valid('param')
  const transfer = await transService.getTransfer(businessId, id)
  return c.json(transfer)
})

inventory.get('/alerts', async (c) => {
  const businessId = c.get('businessId')
  const alerts = await prodService.getLowStockAlerts(businessId)
  return c.json(alerts)
})

export { inventory }

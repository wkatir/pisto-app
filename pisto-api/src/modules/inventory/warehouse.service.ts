import { eq, and } from 'drizzle-orm'
import { db } from '../../config/database'
import { warehouse } from '../../db/schema'
import { AppError } from '../../shared/errors/app-error'

export async function listWarehouses(businessId: string) {
  return db.select().from(warehouse)
    .where(and(eq(warehouse.businessId, businessId), eq(warehouse.isActive, true)))
}

export async function createWarehouse(businessId: string, data: { name: string; address?: string }) {
  const [wh] = await db.insert(warehouse).values({ businessId, ...data }).returning()
  return wh
}

export async function updateWarehouse(businessId: string, id: string, data: { name?: string; address?: string }) {
  const [updated] = await db.update(warehouse)
    .set(data)
    .where(and(eq(warehouse.id, id), eq(warehouse.businessId, businessId)))
  if (!updated) throw new AppError(404, 'Bodega no encontrada')
  return updated
}

export async function deleteWarehouse(businessId: string, id: string) {
  const [updated] = await db.update(warehouse)
    .set({ isActive: false })
    .where(and(eq(warehouse.id, id), eq(warehouse.businessId, businessId)))
    .returning()
  if (!updated) throw new AppError(404, 'Bodega no encontrada')
  return updated
}
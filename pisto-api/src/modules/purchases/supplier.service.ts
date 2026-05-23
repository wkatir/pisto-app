import { eq, and } from 'drizzle-orm'
import { db } from '../../config/database'
import { supplier, supplierProduct } from '../../db/schema'
import { AppError } from '../../shared/errors/app-error'

export async function listSuppliers(businessId: string) {
  return db.select().from(supplier)
    .where(and(eq(supplier.businessId, businessId), eq(supplier.isActive, true)))
}

export async function getSupplier(businessId: string, id: string) {
  const [s] = await db.select().from(supplier)
    .where(and(eq(supplier.id, id), eq(supplier.businessId, businessId)))
  if (!s) throw new AppError(404, 'Proveedor no encontrado')
  return s
}

export async function createSupplier(businessId: string, data: Record<string, unknown>) {
  const [s] = await db.insert(supplier).values({ businessId, ...data } as any).returning()
  return s
}

export async function updateSupplier(businessId: string, id: string, data: Record<string, unknown>) {
  const [updated] = await db.update(supplier)
    .set({ ...data, updatedAt: new Date() } as any)
    .where(and(eq(supplier.id, id), eq(supplier.businessId, businessId)))
  if (!updated) throw new AppError(404, 'Proveedor no encontrado')
  return updated
}

export async function deleteSupplier(businessId: string, id: string) {
  const [deleted] = await db.update(supplier)
    .set({ isActive: false, updatedAt: new Date() })
    .where(and(eq(supplier.id, id), eq(supplier.businessId, businessId)))
    .returning()
  if (!deleted) throw new AppError(404, 'Proveedor no encontrado')
  return deleted
}

export async function listSupplierProducts(businessId: string, supplierId?: string) {
  let query = db.select().from(supplierProduct)
  if (supplierId) {
    return db.select().from(supplierProduct)
      .innerJoin(supplier, eq(supplierProduct.supplierId, supplier.id))
      .where(eq(supplier.businessId, businessId))
  }
  return query
}

export async function createSupplierProduct(_businessId: string, data: Record<string, unknown>) {
  const [sp] = await db.insert(supplierProduct).values(data as any).returning()
  return sp
}

export async function updateSupplierProduct(_businessId: string, id: string, data: Record<string, unknown>) {
  const [updated] = await db.update(supplierProduct)
    .set(data as any)
    .where(eq(supplierProduct.id, id))
    .returning()
  if (!updated) throw new AppError(404, 'Producto de proveedor no encontrado')
  return updated
}

export async function deleteSupplierProduct(_businessId: string, id: string) {
  const [deleted] = await db.delete(supplierProduct)
    .where(eq(supplierProduct.id, id))
    .returning()
  if (!deleted) throw new AppError(404, 'Producto de proveedor no encontrado')
  return deleted
}
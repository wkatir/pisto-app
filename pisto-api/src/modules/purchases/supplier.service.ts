import { eq, and } from 'drizzle-orm'
import { db } from '../../config/database'
import { supplier, supplierProduct } from '../../db/schema'
import { AppError } from '../../shared/errors/app-error'
import { crudService } from '../../shared/crud'

const suppliers = crudService(supplier, {
  notFoundMessage: 'Proveedor no encontrado',
})

export const listSuppliers = suppliers.listAll
export const getSupplier = suppliers.getById
export const createSupplier = suppliers.create
export const updateSupplier = suppliers.update
export const deleteSupplier = suppliers.softDelete

type SupplierProductInsert = Omit<typeof supplierProduct.$inferInsert, 'id'>

export async function listSupplierProducts(businessId: string, supplierId?: string) {
  const conditions = [eq(supplier.businessId, businessId)]
  if (supplierId) conditions.push(eq(supplierProduct.supplierId, supplierId))
  const rows = await db.select({ supplierProduct })
    .from(supplierProduct)
    .innerJoin(supplier, eq(supplierProduct.supplierId, supplier.id))
    .where(and(...conditions))
  return rows.map((r) => r.supplierProduct)
}

async function assertSupplierProductOwned(businessId: string, id: string) {
  const [row] = await db.select({ id: supplierProduct.id })
    .from(supplierProduct)
    .innerJoin(supplier, eq(supplierProduct.supplierId, supplier.id))
    .where(and(eq(supplierProduct.id, id), eq(supplier.businessId, businessId)))
  if (!row) throw new AppError(404, 'Producto de proveedor no encontrado')
}

export async function createSupplierProduct(businessId: string, data: SupplierProductInsert) {
  await getSupplier(businessId, data.supplierId)
  const [sp] = await db.insert(supplierProduct).values(data).returning()
  return sp
}

export async function updateSupplierProduct(businessId: string, id: string, data: Partial<SupplierProductInsert>) {
  await assertSupplierProductOwned(businessId, id)
  const [updated] = await db.update(supplierProduct)
    .set(data)
    .where(eq(supplierProduct.id, id))
    .returning()
  return updated
}

export async function deleteSupplierProduct(businessId: string, id: string) {
  await assertSupplierProductOwned(businessId, id)
  const [deleted] = await db.delete(supplierProduct)
    .where(eq(supplierProduct.id, id))
    .returning()
  return deleted
}

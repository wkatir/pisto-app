import { eq, and } from 'drizzle-orm'
import { db } from '../../config/database'
import { productCategory } from '../../db/schema'
import { AppError } from '../../shared/errors/app-error'

export async function listCategories(businessId: string) {
  return db.select().from(productCategory)
    .where(and(
      eq(productCategory.businessId, businessId),
      eq(productCategory.isActive, true),
    ))
}

export async function createCategory(businessId: string, data: { name: string; parentId?: string; description?: string }) {
  const [category] = await db.insert(productCategory)
    .values({ businessId, ...data })
    .returning()
  return category
}

export async function updateCategory(businessId: string, id: string, data: { name?: string; parentId?: string; description?: string }) {
  const [updated] = await db.update(productCategory)
    .set(data)
    .where(and(eq(productCategory.id, id), eq(productCategory.businessId, businessId)))
  if (!updated) throw new AppError(404, 'Categoría no encontrada')
  return updated
}

export async function deleteCategory(businessId: string, id: string) {
  const [updated] = await db.update(productCategory)
    .set({ isActive: false })
    .where(and(eq(productCategory.id, id), eq(productCategory.businessId, businessId)))
    .returning()
  if (!updated) throw new AppError(404, 'Categoría no encontrada')
  return updated
}
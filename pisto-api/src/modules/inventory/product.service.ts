import { eq, and, like, sql, count } from 'drizzle-orm'
import { db } from '../../config/database'
import { product, productStock, productCategory, unitOfMeasure } from '../../db/schema'
import { AppError } from '../../shared/errors/app-error'

interface ProductQuery {
  page: number
  limit: number
  search?: string
  categoryId?: number
  isActive?: boolean
  warehouseId?: number
}

export async function listProducts(businessId: string, query: ProductQuery) {
  const { page, limit, search, categoryId, isActive } = query
  const offset = (page - 1) * limit

  const conditions = [eq(product.businessId, businessId)]
  if (categoryId) conditions.push(eq(product.categoryId, categoryId))
  if (isActive !== undefined) conditions.push(eq(product.isActive, isActive))
  if (search) conditions.push(like(product.name, `%${search}%`))

  const where = and(...conditions)

  const [items, [total]] = await Promise.all([
    db.select({
      id: product.id,
      sku: product.sku,
      barcode: product.barcode,
      name: product.name,
      costPrice: product.costPrice,
      salePrice: product.salePrice,
      minStock: product.minStock,
      isService: product.isService,
      isTaxable: product.isTaxable,
      isActive: product.isActive,
      imageUrl: product.imageUrl,
      categoryName: productCategory.name,
      unitCode: unitOfMeasure.code,
      totalStock: sql<string>`COALESCE(SUM(${productStock.quantity}), 0)`,
    })
      .from(product)
      .leftJoin(productCategory, eq(product.categoryId, productCategory.id))
      .leftJoin(unitOfMeasure, eq(product.unitId, unitOfMeasure.id))
      .leftJoin(productStock, eq(product.id, productStock.productId))
      .where(where)
      .groupBy(product.id, productCategory.name, unitOfMeasure.code)
      .limit(limit)
      .offset(offset),
    db.select({ count: count() }).from(product).where(where),
  ])

  return {
    data: items,
    pagination: { page, limit, total: total!.count, pages: Math.ceil(total!.count / limit) },
  }
}

export async function getProduct(businessId: string, id: string) {
  const [p] = await db.select()
    .from(product)
    .where(and(eq(product.id, id), eq(product.businessId, businessId)))
    .limit(1)

  if (!p) throw new AppError(404, 'Producto no encontrado')

  const stocks = await db.select().from(productStock).where(eq(productStock.productId, id))

  return { ...p, stocks }
}

export async function createProduct(businessId: string, data: {
  categoryId?: number; unitId: number; sku?: string; barcode?: string
  name: string; description?: string; costPrice?: string; salePrice: string
  minStock?: string; maxStock?: string; isService?: boolean; isTaxable?: boolean
  imageUrl?: string
}) {
  const [p] = await db.insert(product).values({ businessId, ...data }).returning()
  return p
}

export async function updateProduct(businessId: string, id: string, data: Record<string, unknown>) {
  const [updated] = await db.update(product)
    .set({ ...data, updatedAt: new Date() })
    .where(and(eq(product.id, id), eq(product.businessId, businessId)))
    .returning()
  if (!updated) throw new AppError(404, 'Producto no encontrado')
  return updated
}

export async function deleteProduct(businessId: string, id: string) {
  const [updated] = await db.update(product)
    .set({ isActive: false, updatedAt: new Date() })
    .where(and(eq(product.id, id), eq(product.businessId, businessId)))
    .returning()
  if (!updated) throw new AppError(404, 'Producto no encontrado')
  return updated
}

export async function getLowStockAlerts(businessId: string) {
  return db.select({
    productId: product.id,
    productName: product.name,
    sku: product.sku,
    minStock: product.minStock,
    totalStock: sql<string>`COALESCE(SUM(${productStock.quantity}), 0)`,
  })
    .from(product)
    .leftJoin(productStock, eq(product.id, productStock.productId))
    .where(and(
      eq(product.businessId, businessId),
      eq(product.isActive, true),
      eq(product.isService, false),
    ))
    .groupBy(product.id)
    .having(sql`COALESCE(SUM(${productStock.quantity}), 0) <= ${product.minStock}`)
}

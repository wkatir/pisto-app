import { eq, and, desc, sql } from 'drizzle-orm'
import { db } from '../../config/database'
import { inventoryMovement, productStock, product } from '../../db/schema'
import { AppError } from '../../shared/errors/app-error'

export async function listMovements(businessId: string, limit = 100) {
  return db.select({
    movement: inventoryMovement,
    productName: product.name,
    sku: product.sku,
  })
    .from(inventoryMovement)
    .leftJoin(product, eq(inventoryMovement.productId, product.id))
    .where(eq(product.businessId, businessId))
    .orderBy(desc(inventoryMovement.createdAt))
    .offset(0)
    .limit(limit)
}

export async function getProductMovements(productId: string, businessId: string, limit = 50) {
  const [p] = await db.select({ id: product.id }).from(product)
    .where(and(eq(product.id, productId), eq(product.businessId, businessId)))
  if (!p) throw new AppError(404, 'Producto no encontrado')

  return db.select().from(inventoryMovement)
    .where(eq(inventoryMovement.productId, productId))
    .orderBy(desc(inventoryMovement.createdAt))
    .offset(0)
    .limit(limit)
}

export async function createAdjustment(
  businessId: string,
  userId: string,
  data: {
    productId: string
    warehouseId: string
    type: 'adjustment_in' | 'adjustment_out'
    quantity: string
    unitCost?: string
    notes?: string
  }
) {
  const [p] = await db.select({ id: product.id }).from(product)
    .where(and(eq(product.id, data.productId), eq(product.businessId, businessId)))
  if (!p) throw new AppError(404, 'Producto no encontrado')

  const qty = parseFloat(data.quantity)
  const delta = data.type === 'adjustment_in' ? qty : -qty

  return db.transaction(async (tx) => {
    const [movement] = await tx.insert(inventoryMovement)
      .values({
        productId: data.productId,
        warehouseId: data.warehouseId,
        movementType: data.type,
        quantity: data.quantity,
        unitCost: data.unitCost,
        notes: data.notes,
        createdBy: userId,
      })
      .returning()

    await upsertStock(tx, data.productId, data.warehouseId, delta)

    return movement
  })
}

export async function updateStock(
  tx: Parameters<Parameters<typeof db.transaction>[0]>[0],
  productId: string,
  warehouseId: string,
  delta: number,
  movementType: 'purchase_in' | 'sale_out' | 'return_in' | 'return_out' | 'transfer_in' | 'transfer_out',
  userId: string,
  unitCost?: string,
  referenceType?: string,
  referenceId?: string,
) {
  await tx.insert(inventoryMovement).values({
    productId,
    warehouseId,
    movementType,
    quantity: Math.abs(delta).toFixed(2),
    unitCost,
    referenceType,
    referenceId,
    createdBy: userId,
  })

  await upsertStock(tx, productId, warehouseId, delta)
}

async function upsertStock(
  tx: Parameters<Parameters<typeof db.transaction>[0]>[0],
  productId: string,
  warehouseId: string,
  delta: number,
) {
  const [existing] = await tx.select({ qty: productStock.quantity })
    .from(productStock)
    .where(and(
      eq(productStock.productId, productId),
      eq(productStock.warehouseId, warehouseId),
    ))

  if (existing) {
    await tx.update(productStock)
      .set({
        quantity: sql`${productStock.quantity} + ${delta}`,
        updatedAt: new Date(),
      })
      .where(and(
        eq(productStock.productId, productId),
        eq(productStock.warehouseId, warehouseId),
      ))
  } else {
    await tx.insert(productStock).values({
      productId,
      warehouseId,
      quantity: delta.toFixed(2),
    })
  }
}

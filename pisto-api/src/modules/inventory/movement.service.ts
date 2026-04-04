import { eq, and, desc, sql } from 'drizzle-orm'
import { db } from '../../config/database'
import { inventoryMovement, product } from '../../db/schema'
import { AppError } from '../../shared/errors/app-error'

export async function getProductMovements(productId: string, limit = 50) {
  return db.select()
    .from(inventoryMovement)
    .where(eq(inventoryMovement.productId, productId))
    .orderBy(desc(inventoryMovement.createdAt))
    .limit(limit)
}

export async function createAdjustment(
  businessId: string,
  userId: string,
  data: {
    productId: string
    warehouseId: number
    type: 'adjustment_in' | 'adjustment_out'
    quantity: string
    unitCost?: string
    notes?: string
  }
) {
  // Verify product belongs to business
  const [p] = await db.select({ id: product.id })
    .from(product)
    .where(and(eq(product.id, data.productId), eq(product.businessId, businessId)))

  if (!p) throw new AppError(404, 'Producto no encontrado')

  const qty = parseFloat(data.quantity)
  const delta = data.type === 'adjustment_in' ? qty : -qty

  return db.transaction(async (tx) => {
    // Create movement
    const [movement] = await tx.insert(inventoryMovement).values({
      productId: data.productId,
      warehouseId: data.warehouseId,
      movementType: data.type,
      quantity: data.quantity,
      unitCost: data.unitCost,
      notes: data.notes,
      createdBy: userId,
    }).returning()

    // Upsert stock
    await tx.execute(sql`
      INSERT INTO product_stock (product_id, warehouse_id, quantity)
      VALUES (${data.productId}, ${data.warehouseId}, ${delta})
      ON CONFLICT (product_id, warehouse_id)
      DO UPDATE SET quantity = product_stock.quantity + ${delta}, updated_at = NOW()
    `)

    return movement
  })
}

export async function updateStock(
  tx: Parameters<Parameters<typeof db.transaction>[0]>[0],
  productId: string,
  warehouseId: number,
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
    quantity: Math.abs(delta).toString(),
    unitCost,
    referenceType,
    referenceId,
    createdBy: userId,
  })

  await tx.execute(sql`
    INSERT INTO product_stock (product_id, warehouse_id, quantity)
    VALUES (${productId}, ${warehouseId}, ${delta})
    ON CONFLICT (product_id, warehouse_id)
    DO UPDATE SET quantity = product_stock.quantity + ${delta}, updated_at = NOW()
  `)
}

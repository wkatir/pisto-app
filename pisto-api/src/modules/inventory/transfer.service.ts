import { eq, and } from 'drizzle-orm'
import { db } from '../../config/database'
import { inventoryTransfer, inventoryTransferLine } from '../../db/schema'
import { updateStock } from './movement.service'
import { AppError } from '../../shared/errors/app-error'

export async function listTransfers(businessId: string) {
  return db.select()
    .from(inventoryTransfer)
    .where(eq(inventoryTransfer.businessId, businessId))
}

export async function createTransfer(
  businessId: string,
  userId: string,
  data: {
    fromWarehouseId: number
    toWarehouseId: number
    notes?: string
    lines: { productId: string; quantity: string }[]
  }
) {
  if (data.fromWarehouseId === data.toWarehouseId) {
    throw new AppError(400, 'Bodega origen y destino no pueden ser la misma')
  }

  return db.transaction(async (tx) => {
    const [transfer] = await tx.insert(inventoryTransfer).values({
      businessId,
      fromWarehouseId: data.fromWarehouseId,
      toWarehouseId: data.toWarehouseId,
      notes: data.notes,
      createdBy: userId,
      status: 'completed',
      completedAt: new Date(),
    }).returning()

    for (const line of data.lines) {
      await tx.insert(inventoryTransferLine).values({
        transferId: transfer!.id,
        productId: line.productId,
        quantity: line.quantity,
      })

      const qty = parseFloat(line.quantity)

      // Out from source
      await updateStock(tx, line.productId, data.fromWarehouseId, -qty, 'transfer_out', userId, undefined, 'transfer', transfer!.id)

      // In to destination
      await updateStock(tx, line.productId, data.toWarehouseId, qty, 'transfer_in', userId, undefined, 'transfer', transfer!.id)
    }

    return transfer
  })
}

export async function getTransfer(businessId: string, id: string) {
  const [transfer] = await db.select()
    .from(inventoryTransfer)
    .where(and(eq(inventoryTransfer.id, id), eq(inventoryTransfer.businessId, businessId)))

  if (!transfer) throw new AppError(404, 'Transferencia no encontrada')

  const lines = await db.select()
    .from(inventoryTransferLine)
    .where(eq(inventoryTransferLine.transferId, id))

  return { ...transfer, lines }
}

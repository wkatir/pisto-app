import { eq, and } from 'drizzle-orm'
import { db } from '../../config/database'
import { purchaseOrder, purchaseOrderLine, goodsReceipt, goodsReceiptLine, accountPayable } from '../../db/schema'
import { updateStock } from '../inventory/movement.service'
import { generateCorrelative } from '../../shared/utils/correlative'
import { AppError } from '../../shared/errors/app-error'
import Decimal from 'decimal.js'

interface ReceiptLineInput {
  purchaseOrderLineId: string; productId: string; quantityReceived: string
}

export async function receiveGoods(
  businessId: string,
  userId: string,
  purchaseOrderId: string,
  data: { notes?: string; lines: ReceiptLineInput[] }
) {
  const [po] = await db.select().from(purchaseOrder)
    .where(and(eq(purchaseOrder.id, purchaseOrderId), eq(purchaseOrder.businessId, businessId)))
  if (!po) throw new AppError(404, 'Orden de compra no encontrada')
  if (po.status === 'cancelled') throw new AppError(400, 'Orden cancelada')

  const receiptNumber = await generateCorrelative(businessId, 'REC-C', 'goods_receipt')

  return db.transaction(async (tx) => {
    const [receipt] = await tx.insert(goodsReceipt).values({
      purchaseOrderId,
      receiptNumber,
      notes: data.notes,
      receivedBy: userId,
    } as any).returning()

    let allReceived = true

    for (const line of data.lines) {
      await tx.insert(goodsReceiptLine).values({
        goodsReceiptId: receipt!.id,
        purchaseOrderLineId: line.purchaseOrderLineId,
        productId: line.productId,
        quantityReceived: line.quantityReceived,
      } as any)

      const [poLine] = await (tx.select().from(purchaseOrderLine)
        .where(eq(purchaseOrderLine.id, line.purchaseOrderLineId))) as any[]

      if (poLine) {
        const newReceived = new Decimal(poLine.quantityReceived).plus(new Decimal(line.quantityReceived))
        await (tx.update(purchaseOrderLine) as any)
          .set({ quantityReceived: parseFloat(newReceived.toFixed(2)) })
          .where(eq(purchaseOrderLine.id, line.purchaseOrderLineId))

        if (newReceived.lt(new Decimal(poLine.quantityOrdered))) {
          allReceived = false
        }

        await updateStock(
          tx, line.productId, po.warehouseId,
          parseFloat(line.quantityReceived), 'purchase_in',
          userId, String(poLine.unitCost), 'purchase_order', purchaseOrderId
        )
      }
    }

    const newStatus = allReceived ? 'received' : 'partial'
    await tx.update(purchaseOrder)
      .set({ status: newStatus })
      .where(eq(purchaseOrder.id, purchaseOrderId))

    if (allReceived) {
      const dueDate = new Date()
      dueDate.setDate(dueDate.getDate() + 30) // Default 30 days

      await tx.insert(accountPayable).values({
        businessId,
        supplierId: po.supplierId!,
        purchaseOrderId,
        originalAmount: po.total!,
        balance: po.total!,
        dueDate: dueDate.toISOString().split('T')[0],
      } as any)
    }

    return receipt
  })
}

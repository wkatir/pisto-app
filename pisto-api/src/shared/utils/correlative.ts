import { db } from '../../config/database'
import { sale, creditNote, purchaseOrder, collectionPayment, goodsReceipt } from '../../db/schema'
import { eq, sql } from 'drizzle-orm'

type TableName = 'sale' | 'credit_note' | 'purchase_order' | 'collection_payment' | 'goods_receipt'

export async function generateCorrelative(
  businessId: string,
  prefix: string,
  table: TableName,
): Promise<string> {
  const year = new Date().getFullYear()
  const pattern = `${prefix}-${year}-%`
  const result = await getMaxNumber(businessId, table, pattern)
  const lastNumber = result?.[0]?.maxNumber
  let nextSeq = 1

  if (lastNumber != null) {
    const parts = lastNumber.split('-')
    const lastSeq = parseInt(parts[parts.length - 1] ?? '0', 10)
    nextSeq = lastSeq + 1
  }

  return `${prefix}-${year}-${String(nextSeq).padStart(6, '0')}`
}

async function getMaxNumber(businessId: string, table: TableName, _pattern: string) {
  switch (table) {
    case 'sale':
      return db
        .select({ maxNumber: sql<string | null>`MAX(${sale.saleNumber})` })
        .from(sale)
        .where(eq(sale.businessId, businessId))
    case 'credit_note':
      return db
        .select({ maxNumber: sql<string | null>`MAX(${creditNote.noteNumber})` })
        .from(creditNote)
        .where(eq(creditNote.businessId, businessId))
    case 'purchase_order':
      return db
        .select({ maxNumber: sql<string | null>`MAX(${purchaseOrder.orderNumber})` })
        .from(purchaseOrder)
        .where(eq(purchaseOrder.businessId, businessId))
    case 'collection_payment':
      return db
        .select({ maxNumber: sql<string | null>`MAX(${collectionPayment.receiptNumber})` })
        .from(collectionPayment)
        .where(eq(collectionPayment.businessId, businessId))
    case 'goods_receipt':
      return db
        .select({ maxNumber: sql<string | null>`MAX(${goodsReceipt.receiptNumber})` })
        .from(goodsReceipt)
        .innerJoin(purchaseOrder, eq(goodsReceipt.purchaseOrderId, purchaseOrder.id))
        .where(eq(purchaseOrder.businessId, businessId))
    default:
      return [{ maxNumber: null }]
  }
}

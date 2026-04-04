import { sql } from 'drizzle-orm'
import { db } from '../../config/database'

export async function generateCorrelative(
  businessId: string,
  prefix: string,
  tableName: 'sale' | 'credit_note' | 'purchase_order' | 'collection_payment' | 'goods_receipt',
  numberField: string,
): Promise<string> {
  const year = new Date().getFullYear()
  const pattern = `${prefix}-${year}-%`

  const result = await db.execute<{ max_number: string | null }>(
    sql`SELECT MAX(${sql.raw(numberField)}) as max_number FROM ${sql.raw(tableName)} WHERE business_id = ${businessId} AND ${sql.raw(numberField)} LIKE ${pattern}`,
  )

  const lastNumber = result[0]?.max_number
  let nextSeq = 1

  if (lastNumber != null) {
    const parts = lastNumber.split('-')
    const lastSeq = parseInt(parts[parts.length - 1] ?? '0', 10)
    nextSeq = lastSeq + 1
  }

  return `${prefix}-${year}-${String(nextSeq).padStart(6, '0')}`
}

import { eq, and } from 'drizzle-orm'
import { db } from '../../config/database'
import { accountReceivable, collectionPayment } from '../../db/schema'
import { generateCorrelative } from '../../shared/utils/correlative'
import { AppError } from '../../shared/errors/app-error'
import Decimal from 'decimal.js'

export async function createCollectionPayment(
  businessId: string,
  userId: string,
  receivableId: string,
  data: { paymentMethodId: number; amount: string; reference?: string; notes?: string }
) {
  const [ar] = await db.select().from(accountReceivable)
    .where(and(eq(accountReceivable.id, receivableId), eq(accountReceivable.businessId, businessId)))
  if (!ar) throw new AppError(404, 'Cuenta por cobrar no encontrada')
  if (ar.status === 'paid') throw new AppError(400, 'Cuenta ya pagada')

  const payAmount = new Decimal(data.amount)
  const currentBalance = new Decimal(ar.balance)

  if (payAmount.gt(currentBalance)) {
    throw new AppError(400, 'Monto excede el saldo pendiente')
  }

  const receiptNumber = await generateCorrelative(businessId, 'REC', 'collection_payment', 'receipt_number')

  return db.transaction(async (tx) => {
    const [payment] = await tx.insert(collectionPayment).values({
      businessId,
      accountReceivableId: receivableId,
      paymentMethodId: data.paymentMethodId,
      receiptNumber,
      amount: data.amount,
      reference: data.reference,
      notes: data.notes,
      collectedBy: userId,
    }).returning()

    const newBalance = currentBalance.minus(payAmount)
    await tx.update(accountReceivable).set({
      balance: newBalance.toFixed(2),
      status: newBalance.lte(0) ? 'paid' : 'pending',
      updatedAt: new Date(),
    }).where(eq(accountReceivable.id, receivableId))

    return payment
  })
}

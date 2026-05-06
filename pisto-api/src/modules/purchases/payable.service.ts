import { eq, and, desc, count } from 'drizzle-orm'
import { db } from '../../config/database'
import { accountPayable, supplierPayment, supplier } from '../../db/schema'
import { AppError } from '../../shared/errors/app-error'
import { paginatedResponse } from '../../shared/utils/pagination'
import Decimal from 'decimal.js'

export async function listPayables(businessId: string, page = 1, limit = 20) {
  const offset = (page - 1) * limit
  const where = eq(accountPayable.businessId, businessId)

  const [items, [total]] = await Promise.all([
    db.select({
      payable: accountPayable,
      supplierName: supplier.companyName,
    })
      .from(accountPayable)
      .leftJoin(supplier, eq(accountPayable.supplierId, supplier.id))
      .where(where)
      .orderBy(desc(accountPayable.createdAt))
      .offset(offset).fetch(limit),
    db.select({ count: count() }).from(accountPayable).where(where),
  ])

  return paginatedResponse(items, total!.count, { page, limit, sortOrder: 'desc' as const })
}

export async function createSupplierPayment(
  businessId: string,
  userId: string,
  payableId: string,
  data: { paymentMethodId: number; amount: string; reference?: string; notes?: string }
) {
  const [ap] = await db.select().from(accountPayable)
    .where(and(eq(accountPayable.id, payableId), eq(accountPayable.businessId, businessId)))
  if (!ap) throw new AppError(404, 'Cuenta por pagar no encontrada')
  if (ap.status === 'paid') throw new AppError(400, 'Cuenta ya pagada')

  const payAmount = new Decimal(data.amount)
  const currentBalance = new Decimal(ap.balance)

  if (payAmount.gt(currentBalance)) {
    throw new AppError(400, 'Monto excede el saldo pendiente')
  }

  return db.transaction(async (tx) => {
    const [payment] = await tx.insert(supplierPayment).output().values({
      businessId,
      accountPayableId: payableId,
      paymentMethodId: data.paymentMethodId,
      amount: data.amount,
      reference: data.reference,
      notes: data.notes,
      paidBy: userId,
    } as any)

    const newBalance = currentBalance.minus(payAmount)
    await tx.update(accountPayable).set({
      balance: parseFloat(newBalance.toFixed(2)),
      status: newBalance.lte(0) ? 'paid' : 'pending',
      updatedAt: new Date(),
    } as any).where(eq(accountPayable.id, payableId))

    return payment
  })
}

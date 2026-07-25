import { eq, and, desc, count } from 'drizzle-orm'
import { db } from '../../config/database'
import { sale, creditNote, creditNoteLine, accountReceivable } from '../../db/schema'
import { updateStock } from '../inventory/movement.service'
import { generateCorrelative } from '../../shared/utils/correlative'
import { AppError } from '../../shared/errors/app-error'
import { paginatedResponse } from '../../shared/utils/pagination'
import Decimal from 'decimal.js'

interface CreditNoteLineInput {
  productId: string; quantity: string; unitPrice: string
}

export async function createCreditNote(
  businessId: string,
  userId: string,
  saleId: string,
  data: { reason: string; lines: CreditNoteLineInput[] }
) {
  const [s] = await db.select().from(sale)
    .where(and(eq(sale.id, saleId), eq(sale.businessId, businessId)))
  if (!s) throw new AppError(404, 'Venta no encontrada')
  if (s.status === 'cancelled') throw new AppError(400, 'Venta cancelada, no se puede crear nota de crédito')
  if (!s.customerId) throw new AppError(400, 'Venta sin cliente, no se puede crear nota de crédito')

  const noteNumber = await generateCorrelative(businessId, 'NC', 'credit_note')

  return db.transaction(async (tx) => {
    let total = new Decimal(0)
    const lineData: { productId: string; quantity: string; unitPrice: string; lineTotal: string }[] = []

    for (const line of data.lines) {
      const qty = new Decimal(line.quantity)
      const price = new Decimal(line.unitPrice)
      const lineTotal = qty.mul(price)
      total = total.plus(lineTotal)
      lineData.push({
        productId: line.productId,
        quantity: line.quantity,
        unitPrice: line.unitPrice,
        lineTotal: lineTotal.toFixed(2),
      })
    }

    const [note] = await tx.insert(creditNote)
      .values({
        businessId,
        saleId,
        customerId: s.customerId!,
        noteNumber,
        reason: data.reason,
        total: total.toFixed(2),
        createdBy: userId,
      })
      .returning()

    for (const line of lineData) {
      await tx.insert(creditNoteLine).values({
        creditNoteId: note!.id,
        productId: line.productId,
        quantity: line.quantity,
        unitPrice: line.unitPrice,
        lineTotal: line.lineTotal,
      })

      await updateStock(tx, line.productId, s.warehouseId, parseFloat(line.quantity), 'return_in', userId, line.unitPrice, 'credit_note', note!.id)
    }

    if (s.paymentStatus === 'credit') {
      const [ar] = await tx.select().from(accountReceivable)
        .where(eq(accountReceivable.saleId, saleId))
      if (ar) {
        const newBalance = new Decimal(ar.balance).minus(total)
        await tx.update(accountReceivable).set({
          balance: newBalance.lte(0) ? '0.00' : newBalance.toFixed(2),
          status: newBalance.lte(0) ? 'paid' : 'pending',
          updatedAt: new Date(),
        }).where(eq(accountReceivable.id, ar.id))
      }
    }

    return note
  })
}

export async function listCreditNotes(businessId: string, page = 1, limit = 20) {
  const offset = (page - 1) * limit
  const [items, [total]] = await Promise.all([
    db.select().from(creditNote)
      .where(eq(creditNote.businessId, businessId))
      .orderBy(desc(creditNote.createdAt))
      .offset(offset).limit(limit),
    db.select({ count: count() }).from(creditNote).where(eq(creditNote.businessId, businessId)),
  ])
  return paginatedResponse(items, total!.count, page, limit)
}

export async function getCreditNote(businessId: string, id: string) {
  const [note] = await db.select().from(creditNote)
    .where(and(eq(creditNote.id, id), eq(creditNote.businessId, businessId)))
  if (!note) throw new AppError(404, 'Nota de crédito no encontrada')

  const lines = await db.select().from(creditNoteLine).where(eq(creditNoteLine.creditNoteId, id))
  return { ...note, lines }
}

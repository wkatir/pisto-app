import { eq, and, desc, count } from 'drizzle-orm'
import { db } from '../../config/database'
import { sale, saleLine, saleLineTax, salePayment, accountReceivable, tax } from '../../db/schema'
import { updateStock } from '../inventory/movement.service'
import { generateCorrelative } from '../../shared/utils/correlative'
import { AppError } from '../../shared/errors/app-error'
import Decimal from 'decimal.js'

interface SaleLineInput {
  productId: string; quantity: string; unitPrice: string
  discountPct?: string; taxId?: number
}

interface PaymentInput {
  paymentMethodId: number; amount: string; reference?: string
}

export async function createSale(
  businessId: string,
  userId: string,
  data: {
    customerId?: string; documentTypeId: number; warehouseId: number
    dueDate?: string; notes?: string; paymentStatus?: string
    lines: SaleLineInput[]; payments?: PaymentInput[]
  }
) {
  const saleNumber = await generateCorrelative(businessId, 'FAC', 'sale', 'sale_number')

  return db.transaction(async (tx) => {
    let subtotal = new Decimal(0)
    let totalTax = new Decimal(0)
    let totalDiscount = new Decimal(0)

    // Calculate line totals
    const lineData = []
    for (const line of data.lines) {
      const qty = new Decimal(line.quantity)
      const price = new Decimal(line.unitPrice)
      const discPct = new Decimal(line.discountPct || '0')
      const lineSubtotal = qty.mul(price)
      const discAmount = lineSubtotal.mul(discPct).div(100)
      const afterDiscount = lineSubtotal.minus(discAmount)

      let lineTaxAmount = new Decimal(0)
      let taxRate = new Decimal(0)

      if (line.taxId) {
        const [t] = await tx.select().from(tax).where(eq(tax.id, line.taxId))
        if (t) {
          taxRate = new Decimal(t.rate)
          lineTaxAmount = afterDiscount.mul(taxRate)
        }
      }

      const lineTotal = afterDiscount.plus(lineTaxAmount)

      lineData.push({
        productId: line.productId,
        quantity: line.quantity,
        unitPrice: line.unitPrice,
        discountPct: discPct.toString(),
        discountAmount: discAmount.toFixed(2),
        taxId: line.taxId,
        taxAmount: lineTaxAmount.toFixed(2),
        lineTotal: lineTotal.toFixed(2),
        taxRate,
        afterDiscount,
      })

      subtotal = subtotal.plus(lineSubtotal)
      totalDiscount = totalDiscount.plus(discAmount)
      totalTax = totalTax.plus(lineTaxAmount)
    }

    const total = subtotal.minus(totalDiscount).plus(totalTax)
    const paymentStatus = data.paymentStatus || 'paid'

    // Create sale
    const [newSale] = await tx.insert(sale).values({
      businessId,
      customerId: data.customerId,
      documentTypeId: data.documentTypeId,
      warehouseId: data.warehouseId,
      saleNumber,
      dueDate: data.dueDate,
      paymentStatus,
      subtotal: subtotal.toFixed(2),
      taxAmount: totalTax.toFixed(2),
      discountAmount: totalDiscount.toFixed(2),
      total: total.toFixed(2),
      notes: data.notes,
      createdBy: userId,
    }).returning()

    // Insert lines + deduct stock
    for (const line of lineData) {
      const [sl] = await tx.insert(saleLine).values({
        saleId: newSale!.id,
        productId: line.productId,
        quantity: line.quantity,
        unitPrice: line.unitPrice,
        discountPct: line.discountPct,
        discountAmount: line.discountAmount,
        taxId: line.taxId,
        taxAmount: line.taxAmount,
        lineTotal: line.lineTotal,
      }).returning()

      // Tax detail
      if (line.taxId) {
        await tx.insert(saleLineTax).values({
          saleLineId: sl!.id,
          taxId: line.taxId,
          taxBase: line.afterDiscount.toFixed(2),
          taxAmount: line.taxAmount,
        })
      }

      // Deduct stock
      await updateStock(tx, line.productId, data.warehouseId, -parseFloat(line.quantity), 'sale_out', userId, line.unitPrice, 'sale', newSale!.id)
    }

    // Payments (if paid)
    if (data.payments && paymentStatus === 'paid') {
      for (const pay of data.payments) {
        await tx.insert(salePayment).values({
          saleId: newSale!.id,
          paymentMethodId: pay.paymentMethodId,
          amount: pay.amount,
          reference: pay.reference,
        })
      }
    }

    // CxC (if credit)
    if (paymentStatus === 'credit' && data.customerId) {
      await tx.insert(accountReceivable).values({
        businessId,
        customerId: data.customerId!,
        saleId: newSale!.id,
        originalAmount: total.toFixed(2),
        balance: total.toFixed(2),
        dueDate: data.dueDate || new Date().toISOString().split('T')[0],
      } as typeof accountReceivable.$inferInsert)
    }

    return newSale!
  })
}

export async function listSales(businessId: string, page = 1, limit = 20) {
  const offset = (page - 1) * limit
  const [items, [total]] = await Promise.all([
    db.select().from(sale)
      .where(eq(sale.businessId, businessId))
      .orderBy(desc(sale.createdAt))
      .limit(limit).offset(offset),
    db.select({ count: count() }).from(sale).where(eq(sale.businessId, businessId)),
  ])
  return {
    data: items,
    pagination: { page, limit, total: total!.count, pages: Math.ceil(total!.count / limit) },
  }
}

export async function getSale(businessId: string, id: string) {
  const [s] = await db.select().from(sale)
    .where(and(eq(sale.id, id), eq(sale.businessId, businessId)))
  if (!s) throw new AppError(404, 'Venta no encontrada')

  const lines = await db.select().from(saleLine).where(eq(saleLine.saleId, id))
  const payments = await db.select().from(salePayment).where(eq(salePayment.saleId, id))

  return { ...s, lines, payments }
}

export async function cancelSale(businessId: string, saleId: string, userId: string) {
  const [s] = await db.select().from(sale)
    .where(and(eq(sale.id, saleId), eq(sale.businessId, businessId)))
  if (!s) throw new AppError(404, 'Venta no encontrada')
  if (s.status === 'cancelled') throw new AppError(400, 'Venta ya cancelada')

  return db.transaction(async (tx) => {
    await tx.update(sale).set({
      status: 'cancelled',
      cancelledAt: new Date(),
      cancelledBy: userId,
    }).where(eq(sale.id, saleId))

    // Return stock
    const lines = await tx.select().from(saleLine).where(eq(saleLine.saleId, saleId))
    for (const line of lines) {
      await updateStock(tx, line.productId, s.warehouseId, parseFloat(line.quantity), 'return_in', userId, line.unitPrice, 'sale_cancel', saleId)
    }

    return { message: 'Venta cancelada' }
  })
}

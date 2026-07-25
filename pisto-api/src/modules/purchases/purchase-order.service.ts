import { eq, and, desc, count } from 'drizzle-orm'
import { db } from '../../config/database'
import { purchaseOrder, purchaseOrderLine, tax, warehouse } from '../../db/schema'
import { generateCorrelative } from '../../shared/utils/correlative'
import { AppError } from '../../shared/errors/app-error'
import { paginatedResponse } from '../../shared/utils/pagination'
import Decimal from 'decimal.js'

interface POLineInput {
  productId: string; quantityOrdered: string; unitCost: string; taxId?: string
}

export async function createPurchaseOrder(
  businessId: string,
  userId: string,
  data: {
    supplierId: string; warehouseId?: string
    expectedDate?: string; notes?: string
    lines?: POLineInput[]
  }
) {
  const orderNumber = await generateCorrelative(businessId, 'OC', 'purchase_order')

  let resolvedWarehouseId = data.warehouseId
  if (!resolvedWarehouseId) {
    const [firstWh] = await db.select({ id: warehouse.id }).from(warehouse)
      .where(eq(warehouse.businessId, businessId))
    if (!firstWh) throw new AppError(400, 'No hay bodegas configuradas para este negocio')
    resolvedWarehouseId = firstWh.id
  }
  const lines = data.lines ?? []

  return db.transaction(async (tx) => {
    let subtotal = new Decimal(0)
    let totalTax = new Decimal(0)

    const lineData: {
      productId: string; quantityOrdered: string; unitCost: string
      taxId?: string; taxAmount: string; lineTotal: string
    }[] = []

    for (const line of lines) {
      const qty = new Decimal(line.quantityOrdered)
      const cost = new Decimal(line.unitCost)
      const lineSubtotal = qty.mul(cost)

      let lineTaxAmount = new Decimal(0)
      if (line.taxId) {
        const [t] = await tx.select().from(tax).where(eq(tax.id, line.taxId))
        if (t) lineTaxAmount = lineSubtotal.mul(new Decimal(t.rate))
      }

      const lineTotal = lineSubtotal.plus(lineTaxAmount)
      lineData.push({
        productId: line.productId,
        quantityOrdered: line.quantityOrdered,
        unitCost: line.unitCost,
        taxId: line.taxId,
        taxAmount: lineTaxAmount.toFixed(2),
        lineTotal: lineTotal.toFixed(2),
      })

      subtotal = subtotal.plus(lineSubtotal)
      totalTax = totalTax.plus(lineTaxAmount)
    }

    const total = subtotal.plus(totalTax)

    const [po] = await tx.insert(purchaseOrder).values({
      businessId,
      supplierId: data.supplierId,
      warehouseId: resolvedWarehouseId,
      orderNumber,
      expectedDate: data.expectedDate,
      status: 'approved',
      subtotal: subtotal.toFixed(2),
      taxAmount: totalTax.toFixed(2),
      total: total.toFixed(2),
      notes: data.notes,
      createdBy: userId,
    }).returning()

    for (const line of lineData) {
      await tx.insert(purchaseOrderLine).values({
        purchaseOrderId: po!.id,
        productId: line.productId,
        quantityOrdered: line.quantityOrdered,
        unitCost: line.unitCost,
        taxId: line.taxId,
        taxAmount: line.taxAmount,
        lineTotal: line.lineTotal,
      })
    }

    return po
  })
}

export async function listPurchaseOrders(businessId: string, page = 1, limit = 20) {
  const offset = (page - 1) * limit
  const [items, [total]] = await Promise.all([
    db.select().from(purchaseOrder)
      .where(eq(purchaseOrder.businessId, businessId))
      .orderBy(desc(purchaseOrder.createdAt))
      .offset(offset).limit(limit),
    db.select({ count: count() }).from(purchaseOrder).where(eq(purchaseOrder.businessId, businessId)),
  ])
  return paginatedResponse(items, total!.count, page, limit)
}

export async function getPurchaseOrder(businessId: string, id: string) {
  const [po] = await db.select().from(purchaseOrder)
    .where(and(eq(purchaseOrder.id, id), eq(purchaseOrder.businessId, businessId)))
  if (!po) throw new AppError(404, 'Orden de compra no encontrada')

  const lines = await db.select().from(purchaseOrderLine)
    .where(eq(purchaseOrderLine.purchaseOrderId, id))

  return { ...po, lines }
}

export async function updatePurchaseOrder(businessId: string, id: string, data: Record<string, unknown>) {
  const [po] = await db.select().from(purchaseOrder)
    .where(and(eq(purchaseOrder.id, id), eq(purchaseOrder.businessId, businessId)))
  if (!po) throw new AppError(404, 'Orden de compra no encontrada')
  if (po.status === 'received') throw new AppError(400, 'Orden ya recibida, no se puede editar')

  const [updated] = await db.update(purchaseOrder)
    .set(data)
    .where(eq(purchaseOrder.id, id))
    .returning()
  return updated
}
import { and, eq, gt, lte, ne, sql } from 'drizzle-orm'
import { db } from '../../config/database'
import { accountPayable, accountReceivable, customer, product, productStock, supplier } from '../../db/schema'
import * as notificationService from './notification.service'

const DUE_SOON_DAYS = 3

function isoDate(daysFromNow: number): string {
  const d = new Date()
  d.setDate(d.getDate() + daysFromNow)
  return d.toISOString().slice(0, 10)
}

// Notification bodies are user-facing: money as $1,234.56, dates as "25 jul".
const MONTHS_ES = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic']

function fmtMoney(value: string): string {
  return `$${Number(value).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`
}

function fmtDateEs(iso: string): string {
  const [, month, day] = iso.split('-')
  return `${Number(day)} ${MONTHS_ES[Number(month) - 1]}`
}

function fmtQty(value: string): string {
  return String(Number(value))
}

// Lazy generation: Workers free tier has no cron, so the unread-count poll
// triggers this sweep. create()'s dedupe keeps repeated sweeps idempotent.
export async function sweepNotifications(businessId: string): Promise<number> {
  const today = isoDate(0)
  const dueLimit = isoDate(DUE_SOON_DAYS)

  const [lowStock, receivables, payables] = await Promise.all([
    // Same low-stock rule as inventory alerts, plus minStock > 0 so products
    // without a configured minimum don't spam notifications
    db.select({
      productId: product.id,
      productName: product.name,
      minStock: product.minStock,
      totalStock: sql<string>`COALESCE(SUM(${productStock.quantity}), 0)`,
    })
      .from(product)
      .leftJoin(productStock, eq(product.id, productStock.productId))
      .where(and(
        eq(product.businessId, businessId),
        eq(product.isActive, true),
        eq(product.isService, false),
        gt(product.minStock, '0'),
      ))
      .groupBy(product.id, product.name, product.minStock)
      .having(sql`COALESCE(SUM(${productStock.quantity}), 0) <= ${product.minStock}`),

    db.select({
      id: accountReceivable.id,
      balance: accountReceivable.balance,
      dueDate: accountReceivable.dueDate,
      customerName: sql<string>`COALESCE(${customer.companyName}, ${customer.firstName} || ' ' || ${customer.lastName})`,
    })
      .from(accountReceivable)
      .innerJoin(customer, eq(accountReceivable.customerId, customer.id))
      .where(and(
        eq(accountReceivable.businessId, businessId),
        ne(accountReceivable.status, 'paid'),
        gt(accountReceivable.balance, '0'),
        lte(accountReceivable.dueDate, dueLimit),
      )),

    db.select({
      id: accountPayable.id,
      balance: accountPayable.balance,
      dueDate: accountPayable.dueDate,
      supplierName: supplier.companyName,
    })
      .from(accountPayable)
      .innerJoin(supplier, eq(accountPayable.supplierId, supplier.id))
      .where(and(
        eq(accountPayable.businessId, businessId),
        ne(accountPayable.status, 'paid'),
        gt(accountPayable.balance, '0'),
        lte(accountPayable.dueDate, dueLimit),
      )),
  ])

  let created = 0

  for (const p of lowStock) {
    const row = await notificationService.create(businessId, {
      type: 'low_stock',
      title: 'Stock bajo',
      body: `${p.productName} tiene ${fmtQty(p.totalStock)} en existencia (mínimo ${fmtQty(p.minStock)})`,
      entityType: 'product',
      entityId: p.productId,
    })
    if (row) created++
  }

  for (const r of receivables) {
    const overdue = r.dueDate < today
    const row = await notificationService.create(businessId, {
      type: 'receivable_due',
      title: overdue ? 'Cobro vencido' : 'Cobro por vencer',
      body: overdue
        ? `${r.customerName} te debe ${fmtMoney(r.balance)} — venció el ${fmtDateEs(r.dueDate)}`
        : `${r.customerName} te debe ${fmtMoney(r.balance)} — vence el ${fmtDateEs(r.dueDate)}`,
      entityType: 'account_receivable',
      entityId: r.id,
    })
    if (row) created++
  }

  for (const p of payables) {
    const overdue = p.dueDate < today
    const row = await notificationService.create(businessId, {
      type: 'payable_due',
      title: overdue ? 'Pago vencido' : 'Pago por vencer',
      body: overdue
        ? `Debés ${fmtMoney(p.balance)} a ${p.supplierName} — venció el ${fmtDateEs(p.dueDate)}`
        : `Debés ${fmtMoney(p.balance)} a ${p.supplierName} — vence el ${fmtDateEs(p.dueDate)}`,
      entityType: 'account_payable',
      entityId: p.id,
    })
    if (row) created++
  }

  return created
}

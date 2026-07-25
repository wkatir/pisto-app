import { eq, and, desc, count, gt, ne, sql } from 'drizzle-orm'
import { db } from '../../config/database'
import { accountReceivable, customer, sale, collectionPayment } from '../../db/schema'
import { AppError } from '../../shared/errors/app-error'
import { paginatedResponse } from '../../shared/utils/pagination'

export async function listReceivables(businessId: string, page = 1, limit = 20) {
  const offset = (page - 1) * limit
  // Only open accounts — same criteria as the dashboard "por cobrar" KPI.
  const where = and(
    eq(accountReceivable.businessId, businessId),
    ne(accountReceivable.status, 'paid'),
    gt(accountReceivable.balance, '0'),
  )

  const [items, [total]] = await Promise.all([
    db.select({
      receivable: accountReceivable,
      customerName: sql<string>`COALESCE(${customer.companyName}, ${customer.firstName} || ' ' || ${customer.lastName})`,
      customerPhone: customer.phone,
      saleNumber: sale.saleNumber,
    })
      .from(accountReceivable)
      .leftJoin(customer, eq(accountReceivable.customerId, customer.id))
      .leftJoin(sale, eq(accountReceivable.saleId, sale.id))
      .where(where)
      .orderBy(desc(accountReceivable.createdAt))
      .offset(offset).limit(limit),
    db.select({ count: count() }).from(accountReceivable).where(where),
  ])

  return paginatedResponse(items, total!.count, page, limit)
}

export async function getReceivable(businessId: string, id: string) {
  const [ar] = await db.select()
    .from(accountReceivable)
    .where(and(eq(accountReceivable.id, id), eq(accountReceivable.businessId, businessId)))
  if (!ar) throw new AppError(404, 'Cuenta por cobrar no encontrada')
  return ar
}

export async function getReceivablePayments(businessId: string, id: string) {
  return db.select().from(collectionPayment)
    .where(and(eq(collectionPayment.businessId, businessId), eq(collectionPayment.accountReceivableId, id)))
    .orderBy(desc(collectionPayment.createdAt))
}

export async function getAgingReport(businessId: string) {
  const today = new Date().toISOString().split('T')[0]
  const raw = await db.execute(sql`
    WITH cte AS (
      SELECT
        CASE
          WHEN due_date >= CAST(${today} AS DATE) THEN 'current'
          WHEN due_date >= (CAST(${today} AS DATE) - INTERVAL '30 day') THEN '1-30'
          WHEN due_date >= (CAST(${today} AS DATE) - INTERVAL '60 day') THEN '31-60'
          WHEN due_date >= (CAST(${today} AS DATE) - INTERVAL '90 day') THEN '61-90'
          ELSE '90+'
        END AS bucket,
        balance
      FROM account_receivable
      WHERE business_id = ${businessId} AND status != 'paid'
    )
    SELECT
      bucket AS range,
      CAST(COUNT(*) AS INT) AS count,
      CAST(COALESCE(SUM(balance), 0) AS TEXT) AS total
    FROM cte
    GROUP BY bucket
    ORDER BY bucket
  `)
  return raw
}

export async function getCustomerStatement(businessId: string, customerId: string) {
  const receivables = await db.select({
    receivable: accountReceivable,
    saleNumber: sale.saleNumber,
  })
    .from(accountReceivable)
    .leftJoin(sale, eq(accountReceivable.saleId, sale.id))
    .where(and(
      eq(accountReceivable.businessId, businessId),
      eq(accountReceivable.customerId, customerId),
    ))
    .orderBy(desc(accountReceivable.createdAt))

  const payments = await db.select()
    .from(collectionPayment)
    .where(and(
      eq(collectionPayment.businessId, businessId),
      sql`${collectionPayment.accountReceivableId} IN (
        SELECT id FROM account_receivable WHERE customer_id = ${customerId} AND business_id = ${businessId}
      )`,
    ))
    .orderBy(desc(collectionPayment.createdAt))

  return { receivables, payments }
}

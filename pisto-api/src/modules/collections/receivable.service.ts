import { eq, and, desc, count, sql } from 'drizzle-orm'
import { db } from '../../config/database'
import { accountReceivable, customer, sale, collectionPayment } from '../../db/schema'
import { AppError } from '../../shared/errors/app-error'
import { paginatedResponse } from '../../shared/utils/pagination'

export async function listReceivables(businessId: string, page = 1, limit = 20) {
  const offset = (page - 1) * limit
  const where = eq(accountReceivable.businessId, businessId)

  const [items, [total]] = await Promise.all([
    db.select({
      receivable: accountReceivable,
      customerName: sql<string>`COALESCE(${customer.companyName}, ${customer.firstName} + ' ' + ${customer.lastName})`,
      saleNumber: sale.saleNumber,
    })
      .from(accountReceivable)
      .leftJoin(customer, eq(accountReceivable.customerId, customer.id))
      .leftJoin(sale, eq(accountReceivable.saleId, sale.id))
      .where(where)
      .orderBy(desc(accountReceivable.createdAt))
      .offset(offset).fetch(limit),
    db.select({ count: count() }).from(accountReceivable).where(where),
  ])

  return paginatedResponse(items, total!.count, { page, limit, sortOrder: 'desc' as const })
}

export async function getReceivable(businessId: string, id: string) {
  const [ar] = await db.select()
    .from(accountReceivable)
    .where(and(eq(accountReceivable.id, id), eq(accountReceivable.businessId, businessId)))
  if (!ar) throw new AppError(404, 'Cuenta por cobrar no encontrada')
  return ar
}

export async function getReceivablePayments(id: string) {
  return db.select().from(collectionPayment)
    .where(eq(collectionPayment.accountReceivableId, id))
    .orderBy(desc(collectionPayment.createdAt))
}

export async function getAgingReport(businessId: string) {
  const today = new Date().toISOString().split('T')[0]
  const raw = await db.execute(sql`
    WITH cte AS (
      SELECT
        CASE
          WHEN due_date >= CAST(${today} AS DATE) THEN 'current'
          WHEN due_date >= DATEADD(day, -30, CAST(${today} AS DATE)) THEN '1-30'
          WHEN due_date >= DATEADD(day, -60, CAST(${today} AS DATE)) THEN '31-60'
          WHEN due_date >= DATEADD(day, -90, CAST(${today} AS DATE)) THEN '61-90'
          ELSE '90+'
        END AS bucket,
        balance
      FROM account_receivable
      WHERE business_id = ${businessId} AND status != 'paid'
    )
    SELECT
      bucket AS range,
      CAST(COUNT(*) AS INT) AS count,
      CAST(COALESCE(SUM(balance), 0) AS NVARCHAR(50)) AS total
    FROM cte
    GROUP BY bucket
    ORDER BY bucket
  `)
  return (raw as any).recordset ?? raw
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

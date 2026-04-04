import { eq, and, desc, count, sql } from 'drizzle-orm'
import { db } from '../../config/database'
import { accountReceivable, customer, sale, collectionPayment } from '../../db/schema'
import { AppError } from '../../shared/errors/app-error'

export async function listReceivables(businessId: string, page = 1, limit = 20) {
  const offset = (page - 1) * limit
  const where = eq(accountReceivable.businessId, businessId)

  const [items, [total]] = await Promise.all([
    db.select({
      receivable: accountReceivable,
      customerName: sql<string>`COALESCE(${customer.companyName}, ${customer.firstName} || ' ' || ${customer.lastName})`,
      saleNumber: sale.saleNumber,
    })
      .from(accountReceivable)
      .leftJoin(customer, eq(accountReceivable.customerId, customer.id))
      .leftJoin(sale, eq(accountReceivable.saleId, sale.id))
      .where(where)
      .orderBy(desc(accountReceivable.createdAt))
      .limit(limit).offset(offset),
    db.select({ count: count() }).from(accountReceivable).where(where),
  ])

  return {
    data: items,
    pagination: { page, limit, total: total!.count, pages: Math.ceil(total!.count / limit) },
  }
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
  const result = await db.execute<{
    range: string; count: number; total: string
  }>(sql`
    SELECT
      CASE
        WHEN due_date >= ${today} THEN 'current'
        WHEN due_date >= ${today}::date - 30 THEN '1-30'
        WHEN due_date >= ${today}::date - 60 THEN '31-60'
        WHEN due_date >= ${today}::date - 90 THEN '61-90'
        ELSE '90+'
      END AS range,
      COUNT(*)::int AS count,
      COALESCE(SUM(balance), 0)::text AS total
    FROM account_receivable
    WHERE business_id = ${businessId} AND status != 'paid'
    GROUP BY range
    ORDER BY range
  `)
  return result
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

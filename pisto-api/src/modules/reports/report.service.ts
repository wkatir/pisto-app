import { sql } from 'drizzle-orm'
import { db } from '../../config/database'

export async function getSalesSummary(businessId: string, from?: string, to?: string) {
  const fromDate = from || new Date(new Date().getFullYear(), new Date().getMonth(), 1).toISOString().split('T')[0]
  const toDate = to || new Date().toISOString().split('T')[0]

  const result = await db.execute<{
    total_sales: string; total_revenue: string; total_tax: string; total_discount: string; avg_sale: string
  }>(sql`
    SELECT
      COUNT(*)::int AS total_sales,
      COALESCE(SUM(total), 0)::text AS total_revenue,
      COALESCE(SUM(tax_amount), 0)::text AS total_tax,
      COALESCE(SUM(discount_amount), 0)::text AS total_discount,
      COALESCE(AVG(total), 0)::text AS avg_sale
    FROM sale
    WHERE business_id = ${businessId}
      AND status != 'cancelled'
      AND sale_date >= ${fromDate}
      AND sale_date <= ${toDate}
  `)
  return result[0]
}

export async function getTopProducts(businessId: string, limit = 10, from?: string, to?: string) {
  const fromDate = from || new Date(new Date().getFullYear(), 0, 1).toISOString().split('T')[0]
  const toDate = to || new Date().toISOString().split('T')[0]

  return db.execute(sql`
    SELECT
      p.id, p.name, p.sku,
      SUM(sl.quantity::numeric)::text AS total_quantity,
      SUM(sl.line_total::numeric)::text AS total_revenue
    FROM sale_line sl
    JOIN sale s ON s.id = sl.sale_id
    JOIN product p ON p.id = sl.product_id
    WHERE s.business_id = ${businessId}
      AND s.status != 'cancelled'
      AND s.sale_date >= ${fromDate}
      AND s.sale_date <= ${toDate}
    GROUP BY p.id, p.name, p.sku
    ORDER BY total_revenue DESC
    LIMIT ${limit}
  `)
}

export async function getInventoryValuation(businessId: string) {
  return db.execute(sql`
    SELECT
      p.id, p.name, p.sku, p.cost_price,
      COALESCE(SUM(ps.quantity::numeric), 0)::text AS total_stock,
      (COALESCE(SUM(ps.quantity::numeric), 0) * p.cost_price::numeric)::text AS valuation
    FROM product p
    LEFT JOIN product_stock ps ON ps.product_id = p.id
    WHERE p.business_id = ${businessId} AND p.is_active = true
    GROUP BY p.id, p.name, p.sku, p.cost_price
    HAVING COALESCE(SUM(ps.quantity::numeric), 0) > 0
    ORDER BY valuation DESC
  `)
}

export async function getReceivablesAging(businessId: string) {
  return db.execute(sql`
    SELECT
      COALESCE(c.company_name, c.first_name || ' ' || c.last_name) AS customer_name,
      COUNT(*)::int AS open_invoices,
      SUM(ar.balance::numeric)::text AS total_balance,
      MIN(ar.due_date) AS oldest_due
    FROM account_receivable ar
    JOIN customer c ON c.id = ar.customer_id
    WHERE ar.business_id = ${businessId} AND ar.status != 'paid'
    GROUP BY c.id, c.company_name, c.first_name, c.last_name
    ORDER BY total_balance DESC
  `)
}

export async function getPurchasesBySupplier(businessId: string, from?: string, to?: string) {
  const fromDate = from || new Date(new Date().getFullYear(), 0, 1).toISOString().split('T')[0]
  const toDate = to || new Date().toISOString().split('T')[0]

  return db.execute(sql`
    SELECT
      s.id AS supplier_id, s.company_name,
      COUNT(*)::int AS total_orders,
      SUM(po.total::numeric)::text AS total_amount
    FROM purchase_order po
    JOIN supplier s ON s.id = po.supplier_id
    WHERE po.business_id = ${businessId}
      AND po.status != 'cancelled'
      AND po.order_date >= ${fromDate}
      AND po.order_date <= ${toDate}
    GROUP BY s.id, s.company_name
    ORDER BY total_amount DESC
  `)
}

export async function getGrossProfit(businessId: string, from?: string, to?: string) {
  const fromDate = from || new Date(new Date().getFullYear(), new Date().getMonth(), 1).toISOString().split('T')[0]
  const toDate = to || new Date().toISOString().split('T')[0]

  return db.execute(sql`
    SELECT
      SUM(sl.line_total::numeric)::text AS revenue,
      SUM(sl.quantity::numeric * p.cost_price::numeric)::text AS cost,
      (SUM(sl.line_total::numeric) - SUM(sl.quantity::numeric * p.cost_price::numeric))::text AS gross_profit,
      CASE
        WHEN SUM(sl.line_total::numeric) > 0
        THEN ((SUM(sl.line_total::numeric) - SUM(sl.quantity::numeric * p.cost_price::numeric)) / SUM(sl.line_total::numeric) * 100)::text
        ELSE '0'
      END AS margin_pct
    FROM sale_line sl
    JOIN sale s ON s.id = sl.sale_id
    JOIN product p ON p.id = sl.product_id
    WHERE s.business_id = ${businessId}
      AND s.status != 'cancelled'
      AND s.sale_date >= ${fromDate}
      AND s.sale_date <= ${toDate}
  `)
}

export async function getSalesTrend(businessId: string, days = 30) {
  const fromDate = new Date()
  fromDate.setDate(fromDate.getDate() - days)
  const fromStr = fromDate.toISOString().split('T')[0]
  const toStr = new Date().toISOString().split('T')[0]

  return db.execute(sql`
    SELECT
      sale_date::text AS date,
      COUNT(*)::int AS count,
      COALESCE(SUM(total::numeric), 0)::text AS revenue
    FROM sale
    WHERE business_id = ${businessId}
      AND status != 'cancelled'
      AND sale_date >= ${fromStr}
      AND sale_date <= ${toStr}
    GROUP BY sale_date
    ORDER BY sale_date
  `)
}

export async function getSalesByCategory(businessId: string) {
  return db.execute(sql`
    SELECT
      COALESCE(pc.name, 'Sin categoría') AS category,
      SUM(sl.line_total::numeric)::text AS revenue
    FROM sale_line sl
    JOIN sale s ON s.id = sl.sale_id
    JOIN product p ON p.id = sl.product_id
    LEFT JOIN product_category pc ON pc.id = p.category_id
    WHERE s.business_id = ${businessId}
      AND s.status != 'cancelled'
    GROUP BY pc.name
    ORDER BY revenue DESC
  `)
}

export async function getDashboardKPIs(businessId: string) {
  const today = new Date().toISOString().split('T')[0]
  const monthStart = new Date(new Date().getFullYear(), new Date().getMonth(), 1).toISOString().split('T')[0]

  const [salesKPI, receivablesKPI, inventoryKPI] = await Promise.all([
    db.execute(sql`
      SELECT
        COUNT(*)::int AS sales_count,
        COALESCE(SUM(total), 0)::text AS revenue
      FROM sale
      WHERE business_id = ${businessId} AND status != 'cancelled'
        AND sale_date >= ${monthStart} AND sale_date <= ${today}
    `),
    db.execute(sql`
      SELECT
        COUNT(*)::int AS pending_count,
        COALESCE(SUM(balance), 0)::text AS total_pending
      FROM account_receivable
      WHERE business_id = ${businessId} AND status != 'paid'
    `),
    db.execute(sql`
      SELECT COUNT(*)::int AS low_stock_count
      FROM product p
      JOIN product_stock ps ON ps.product_id = p.id
      WHERE p.business_id = ${businessId} AND p.is_active = true
        AND ps.quantity::numeric <= p.min_stock::numeric AND p.min_stock::numeric > 0
    `),
  ])

  return {
    monthlySales: salesKPI[0],
    receivables: receivablesKPI[0],
    lowStock: inventoryKPI[0],
  }
}

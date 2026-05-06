import { sql } from 'drizzle-orm'
import { db } from '../../config/database'

async function execRows<T = Record<string, unknown>>(query: Parameters<typeof db.execute>[0]): Promise<T[]> {
  const result = await db.execute(query)
  return ((result as any).recordset ?? result) as T[]
}

export async function getSalesSummary(businessId: string, from?: string, to?: string) {
  const fromDate = from || new Date(new Date().getFullYear(), new Date().getMonth(), 1).toISOString().split('T')[0]
  const toDate = to || new Date().toISOString().split('T')[0]

  const rows = await execRows(sql`
    SELECT
      CAST(COUNT(*) AS INT) AS total_sales,
      CAST(COALESCE(SUM(total), 0) AS NVARCHAR(50)) AS total_revenue,
      CAST(COALESCE(SUM(tax_amount), 0) AS NVARCHAR(50)) AS total_tax,
      CAST(COALESCE(SUM(discount_amount), 0) AS NVARCHAR(50)) AS total_discount,
      CAST(COALESCE(AVG(total), 0) AS NVARCHAR(50)) AS avg_sale
    FROM sale
    WHERE business_id = ${businessId}
      AND status != 'cancelled'
      AND sale_date >= ${fromDate}
      AND sale_date <= ${toDate}
  `)
  return rows[0]
}

export async function getTopProducts(businessId: string, limit = 10, from?: string, to?: string) {
  const fromDate = from || new Date(new Date().getFullYear(), 0, 1).toISOString().split('T')[0]
  const toDate = to || new Date().toISOString().split('T')[0]

  return execRows(sql`
    SELECT TOP (${limit})
      p.id, p.name, p.sku,
      CAST(SUM(sl.quantity) AS NVARCHAR(50)) AS total_quantity,
      CAST(SUM(sl.line_total) AS NVARCHAR(50)) AS total_revenue
    FROM sale_line sl
    JOIN sale s ON s.id = sl.sale_id
    JOIN product p ON p.id = sl.product_id
    WHERE s.business_id = ${businessId}
      AND s.status != 'cancelled'
      AND s.sale_date >= ${fromDate}
      AND s.sale_date <= ${toDate}
    GROUP BY p.id, p.name, p.sku
    ORDER BY SUM(sl.line_total) DESC
  `)
}

export async function getInventoryValuation(businessId: string) {
  return execRows(sql`
    SELECT
      p.id, p.name, p.sku, p.cost_price,
      CAST(COALESCE(SUM(ps.quantity), 0) AS NVARCHAR(50)) AS total_stock,
      CAST(COALESCE(SUM(ps.quantity), 0) * p.cost_price AS NVARCHAR(50)) AS valuation
    FROM product p
    LEFT JOIN product_stock ps ON ps.product_id = p.id
    WHERE p.business_id = ${businessId} AND p.is_active = 1
    GROUP BY p.id, p.name, p.sku, p.cost_price
    HAVING COALESCE(SUM(ps.quantity), 0) > 0
    ORDER BY COALESCE(SUM(ps.quantity), 0) * p.cost_price DESC
  `)
}

export async function getReceivablesAging(businessId: string) {
  return execRows(sql`
    SELECT
      COALESCE(c.company_name, c.first_name + ' ' + c.last_name) AS customer_name,
      CAST(COUNT(*) AS INT) AS open_invoices,
      CAST(SUM(ar.balance) AS NVARCHAR(50)) AS total_balance,
      MIN(ar.due_date) AS oldest_due
    FROM account_receivable ar
    JOIN customer c ON c.id = ar.customer_id
    WHERE ar.business_id = ${businessId} AND ar.status != 'paid'
    GROUP BY c.id, c.company_name, c.first_name, c.last_name
    ORDER BY SUM(ar.balance) DESC
  `)
}

export async function getPurchasesBySupplier(businessId: string, from?: string, to?: string) {
  const fromDate = from || new Date(new Date().getFullYear(), 0, 1).toISOString().split('T')[0]
  const toDate = to || new Date().toISOString().split('T')[0]

  return execRows(sql`
    SELECT
      s.id AS supplier_id, s.company_name,
      CAST(COUNT(*) AS INT) AS total_orders,
      CAST(SUM(po.total) AS NVARCHAR(50)) AS total_amount
    FROM purchase_order po
    JOIN supplier s ON s.id = po.supplier_id
    WHERE po.business_id = ${businessId}
      AND po.status != 'cancelled'
      AND po.order_date >= ${fromDate}
      AND po.order_date <= ${toDate}
    GROUP BY s.id, s.company_name
    ORDER BY SUM(po.total) DESC
  `)
}

export async function getGrossProfit(businessId: string, from?: string, to?: string) {
  const fromDate = from || new Date(new Date().getFullYear(), new Date().getMonth(), 1).toISOString().split('T')[0]
  const toDate = to || new Date().toISOString().split('T')[0]

  const rows = await execRows(sql`
    SELECT
      CAST(SUM(sl.line_total) AS NVARCHAR(50)) AS revenue,
      CAST(SUM(sl.quantity * p.cost_price) AS NVARCHAR(50)) AS cost,
      CAST(SUM(sl.line_total) - SUM(sl.quantity * p.cost_price) AS NVARCHAR(50)) AS gross_profit,
      CAST(
        CASE WHEN SUM(sl.line_total) > 0
          THEN (SUM(sl.line_total) - SUM(sl.quantity * p.cost_price)) / SUM(sl.line_total) * 100
          ELSE 0
        END AS NVARCHAR(50)
      ) AS margin_pct
    FROM sale_line sl
    JOIN sale s ON s.id = sl.sale_id
    JOIN product p ON p.id = sl.product_id
    WHERE s.business_id = ${businessId}
      AND s.status != 'cancelled'
      AND s.sale_date >= ${fromDate}
      AND s.sale_date <= ${toDate}
  `)
  return rows[0]
}

export async function getSalesTrend(businessId: string, days = 30) {
  const fromDate = new Date()
  fromDate.setDate(fromDate.getDate() - days)
  const fromStr = fromDate.toISOString().split('T')[0]
  const toStr = new Date().toISOString().split('T')[0]

  return execRows(sql`
    SELECT
      CAST(sale_date AS NVARCHAR(10)) AS date,
      CAST(COUNT(*) AS INT) AS count,
      CAST(COALESCE(SUM(total), 0) AS NVARCHAR(50)) AS revenue
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
  return execRows(sql`
    SELECT
      COALESCE(pc.name, 'Sin categoría') AS category,
      CAST(SUM(sl.line_total) AS NVARCHAR(50)) AS revenue
    FROM sale_line sl
    JOIN sale s ON s.id = sl.sale_id
    JOIN product p ON p.id = sl.product_id
    LEFT JOIN product_category pc ON pc.id = p.category_id
    WHERE s.business_id = ${businessId}
      AND s.status != 'cancelled'
    GROUP BY pc.name
    ORDER BY SUM(sl.line_total) DESC
  `)
}

export async function getDashboardKPIs(businessId: string) {
  const today = new Date().toISOString().split('T')[0]
  const monthStart = new Date(new Date().getFullYear(), new Date().getMonth(), 1).toISOString().split('T')[0]

  const [salesRows, receivablesRows, inventoryRows] = await Promise.all([
    execRows(sql`
      SELECT
        CAST(COUNT(*) AS INT) AS sales_count,
        CAST(COALESCE(SUM(total), 0) AS NVARCHAR(50)) AS revenue
      FROM sale
      WHERE business_id = ${businessId} AND status != 'cancelled'
        AND sale_date >= ${monthStart} AND sale_date <= ${today}
    `),
    execRows(sql`
      SELECT
        CAST(COUNT(*) AS INT) AS pending_count,
        CAST(COALESCE(SUM(balance), 0) AS NVARCHAR(50)) AS total_pending
      FROM account_receivable
      WHERE business_id = ${businessId} AND status != 'paid'
    `),
    execRows(sql`
      SELECT CAST(COUNT(*) AS INT) AS low_stock_count
      FROM product p
      JOIN product_stock ps ON ps.product_id = p.id
      WHERE p.business_id = ${businessId} AND p.is_active = 1
        AND ps.quantity <= p.min_stock AND p.min_stock > 0
    `),
  ])

  return {
    monthlySales: salesRows[0],
    receivables: receivablesRows[0],
    lowStock: inventoryRows[0],
  }
}

import type OpenAI from 'openai'
import { getAiClient, getAiModel } from './ai-client'
import { sql } from 'drizzle-orm'
import { db } from '../../config/database'

const SYSTEM_PROMPT = `Eres el asistente financiero de Pisto App. Ayudas a microempresarios en El Salvador a entender sus finanzas. Responde siempre en español, de forma clara y amigable. Usa los datos reales del negocio. Cuando des cifras, usa formato de moneda ($X,XXX.XX). Si no tienes datos suficientes, dilo honestamente. Nunca inventes números.`

// ── Helper to run raw SQL and get rows ──

async function execRows<T = Record<string, unknown>>(query: Parameters<typeof db.execute>[0]): Promise<T[]> {
  const result = await db.execute(query)
  return result as unknown as T[]
}

// ── Tool functions ──

async function querySales(businessId: string, params: { from?: string; to?: string }) {
  const fromDate = params.from || new Date(new Date().getFullYear(), new Date().getMonth(), 1).toISOString().split('T')[0]
  const toDate = params.to || new Date().toISOString().split('T')[0]

  const rows = await execRows(sql`
    SELECT
      CAST(COUNT(*) AS INT) AS total_sales,
      CAST(COALESCE(SUM(total), 0) AS FLOAT) AS total_revenue,
      CAST(COALESCE(SUM(tax_amount), 0) AS FLOAT) AS total_tax,
      CAST(COALESCE(SUM(discount_amount), 0) AS FLOAT) AS total_discount,
      CAST(COALESCE(AVG(total), 0) AS FLOAT) AS avg_sale
    FROM sale
    WHERE business_id = ${businessId}
      AND status != 'cancelled'
      AND sale_date >= ${fromDate}
      AND sale_date <= ${toDate}
  `)

  return { period: { from: fromDate, to: toDate }, ...rows[0] }
}

async function queryExpenses(businessId: string, params: { from?: string; to?: string }) {
  const fromDate = params.from || new Date(new Date().getFullYear(), new Date().getMonth(), 1).toISOString().split('T')[0]
  const toDate = params.to || new Date().toISOString().split('T')[0]

  const summary = await execRows(sql`
    SELECT
      CAST(COUNT(*) AS INT) AS total_count,
      CAST(COALESCE(SUM(CAST(amount AS FLOAT)), 0) AS FLOAT) AS total_amount
    FROM expense
    WHERE business_id = ${businessId}
      AND expense_date >= ${fromDate}
      AND expense_date <= ${toDate}
  `)

  const byCategory = await execRows(sql`
    SELECT
      COALESCE(ec.name, 'Sin categoría') AS category,
      CAST(COUNT(*) AS INT) AS count,
      CAST(COALESCE(SUM(CAST(e.amount AS FLOAT)), 0) AS FLOAT) AS total
    FROM expense e
    LEFT JOIN expense_category ec ON ec.id = e.category_id
    WHERE e.business_id = ${businessId}
      AND e.expense_date >= ${fromDate}
      AND e.expense_date <= ${toDate}
    GROUP BY ec.name
    ORDER BY SUM(CAST(e.amount AS FLOAT)) DESC
  `)

  return { period: { from: fromDate, to: toDate }, ...summary[0], by_category: byCategory }
}

async function queryReceivables(businessId: string) {
  const rows = await execRows(sql`
    SELECT
      CAST(COUNT(*) AS INT) AS total_accounts,
      CAST(COALESCE(SUM(CAST(balance AS FLOAT)), 0) AS FLOAT) AS total_pending,
      CAST(COALESCE(SUM(CASE WHEN due_date < CURRENT_DATE THEN CAST(balance AS FLOAT) ELSE 0 END), 0) AS FLOAT) AS total_overdue,
      CAST(SUM(CASE WHEN due_date < CURRENT_DATE THEN 1 ELSE 0 END) AS INT) AS overdue_count
    FROM account_receivable
    WHERE business_id = ${businessId}
      AND status != 'paid'
  `)

  return rows[0]
}

async function queryInventory(businessId: string) {
  const summary = await execRows(sql`
    SELECT
      CAST(COUNT(DISTINCT p.id) AS INT) AS total_products,
      CAST(COALESCE(SUM(CAST(ps.quantity AS FLOAT) * CAST(p.cost_price AS FLOAT)), 0) AS FLOAT) AS total_valuation
    FROM product p
    LEFT JOIN product_stock ps ON ps.product_id = p.id
    WHERE p.business_id = ${businessId} AND p.is_active = true
  `)

  const lowStock = await execRows(sql`
    SELECT
      p.name,
      p.sku,
      CAST(COALESCE(SUM(CAST(ps.quantity AS FLOAT)), 0) AS FLOAT) AS current_stock,
      CAST(p.min_stock AS FLOAT) AS min_stock
    FROM product p
    LEFT JOIN product_stock ps ON ps.product_id = p.id
    WHERE p.business_id = ${businessId}
      AND p.is_active = true
      AND p.is_service = false
    GROUP BY p.id, p.name, p.sku, p.min_stock
    HAVING COALESCE(SUM(CAST(ps.quantity AS FLOAT)), 0) <= CAST(p.min_stock AS FLOAT)
    ORDER BY COALESCE(SUM(CAST(ps.quantity AS FLOAT)), 0) ASC
    LIMIT 10
  `)

  return { ...summary[0], low_stock_items: lowStock }
}

async function queryCashFlow(businessId: string, params: { from?: string; to?: string }) {
  const fromDate = params.from || new Date(new Date().getFullYear(), new Date().getMonth(), 1).toISOString().split('T')[0]
  const toDate = params.to || new Date().toISOString().split('T')[0]

  const income = await execRows<{ total: number }>(sql`
    SELECT CAST(COALESCE(SUM(CAST(total AS FLOAT)), 0) AS FLOAT) AS total
    FROM sale
    WHERE business_id = ${businessId}
      AND status != 'cancelled'
      AND sale_date >= ${fromDate}
      AND sale_date <= ${toDate}
  `)

  const expenses = await execRows<{ total: number }>(sql`
    SELECT CAST(COALESCE(SUM(CAST(amount AS FLOAT)), 0) AS FLOAT) AS total
    FROM expense
    WHERE business_id = ${businessId}
      AND expense_date >= ${fromDate}
      AND expense_date <= ${toDate}
  `)

  const purchases = await execRows<{ total: number }>(sql`
    SELECT CAST(COALESCE(SUM(CAST(total AS FLOAT)), 0) AS FLOAT) AS total
    FROM purchase_order
    WHERE business_id = ${businessId}
      AND status NOT IN ('draft', 'cancelled')
      AND order_date >= ${fromDate}
      AND order_date <= ${toDate}
  `)

  // Bare aggregate queries (no GROUP BY) always return exactly one row; COALESCE guarantees total is never null.
  const totalIncome = income[0]!.total
  const totalExpenses = expenses[0]!.total + purchases[0]!.total

  return {
    period: { from: fromDate, to: toDate },
    income: totalIncome,
    expenses: totalExpenses,
    purchases: purchases[0]!.total,
    operating_expenses: expenses[0]!.total,
    net_cash_flow: totalIncome - totalExpenses,
  }
}

// ── Tool definitions (OpenAI function calling format) ──

const tools: OpenAI.ChatCompletionTool[] = [
  {
    type: 'function',
    function: {
      name: 'query_sales',
      description: 'Obtiene resumen de ventas: total vendido, cantidad de ventas, promedio por venta. Puede filtrar por rango de fechas.',
      parameters: {
        type: 'object',
        properties: {
          from: { type: 'string', description: 'Fecha inicio (YYYY-MM-DD). Por defecto: inicio del mes actual.' },
          to: { type: 'string', description: 'Fecha fin (YYYY-MM-DD). Por defecto: hoy.' },
        },
        required: [],
      },
    },
  },
  {
    type: 'function',
    function: {
      name: 'query_expenses',
      description: 'Obtiene resumen de gastos: total, cantidad, desglose por categoría. Puede filtrar por rango de fechas.',
      parameters: {
        type: 'object',
        properties: {
          from: { type: 'string', description: 'Fecha inicio (YYYY-MM-DD). Por defecto: inicio del mes actual.' },
          to: { type: 'string', description: 'Fecha fin (YYYY-MM-DD). Por defecto: hoy.' },
        },
        required: [],
      },
    },
  },
  {
    type: 'function',
    function: {
      name: 'query_receivables',
      description: 'Obtiene estado de cuentas por cobrar: pendientes, vencidas, montos.',
      parameters: { type: 'object', properties: {}, required: [] },
    },
  },
  {
    type: 'function',
    function: {
      name: 'query_inventory',
      description: 'Obtiene estado del inventario: productos con stock bajo, valuación total del inventario.',
      parameters: { type: 'object', properties: {}, required: [] },
    },
  },
  {
    type: 'function',
    function: {
      name: 'query_cash_flow',
      description: 'Obtiene flujo de caja: ingresos por ventas vs egresos (gastos + compras) para un período.',
      parameters: {
        type: 'object',
        properties: {
          from: { type: 'string', description: 'Fecha inicio (YYYY-MM-DD). Por defecto: inicio del mes actual.' },
          to: { type: 'string', description: 'Fecha fin (YYYY-MM-DD). Por defecto: hoy.' },
        },
        required: [],
      },
    },
  },
]

// ── Execute a tool call ──

async function executeTool(businessId: string, name: string, input: Record<string, unknown>): Promise<string> {
  switch (name) {
    case 'query_sales':
      return JSON.stringify(await querySales(businessId, input as { from?: string; to?: string }))
    case 'query_expenses':
      return JSON.stringify(await queryExpenses(businessId, input as { from?: string; to?: string }))
    case 'query_receivables':
      return JSON.stringify(await queryReceivables(businessId))
    case 'query_inventory':
      return JSON.stringify(await queryInventory(businessId))
    case 'query_cash_flow':
      return JSON.stringify(await queryCashFlow(businessId, input as { from?: string; to?: string }))
    default:
      return JSON.stringify({ error: `Herramienta desconocida: ${name}` })
  }
}

// ── Main chat function ──

export async function chat(
  businessId: string,
  _userId: string,
  message: string,
  conversationHistory: Array<{ role: 'user' | 'assistant'; content: string }>,
) {
  const messages: OpenAI.ChatCompletionMessageParam[] = [
    { role: 'system', content: SYSTEM_PROMPT },
    ...conversationHistory.map((m) => ({ role: m.role as 'user' | 'assistant', content: m.content })),
    { role: 'user', content: message },
  ]

  for (let i = 0; i < 10; i++) {
    const response = await getAiClient().chat.completions.create({
      model: getAiModel(),
      max_tokens: 1024,
      tools,
      messages,
    })

    const choice = response.choices[0]
    if (!choice) break

    messages.push(choice.message)

    if (choice.message.tool_calls?.length) {
      for (const tc of choice.message.tool_calls) {
        if (tc.type !== 'function') continue
        const args = JSON.parse(tc.function.arguments || '{}')
        const result = await executeTool(businessId, tc.function.name, args)
        messages.push({ role: 'tool', tool_call_id: tc.id, content: result })
      }
      continue
    }

    if (!choice.message.content) throw new Error('AI returned empty response for chat')
    return choice.message.content
  }

  throw new Error('AI tool call loop exceeded max iterations (10)')
}

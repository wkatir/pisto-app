import { client, AI_MODEL } from './ai-client'
import { sql } from 'drizzle-orm'
import { db } from '../../config/database'

async function execRows<T = Record<string, unknown>>(query: Parameters<typeof db.execute>[0]): Promise<T[]> {
  const result = await db.execute(query)
  return ((result as any).recordset ?? result) as T[]
}

// ── Cash Flow Forecast ──────────────────────────────────────────────

interface DailySales { sale_date: string; total_sales: string; sale_count: number }
interface DailyExpenses { expense_date: string; total_expenses: string; expense_count: number }
interface PendingReceivable { due_date: string; total_balance: string; count: number }
interface PendingPayable { due_date: string; total_balance: string; count: number }

async function getLast90DaysSales(businessId: string): Promise<DailySales[]> {
  return execRows<DailySales>(sql`
    SELECT
      CONVERT(VARCHAR(10), sale_date, 23) AS sale_date,
      CAST(COALESCE(SUM(total), 0) AS NVARCHAR(50)) AS total_sales,
      CAST(COUNT(*) AS INT) AS sale_count
    FROM sale
    WHERE business_id = ${businessId}
      AND status != 'cancelled'
      AND sale_date >= DATEADD(DAY, -90, CAST(GETDATE() AS DATE))
    GROUP BY sale_date
    ORDER BY sale_date
  `)
}

async function getLast90DaysExpenses(businessId: string): Promise<DailyExpenses[]> {
  return execRows<DailyExpenses>(sql`
    SELECT
      CONVERT(VARCHAR(10), expense_date, 23) AS expense_date,
      CAST(COALESCE(SUM(amount), 0) AS NVARCHAR(50)) AS total_expenses,
      CAST(COUNT(*) AS INT) AS expense_count
    FROM expense
    WHERE business_id = ${businessId}
      AND expense_date >= DATEADD(DAY, -90, CAST(GETDATE() AS DATE))
    GROUP BY expense_date
    ORDER BY expense_date
  `)
}

async function getPendingReceivables(businessId: string): Promise<PendingReceivable[]> {
  return execRows<PendingReceivable>(sql`
    SELECT
      CONVERT(VARCHAR(10), due_date, 23) AS due_date,
      CAST(COALESCE(SUM(balance), 0) AS NVARCHAR(50)) AS total_balance,
      CAST(COUNT(*) AS INT) AS count
    FROM account_receivable
    WHERE business_id = ${businessId}
      AND status = 'pending'
    GROUP BY due_date
    ORDER BY due_date
  `)
}

async function getPendingPayables(businessId: string): Promise<PendingPayable[]> {
  return execRows<PendingPayable>(sql`
    SELECT
      CONVERT(VARCHAR(10), due_date, 23) AS due_date,
      CAST(COALESCE(SUM(balance), 0) AS NVARCHAR(50)) AS total_balance,
      CAST(COUNT(*) AS INT) AS count
    FROM account_payable
    WHERE business_id = ${businessId}
      AND status = 'pending'
    GROUP BY due_date
    ORDER BY due_date
  `)
}

export async function forecastCashFlow(businessId: string, days: number = 30) {
  const [dailySales, dailyExpenses, receivables, payables] = await Promise.all([
    getLast90DaysSales(businessId),
    getLast90DaysExpenses(businessId),
    getPendingReceivables(businessId),
    getPendingPayables(businessId),
  ])

  if (dailySales.length === 0 && dailyExpenses.length === 0) {
    return {
      forecast: [],
      summary: { totalProjectedIncome: 0, totalProjectedExpenses: 0, netProjection: 0 },
      insights: ['No hay suficientes datos históricos para generar una proyección. Registra ventas y gastos para obtener pronósticos.'],
      risk: 'bajo' as const,
    }
  }

  const historicalData = {
    dailySales,
    dailyExpenses,
    pendingReceivables: receivables,
    pendingPayables: payables,
  }

  const response = await client.chat.completions.create({
    model: AI_MODEL,
    max_tokens: 4096,
    messages: [
      {
        role: 'user',
        content: `Eres un analista financiero. Basándote en estos datos históricos de los últimos 90 días de un negocio en El Salvador, proyecta el flujo de caja para los próximos ${days} días.

Datos: ${JSON.stringify(historicalData)}

Responde ÚNICAMENTE con JSON válido (sin markdown, sin backticks) con esta estructura:
- forecast: array de { date: 'YYYY-MM-DD', projectedIncome: number, projectedExpenses: number, netCashFlow: number }
- summary: { totalProjectedIncome: number, totalProjectedExpenses: number, netProjection: number }
- insights: array de strings con 2-3 observaciones clave en español
- risk: 'bajo' | 'medio' | 'alto' basado en si los gastos proyectados superan los ingresos

Basa tus proyecciones en tendencias reales. No inventes datos.`,
      },
    ],
  })

  const text = response.choices[0]?.message?.content
  if (!text) throw new Error('AI returned empty response for forecast')

  const cleaned = text.replace(/^```(?:json)?\s*\n?/i, '').replace(/\n?```\s*$/i, '').trim()
  try {
    return JSON.parse(cleaned)
  } catch (e) {
    throw new Error(`Failed to parse forecast JSON: ${(e as Error).message}\nRaw: ${cleaned.slice(0, 500)}`)
  }
}

// ── Anomaly Detection ───────────────────────────────────────────────

interface TransactionRow {
  transaction_date: string
  type: string
  description: string
  amount: string
}

async function getTransactions(businessId: string, daysAgo: number, daysEnd: number): Promise<TransactionRow[]> {
  return execRows<TransactionRow>(sql`
    SELECT
      CONVERT(VARCHAR(10), sale_date, 23) AS transaction_date,
      'venta' AS type,
      sale_number AS description,
      CAST(total AS NVARCHAR(50)) AS amount
    FROM sale
    WHERE business_id = ${businessId}
      AND status != 'cancelled'
      AND sale_date >= DATEADD(DAY, ${-daysAgo}, CAST(GETDATE() AS DATE))
      AND sale_date < DATEADD(DAY, ${-daysEnd}, CAST(GETDATE() AS DATE))

    UNION ALL

    SELECT
      CONVERT(VARCHAR(10), expense_date, 23) AS transaction_date,
      'gasto' AS type,
      description,
      CAST(amount AS NVARCHAR(50)) AS amount
    FROM expense
    WHERE business_id = ${businessId}
      AND expense_date >= DATEADD(DAY, ${-daysAgo}, CAST(GETDATE() AS DATE))
      AND expense_date < DATEADD(DAY, ${-daysEnd}, CAST(GETDATE() AS DATE))

    ORDER BY transaction_date
  `)
}

export async function detectAnomalies(businessId: string) {
  const [recentTransactions, baselineTransactions] = await Promise.all([
    getTransactions(businessId, 30, 0),
    getTransactions(businessId, 60, 30),
  ])

  if (recentTransactions.length === 0 && baselineTransactions.length === 0) {
    return {
      anomalies: [],
      summary: 'No hay suficientes transacciones para analizar. Registra ventas y gastos para obtener análisis de anomalías.',
    }
  }

  const response = await client.chat.completions.create({
    model: AI_MODEL,
    max_tokens: 4096,
    messages: [
      {
        role: 'user',
        content: `Analiza estas transacciones de un negocio y detecta anomalías. Compara los últimos 30 días con el período anterior.

Últimos 30 días: ${JSON.stringify(recentTransactions)}
Período anterior: ${JSON.stringify(baselineTransactions)}

Responde ÚNICAMENTE con JSON válido (sin markdown, sin backticks) con esta estructura:
- anomalies: array de { type: 'gasto_inusual' | 'venta_atipica' | 'factura_duplicada' | 'patron_sospechoso', description: string, severity: 'info' | 'warning' | 'critical', amount?: number, date?: string }
- summary: string con resumen de 1-2 oraciones

Si no hay anomalías, devuelve un array vacío con summary: 'Todo se ve normal.'
Solo reporta anomalías reales, no inventes.`,
      },
    ],
  })

  const text = response.choices[0]?.message?.content
  if (!text) throw new Error('AI returned empty response for anomalies')

  const cleaned = text.replace(/^```(?:json)?\s*\n?/i, '').replace(/\n?```\s*$/i, '').trim()
  try {
    return JSON.parse(cleaned)
  } catch (e) {
    throw new Error(`Failed to parse anomalies JSON: ${(e as Error).message}\nRaw: ${cleaned.slice(0, 500)}`)
  }
}

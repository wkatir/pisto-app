import { Hono } from 'hono'
import { vValidator } from '@hono/valibot-validator'
import * as v from 'valibot'
import * as reportService from './report.service'
import { dateRangeQuerySchema, intParam } from '../../shared/schemas/pagination'
import type { AppEnv } from '../../types/app-env'

const dashboardQuerySchema = v.object({
  startDate: v.optional(v.pipe(v.string(), v.isoDate())),
  endDate: v.optional(v.pipe(v.string(), v.isoDate())),
})

const topProductsQuerySchema = v.object({
  limit: intParam(1, 500),
  from: v.optional(v.pipe(v.string(), v.isoDate())),
  to: v.optional(v.pipe(v.string(), v.isoDate())),
})

const salesTrendQuerySchema = v.object({
  days: intParam(1, 365),
  startDate: v.optional(v.pipe(v.string(), v.isoDate())),
  endDate: v.optional(v.pipe(v.string(), v.isoDate())),
})

const reports = new Hono<AppEnv>()

reports.get('/dashboard', vValidator('query', dashboardQuerySchema), async (c) => {
  const businessId = c.get('businessId')
  const { startDate, endDate } = c.req.valid('query')
  const kpis = await reportService.getDashboardKPIs(businessId, startDate, endDate)
  return c.json(kpis)
})

reports.get('/sales-summary', vValidator('query', dateRangeQuerySchema), async (c) => {
  const businessId = c.get('businessId')
  const { from, to } = c.req.valid('query')
  const summary = await reportService.getSalesSummary(businessId, from, to)
  return c.json(summary)
})

reports.get('/top-products', vValidator('query', topProductsQuerySchema), async (c) => {
  const businessId = c.get('businessId')
  const { limit = 10, from, to } = c.req.valid('query')
  const products = await reportService.getTopProducts(businessId, limit, from, to)
  return c.json(products)
})

reports.get('/inventory-valuation', async (c) => {
  const businessId = c.get('businessId')
  const valuation = await reportService.getInventoryValuation(businessId)
  return c.json(valuation)
})

reports.get('/receivables-aging', async (c) => {
  const businessId = c.get('businessId')
  const aging = await reportService.getReceivablesAging(businessId)
  return c.json(aging)
})

reports.get('/purchases-by-supplier', vValidator('query', dateRangeQuerySchema), async (c) => {
  const businessId = c.get('businessId')
  const { from, to } = c.req.valid('query')
  const data = await reportService.getPurchasesBySupplier(businessId, from, to)
  return c.json(data)
})

reports.get('/sales-trend', vValidator('query', salesTrendQuerySchema), async (c) => {
  const businessId = c.get('businessId')
  const { days = 30, startDate, endDate } = c.req.valid('query')
  const trend = await reportService.getSalesTrend(businessId, days, startDate, endDate)
  return c.json(trend)
})

reports.get('/sales-by-category', async (c) => {
  const businessId = c.get('businessId')
  const data = await reportService.getSalesByCategory(businessId)
  return c.json(data)
})

reports.get('/gross-profit', vValidator('query', dateRangeQuerySchema), async (c) => {
  const businessId = c.get('businessId')
  const { from, to } = c.req.valid('query')
  const profit = await reportService.getGrossProfit(businessId, from, to)
  return c.json(profit)
})

export { reports }

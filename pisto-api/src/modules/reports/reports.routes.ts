import { Hono } from 'hono'
import * as reportService from './report.service'
import type { AppEnv } from '../../types/app-env'

const reports = new Hono<AppEnv>()

reports.get('/dashboard', async (c) => {
  const businessId = c.get('businessId')
  const kpis = await reportService.getDashboardKPIs(businessId)
  return c.json(kpis)
})

reports.get('/sales-summary', async (c) => {
  const businessId = c.get('businessId')
  const from = c.req.query('from')
  const to = c.req.query('to')
  const summary = await reportService.getSalesSummary(businessId, from, to)
  return c.json(summary)
})

reports.get('/top-products', async (c) => {
  const businessId = c.get('businessId')
  const limit = parseInt(c.req.query('limit') || '10')
  const from = c.req.query('from')
  const to = c.req.query('to')
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

reports.get('/purchases-by-supplier', async (c) => {
  const businessId = c.get('businessId')
  const from = c.req.query('from')
  const to = c.req.query('to')
  const data = await reportService.getPurchasesBySupplier(businessId, from, to)
  return c.json(data)
})

reports.get('/sales-trend', async (c) => {
  const businessId = c.get('businessId')
  const days = parseInt(c.req.query('days') || '30')
  const trend = await reportService.getSalesTrend(businessId, days)
  return c.json(trend)
})

reports.get('/sales-by-category', async (c) => {
  const businessId = c.get('businessId')
  const data = await reportService.getSalesByCategory(businessId)
  return c.json(data)
})

reports.get('/gross-profit', async (c) => {
  const businessId = c.get('businessId')
  const from = c.req.query('from')
  const to = c.req.query('to')
  const profit = await reportService.getGrossProfit(businessId, from, to)
  return c.json(profit)
})

export { reports }

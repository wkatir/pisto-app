import { Hono } from 'hono'
import { vValidator } from '@hono/valibot-validator'
import { forecastQuerySchema } from './ai-insights.schemas'
import * as forecastService from './forecast.service'
import type { AppEnv } from '../../types/app-env'

const aiInsights = new Hono<AppEnv>()

aiInsights.get('/forecast', vValidator('query', forecastQuerySchema), async (c) => {
  const businessId = c.get('businessId')
  const { days } = c.req.valid('query')
  const data = await forecastService.forecastCashFlow(businessId, days ?? 30)
  return c.json({ data })
})

aiInsights.get('/anomalies', async (c) => {
  const businessId = c.get('businessId')
  const data = await forecastService.detectAnomalies(businessId)
  return c.json({ data })
})

export { aiInsights }

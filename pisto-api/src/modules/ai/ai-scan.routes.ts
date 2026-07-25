import { Hono } from 'hono'
import { vValidator } from '@hono/valibot-validator'
import type { AppEnv } from '../../types/app-env'
import { scanReceiptSchema, categorizeExpenseSchema } from './ai-scan.schemas'
import * as scanService from './scan.service'

const aiScan = new Hono<AppEnv>()

aiScan.post('/scan-receipt', vValidator('json', scanReceiptSchema), async (c) => {
  const { image, mimeType } = c.req.valid('json')
  const result = await scanService.scanReceipt(image, mimeType)
  return c.json({ data: result.data, message: null })
})

aiScan.post('/categorize', vValidator('json', categorizeExpenseSchema), async (c) => {
  const businessId = c.get('businessId')
  const { description, amount, vendor } = c.req.valid('json')
  const result = await scanService.categorizeExpense(description, amount, vendor, businessId)
  return c.json(result)
})

export { aiScan }

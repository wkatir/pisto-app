import { Hono } from 'hono'
import { vValidator } from '@hono/valibot-validator'
import type { AppEnv } from '../../types/app-env'
import { scanReceiptSchema, categorizeExpenseSchema } from './ai-scan.schemas'
import * as scanService from './scan.service'

const aiScan = new Hono<AppEnv>()

aiScan.post('/scan-receipt', vValidator('json', scanReceiptSchema), async (c) => {
  const { image, mimeType } = c.req.valid('json')

  try {
    const result = await scanService.scanReceipt(image, mimeType)
    return c.json({ data: result.data, message: result.message ?? null })
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : 'Error al procesar la imagen'
    return c.json({ error: message }, 422)
  }
})

aiScan.post('/categorize', vValidator('json', categorizeExpenseSchema), async (c) => {
  const businessId = c.get('businessId')
  const { description, amount, vendor } = c.req.valid('json')

  try {
    const result = await scanService.categorizeExpense(description, amount, vendor, businessId)
    return c.json(result)
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : 'Error al categorizar el gasto'
    return c.json({ error: message }, 422)
  }
})

export { aiScan }

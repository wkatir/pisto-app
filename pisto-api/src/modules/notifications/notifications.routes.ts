import { Hono } from 'hono'
import { vValidator } from '@hono/valibot-validator'
import type { AppEnv } from '../../types/app-env'
import { notificationQuerySchema } from './notifications.schemas'
import * as notificationService from './notification.service'
import { sweepNotifications } from './sweep.service'
import { idParamSchema } from '../../shared/schemas/common'

const notifications = new Hono<AppEnv>()

notifications.get('/', vValidator('query', notificationQuerySchema), async (c) => {
  const businessId = c.get('businessId')
  const query = c.req.valid('query')
  const result = await notificationService.list(businessId, query)
  return c.json(result)
})

// The app polls this for the badge; sweeping here replaces a cron
notifications.get('/unread-count', async (c) => {
  const businessId = c.get('businessId')
  await sweepNotifications(businessId)
  const count = await notificationService.unreadCount(businessId)
  return c.json({ data: { count } })
})

notifications.post('/:id/read', vValidator('param', idParamSchema), async (c) => {
  const businessId = c.get('businessId')
  const { id } = c.req.valid('param')
  const data = await notificationService.markRead(businessId, id)
  return c.json({ data })
})

notifications.post('/read-all', async (c) => {
  const businessId = c.get('businessId')
  const data = await notificationService.markAllRead(businessId)
  return c.json({ data })
})

export { notifications }

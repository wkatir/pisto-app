import * as v from 'valibot'
import { intParam } from '../../shared/utils/pagination'

export const notificationQuerySchema = v.object({
  page: v.optional(intParam(1, 10000), '1'),
  limit: v.optional(intParam(1, 200), '20'),
  unreadOnly: v.optional(
    v.pipe(v.picklist(['true', 'false'], 'unreadOnly debe ser true o false'), v.transform((s) => s === 'true')),
    'false',
  ),
})

export type NotificationQuery = v.InferOutput<typeof notificationQuerySchema>

import { and, count, desc, eq, isNull } from 'drizzle-orm'
import { db } from '../../config/database'
import { notification } from '../../db/schema'
import { AppError } from '../../shared/errors/app-error'
import { paginatedResponse } from '../../shared/utils/pagination'

export interface CreateNotificationInput {
  type: 'low_stock' | 'receivable_due' | 'payable_due' | 'ai_suggestion'
  title: string
  body: string
  entityType?: string
  entityId?: string
}

export async function list(
  businessId: string,
  query: { page: number; limit: number; unreadOnly: boolean },
) {
  const conditions = [eq(notification.businessId, businessId)]
  if (query.unreadOnly) conditions.push(isNull(notification.readAt))
  const where = and(...conditions)

  const [items, [total]] = await Promise.all([
    db.select().from(notification).where(where)
      .orderBy(desc(notification.createdAt))
      .offset((query.page - 1) * query.limit)
      .limit(query.limit),
    db.select({ count: count() }).from(notification).where(where),
  ])
  return paginatedResponse(items, total!.count, query.page, query.limit)
}

export async function unreadCount(businessId: string): Promise<number> {
  const [row] = await db.select({ count: count() }).from(notification)
    .where(and(eq(notification.businessId, businessId), isNull(notification.readAt)))
  return row!.count
}

export async function markRead(businessId: string, id: string) {
  const [row] = await db.update(notification)
    .set({ readAt: new Date() })
    .where(and(eq(notification.id, id), eq(notification.businessId, businessId)))
    .returning()
  if (!row) throw new AppError(404, 'Notificación no encontrada')
  return row
}

export async function markAllRead(businessId: string) {
  const rows = await db.update(notification)
    .set({ readAt: new Date() })
    .where(and(eq(notification.businessId, businessId), isNull(notification.readAt)))
    .returning({ id: notification.id })
  return { updated: rows.length }
}

// Internal (sweep, AI). Dedupe: skip if an unread notification for the same
// type + entity already exists, so lazy sweeps don't pile up duplicates.
export async function create(businessId: string, input: CreateNotificationInput) {
  if (input.entityId) {
    const [existing] = await db.select({ id: notification.id }).from(notification)
      .where(and(
        eq(notification.businessId, businessId),
        eq(notification.type, input.type),
        eq(notification.entityId, input.entityId),
        isNull(notification.readAt),
      ))
      .limit(1)
    if (existing) return null
  }
  const [row] = await db.insert(notification).values({ businessId, ...input }).returning()
  return row!
}

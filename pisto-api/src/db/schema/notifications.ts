import { pgTable, varchar, text, timestamp, index } from 'drizzle-orm/pg-core'
import { randomUUID } from 'crypto'
import { business } from './core'

// type: 'low_stock' | 'receivable_due' | 'payable_due' | 'ai_suggestion'
export const notification = pgTable('notification', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id, { onDelete: 'cascade' }),
  type: varchar('type', { length: 30 }).notNull(),
  title: varchar('title', { length: 200 }).notNull(),
  body: text('body').notNull(),
  entityType: varchar('entity_type', { length: 30 }),
  entityId: varchar('entity_id', { length: 36 }),
  readAt: timestamp('read_at'),
  createdAt: timestamp('created_at').$defaultFn(() => new Date()).notNull(),
}, (t) => [
  index('notification_business_read_idx').on(t.businessId, t.readAt),
])

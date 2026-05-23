import { pgTable, varchar, text, numeric, timestamp, date } from 'drizzle-orm/pg-core'
import { randomUUID } from 'crypto'
import { business, appUser, paymentMethod } from './core'

export const expenseCategory = pgTable('expense_category', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id, { onDelete: 'cascade' }),
  name: varchar('name', { length: 80 }).notNull(),
  icon: varchar('icon', { length: 40 }),
  createdAt: timestamp('created_at').$defaultFn(() => new Date()).notNull(),
})

export const expense = pgTable('expense', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id, { onDelete: 'cascade' }),
  categoryId: varchar('category_id', { length: 36 }).references(() => expenseCategory.id),
  description: varchar('description', { length: 500 }).notNull(),
  amount: numeric('amount', { precision: 12, scale: 2 }).$type<string>().notNull(),
  expenseDate: date('expense_date', { mode: 'string' }).notNull(),
  paymentMethodId: varchar('payment_method_id', { length: 36 }).references(() => paymentMethod.id),
  notes: varchar('notes', { length: 500 }),
  receiptUrl: text('receipt_url'),
  createdBy: varchar('created_by', { length: 36 }).references(() => appUser.id),
  createdAt: timestamp('created_at').$defaultFn(() => new Date()).notNull(),
})

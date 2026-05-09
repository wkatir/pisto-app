import { mssqlTable, varchar, nvarchar, decimal, date, datetimeOffset } from 'drizzle-orm/mssql-core'
import { randomUUID } from 'crypto'
import { business, appUser, paymentMethod } from './core'

export const expenseCategory = mssqlTable('expense_category', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id, { onDelete: 'cascade' }),
  name: nvarchar('name', { length: 80 }).notNull(),
  icon: nvarchar('icon', { length: 40 }),
  createdAt: datetimeOffset('created_at').$defaultFn(() => new Date()).notNull(),
})

export const expense = mssqlTable('expense', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id, { onDelete: 'cascade' }),
  categoryId: varchar('category_id', { length: 36 }).references(() => expenseCategory.id),
  description: nvarchar('description', { length: 500 }).notNull(),
  amount: decimal('amount', { precision: 12, scale: 2 }).$type<string>().notNull(),
  expenseDate: date('expense_date', { mode: 'string' }).notNull(),
  paymentMethodId: varchar('payment_method_id', { length: 36 }).references(() => paymentMethod.id),
  notes: nvarchar('notes', { length: 500 }),
  receiptUrl: nvarchar('receipt_url', { length: 'max' }),
  createdBy: varchar('created_by', { length: 36 }).references(() => appUser.id),
  createdAt: datetimeOffset('created_at').$defaultFn(() => new Date()).notNull(),
})

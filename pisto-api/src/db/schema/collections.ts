import { mssqlTable, varchar, nvarchar, decimal, datetimeOffset, date, uniqueIndex, index } from 'drizzle-orm/mssql-core'
import { randomUUID } from 'crypto'
import { business, appUser, paymentMethod } from './core'
import { customer, sale } from './sales'

export const accountReceivable = mssqlTable('account_receivable', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id),
  customerId: varchar('customer_id', { length: 36 }).notNull().references(() => customer.id),
  saleId: varchar('sale_id', { length: 36 }).notNull().references(() => sale.id),
  originalAmount: decimal('original_amount', { precision: 12, scale: 2 }).notNull(),
  balance: decimal('balance', { precision: 12, scale: 2 }).notNull(),
  dueDate: date('due_date').notNull(),
  status: nvarchar('status', { length: 20 }).default('pending').notNull(),
  createdAt: datetimeOffset('created_at').$defaultFn(() => new Date()).notNull(),
  updatedAt: datetimeOffset('updated_at').$defaultFn(() => new Date()).notNull(),
}, (t) => [
  index('ar_customer_idx').on(t.customerId),
  index('ar_business_status_idx').on(t.businessId, t.status),
  index('ar_due_date_idx').on(t.dueDate),
])

export const collectionPayment = mssqlTable('collection_payment', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id),
  accountReceivableId: varchar('account_receivable_id', { length: 36 }).notNull().references(() => accountReceivable.id),
  paymentMethodId: varchar('payment_method_id', { length: 36 }).notNull().references(() => paymentMethod.id),
  receiptNumber: nvarchar('receipt_number', { length: 30 }),
  amount: decimal('amount', { precision: 12, scale: 2 }).notNull(),
  paymentDate: date('payment_date').$defaultFn(() => new Date()).notNull(),
  reference: nvarchar('reference', { length: 100 }),
  notes: nvarchar('notes', { length: 'max' }),
  collectedBy: varchar('collected_by', { length: 36 }).references(() => appUser.id),
  createdAt: datetimeOffset('created_at').$defaultFn(() => new Date()).notNull(),
}, (t) => [
  uniqueIndex('collection_payment_receipt_idx').on(t.businessId, t.receiptNumber),
])

export const statementHistory = mssqlTable('statement_history', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  customerId: varchar('customer_id', { length: 36 }).notNull().references(() => customer.id),
  sentDate: datetimeOffset('sent_date').$defaultFn(() => new Date()).notNull(),
  sentVia: nvarchar('sent_via', { length: 20 }),
  totalDue: decimal('total_due', { precision: 12, scale: 2 }).notNull(),
  generatedBy: varchar('generated_by', { length: 36 }).references(() => appUser.id),
})

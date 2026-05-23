import { pgTable, varchar, text, numeric, timestamp, date, uniqueIndex, index } from 'drizzle-orm/pg-core'
import { randomUUID } from 'crypto'
import { business, appUser, paymentMethod } from './core'
import { customer, sale } from './sales'

export const accountReceivable = pgTable('account_receivable', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id),
  customerId: varchar('customer_id', { length: 36 }).notNull().references(() => customer.id),
  saleId: varchar('sale_id', { length: 36 }).notNull().references(() => sale.id),
  originalAmount: numeric('original_amount', { precision: 12, scale: 2 }).notNull(),
  balance: numeric('balance', { precision: 12, scale: 2 }).notNull(),
  dueDate: date('due_date').notNull(),
  status: varchar('status', { length: 20 }).default('pending').notNull(),
  createdAt: timestamp('created_at').$defaultFn(() => new Date()).notNull(),
  updatedAt: timestamp('updated_at').$defaultFn(() => new Date()).notNull(),
}, (t) => [
  index('ar_customer_idx').on(t.customerId),
  index('ar_business_status_idx').on(t.businessId, t.status),
  index('ar_due_date_idx').on(t.dueDate),
])

export const collectionPayment = pgTable('collection_payment', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id),
  accountReceivableId: varchar('account_receivable_id', { length: 36 }).notNull().references(() => accountReceivable.id),
  paymentMethodId: varchar('payment_method_id', { length: 36 }).notNull().references(() => paymentMethod.id),
  receiptNumber: varchar('receipt_number', { length: 30 }),
  amount: numeric('amount', { precision: 12, scale: 2 }).notNull(),
  paymentDate: date('payment_date').$defaultFn(() => new Date()).notNull(),
  reference: varchar('reference', { length: 100 }),
  notes: text('notes'),
  collectedBy: varchar('collected_by', { length: 36 }).references(() => appUser.id),
  createdAt: timestamp('created_at').$defaultFn(() => new Date()).notNull(),
}, (t) => [
  uniqueIndex('collection_payment_receipt_idx').on(t.businessId, t.receiptNumber),
])

export const statementHistory = pgTable('statement_history', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  customerId: varchar('customer_id', { length: 36 }).notNull().references(() => customer.id),
  sentDate: timestamp('sent_date').$defaultFn(() => new Date()).notNull(),
  sentVia: varchar('sent_via', { length: 20 }),
  totalDue: numeric('total_due', { precision: 12, scale: 2 }).notNull(),
  generatedBy: varchar('generated_by', { length: 36 }).references(() => appUser.id),
})

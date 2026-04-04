import { pgTable, uuid, varchar, text, decimal, timestamp, date, integer, bigserial, uniqueIndex, index } from 'drizzle-orm/pg-core'
import { business, appUser, paymentMethod } from './core'
import { customer, sale } from './sales'

export const accountReceivable = pgTable('account_receivable', {
  id: uuid('id').primaryKey().defaultRandom(),
  businessId: uuid('business_id').notNull().references(() => business.id),
  customerId: uuid('customer_id').notNull().references(() => customer.id),
  saleId: uuid('sale_id').notNull().references(() => sale.id),
  originalAmount: decimal('original_amount', { precision: 12, scale: 2 }).notNull(),
  balance: decimal('balance', { precision: 12, scale: 2 }).notNull(),
  dueDate: date('due_date').notNull(),
  status: varchar('status', { length: 20 }).default('pending').notNull(),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
}, (t) => [
  index('ar_customer_idx').on(t.customerId),
  index('ar_business_status_idx').on(t.businessId, t.status),
])

export const collectionPayment = pgTable('collection_payment', {
  id: uuid('id').primaryKey().defaultRandom(),
  businessId: uuid('business_id').notNull().references(() => business.id),
  accountReceivableId: uuid('account_receivable_id').notNull().references(() => accountReceivable.id),
  paymentMethodId: integer('payment_method_id').notNull().references(() => paymentMethod.id),
  receiptNumber: varchar('receipt_number', { length: 30 }),
  amount: decimal('amount', { precision: 12, scale: 2 }).notNull(),
  paymentDate: date('payment_date').defaultNow().notNull(),
  reference: varchar('reference', { length: 100 }),
  notes: text('notes'),
  collectedBy: uuid('collected_by').references(() => appUser.id),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
}, (t) => [
  uniqueIndex('collection_payment_receipt_idx').on(t.businessId, t.receiptNumber),
])

export const statementHistory = pgTable('statement_history', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  customerId: uuid('customer_id').notNull().references(() => customer.id),
  sentDate: timestamp('sent_date', { withTimezone: true }).defaultNow().notNull(),
  sentVia: varchar('sent_via', { length: 20 }),
  totalDue: decimal('total_due', { precision: 12, scale: 2 }).notNull(),
  generatedBy: uuid('generated_by').references(() => appUser.id),
})

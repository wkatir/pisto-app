import { pgTable, uuid, varchar, text, boolean, timestamp, integer, decimal, serial, date, uniqueIndex, index } from 'drizzle-orm/pg-core'
import { business, appUser, documentType, paymentMethod, tax } from './core'
import { product, warehouse } from './inventory'

export const customer = pgTable('customer', {
  id: uuid('id').primaryKey().defaultRandom(),
  businessId: uuid('business_id').notNull().references(() => business.id),
  customerType: varchar('customer_type', { length: 10 }).default('person').notNull(),
  firstName: varchar('first_name', { length: 80 }),
  lastName: varchar('last_name', { length: 80 }),
  companyName: varchar('company_name', { length: 150 }),
  taxId: varchar('tax_id', { length: 20 }),
  taxReg: varchar('tax_reg', { length: 20 }),
  email: varchar('email', { length: 150 }),
  phone: varchar('phone', { length: 20 }),
  address: text('address'),
  creditLimit: decimal('credit_limit', { precision: 12, scale: 2 }).default('0').notNull(),
  creditDays: integer('credit_days').default(0).notNull(),
  isActive: boolean('is_active').default(true).notNull(),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
})

export const sale = pgTable('sale', {
  id: uuid('id').primaryKey().defaultRandom(),
  businessId: uuid('business_id').notNull().references(() => business.id),
  customerId: uuid('customer_id').references(() => customer.id),
  documentTypeId: integer('document_type_id').notNull().references(() => documentType.id),
  warehouseId: integer('warehouse_id').notNull().references(() => warehouse.id),
  saleNumber: varchar('sale_number', { length: 30 }).notNull(),
  saleDate: date('sale_date').defaultNow().notNull(),
  dueDate: date('due_date'),
  status: varchar('status', { length: 20 }).default('completed').notNull(),
  paymentStatus: varchar('payment_status', { length: 20 }).default('paid').notNull(),
  subtotal: decimal('subtotal', { precision: 12, scale: 2 }).default('0').notNull(),
  taxAmount: decimal('tax_amount', { precision: 12, scale: 2 }).default('0').notNull(),
  discountAmount: decimal('discount_amount', { precision: 12, scale: 2 }).default('0').notNull(),
  total: decimal('total', { precision: 12, scale: 2 }).default('0').notNull(),
  notes: text('notes'),
  createdBy: uuid('created_by').references(() => appUser.id),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  cancelledAt: timestamp('cancelled_at', { withTimezone: true }),
  cancelledBy: uuid('cancelled_by').references(() => appUser.id),
}, (t) => [
  uniqueIndex('sale_business_number_idx').on(t.businessId, t.saleNumber),
  index('sale_business_date_idx').on(t.businessId, t.saleDate),
  index('sale_customer_idx').on(t.customerId),
  index('sale_payment_status_idx').on(t.businessId, t.paymentStatus),
])

export const saleLine = pgTable('sale_line', {
  id: serial('id').primaryKey(),
  saleId: uuid('sale_id').notNull().references(() => sale.id, { onDelete: 'cascade' }),
  productId: uuid('product_id').notNull().references(() => product.id),
  quantity: decimal('quantity', { precision: 12, scale: 2 }).notNull(),
  unitPrice: decimal('unit_price', { precision: 12, scale: 2 }).notNull(),
  discountPct: decimal('discount_pct', { precision: 5, scale: 2 }).default('0').notNull(),
  discountAmount: decimal('discount_amount', { precision: 12, scale: 2 }).default('0').notNull(),
  taxId: integer('tax_id').references(() => tax.id),
  taxAmount: decimal('tax_amount', { precision: 12, scale: 2 }).default('0').notNull(),
  lineTotal: decimal('line_total', { precision: 12, scale: 2 }).notNull(),
})

export const saleLineTax = pgTable('sale_line_tax', {
  id: serial('id').primaryKey(),
  saleLineId: integer('sale_line_id').notNull().references(() => saleLine.id, { onDelete: 'cascade' }),
  taxId: integer('tax_id').notNull().references(() => tax.id),
  taxBase: decimal('tax_base', { precision: 12, scale: 2 }).notNull(),
  taxAmount: decimal('tax_amount', { precision: 12, scale: 2 }).notNull(),
})

export const salePayment = pgTable('sale_payment', {
  id: serial('id').primaryKey(),
  saleId: uuid('sale_id').notNull().references(() => sale.id, { onDelete: 'cascade' }),
  paymentMethodId: integer('payment_method_id').notNull().references(() => paymentMethod.id),
  amount: decimal('amount', { precision: 12, scale: 2 }).notNull(),
  reference: varchar('reference', { length: 100 }),
  paymentDate: date('payment_date').defaultNow().notNull(),
})

export const creditNote = pgTable('credit_note', {
  id: uuid('id').primaryKey().defaultRandom(),
  businessId: uuid('business_id').notNull().references(() => business.id),
  saleId: uuid('sale_id').notNull().references(() => sale.id),
  customerId: uuid('customer_id').notNull().references(() => customer.id),
  noteNumber: varchar('note_number', { length: 30 }).notNull(),
  reason: text('reason').notNull(),
  total: decimal('total', { precision: 12, scale: 2 }).notNull(),
  status: varchar('status', { length: 20 }).default('active').notNull(),
  createdBy: uuid('created_by').references(() => appUser.id),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
}, (t) => [
  uniqueIndex('credit_note_business_number_idx').on(t.businessId, t.noteNumber),
])

export const creditNoteLine = pgTable('credit_note_line', {
  id: serial('id').primaryKey(),
  creditNoteId: uuid('credit_note_id').notNull().references(() => creditNote.id, { onDelete: 'cascade' }),
  productId: uuid('product_id').notNull().references(() => product.id),
  quantity: decimal('quantity', { precision: 12, scale: 2 }).notNull(),
  unitPrice: decimal('unit_price', { precision: 12, scale: 2 }).notNull(),
  lineTotal: decimal('line_total', { precision: 12, scale: 2 }).notNull(),
})

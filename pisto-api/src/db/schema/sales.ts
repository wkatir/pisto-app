import { pgTable, varchar, text, boolean, timestamp, numeric, integer, date, uniqueIndex, index } from 'drizzle-orm/pg-core'
import { randomUUID } from 'crypto'
import { business, appUser, documentType, paymentMethod, tax } from './core'
import { product, warehouse } from './inventory'

export const customer = pgTable('customer', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id),
  customerType: varchar('customer_type', { length: 10 }).default('person').notNull(),
  firstName: varchar('first_name', { length: 80 }),
  lastName: varchar('last_name', { length: 80 }),
  companyName: varchar('company_name', { length: 150 }),
  taxId: varchar('tax_id', { length: 20 }),
  taxReg: varchar('tax_reg', { length: 20 }),
  email: varchar('email', { length: 150 }),
  phone: varchar('phone', { length: 20 }),
  address: text('address'),
  creditLimit: numeric('credit_limit', { precision: 12, scale: 2 }).default(0).notNull(),
  creditDays: integer('credit_days').default(0).notNull(),
  isActive: boolean('is_active').default(true).notNull(),
  createdAt: timestamp('created_at').$defaultFn(() => new Date()).notNull(),
  updatedAt: timestamp('updated_at').$defaultFn(() => new Date()).notNull(),
})

export const sale = pgTable('sale', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id),
  customerId: varchar('customer_id', { length: 36 }).references(() => customer.id),
  documentTypeId: varchar('document_type_id', { length: 36 }).notNull().references(() => documentType.id),
  warehouseId: varchar('warehouse_id', { length: 36 }).notNull().references(() => warehouse.id),
  saleNumber: varchar('sale_number', { length: 30 }).notNull(),
  saleDate: date('sale_date').$defaultFn(() => new Date()).notNull(),
  dueDate: date('due_date'),
  status: varchar('status', { length: 20 }).default('completed').notNull(),
  paymentStatus: varchar('payment_status', { length: 20 }).default('paid').notNull(),
  subtotal: numeric('subtotal', { precision: 12, scale: 2 }).default(0).notNull(),
  taxAmount: numeric('tax_amount', { precision: 12, scale: 2 }).default(0).notNull(),
  discountAmount: numeric('discount_amount', { precision: 12, scale: 2 }).default(0).notNull(),
  total: numeric('total', { precision: 12, scale: 2 }).default(0).notNull(),
  notes: text('notes'),
  createdBy: varchar('created_by', { length: 36 }).references(() => appUser.id),
  createdAt: timestamp('created_at').$defaultFn(() => new Date()).notNull(),
  cancelledAt: timestamp('cancelled_at'),
  cancelledBy: varchar('cancelled_by', { length: 36 }).references(() => appUser.id),
}, (t) => [
  uniqueIndex('sale_business_number_idx').on(t.businessId, t.saleNumber),
  index('sale_business_date_idx').on(t.businessId, t.saleDate),
  index('sale_customer_idx').on(t.customerId),
  index('sale_payment_status_idx').on(t.businessId, t.paymentStatus),
])

export const saleLine = pgTable('sale_line', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  saleId: varchar('sale_id', { length: 36 }).notNull().references(() => sale.id, { onDelete: 'cascade' }),
  productId: varchar('product_id', { length: 36 }).notNull().references(() => product.id),
  quantity: numeric('quantity', { precision: 12, scale: 2 }).notNull(),
  unitPrice: numeric('unit_price', { precision: 12, scale: 2 }).notNull(),
  discountPct: numeric('discount_pct', { precision: 5, scale: 2 }).default(0).notNull(),
  discountAmount: numeric('discount_amount', { precision: 12, scale: 2 }).default(0).notNull(),
  taxId: varchar('tax_id', { length: 36 }).references(() => tax.id),
  taxAmount: numeric('tax_amount', { precision: 12, scale: 2 }).default(0).notNull(),
  lineTotal: numeric('line_total', { precision: 12, scale: 2 }).notNull(),
})

export const saleLineTax = pgTable('sale_line_tax', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  saleLineId: varchar('sale_line_id', { length: 36 }).notNull().references(() => saleLine.id, { onDelete: 'cascade' }),
  taxId: varchar('tax_id', { length: 36 }).notNull().references(() => tax.id),
  taxBase: numeric('tax_base', { precision: 12, scale: 2 }).notNull(),
  taxAmount: numeric('tax_amount', { precision: 12, scale: 2 }).notNull(),
})

export const salePayment = pgTable('sale_payment', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  saleId: varchar('sale_id', { length: 36 }).notNull().references(() => sale.id, { onDelete: 'cascade' }),
  paymentMethodId: varchar('payment_method_id', { length: 36 }).notNull().references(() => paymentMethod.id),
  amount: numeric('amount', { precision: 12, scale: 2 }).notNull(),
  reference: varchar('reference', { length: 100 }),
  paymentDate: date('payment_date').$defaultFn(() => new Date()).notNull(),
})

export const creditNote = pgTable('credit_note', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id),
  saleId: varchar('sale_id', { length: 36 }).notNull().references(() => sale.id),
  customerId: varchar('customer_id', { length: 36 }).notNull().references(() => customer.id),
  noteNumber: varchar('note_number', { length: 30 }).notNull(),
  reason: text('reason').notNull(),
  total: numeric('total', { precision: 12, scale: 2 }).notNull(),
  status: varchar('status', { length: 20 }).default('active').notNull(),
  createdBy: varchar('created_by', { length: 36 }).references(() => appUser.id),
  createdAt: timestamp('created_at').$defaultFn(() => new Date()).notNull(),
}, (t) => [
  uniqueIndex('credit_note_business_number_idx').on(t.businessId, t.noteNumber),
])

export const creditNoteLine = pgTable('credit_note_line', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  creditNoteId: varchar('credit_note_id', { length: 36 }).notNull().references(() => creditNote.id, { onDelete: 'cascade' }),
  productId: varchar('product_id', { length: 36 }).notNull().references(() => product.id),
  quantity: numeric('quantity', { precision: 12, scale: 2 }).notNull(),
  unitPrice: numeric('unit_price', { precision: 12, scale: 2 }).notNull(),
  lineTotal: numeric('line_total', { precision: 12, scale: 2 }).notNull(),
})

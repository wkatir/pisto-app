import { mssqlTable, varchar, nvarchar, bit, datetimeOffset, int, decimal, date, uniqueIndex, index } from 'drizzle-orm/mssql-core'
import { randomUUID } from 'crypto'
import { business, appUser, documentType, paymentMethod, tax } from './core'
import { product, warehouse } from './inventory'

export const customer = mssqlTable('customer', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id),
  customerType: nvarchar('customer_type', { length: 10 }).default('person').notNull(),
  firstName: nvarchar('first_name', { length: 80 }),
  lastName: nvarchar('last_name', { length: 80 }),
  companyName: nvarchar('company_name', { length: 150 }),
  taxId: nvarchar('tax_id', { length: 20 }),
  taxReg: nvarchar('tax_reg', { length: 20 }),
  email: nvarchar('email', { length: 150 }),
  phone: nvarchar('phone', { length: 20 }),
  address: nvarchar('address', { length: 'max' }),
  creditLimit: decimal('credit_limit', { precision: 12, scale: 2 }).default(0).notNull(),
  creditDays: int('credit_days').default(0).notNull(),
  isActive: bit('is_active').default(true).notNull(),
  createdAt: datetimeOffset('created_at').$defaultFn(() => new Date()).notNull(),
  updatedAt: datetimeOffset('updated_at').$defaultFn(() => new Date()).notNull(),
})

export const sale = mssqlTable('sale', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id),
  customerId: varchar('customer_id', { length: 36 }).references(() => customer.id),
  documentTypeId: varchar('document_type_id', { length: 36 }).notNull().references(() => documentType.id),
  warehouseId: varchar('warehouse_id', { length: 36 }).notNull().references(() => warehouse.id),
  saleNumber: nvarchar('sale_number', { length: 30 }).notNull(),
  saleDate: date('sale_date').$defaultFn(() => new Date()).notNull(),
  dueDate: date('due_date'),
  status: nvarchar('status', { length: 20 }).default('completed').notNull(),
  paymentStatus: nvarchar('payment_status', { length: 20 }).default('paid').notNull(),
  subtotal: decimal('subtotal', { precision: 12, scale: 2 }).default(0).notNull(),
  taxAmount: decimal('tax_amount', { precision: 12, scale: 2 }).default(0).notNull(),
  discountAmount: decimal('discount_amount', { precision: 12, scale: 2 }).default(0).notNull(),
  total: decimal('total', { precision: 12, scale: 2 }).default(0).notNull(),
  notes: nvarchar('notes', { length: 'max' }),
  createdBy: varchar('created_by', { length: 36 }).references(() => appUser.id),
  createdAt: datetimeOffset('created_at').$defaultFn(() => new Date()).notNull(),
  cancelledAt: datetimeOffset('cancelled_at'),
  cancelledBy: varchar('cancelled_by', { length: 36 }).references(() => appUser.id),
}, (t) => [
  uniqueIndex('sale_business_number_idx').on(t.businessId, t.saleNumber),
  index('sale_business_date_idx').on(t.businessId, t.saleDate),
  index('sale_customer_idx').on(t.customerId),
  index('sale_payment_status_idx').on(t.businessId, t.paymentStatus),
])

export const saleLine = mssqlTable('sale_line', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  saleId: varchar('sale_id', { length: 36 }).notNull().references(() => sale.id, { onDelete: 'cascade' }),
  productId: varchar('product_id', { length: 36 }).notNull().references(() => product.id),
  quantity: decimal('quantity', { precision: 12, scale: 2 }).notNull(),
  unitPrice: decimal('unit_price', { precision: 12, scale: 2 }).notNull(),
  discountPct: decimal('discount_pct', { precision: 5, scale: 2 }).default(0).notNull(),
  discountAmount: decimal('discount_amount', { precision: 12, scale: 2 }).default(0).notNull(),
  taxId: varchar('tax_id', { length: 36 }).references(() => tax.id),
  taxAmount: decimal('tax_amount', { precision: 12, scale: 2 }).default(0).notNull(),
  lineTotal: decimal('line_total', { precision: 12, scale: 2 }).notNull(),
})

export const saleLineTax = mssqlTable('sale_line_tax', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  saleLineId: varchar('sale_line_id', { length: 36 }).notNull().references(() => saleLine.id, { onDelete: 'cascade' }),
  taxId: varchar('tax_id', { length: 36 }).notNull().references(() => tax.id),
  taxBase: decimal('tax_base', { precision: 12, scale: 2 }).notNull(),
  taxAmount: decimal('tax_amount', { precision: 12, scale: 2 }).notNull(),
})

export const salePayment = mssqlTable('sale_payment', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  saleId: varchar('sale_id', { length: 36 }).notNull().references(() => sale.id, { onDelete: 'cascade' }),
  paymentMethodId: varchar('payment_method_id', { length: 36 }).notNull().references(() => paymentMethod.id),
  amount: decimal('amount', { precision: 12, scale: 2 }).notNull(),
  reference: nvarchar('reference', { length: 100 }),
  paymentDate: date('payment_date').$defaultFn(() => new Date()).notNull(),
})

export const creditNote = mssqlTable('credit_note', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id),
  saleId: varchar('sale_id', { length: 36 }).notNull().references(() => sale.id),
  customerId: varchar('customer_id', { length: 36 }).notNull().references(() => customer.id),
  noteNumber: nvarchar('note_number', { length: 30 }).notNull(),
  reason: nvarchar('reason', { length: 'max' }).notNull(),
  total: decimal('total', { precision: 12, scale: 2 }).notNull(),
  status: nvarchar('status', { length: 20 }).default('active').notNull(),
  createdBy: varchar('created_by', { length: 36 }).references(() => appUser.id),
  createdAt: datetimeOffset('created_at').$defaultFn(() => new Date()).notNull(),
}, (t) => [
  uniqueIndex('credit_note_business_number_idx').on(t.businessId, t.noteNumber),
])

export const creditNoteLine = mssqlTable('credit_note_line', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  creditNoteId: varchar('credit_note_id', { length: 36 }).notNull().references(() => creditNote.id, { onDelete: 'cascade' }),
  productId: varchar('product_id', { length: 36 }).notNull().references(() => product.id),
  quantity: decimal('quantity', { precision: 12, scale: 2 }).notNull(),
  unitPrice: decimal('unit_price', { precision: 12, scale: 2 }).notNull(),
  lineTotal: decimal('line_total', { precision: 12, scale: 2 }).notNull(),
})

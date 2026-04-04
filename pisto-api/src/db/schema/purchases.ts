import { pgTable, uuid, varchar, text, boolean, timestamp, date, integer, decimal, uniqueIndex, index } from 'drizzle-orm/pg-core'
import { business, appUser, paymentMethod, tax } from './core'
import { product, warehouse } from './inventory'

export const supplier = pgTable('supplier', {
  id: uuid('id').primaryKey().defaultRandom(),
  businessId: uuid('business_id').notNull().references(() => business.id),
  companyName: varchar('company_name', { length: 150 }).notNull(),
  contactName: varchar('contact_name', { length: 100 }),
  taxId: varchar('tax_id', { length: 20 }),
  phone: varchar('phone', { length: 20 }),
  email: varchar('email', { length: 150 }),
  address: text('address'),
  paymentTerms: integer('payment_terms').default(30).notNull(),
  isActive: boolean('is_active').default(true).notNull(),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
})

export const supplierProduct = pgTable('supplier_product', {
  id: uuid('id').primaryKey().defaultRandom(),
  supplierId: uuid('supplier_id').notNull().references(() => supplier.id),
  productId: uuid('product_id').notNull().references(() => product.id),
  supplierSku: varchar('supplier_sku', { length: 50 }),
  supplierPrice: decimal('supplier_price', { precision: 12, scale: 2 }),
  leadTimeDays: integer('lead_time_days'),
}, (t) => [
  uniqueIndex('supplier_product_unique').on(t.supplierId, t.productId),
])

export const purchaseOrder = pgTable('purchase_order', {
  id: uuid('id').primaryKey().defaultRandom(),
  businessId: uuid('business_id').notNull().references(() => business.id),
  supplierId: uuid('supplier_id').notNull().references(() => supplier.id),
  warehouseId: uuid('warehouse_id').notNull().references(() => warehouse.id),
  orderNumber: varchar('order_number', { length: 30 }).notNull(),
  orderDate: date('order_date').defaultNow().notNull(),
  expectedDate: date('expected_date'),
  status: varchar('status', { length: 20 }).default('draft').notNull(),
  subtotal: decimal('subtotal', { precision: 12, scale: 2 }).default('0').notNull(),
  taxAmount: decimal('tax_amount', { precision: 12, scale: 2 }).default('0').notNull(),
  total: decimal('total', { precision: 12, scale: 2 }).default('0').notNull(),
  notes: text('notes'),
  createdBy: uuid('created_by').references(() => appUser.id),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
}, (t) => [
  uniqueIndex('po_business_number_idx').on(t.businessId, t.orderNumber),
  index('po_supplier_idx').on(t.supplierId),
])

export const purchaseOrderLine = pgTable('purchase_order_line', {
  id: uuid('id').primaryKey().defaultRandom(),
  purchaseOrderId: uuid('purchase_order_id').notNull().references(() => purchaseOrder.id, { onDelete: 'cascade' }),
  productId: uuid('product_id').notNull().references(() => product.id),
  quantityOrdered: decimal('quantity_ordered', { precision: 12, scale: 2 }).notNull(),
  quantityReceived: decimal('quantity_received', { precision: 12, scale: 2 }).default('0').notNull(),
  unitCost: decimal('unit_cost', { precision: 12, scale: 2 }).notNull(),
  taxId: uuid('tax_id').references(() => tax.id),
  taxAmount: decimal('tax_amount', { precision: 12, scale: 2 }).default('0').notNull(),
  lineTotal: decimal('line_total', { precision: 12, scale: 2 }).notNull(),
})

export const goodsReceipt = pgTable('goods_receipt', {
  id: uuid('id').primaryKey().defaultRandom(),
  purchaseOrderId: uuid('purchase_order_id').notNull().references(() => purchaseOrder.id),
  receiptNumber: varchar('receipt_number', { length: 30 }).notNull(),
  receiptDate: date('receipt_date').defaultNow().notNull(),
  notes: text('notes'),
  receivedBy: uuid('received_by').references(() => appUser.id),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
})

export const goodsReceiptLine = pgTable('goods_receipt_line', {
  id: uuid('id').primaryKey().defaultRandom(),
  goodsReceiptId: uuid('goods_receipt_id').notNull().references(() => goodsReceipt.id, { onDelete: 'cascade' }),
  purchaseOrderLineId: uuid('purchase_order_line_id').notNull().references(() => purchaseOrderLine.id),
  productId: uuid('product_id').notNull().references(() => product.id),
  quantityReceived: decimal('quantity_received', { precision: 12, scale: 2 }).notNull(),
})

export const accountPayable = pgTable('account_payable', {
  id: uuid('id').primaryKey().defaultRandom(),
  businessId: uuid('business_id').notNull().references(() => business.id),
  supplierId: uuid('supplier_id').notNull().references(() => supplier.id),
  purchaseOrderId: uuid('purchase_order_id').notNull().references(() => purchaseOrder.id),
  originalAmount: decimal('original_amount', { precision: 12, scale: 2 }).notNull(),
  balance: decimal('balance', { precision: 12, scale: 2 }).notNull(),
  dueDate: date('due_date').notNull(),
  status: varchar('status', { length: 20 }).default('pending').notNull(),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
}, (t) => [
  index('ap_business_status_idx').on(t.businessId, t.status),
])

export const supplierPayment = pgTable('supplier_payment', {
  id: uuid('id').primaryKey().defaultRandom(),
  businessId: uuid('business_id').notNull().references(() => business.id),
  accountPayableId: uuid('account_payable_id').notNull().references(() => accountPayable.id),
  paymentMethodId: uuid('payment_method_id').notNull().references(() => paymentMethod.id),
  amount: decimal('amount', { precision: 12, scale: 2 }).notNull(),
  paymentDate: date('payment_date').defaultNow().notNull(),
  reference: varchar('reference', { length: 100 }),
  notes: text('notes'),
  paidBy: uuid('paid_by').references(() => appUser.id),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
})

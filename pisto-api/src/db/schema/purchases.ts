import { pgTable, varchar, text, boolean, timestamp, numeric, integer, date, uniqueIndex, index } from 'drizzle-orm/pg-core'
import { randomUUID } from 'crypto'
import { business, appUser, paymentMethod, tax } from './core'
import { product, warehouse } from './inventory'

export const supplier = pgTable('supplier', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id),
  companyName: varchar('company_name', { length: 150 }).notNull(),
  contactName: varchar('contact_name', { length: 100 }),
  taxId: varchar('tax_id', { length: 20 }),
  phone: varchar('phone', { length: 20 }),
  email: varchar('email', { length: 150 }),
  address: text('address'),
  paymentTerms: integer('payment_terms').default(30).notNull(),
  isActive: boolean('is_active').default(true).notNull(),
  createdAt: timestamp('created_at').$defaultFn(() => new Date()).notNull(),
  updatedAt: timestamp('updated_at').$defaultFn(() => new Date()).notNull(),
})

export const supplierProduct = pgTable('supplier_product', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  supplierId: varchar('supplier_id', { length: 36 }).notNull().references(() => supplier.id),
  productId: varchar('product_id', { length: 36 }).notNull().references(() => product.id),
  supplierSku: varchar('supplier_sku', { length: 50 }),
  supplierPrice: numeric('supplier_price', { precision: 12, scale: 2 }),
  leadTimeDays: integer('lead_time_days'),
}, (t) => [
  uniqueIndex('supplier_product_unique').on(t.supplierId, t.productId),
])

export const purchaseOrder = pgTable('purchase_order', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id),
  supplierId: varchar('supplier_id', { length: 36 }).notNull().references(() => supplier.id),
  warehouseId: varchar('warehouse_id', { length: 36 }).notNull().references(() => warehouse.id),
  orderNumber: varchar('order_number', { length: 30 }).notNull(),
  orderDate: date('order_date').$defaultFn(() => new Date().toISOString().slice(0, 10)).notNull(),
  expectedDate: date('expected_date'),
  status: varchar('status', { length: 20 }).default('draft').notNull(),
  subtotal: numeric('subtotal', { precision: 12, scale: 2 }).default('0').notNull(),
  taxAmount: numeric('tax_amount', { precision: 12, scale: 2 }).default('0').notNull(),
  total: numeric('total', { precision: 12, scale: 2 }).default('0').notNull(),
  notes: text('notes'),
  createdBy: varchar('created_by', { length: 36 }).references(() => appUser.id),
  createdAt: timestamp('created_at').$defaultFn(() => new Date()).notNull(),
}, (t) => [
  uniqueIndex('po_business_number_idx').on(t.businessId, t.orderNumber),
  index('po_supplier_idx').on(t.supplierId),
])

export const purchaseOrderLine = pgTable('purchase_order_line', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  purchaseOrderId: varchar('purchase_order_id', { length: 36 }).notNull().references(() => purchaseOrder.id, { onDelete: 'cascade' }),
  productId: varchar('product_id', { length: 36 }).notNull().references(() => product.id),
  quantityOrdered: numeric('quantity_ordered', { precision: 12, scale: 2 }).notNull(),
  quantityReceived: numeric('quantity_received', { precision: 12, scale: 2 }).default('0').notNull(),
  unitCost: numeric('unit_cost', { precision: 12, scale: 2 }).notNull(),
  taxId: varchar('tax_id', { length: 36 }).references(() => tax.id),
  taxAmount: numeric('tax_amount', { precision: 12, scale: 2 }).default('0').notNull(),
  lineTotal: numeric('line_total', { precision: 12, scale: 2 }).notNull(),
})

export const goodsReceipt = pgTable('goods_receipt', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  purchaseOrderId: varchar('purchase_order_id', { length: 36 }).notNull().references(() => purchaseOrder.id),
  receiptNumber: varchar('receipt_number', { length: 30 }).notNull(),
  receiptDate: date('receipt_date').$defaultFn(() => new Date().toISOString().slice(0, 10)).notNull(),
  notes: text('notes'),
  receivedBy: varchar('received_by', { length: 36 }).references(() => appUser.id),
  createdAt: timestamp('created_at').$defaultFn(() => new Date()).notNull(),
})

export const goodsReceiptLine = pgTable('goods_receipt_line', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  goodsReceiptId: varchar('goods_receipt_id', { length: 36 }).notNull().references(() => goodsReceipt.id, { onDelete: 'cascade' }),
  purchaseOrderLineId: varchar('purchase_order_line_id', { length: 36 }).notNull().references(() => purchaseOrderLine.id),
  productId: varchar('product_id', { length: 36 }).notNull().references(() => product.id),
  quantityReceived: numeric('quantity_received', { precision: 12, scale: 2 }).notNull(),
})

export const accountPayable = pgTable('account_payable', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id),
  supplierId: varchar('supplier_id', { length: 36 }).notNull().references(() => supplier.id),
  purchaseOrderId: varchar('purchase_order_id', { length: 36 }).notNull().references(() => purchaseOrder.id),
  originalAmount: numeric('original_amount', { precision: 12, scale: 2 }).notNull(),
  balance: numeric('balance', { precision: 12, scale: 2 }).notNull(),
  dueDate: date('due_date').notNull(),
  status: varchar('status', { length: 20 }).default('pending').notNull(),
  createdAt: timestamp('created_at').$defaultFn(() => new Date()).notNull(),
  updatedAt: timestamp('updated_at').$defaultFn(() => new Date()).notNull(),
}, (t) => [
  index('ap_business_status_idx').on(t.businessId, t.status),
])

export const supplierPayment = pgTable('supplier_payment', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id),
  accountPayableId: varchar('account_payable_id', { length: 36 }).notNull().references(() => accountPayable.id),
  paymentMethodId: varchar('payment_method_id', { length: 36 }).notNull().references(() => paymentMethod.id),
  amount: numeric('amount', { precision: 12, scale: 2 }).notNull(),
  paymentDate: date('payment_date').$defaultFn(() => new Date().toISOString().slice(0, 10)).notNull(),
  reference: varchar('reference', { length: 100 }),
  notes: text('notes'),
  paidBy: varchar('paid_by', { length: 36 }).references(() => appUser.id),
  createdAt: timestamp('created_at').$defaultFn(() => new Date()).notNull(),
})

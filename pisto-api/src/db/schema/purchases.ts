import { mssqlTable, varchar, nvarchar, bit, datetimeOffset, int, decimal, date, uniqueIndex, index } from 'drizzle-orm/mssql-core'
import { randomUUID } from 'crypto'
import { business, appUser, paymentMethod, tax } from './core'
import { product, warehouse } from './inventory'

export const supplier = mssqlTable('supplier', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id),
  companyName: nvarchar('company_name', { length: 150 }).notNull(),
  contactName: nvarchar('contact_name', { length: 100 }),
  taxId: nvarchar('tax_id', { length: 20 }),
  phone: nvarchar('phone', { length: 20 }),
  email: nvarchar('email', { length: 150 }),
  address: nvarchar('address', { length: 'max' }),
  paymentTerms: int('payment_terms').default(30).notNull(),
  isActive: bit('is_active').default(true).notNull(),
  createdAt: datetimeOffset('created_at').$defaultFn(() => new Date()).notNull(),
  updatedAt: datetimeOffset('updated_at').$defaultFn(() => new Date()).notNull(),
})

export const supplierProduct = mssqlTable('supplier_product', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  supplierId: varchar('supplier_id', { length: 36 }).notNull().references(() => supplier.id),
  productId: varchar('product_id', { length: 36 }).notNull().references(() => product.id),
  supplierSku: nvarchar('supplier_sku', { length: 50 }),
  supplierPrice: decimal('supplier_price', { precision: 12, scale: 2 }),
  leadTimeDays: int('lead_time_days'),
}, (t) => [
  uniqueIndex('supplier_product_unique').on(t.supplierId, t.productId),
])

export const purchaseOrder = mssqlTable('purchase_order', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id),
  supplierId: varchar('supplier_id', { length: 36 }).notNull().references(() => supplier.id),
  warehouseId: varchar('warehouse_id', { length: 36 }).notNull().references(() => warehouse.id),
  orderNumber: nvarchar('order_number', { length: 30 }).notNull(),
  orderDate: date('order_date').$defaultFn(() => new Date()).notNull(),
  expectedDate: date('expected_date'),
  status: nvarchar('status', { length: 20 }).default('draft').notNull(),
  subtotal: decimal('subtotal', { precision: 12, scale: 2 }).default(0).notNull(),
  taxAmount: decimal('tax_amount', { precision: 12, scale: 2 }).default(0).notNull(),
  total: decimal('total', { precision: 12, scale: 2 }).default(0).notNull(),
  notes: nvarchar('notes', { length: 'max' }),
  createdBy: varchar('created_by', { length: 36 }).references(() => appUser.id),
  createdAt: datetimeOffset('created_at').$defaultFn(() => new Date()).notNull(),
}, (t) => [
  uniqueIndex('po_business_number_idx').on(t.businessId, t.orderNumber),
  index('po_supplier_idx').on(t.supplierId),
])

export const purchaseOrderLine = mssqlTable('purchase_order_line', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  purchaseOrderId: varchar('purchase_order_id', { length: 36 }).notNull().references(() => purchaseOrder.id, { onDelete: 'cascade' }),
  productId: varchar('product_id', { length: 36 }).notNull().references(() => product.id),
  quantityOrdered: decimal('quantity_ordered', { precision: 12, scale: 2 }).notNull(),
  quantityReceived: decimal('quantity_received', { precision: 12, scale: 2 }).default(0).notNull(),
  unitCost: decimal('unit_cost', { precision: 12, scale: 2 }).notNull(),
  taxId: varchar('tax_id', { length: 36 }).references(() => tax.id),
  taxAmount: decimal('tax_amount', { precision: 12, scale: 2 }).default(0).notNull(),
  lineTotal: decimal('line_total', { precision: 12, scale: 2 }).notNull(),
})

export const goodsReceipt = mssqlTable('goods_receipt', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  purchaseOrderId: varchar('purchase_order_id', { length: 36 }).notNull().references(() => purchaseOrder.id),
  receiptNumber: nvarchar('receipt_number', { length: 30 }).notNull(),
  receiptDate: date('receipt_date').$defaultFn(() => new Date()).notNull(),
  notes: nvarchar('notes', { length: 'max' }),
  receivedBy: varchar('received_by', { length: 36 }).references(() => appUser.id),
  createdAt: datetimeOffset('created_at').$defaultFn(() => new Date()).notNull(),
})

export const goodsReceiptLine = mssqlTable('goods_receipt_line', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  goodsReceiptId: varchar('goods_receipt_id', { length: 36 }).notNull().references(() => goodsReceipt.id, { onDelete: 'cascade' }),
  purchaseOrderLineId: varchar('purchase_order_line_id', { length: 36 }).notNull().references(() => purchaseOrderLine.id),
  productId: varchar('product_id', { length: 36 }).notNull().references(() => product.id),
  quantityReceived: decimal('quantity_received', { precision: 12, scale: 2 }).notNull(),
})

export const accountPayable = mssqlTable('account_payable', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id),
  supplierId: varchar('supplier_id', { length: 36 }).notNull().references(() => supplier.id),
  purchaseOrderId: varchar('purchase_order_id', { length: 36 }).notNull().references(() => purchaseOrder.id),
  originalAmount: decimal('original_amount', { precision: 12, scale: 2 }).notNull(),
  balance: decimal('balance', { precision: 12, scale: 2 }).notNull(),
  dueDate: date('due_date').notNull(),
  status: nvarchar('status', { length: 20 }).default('pending').notNull(),
  createdAt: datetimeOffset('created_at').$defaultFn(() => new Date()).notNull(),
  updatedAt: datetimeOffset('updated_at').$defaultFn(() => new Date()).notNull(),
}, (t) => [
  index('ap_business_status_idx').on(t.businessId, t.status),
])

export const supplierPayment = mssqlTable('supplier_payment', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id),
  accountPayableId: varchar('account_payable_id', { length: 36 }).notNull().references(() => accountPayable.id),
  paymentMethodId: varchar('payment_method_id', { length: 36 }).notNull().references(() => paymentMethod.id),
  amount: decimal('amount', { precision: 12, scale: 2 }).notNull(),
  paymentDate: date('payment_date').$defaultFn(() => new Date()).notNull(),
  reference: nvarchar('reference', { length: 100 }),
  notes: nvarchar('notes', { length: 'max' }),
  paidBy: varchar('paid_by', { length: 36 }).references(() => appUser.id),
  createdAt: datetimeOffset('created_at').$defaultFn(() => new Date()).notNull(),
})

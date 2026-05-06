import { mssqlTable, varchar, nvarchar, bit, datetimeOffset, decimal, uniqueIndex, index } from 'drizzle-orm/mssql-core'
import { randomUUID } from 'crypto'
import { business, appUser } from './core'

export const productCategory = mssqlTable('product_category', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id),
  parentId: varchar('parent_id', { length: 36 }),
  name: nvarchar('name', { length: 100 }).notNull(),
  description: nvarchar('description', { length: 'max' }),
  isActive: bit('is_active').default(true).notNull(),
}, (t) => [
  uniqueIndex('product_category_unique').on(t.businessId, t.name, t.parentId),
])

export const unitOfMeasure = mssqlTable('unit_of_measure', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  code: nvarchar('code', { length: 10 }).notNull().unique(),
  name: nvarchar('name', { length: 50 }).notNull(),
})

export const warehouse = mssqlTable('warehouse', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id),
  name: nvarchar('name', { length: 100 }).notNull(),
  address: nvarchar('address', { length: 'max' }),
  isActive: bit('is_active').default(true).notNull(),
}, (t) => [
  uniqueIndex('warehouse_business_name_idx').on(t.businessId, t.name),
])

export const product = mssqlTable('product', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id),
  categoryId: varchar('category_id', { length: 36 }).references(() => productCategory.id),
  unitId: varchar('unit_id', { length: 36 }).notNull().references(() => unitOfMeasure.id),
  sku: nvarchar('sku', { length: 50 }),
  barcode: nvarchar('barcode', { length: 50 }),
  name: nvarchar('name', { length: 200 }).notNull(),
  description: nvarchar('description', { length: 'max' }),
  costPrice: decimal('cost_price', { precision: 15, scale: 2 }).default(0).notNull(),
  salePrice: decimal('sale_price', { precision: 15, scale: 2 }).notNull(),
  minStock: decimal('min_stock', { precision: 15, scale: 2 }).default(0).notNull(),
  maxStock: decimal('max_stock', { precision: 15, scale: 2 }),
  isService: bit('is_service').default(false).notNull(),
  isTaxable: bit('is_taxable').default(true).notNull(),
  isActive: bit('is_active').default(true).notNull(),
  imageUrl: nvarchar('image_url', { length: 'max' }),
  createdAt: datetimeOffset('created_at').$defaultFn(() => new Date()).notNull(),
  updatedAt: datetimeOffset('updated_at').$defaultFn(() => new Date()).notNull(),
}, (t) => [
  uniqueIndex('product_business_sku_idx').on(t.businessId, t.sku),
  index('product_business_idx').on(t.businessId),
  index('product_barcode_idx').on(t.barcode),
])

export const productStock = mssqlTable('product_stock', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  productId: varchar('product_id', { length: 36 }).notNull().references(() => product.id),
  warehouseId: varchar('warehouse_id', { length: 36 }).notNull().references(() => warehouse.id),
  quantity: decimal('quantity', { precision: 15, scale: 2 }).default(0).notNull(),
  updatedAt: datetimeOffset('updated_at').$defaultFn(() => new Date()).notNull(),
}, (t) => [
  uniqueIndex('product_stock_unique').on(t.productId, t.warehouseId),
  index('product_stock_product_idx').on(t.productId),
  index('product_stock_warehouse_idx').on(t.warehouseId),
])

export const inventoryMovement = mssqlTable('inventory_movement', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  productId: varchar('product_id', { length: 36 }).notNull().references(() => product.id),
  warehouseId: varchar('warehouse_id', { length: 36 }).notNull().references(() => warehouse.id),
  movementType: nvarchar('movement_type', { length: 30 }).notNull(),
  quantity: decimal('quantity', { precision: 15, scale: 2 }).notNull(),
  unitCost: decimal('unit_cost', { precision: 15, scale: 2 }),
  referenceType: nvarchar('reference_type', { length: 30 }),
  referenceId: varchar('reference_id', { length: 36 }),
  notes: nvarchar('notes', { length: 'max' }),
  createdBy: varchar('created_by', { length: 36 }).references(() => appUser.id),
  createdAt: datetimeOffset('created_at').$defaultFn(() => new Date()).notNull(),
}, (t) => [
  index('inv_movement_product_date_idx').on(t.productId, t.createdAt),
])

export const inventoryTransfer = mssqlTable('inventory_transfer', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id),
  fromWarehouseId: varchar('from_warehouse_id', { length: 36 }).notNull().references(() => warehouse.id),
  toWarehouseId: varchar('to_warehouse_id', { length: 36 }).notNull().references(() => warehouse.id),
  status: nvarchar('status', { length: 20 }).default('pending').notNull(),
  notes: nvarchar('notes', { length: 'max' }),
  createdBy: varchar('created_by', { length: 36 }).references(() => appUser.id),
  createdAt: datetimeOffset('created_at').$defaultFn(() => new Date()).notNull(),
  completedAt: datetimeOffset('completed_at'),
}, (t) => [
  index('inv_transfer_business_idx').on(t.businessId),
])

export const inventoryTransferLine = mssqlTable('inventory_transfer_line', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  transferId: varchar('transfer_id', { length: 36 }).notNull().references(() => inventoryTransfer.id, { onDelete: 'cascade' }),
  productId: varchar('product_id', { length: 36 }).notNull().references(() => product.id),
  quantity: decimal('quantity', { precision: 12, scale: 2 }).notNull(),
})

import { pgTable, varchar, text, boolean, timestamp, numeric, uniqueIndex, index } from 'drizzle-orm/pg-core'
import { randomUUID } from 'crypto'
import { business, appUser } from './core'

export const productCategory = pgTable('product_category', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id),
  parentId: varchar('parent_id', { length: 36 }),
  name: varchar('name', { length: 100 }).notNull(),
  description: text('description'),
  isActive: boolean('is_active').default(true).notNull(),
}, (t) => [
  uniqueIndex('product_category_unique').on(t.businessId, t.name, t.parentId),
])

export const unitOfMeasure = pgTable('unit_of_measure', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  code: varchar('code', { length: 10 }).notNull().unique(),
  name: varchar('name', { length: 50 }).notNull(),
})

export const warehouse = pgTable('warehouse', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id),
  name: varchar('name', { length: 100 }).notNull(),
  address: text('address'),
  isActive: boolean('is_active').default(true).notNull(),
}, (t) => [
  uniqueIndex('warehouse_business_name_idx').on(t.businessId, t.name),
])

export const product = pgTable('product', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id),
  categoryId: varchar('category_id', { length: 36 }).references(() => productCategory.id),
  unitId: varchar('unit_id', { length: 36 }).notNull().references(() => unitOfMeasure.id),
  sku: varchar('sku', { length: 50 }),
  barcode: varchar('barcode', { length: 50 }),
  name: varchar('name', { length: 200 }).notNull(),
  description: text('description'),
  costPrice: numeric('cost_price', { precision: 15, scale: 2 }).default(0).notNull(),
  salePrice: numeric('sale_price', { precision: 15, scale: 2 }).notNull(),
  minStock: numeric('min_stock', { precision: 15, scale: 2 }).default(0).notNull(),
  maxStock: numeric('max_stock', { precision: 15, scale: 2 }),
  isService: boolean('is_service').default(false).notNull(),
  isTaxable: boolean('is_taxable').default(true).notNull(),
  isActive: boolean('is_active').default(true).notNull(),
  imageUrl: text('image_url'),
  createdAt: timestamp('created_at').$defaultFn(() => new Date()).notNull(),
  updatedAt: timestamp('updated_at').$defaultFn(() => new Date()).notNull(),
}, (t) => [
  uniqueIndex('product_business_sku_idx').on(t.businessId, t.sku),
  index('product_business_idx').on(t.businessId),
  index('product_barcode_idx').on(t.barcode),
])

export const productStock = pgTable('product_stock', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  productId: varchar('product_id', { length: 36 }).notNull().references(() => product.id),
  warehouseId: varchar('warehouse_id', { length: 36 }).notNull().references(() => warehouse.id),
  quantity: numeric('quantity', { precision: 15, scale: 2 }).default(0).notNull(),
  updatedAt: timestamp('updated_at').$defaultFn(() => new Date()).notNull(),
}, (t) => [
  uniqueIndex('product_stock_unique').on(t.productId, t.warehouseId),
  index('product_stock_product_idx').on(t.productId),
  index('product_stock_warehouse_idx').on(t.warehouseId),
])

export const inventoryMovement = pgTable('inventory_movement', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  productId: varchar('product_id', { length: 36 }).notNull().references(() => product.id),
  warehouseId: varchar('warehouse_id', { length: 36 }).notNull().references(() => warehouse.id),
  movementType: varchar('movement_type', { length: 30 }).notNull(),
  quantity: numeric('quantity', { precision: 15, scale: 2 }).notNull(),
  unitCost: numeric('unit_cost', { precision: 15, scale: 2 }),
  referenceType: varchar('reference_type', { length: 30 }),
  referenceId: varchar('reference_id', { length: 36 }),
  notes: text('notes'),
  createdBy: varchar('created_by', { length: 36 }).references(() => appUser.id),
  createdAt: timestamp('created_at').$defaultFn(() => new Date()).notNull(),
}, (t) => [
  index('inv_movement_product_date_idx').on(t.productId, t.createdAt),
])

export const inventoryTransfer = pgTable('inventory_transfer', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id),
  fromWarehouseId: varchar('from_warehouse_id', { length: 36 }).notNull().references(() => warehouse.id),
  toWarehouseId: varchar('to_warehouse_id', { length: 36 }).notNull().references(() => warehouse.id),
  status: varchar('status', { length: 20 }).default('pending').notNull(),
  notes: text('notes'),
  createdBy: varchar('created_by', { length: 36 }).references(() => appUser.id),
  createdAt: timestamp('created_at').$defaultFn(() => new Date()).notNull(),
  completedAt: timestamp('completed_at'),
}, (t) => [
  index('inv_transfer_business_idx').on(t.businessId),
])

export const inventoryTransferLine = pgTable('inventory_transfer_line', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  transferId: varchar('transfer_id', { length: 36 }).notNull().references(() => inventoryTransfer.id, { onDelete: 'cascade' }),
  productId: varchar('product_id', { length: 36 }).notNull().references(() => product.id),
  quantity: numeric('quantity', { precision: 12, scale: 2 }).notNull(),
})

import { pgTable, pgEnum, uuid, varchar, text, boolean, timestamp, integer, decimal, uniqueIndex, index } from 'drizzle-orm/pg-core'
import { business, appUser } from './core'

export const productCategory = pgTable('product_category', {
  id: uuid('id').primaryKey().defaultRandom(),
  businessId: uuid('business_id').notNull().references(() => business.id),
  parentId: uuid('parent_id'),
  name: varchar('name', { length: 100 }).notNull(),
  description: text('description'),
  isActive: boolean('is_active').default(true).notNull(),
}, (t) => [
  uniqueIndex('product_category_unique').on(t.businessId, t.name, t.parentId),
])

export const unitOfMeasure = pgTable('unit_of_measure', {
  id: uuid('id').primaryKey().defaultRandom(),
  code: varchar('code', { length: 10 }).notNull().unique(),
  name: varchar('name', { length: 50 }).notNull(),
})

export const warehouse = pgTable('warehouse', {
  id: uuid('id').primaryKey().defaultRandom(),
  businessId: uuid('business_id').notNull().references(() => business.id),
  name: varchar('name', { length: 100 }).notNull(),
  address: text('address'),
  isActive: boolean('is_active').default(true).notNull(),
}, (t) => [
  uniqueIndex('warehouse_business_name_idx').on(t.businessId, t.name),
])

export const product = pgTable('product', {
  id: uuid('id').primaryKey().defaultRandom(),
  businessId: uuid('business_id').notNull().references(() => business.id),
  categoryId: uuid('category_id').references(() => productCategory.id),
  unitId: uuid('unit_id').notNull().references(() => unitOfMeasure.id),
  sku: varchar('sku', { length: 50 }),
  barcode: varchar('barcode', { length: 50 }),
  name: varchar('name', { length: 200 }).notNull(),
  description: text('description'),
  costPrice: decimal('cost_price', { precision: 12, scale: 2 }).default('0').notNull(),
  salePrice: decimal('sale_price', { precision: 12, scale: 2 }).notNull(),
  minStock: decimal('min_stock', { precision: 12, scale: 2 }).default('0').notNull(),
  maxStock: decimal('max_stock', { precision: 12, scale: 2 }),
  isService: boolean('is_service').default(false).notNull(),
  isTaxable: boolean('is_taxable').default(true).notNull(),
  isActive: boolean('is_active').default(true).notNull(),
  imageUrl: text('image_url'),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
}, (t) => [
  uniqueIndex('product_business_sku_idx').on(t.businessId, t.sku),
  index('product_business_idx').on(t.businessId),
  index('product_barcode_idx').on(t.barcode),
])

export const productStock = pgTable('product_stock', {
  id: uuid('id').primaryKey().defaultRandom(),
  productId: uuid('product_id').notNull().references(() => product.id),
  warehouseId: uuid('warehouse_id').notNull().references(() => warehouse.id),
  quantity: decimal('quantity', { precision: 12, scale: 2 }).default('0').notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
}, (t) => [
  uniqueIndex('product_stock_unique').on(t.productId, t.warehouseId),
  index('product_stock_product_idx').on(t.productId),
])

export const inventoryMovementTypeEnum = pgEnum('inventory_movement_type', [
  'purchase_in', 'sale_out', 'adjustment_in', 'adjustment_out',
  'transfer_in', 'transfer_out', 'return_in', 'return_out',
])

export const inventoryMovement = pgTable('inventory_movement', {
  id: uuid('id').primaryKey().defaultRandom(),
  productId: uuid('product_id').notNull().references(() => product.id),
  warehouseId: uuid('warehouse_id').notNull().references(() => warehouse.id),
  movementType: inventoryMovementTypeEnum('movement_type').notNull(),
  quantity: decimal('quantity', { precision: 12, scale: 2 }).notNull(),
  unitCost: decimal('unit_cost', { precision: 12, scale: 2 }),
  referenceType: varchar('reference_type', { length: 30 }),
  referenceId: uuid('reference_id'),
  notes: text('notes'),
  createdBy: uuid('created_by').references(() => appUser.id),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
}, (t) => [
  index('inv_movement_product_date_idx').on(t.productId, t.createdAt),
])

export const inventoryTransfer = pgTable('inventory_transfer', {
  id: uuid('id').primaryKey().defaultRandom(),
  businessId: uuid('business_id').notNull().references(() => business.id),
  fromWarehouseId: uuid('from_warehouse_id').notNull().references(() => warehouse.id),
  toWarehouseId: uuid('to_warehouse_id').notNull().references(() => warehouse.id),
  status: varchar('status', { length: 20 }).default('pending').notNull(),
  notes: text('notes'),
  createdBy: uuid('created_by').references(() => appUser.id),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  completedAt: timestamp('completed_at', { withTimezone: true }),
})

export const inventoryTransferLine = pgTable('inventory_transfer_line', {
  id: uuid('id').primaryKey().defaultRandom(),
  transferId: uuid('transfer_id').notNull().references(() => inventoryTransfer.id, { onDelete: 'cascade' }),
  productId: uuid('product_id').notNull().references(() => product.id),
  quantity: decimal('quantity', { precision: 12, scale: 2 }).notNull(),
})

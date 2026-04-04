import { pgTable, uuid, varchar, text, char, boolean, timestamp, serial, integer, decimal, uniqueIndex } from 'drizzle-orm/pg-core'

export const business = pgTable('business', {
  id: uuid('id').primaryKey().defaultRandom(),
  name: varchar('name', { length: 150 }).notNull(),
  tradeName: varchar('trade_name', { length: 150 }),
  taxId: varchar('tax_id', { length: 20 }),
  phone: varchar('phone', { length: 20 }),
  email: varchar('email', { length: 100 }),
  address: text('address'),
  logoUrl: text('logo_url'),
  currencyCode: char('currency_code', { length: 3 }).default('USD').notNull(),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
})

export const appUser = pgTable('app_user', {
  id: uuid('id').primaryKey().defaultRandom(),
  businessId: uuid('business_id').notNull().references(() => business.id),
  email: varchar('email', { length: 150 }).notNull().unique(),
  passwordHash: varchar('password_hash', { length: 255 }).notNull(),
  firstName: varchar('first_name', { length: 80 }).notNull(),
  lastName: varchar('last_name', { length: 80 }).notNull(),
  phone: varchar('phone', { length: 20 }),
  isActive: boolean('is_active').default(true).notNull(),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
})

export const role = pgTable('role', {
  id: serial('id').primaryKey(),
  businessId: uuid('business_id').notNull().references(() => business.id),
  name: varchar('name', { length: 50 }).notNull(),
  description: varchar('description', { length: 200 }),
}, (t) => [
  uniqueIndex('role_business_name_idx').on(t.businessId, t.name),
])

export const permission = pgTable('permission', {
  id: serial('id').primaryKey(),
  code: varchar('code', { length: 80 }).notNull().unique(),
  description: varchar('description', { length: 200 }),
})

export const rolePermission = pgTable('role_permission', {
  roleId: integer('role_id').notNull().references(() => role.id, { onDelete: 'cascade' }),
  permissionId: integer('permission_id').notNull().references(() => permission.id, { onDelete: 'cascade' }),
}, (t) => [
  uniqueIndex('role_permission_pk').on(t.roleId, t.permissionId),
])

export const userRole = pgTable('user_role', {
  userId: uuid('user_id').notNull().references(() => appUser.id, { onDelete: 'cascade' }),
  roleId: integer('role_id').notNull().references(() => role.id, { onDelete: 'cascade' }),
  assignedAt: timestamp('assigned_at', { withTimezone: true }).defaultNow().notNull(),
}, (t) => [
  uniqueIndex('user_role_pk').on(t.userId, t.roleId),
])

export const documentType = pgTable('document_type', {
  id: serial('id').primaryKey(),
  code: varchar('code', { length: 20 }).notNull().unique(),
  name: varchar('name', { length: 80 }).notNull(),
  isFiscal: boolean('is_fiscal').default(false).notNull(),
  affectsTax: boolean('affects_tax').default(false).notNull(),
})

export const paymentMethod = pgTable('payment_method', {
  id: serial('id').primaryKey(),
  name: varchar('name', { length: 50 }).notNull(),
  isActive: boolean('is_active').default(true).notNull(),
})

export const tax = pgTable('tax', {
  id: serial('id').primaryKey(),
  businessId: uuid('business_id').notNull().references(() => business.id),
  name: varchar('name', { length: 50 }).notNull(),
  rate: decimal('rate', { precision: 5, scale: 4 }).notNull(),
  isDefault: boolean('is_default').default(false).notNull(),
  isActive: boolean('is_active').default(true).notNull(),
})

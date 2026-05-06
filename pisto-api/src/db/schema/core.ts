import { mssqlTable, varchar, nvarchar, nchar, bit, datetimeOffset, decimal, uniqueIndex, index } from 'drizzle-orm/mssql-core'
import { randomUUID } from 'crypto'

export const business = mssqlTable('business', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  name: nvarchar('name', { length: 150 }).notNull(),
  tradeName: nvarchar('trade_name', { length: 150 }),
  taxId: nvarchar('tax_id', { length: 20 }),
  phone: nvarchar('phone', { length: 20 }),
  email: nvarchar('email', { length: 100 }),
  address: nvarchar('address', { length: 'max' }),
  logoUrl: nvarchar('logo_url', { length: 'max' }),
  currencyCode: nchar('currency_code', { length: 3 }).default('USD').notNull(),
  createdAt: datetimeOffset('created_at').$defaultFn(() => new Date()).notNull(),
  updatedAt: datetimeOffset('updated_at').$defaultFn(() => new Date()).notNull(),
})

export const appUser = mssqlTable('app_user', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id),
  email: nvarchar('email', { length: 150 }).notNull().unique(),
  passwordHash: nvarchar('password_hash', { length: 255 }).notNull(),
  firstName: nvarchar('first_name', { length: 80 }).notNull(),
  lastName: nvarchar('last_name', { length: 80 }).notNull(),
  phone: nvarchar('phone', { length: 20 }),
  isActive: bit('is_active').default(true).notNull(),
  createdAt: datetimeOffset('created_at').$defaultFn(() => new Date()).notNull(),
  updatedAt: datetimeOffset('updated_at').$defaultFn(() => new Date()).notNull(),
})

export const role = mssqlTable('role', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id),
  name: nvarchar('name', { length: 50 }).notNull(),
  description: nvarchar('description', { length: 200 }),
}, (t) => [
  uniqueIndex('role_business_name_idx').on(t.businessId, t.name),
])

export const permission = mssqlTable('permission', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  code: nvarchar('code', { length: 80 }).notNull().unique(),
  description: nvarchar('description', { length: 200 }),
})

export const rolePermission = mssqlTable('role_permission', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  roleId: varchar('role_id', { length: 36 }).notNull().references(() => role.id, { onDelete: 'cascade' }),
  permissionId: varchar('permission_id', { length: 36 }).notNull().references(() => permission.id, { onDelete: 'cascade' }),
}, (t) => [
  uniqueIndex('role_permission_pk').on(t.roleId, t.permissionId),
])

export const userRole = mssqlTable('user_role', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  userId: varchar('user_id', { length: 36 }).notNull().references(() => appUser.id, { onDelete: 'cascade' }),
  roleId: varchar('role_id', { length: 36 }).notNull().references(() => role.id, { onDelete: 'cascade' }),
  assignedAt: datetimeOffset('assigned_at').$defaultFn(() => new Date()).notNull(),
}, (t) => [
  uniqueIndex('user_role_pk').on(t.userId, t.roleId),
])

export const refreshToken = mssqlTable('refresh_token', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  userId: varchar('user_id', { length: 36 }).notNull().references(() => appUser.id, { onDelete: 'cascade' }),
  tokenHash: nvarchar('token_hash', { length: 255 }).notNull(),
  expiresAt: datetimeOffset('expires_at').notNull(),
  revokedAt: datetimeOffset('revoked_at'),
  createdAt: datetimeOffset('created_at').$defaultFn(() => new Date()).notNull(),
}, (t) => [
  uniqueIndex('refresh_token_hash_idx').on(t.tokenHash),
  index('refresh_token_user_idx').on(t.userId),
])

export const documentType = mssqlTable('document_type', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id),
  name: nvarchar('name', { length: 50 }).notNull(),
  code: nvarchar('code', { length: 20 }).notNull(),
  isActive: bit('is_active').default(true).notNull(),
  createdAt: datetimeOffset('created_at').$defaultFn(() => new Date()).notNull(),
}, (t) => [
  uniqueIndex('doc_type_business_code_idx').on(t.businessId, t.code),
])

export const paymentMethod = mssqlTable('payment_method', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id),
  name: nvarchar('name', { length: 50 }).notNull(),
  isActive: bit('is_active').default(true).notNull(),
  createdAt: datetimeOffset('created_at').$defaultFn(() => new Date()).notNull(),
})

export const tax = mssqlTable('tax', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id),
  name: nvarchar('name', { length: 50 }).notNull(),
  rate: decimal('rate', { precision: 5, scale: 2 }).notNull(),
  isActive: bit('is_active').default(true).notNull(),
  createdAt: datetimeOffset('created_at').$defaultFn(() => new Date()).notNull(),
})

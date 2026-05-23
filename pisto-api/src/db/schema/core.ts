import { pgTable, varchar, text, boolean, timestamp, numeric, uniqueIndex, index } from 'drizzle-orm/pg-core'
import { randomUUID } from 'crypto'

export const business = pgTable('business', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  name: varchar('name', { length: 150 }).notNull(),
  tradeName: varchar('trade_name', { length: 150 }),
  taxId: varchar('tax_id', { length: 20 }),
  phone: varchar('phone', { length: 20 }),
  email: varchar('email', { length: 100 }),
  address: text('address'),
  logoUrl: text('logo_url'),
  currencyCode: varchar('currency_code', { length: 3 }).default('USD').notNull(),
  createdAt: timestamp('created_at').$defaultFn(() => new Date()).notNull(),
  updatedAt: timestamp('updated_at').$defaultFn(() => new Date()).notNull(),
})

export const appUser = pgTable('app_user', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id),
  email: varchar('email', { length: 150 }).notNull().unique(),
  passwordHash: varchar('password_hash', { length: 255 }).notNull(),
  firstName: varchar('first_name', { length: 80 }).notNull(),
  lastName: varchar('last_name', { length: 80 }).notNull(),
  phone: varchar('phone', { length: 20 }),
  avatarUrl: text('avatar_url'),
  isActive: boolean('is_active').default(true).notNull(),
  createdAt: timestamp('created_at').$defaultFn(() => new Date()).notNull(),
  updatedAt: timestamp('updated_at').$defaultFn(() => new Date()).notNull(),
})

export const role = pgTable('role', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id),
  name: varchar('name', { length: 50 }).notNull(),
  description: varchar('description', { length: 200 }),
}, (t) => [
  uniqueIndex('role_business_name_idx').on(t.businessId, t.name),
])

export const permission = pgTable('permission', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  code: varchar('code', { length: 80 }).notNull().unique(),
  description: varchar('description', { length: 200 }),
})

export const rolePermission = pgTable('role_permission', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  roleId: varchar('role_id', { length: 36 }).notNull().references(() => role.id, { onDelete: 'cascade' }),
  permissionId: varchar('permission_id', { length: 36 }).notNull().references(() => permission.id, { onDelete: 'cascade' }),
}, (t) => [
  uniqueIndex('role_permission_pk').on(t.roleId, t.permissionId),
])

export const userRole = pgTable('user_role', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  userId: varchar('user_id', { length: 36 }).notNull().references(() => appUser.id, { onDelete: 'cascade' }),
  roleId: varchar('role_id', { length: 36 }).notNull().references(() => role.id, { onDelete: 'cascade' }),
  assignedAt: timestamp('assigned_at').$defaultFn(() => new Date()).notNull(),
}, (t) => [
  uniqueIndex('user_role_pk').on(t.userId, t.roleId),
])

export const refreshToken = pgTable('refresh_token', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  userId: varchar('user_id', { length: 36 }).notNull().references(() => appUser.id, { onDelete: 'cascade' }),
  tokenHash: varchar('token_hash', { length: 255 }).notNull(),
  expiresAt: timestamp('expires_at').notNull(),
  revokedAt: timestamp('revoked_at'),
  createdAt: timestamp('created_at').$defaultFn(() => new Date()).notNull(),
}, (t) => [
  uniqueIndex('refresh_token_hash_idx').on(t.tokenHash),
  index('refresh_token_user_idx').on(t.userId),
])

export const documentType = pgTable('document_type', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id),
  name: varchar('name', { length: 50 }).notNull(),
  code: varchar('code', { length: 20 }).notNull(),
  isActive: boolean('is_active').default(true).notNull(),
  createdAt: timestamp('created_at').$defaultFn(() => new Date()).notNull(),
}, (t) => [
  uniqueIndex('doc_type_business_code_idx').on(t.businessId, t.code),
])

export const paymentMethod = pgTable('payment_method', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id),
  name: varchar('name', { length: 50 }).notNull(),
  isActive: boolean('is_active').default(true).notNull(),
  createdAt: timestamp('created_at').$defaultFn(() => new Date()).notNull(),
})

export const tax = pgTable('tax', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => randomUUID()),
  businessId: varchar('business_id', { length: 36 }).notNull().references(() => business.id),
  name: varchar('name', { length: 50 }).notNull(),
  rate: numeric('rate', { precision: 5, scale: 2 }).$type<string>().notNull(),
  isActive: boolean('is_active').default(true).notNull(),
  createdAt: timestamp('created_at').$defaultFn(() => new Date()).notNull(),
})

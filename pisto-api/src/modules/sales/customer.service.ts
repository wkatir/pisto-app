import { eq, and, or, like, count } from 'drizzle-orm'
import { db } from '../../config/database'
import { customer } from '../../db/schema'
import { AppError } from '../../shared/errors/app-error'
import { paginatedResponse } from '../../shared/utils/pagination'

type CustomerInsert = Omit<typeof customer.$inferInsert, 'id' | 'businessId' | 'createdAt' | 'updatedAt'>
type CustomerUpdate = Partial<CustomerInsert>

export async function listCustomers(businessId: string, query: { page: number; limit: number; search?: string }) {
  const { page, limit, search } = query
  const offset = (page - 1) * limit

  const conditions = [eq(customer.businessId, businessId), eq(customer.isActive, true)]
  if (search) {
    conditions.push(
      or(
        like(customer.firstName, `%${search}%`),
        like(customer.lastName, `%${search}%`),
        like(customer.companyName, `%${search}%`),
        like(customer.email, `%${search}%`),
      )!
    )
  }

  const where = and(...conditions)

  const [items, [total]] = await Promise.all([
    db.select().from(customer).where(where).orderBy(customer.createdAt).offset(offset).limit(limit),
    db.select({ count: count() }).from(customer).where(where),
  ])

  return paginatedResponse(items, total!.count, { page, limit, sortOrder: 'desc' as const })
}

export async function getCustomer(businessId: string, id: string) {
  const [c] = await db.select().from(customer)
    .where(and(eq(customer.id, id), eq(customer.businessId, businessId)))
  if (!c) throw new AppError(404, 'Cliente no encontrado')
  return c
}

export async function createCustomer(businessId: string, data: CustomerInsert) {
  const [c] = await db.insert(customer)
    .values({ businessId, ...data })
    .returning()
  return c
}

export async function updateCustomer(businessId: string, id: string, data: CustomerUpdate) {
  const [updated] = await db.update(customer)
    .set({ ...data, updatedAt: new Date() })
    .where(and(eq(customer.id, id), eq(customer.businessId, businessId)))
  if (!updated) throw new AppError(404, 'Cliente no encontrado')
  return updated
}

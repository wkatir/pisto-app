import { eq, and, or, like, count } from 'drizzle-orm'
import { db } from '../../config/database'
import { customer } from '../../db/schema'
import { AppError } from '../../shared/errors/app-error'

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
    db.select().from(customer).where(where).limit(limit).offset(offset),
    db.select({ count: count() }).from(customer).where(where),
  ])

  return {
    data: items,
    pagination: { page, limit, total: total!.count, pages: Math.ceil(total!.count / limit) },
  }
}

export async function getCustomer(businessId: string, id: string) {
  const [c] = await db.select().from(customer)
    .where(and(eq(customer.id, id), eq(customer.businessId, businessId)))
  if (!c) throw new AppError(404, 'Cliente no encontrado')
  return c
}

export async function createCustomer(businessId: string, data: Record<string, unknown>) {
  const [c] = await db.insert(customer).values({ businessId, ...data } as any).returning()
  return c
}

export async function updateCustomer(businessId: string, id: string, data: Record<string, unknown>) {
  const [updated] = await db.update(customer)
    .set({ ...data, updatedAt: new Date() } as any)
    .where(and(eq(customer.id, id), eq(customer.businessId, businessId)))
    .returning()
  if (!updated) throw new AppError(404, 'Cliente no encontrado')
  return updated
}

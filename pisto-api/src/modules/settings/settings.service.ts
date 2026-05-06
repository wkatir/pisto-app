import { db } from '../../config/database'
import { business, tax, paymentMethod } from '../../db/schema'
import { eq, and } from 'drizzle-orm'

export async function getBusiness(businessId: string) {
  const rows = await db.select().from(business).where(eq(business.id, businessId))
  return rows[0] ?? null
}

export async function updateBusiness(businessId: string, data: Partial<{
  name: string; tradeName: string; phone: string; email: string; address: string; currencyCode: string;
}>) {
  await db.update(business).set({ ...data, updatedAt: new Date() }).where(eq(business.id, businessId))
  return getBusiness(businessId)
}

export async function listTaxes(businessId: string) {
  return db.select().from(tax).where(eq(tax.businessId, businessId))
}

export async function createTax(businessId: string, data: { name: string; rate: string }) {
  const id = crypto.randomUUID()
  await db.insert(tax).values({ id, businessId, name: data.name, rate: data.rate, isActive: true })
  return { id, businessId, ...data, isActive: true }
}

export async function toggleTax(id: string, businessId: string, isActive: boolean) {
  await db.update(tax).set({ isActive }).where(and(eq(tax.id, id), eq(tax.businessId, businessId)))
  return { id, isActive }
}

export async function listPaymentMethods(businessId: string) {
  return db.select().from(paymentMethod).where(eq(paymentMethod.businessId, businessId))
}

export async function createPaymentMethod(businessId: string, data: { name: string }) {
  const id = crypto.randomUUID()
  await db.insert(paymentMethod).values({ id, businessId, name: data.name, isActive: true })
  return { id, businessId, name: data.name, isActive: true }
}

export async function togglePaymentMethod(id: string, businessId: string, isActive: boolean) {
  await db.update(paymentMethod).set({ isActive }).where(and(eq(paymentMethod.id, id), eq(paymentMethod.businessId, businessId)))
  return { id, isActive }
}

import { db } from '../../config/database'
import { expense, expenseCategory } from '../../db/schema'
import { eq, and, gte, lte, desc, getTableColumns } from 'drizzle-orm'

export async function listCategories(businessId: string) {
  return db.select().from(expenseCategory)
    .where(eq(expenseCategory.businessId, businessId))
    .orderBy(expenseCategory.name)
}

export async function createCategory(businessId: string, data: { name: string; icon?: string }) {
  const id = crypto.randomUUID()
  await db.insert(expenseCategory).values({ id, businessId, name: data.name, icon: data.icon })
  return { id, businessId, ...data }
}

export async function listExpenses(businessId: string, filters: {
  startDate?: string
  endDate?: string
  categoryId?: string
  page?: number
  limit?: number
}) {
  const page = filters.page ?? 1
  const limit = filters.limit ?? 50
  const offset = (page - 1) * limit

  const conditions = [eq(expense.businessId, businessId)]
  if (filters.startDate) conditions.push(gte(expense.expenseDate, filters.startDate))
  if (filters.endDate) conditions.push(lte(expense.expenseDate, filters.endDate))
  if (filters.categoryId) conditions.push(eq(expense.categoryId, filters.categoryId))

  const rows = await db.select({
    ...getTableColumns(expense),
    categoryName: expenseCategory.name,
  })
    .from(expense)
    .leftJoin(expenseCategory, eq(expense.categoryId, expenseCategory.id))
    .where(and(...conditions))
    .orderBy(desc(expense.expenseDate))
    .offset(offset).limit(limit)

  return rows
}

export async function getExpense(businessId: string, id: string) {
  const rows = await db.select().from(expense)
    .where(and(eq(expense.id, id), eq(expense.businessId, businessId)))
  return rows[0] ?? null
}

export async function createExpense(businessId: string, userId: string, data: {
  categoryId?: string
  description: string
  amount: string
  expenseDate: string
  paymentMethodId?: string
  notes?: string
  receiptUrl?: string
}) {
  const id = crypto.randomUUID()
  const { receiptUrl, ...rest } = data
  await db.insert(expense).values({
    id,
    businessId,
    createdBy: userId,
    ...rest,
    receiptUrl: receiptUrl || null,
  })
  return { id, businessId, createdBy: userId, ...data }
}

export async function updateExpense(id: string, businessId: string, data: Partial<{
  description: string
  amount: string
  expenseDate: string
  categoryId: string
  paymentMethodId: string
  notes: string
  receiptUrl: string
}>) {
  const updates: Record<string, unknown> = { ...data }
  if (data.receiptUrl !== undefined) updates.receiptUrl = data.receiptUrl || null
  await db.update(expense).set(updates)
    .where(and(eq(expense.id, id), eq(expense.businessId, businessId)))
  return { id, ...data }
}

export async function deleteExpense(id: string, businessId: string) {
  await db.delete(expense)
    .where(and(eq(expense.id, id), eq(expense.businessId, businessId)))
}

export async function getExpenseSummary(businessId: string, startDate?: string, endDate?: string) {
  const conditions = [eq(expense.businessId, businessId)]
  if (startDate) conditions.push(gte(expense.expenseDate, startDate))
  if (endDate) conditions.push(lte(expense.expenseDate, endDate))

  const rows = await db.select().from(expense).where(and(...conditions))
  const total = rows.reduce((sum, r) => sum + parseFloat(r.amount as string), 0)
  return { total: total.toFixed(2), count: rows.length }
}

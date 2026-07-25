import { and, count, eq, like, or, type SQL } from 'drizzle-orm'
import type { PgColumn, PgTable } from 'drizzle-orm/pg-core'
import { db } from '../config/database'
import { AppError } from './errors/app-error'
import { paginatedResponse } from './utils/pagination'

type CrudTable = PgTable & {
  id: PgColumn
  businessId: PgColumn
  isActive?: PgColumn
  updatedAt?: PgColumn
}

interface CrudOptions {
  notFoundMessage: string
  searchColumns?: PgColumn[]
  defaultOrder?: PgColumn | SQL
}

export interface ListQuery {
  page: number
  limit: number
  search?: string
}

// Standard CRUD for simple aggregates: list (search + pagination), listAll,
// get, create, update, soft-delete — always scoped by businessId. Tables with
// an isActive column are filtered to active rows on list/listAll and
// soft-deleted; deletion on tables without isActive is not offered here.
export function crudService<T extends CrudTable>(table: T, opts: CrudOptions) {
  type Row = T['$inferSelect']
  type CreateData = Omit<T['$inferInsert'], 'id' | 'businessId' | 'createdAt' | 'updatedAt'>
  type UpdateData = Partial<CreateData>

  function baseConditions(businessId: string): SQL[] {
    const conditions = [eq(table.businessId, businessId)]
    if (table.isActive) conditions.push(eq(table.isActive, true))
    return conditions
  }

  async function list(businessId: string, query: ListQuery) {
    const conditions = baseConditions(businessId)
    if (query.search && opts.searchColumns?.length) {
      conditions.push(or(...opts.searchColumns.map((col) => like(col, `%${query.search}%`)))!)
    }
    const where = and(...conditions)

    let select = db.select().from(table as PgTable).where(where).$dynamic()
    if (opts.defaultOrder) select = select.orderBy(opts.defaultOrder)

    const [items, [total]] = await Promise.all([
      select.offset((query.page - 1) * query.limit).limit(query.limit),
      db.select({ count: count() }).from(table as PgTable).where(where),
    ])
    return paginatedResponse(items as Row[], total!.count, query.page, query.limit)
  }

  async function listAll(businessId: string): Promise<Row[]> {
    let select = db.select().from(table as PgTable).where(and(...baseConditions(businessId))).$dynamic()
    if (opts.defaultOrder) select = select.orderBy(opts.defaultOrder)
    return (await select) as Row[]
  }

  async function getById(businessId: string, id: string): Promise<Row> {
    const [row] = await db.select().from(table as PgTable)
      .where(and(eq(table.id, id), eq(table.businessId, businessId)))
    if (!row) throw new AppError(404, opts.notFoundMessage)
    return row as Row
  }

  async function create(businessId: string, data: CreateData): Promise<Row> {
    const [row] = await db.insert(table).values({ businessId, ...data } as never).returning()
    return row as Row
  }

  async function update(businessId: string, id: string, data: UpdateData): Promise<Row> {
    const values: Record<string, unknown> = { ...data }
    if (table.updatedAt) values.updatedAt = new Date()
    const [row] = await db.update(table).set(values as never)
      .where(and(eq(table.id, id), eq(table.businessId, businessId)))
      .returning()
    if (!row) throw new AppError(404, opts.notFoundMessage)
    return row as Row
  }

  async function softDelete(businessId: string, id: string): Promise<Row> {
    if (!table.isActive) throw new Error(`Table has no isActive column for soft delete`)
    const values: Record<string, unknown> = { isActive: false }
    if (table.updatedAt) values.updatedAt = new Date()
    const [row] = await db.update(table).set(values as never)
      .where(and(eq(table.id, id), eq(table.businessId, businessId)))
      .returning()
    if (!row) throw new AppError(404, opts.notFoundMessage)
    return row as Row
  }

  return { list, listAll, getById, create, update, softDelete }
}

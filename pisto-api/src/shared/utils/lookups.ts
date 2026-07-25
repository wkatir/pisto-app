import { and, eq } from 'drizzle-orm'
import type { PgColumn, PgTable } from 'drizzle-orm/pg-core'
import { db } from '../../config/database'

type LookupTable = PgTable & { businessId: PgColumn; isActive: PgColumn }

export async function activeLookup<T extends LookupTable>(
  table: T,
  businessId: string,
): Promise<T['$inferSelect'][]> {
  const rows = await db.select().from(table as PgTable)
    .where(and(eq(table.businessId, businessId), eq(table.isActive, true)))
  return rows as T['$inferSelect'][]
}

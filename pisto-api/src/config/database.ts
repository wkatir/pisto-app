import { AsyncLocalStorage } from 'node:async_hooks'
import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'
import * as schema from '../db/schema'

type Db = ReturnType<typeof drizzle<typeof schema>>

const dbStorage = new AsyncLocalStorage<Db>()

// New connection per request — Workers can't share I/O across requests.
export async function runWithDb<T>(databaseUrl: string, fn: () => Promise<T>): Promise<T> {
  const client = postgres(databaseUrl, {
    max: 5,
    fetch_types: false,
    prepare: false,
  })
  const dbInstance = drizzle(client, { schema })
  try {
    return await dbStorage.run(dbInstance, fn)
  } finally {
    // Best-effort close: the response is already resolved, so a close failure here must not
    // override it or crash an otherwise-successful request.
    await client.end({ timeout: 5 }).catch(() => {})
  }
}

// Proxy delegating to the current request's store — services keep importing `db` unchanged.
export const db = new Proxy({} as Db, {
  get(_, prop: string | symbol) {
    const current = dbStorage.getStore()
    if (!current) throw new Error('DB not initialized for this request. runWithDb() must wrap the handler.')
    return (current as any)[prop]
  },
})

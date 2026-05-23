import { AsyncLocalStorage } from 'node:async_hooks'
import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'
import * as schema from '../db/schema'

type Db = ReturnType<typeof drizzle<typeof schema>>

const dbStorage = new AsyncLocalStorage<Db>()

// Crea una conexión nueva por request (Workers no permite compartir I/O entre requests)
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
    // Cerrar la conexión al final del request
    await client.end({ timeout: 5 }).catch(() => {})
  }
}

// Proxy que delega al storage del request actual — servicios siguen usando `import { db }`
export const db = new Proxy({} as Db, {
  get(_, prop: string | symbol) {
    const current = dbStorage.getStore()
    if (!current) throw new Error('DB no inicializada para este request. runWithDb() debe envolver el handler.')
    return (current as any)[prop]
  },
})

import { drizzle } from 'drizzle-orm/node-mssql'
import mssql from 'mssql'
import { env } from './env'
import * as schema from '../db/schema'

const pool = await mssql.connect({
  server: env.DB_SERVER,
  port: env.DB_PORT,
  database: env.DB_NAME,
  user: env.DB_USER,
  password: env.DB_PASSWORD,
  options: {
    encrypt: env.DB_ENCRYPT,
    trustServerCertificate: env.DB_TRUST_SERVER_CERTIFICATE,
  },
  pool: {
    min: 2,
    max: 10,
    idleTimeoutMillis: 30000,
  },
})

export const db = drizzle(pool, { schema })

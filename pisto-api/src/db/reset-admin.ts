import { drizzle } from 'drizzle-orm/node-mssql'
import mssql from 'mssql'
import { eq } from 'drizzle-orm'
import { appUser } from './schema'

const pool = await mssql.connect({
  server: process.env.DB_SERVER ?? 'localhost',
  port: Number(process.env.DB_PORT ?? '1433'),
  database: process.env.DB_NAME ?? 'pisto_app',
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  options: {
    encrypt: process.env.DB_ENCRYPT !== 'false',
    trustServerCertificate: process.env.DB_TRUST_SERVER_CERTIFICATE === 'true',
  },
})
const db = drizzle(pool)

const email = 'admin@pistoapp.com'
const newPassword = 'Admin123!'
const passwordHash = await Bun.password.hash(newPassword)

await db.update(appUser).set({ passwordHash }).where(eq(appUser.email, email))
console.log(`OK -> ${email} / ${newPassword}`)
await pool.close()
process.exit(0)

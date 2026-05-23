import 'dotenv/config'
import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'
import { eq } from 'drizzle-orm'
import { appUser } from './schema'

async function hashPassword(password: string): Promise<string> {
  const encoder = new TextEncoder()
  const salt = crypto.getRandomValues(new Uint8Array(16))
  const keyMaterial = await crypto.subtle.importKey('raw', encoder.encode(password), 'PBKDF2', false, ['deriveBits'])
  const hash = await crypto.subtle.deriveBits({ name: 'PBKDF2', salt, iterations: 100000, hash: 'SHA-256' }, keyMaterial, 256)
  const toHex = (arr: Uint8Array) => Array.from(arr).map(b => b.toString(16).padStart(2, '0')).join('')
  return `${toHex(salt)}:${toHex(new Uint8Array(hash))}`
}

const url = process.env.DATABASE_URL_DIRECT
if (!url) throw new Error('DATABASE_URL_DIRECT no definida en .dev.vars')

const client = postgres(url, { max: 1 })
const db = drizzle(client)

const email = 'admin@pistoapp.com'
const newPassword = 'Pisto2026!'
const passwordHash = await hashPassword(newPassword)

await db.update(appUser).set({ passwordHash }).where(eq(appUser.email, email))
console.log(`OK -> ${email} / ${newPassword}`)
await client.end()
process.exit(0)

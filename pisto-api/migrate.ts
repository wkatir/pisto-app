import { config } from 'dotenv';
import { migrate } from 'drizzle-orm/postgres-js/migrator';
import postgres from 'postgres';
import { drizzle } from 'drizzle-orm/postgres-js';

config({ path: '.dev.vars' });

const url = process.env.DATABASE_URL_DIRECT;
if (!url) throw new Error('DATABASE_URL_DIRECT no está definida en .dev.vars');

// Local dev Postgres has no TLS; Supabase requires it.
const ssl = new URL(url).hostname === 'localhost' ? false : ('require' as const);
const client = postgres(url, { max: 1, ssl });
const db = drizzle(client);

console.log('Aplicando migraciones...');
await migrate(db, { migrationsFolder: 'migrations' });
console.log('¡Migraciones aplicadas exitosamente!');

await client.end();
process.exit(0);

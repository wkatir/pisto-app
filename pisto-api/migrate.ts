import { config } from 'dotenv';
import { migrate } from 'drizzle-orm/postgres-js/migrator';
import postgres from 'postgres';
import { drizzle } from 'drizzle-orm/postgres-js';

config({ path: '.dev.vars' });

const url = process.env.DATABASE_URL_DIRECT;
if (!url) throw new Error('DATABASE_URL_DIRECT no está definida en .dev.vars');

const client = postgres(url, { max: 1, ssl: 'require' });
const db = drizzle(client);

console.log('Aplicando migraciones...');
await migrate(db, { migrationsFolder: 'migrations' });
console.log('¡Migraciones aplicadas exitosamente!');

await client.end();
process.exit(0);

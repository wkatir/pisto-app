// @ts-ignore — drizzle-kit mssql dialect support (branch build)
export default {
  schema: './src/db/schema/index.ts',
  out: './drizzle',
  // @ts-ignore
  dialect: 'mssql',
  dbCredentials: {
    server: process.env.DB_SERVER ?? 'localhost',
    port: Number(process.env.DB_PORT ?? '1433'),
    database: process.env.DB_NAME!,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    options: {
      encrypt: process.env.DB_ENCRYPT !== 'false',
      trustServerCertificate: process.env.DB_TRUST_SERVER_CERTIFICATE === 'true',
    },
  },
}

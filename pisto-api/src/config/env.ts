function requireEnv(name: string): string {
  const value = process.env[name]
  if (!value) throw new Error(`Missing required environment variable: ${name}`)
  return value
}

function requireEnvMin(name: string, min: number): string {
  const value = requireEnv(name)
  if (value.length < min) throw new Error(`Environment variable ${name} must be at least ${min} characters`)
  return value
}

export const env = {
  DB_SERVER: process.env.DB_SERVER ?? 'localhost',
  DB_PORT: process.env.DB_PORT ? Number(process.env.DB_PORT) : 1433,
  DB_NAME: requireEnv('DB_NAME'),
  DB_USER: requireEnv('DB_USER'),
  DB_PASSWORD: requireEnv('DB_PASSWORD'),
  DB_ENCRYPT: process.env.DB_ENCRYPT !== 'false',
  DB_TRUST_SERVER_CERTIFICATE: process.env.DB_TRUST_SERVER_CERTIFICATE === 'true',
  JWT_ACCESS_SECRET: requireEnvMin('JWT_ACCESS_SECRET', 10),
  JWT_REFRESH_SECRET: requireEnvMin('JWT_REFRESH_SECRET', 10),
  PORT: process.env.PORT ? Number(process.env.PORT) : 3000,
  CORS_ORIGIN: process.env.CORS_ORIGIN ?? '*',
  RATE_LIMIT_ENABLED: process.env.RATE_LIMIT_ENABLED === 'true',
}

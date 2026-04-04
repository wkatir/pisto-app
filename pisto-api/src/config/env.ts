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
  DATABASE_URL: requireEnv('DATABASE_URL'),
  JWT_ACCESS_SECRET: requireEnvMin('JWT_ACCESS_SECRET', 10),
  JWT_REFRESH_SECRET: requireEnvMin('JWT_REFRESH_SECRET', 10),
  PORT: process.env.PORT ? Number(process.env.PORT) : 3000,
  CORS_ORIGIN: process.env.CORS_ORIGIN ?? '*',
}

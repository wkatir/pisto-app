const KNOWN_WEAK_SECRETS = new Set([
  'min_10_chars_access_secret',
  'min_10_chars_refresh_secret',
  'changeme',
  'secret',
  'password',
  'jwt_secret',
])

const NODE_ENV = process.env.NODE_ENV ?? 'development'
const IS_PRODUCTION = NODE_ENV === 'production'

function requireEnv(name: string): string {
  const value = process.env[name]
  if (!value) throw new Error(`Missing required environment variable: ${name}`)
  return value
}

function requireSecret(name: string, min: number): string {
  const value = requireEnv(name)
  if (value.length < min) {
    throw new Error(`Environment variable ${name} must be at least ${min} characters`)
  }
  if (KNOWN_WEAK_SECRETS.has(value.toLowerCase())) {
    throw new Error(`Environment variable ${name} uses a known weak/example value. Generate a strong secret.`)
  }
  return value
}

function parseCorsOrigin(raw: string | undefined): string | string[] {
  if (!raw || raw.trim() === '') {
    if (IS_PRODUCTION) {
      throw new Error('CORS_ORIGIN must be set to an explicit origin list in production (no wildcard).')
    }
    return ['http://localhost:3000', 'http://localhost:8080', 'http://localhost:5173']
  }
  if (raw.trim() === '*') {
    if (IS_PRODUCTION) {
      throw new Error('CORS_ORIGIN="*" is not allowed in production. Use an explicit comma-separated origin list.')
    }
    return '*'
  }
  return raw.split(',').map((o) => o.trim()).filter(Boolean)
}

export const env = {
  NODE_ENV,
  IS_PRODUCTION,
  DB_SERVER: process.env.DB_SERVER ?? 'localhost',
  DB_PORT: process.env.DB_PORT ? Number(process.env.DB_PORT) : 1433,
  DB_NAME: requireEnv('DB_NAME'),
  DB_USER: requireEnv('DB_USER'),
  DB_PASSWORD: requireEnv('DB_PASSWORD'),
  DB_ENCRYPT: process.env.DB_ENCRYPT !== 'false',
  DB_TRUST_SERVER_CERTIFICATE: process.env.DB_TRUST_SERVER_CERTIFICATE === 'true',
  JWT_ACCESS_SECRET: requireSecret('JWT_ACCESS_SECRET', 32),
  JWT_REFRESH_SECRET: requireSecret('JWT_REFRESH_SECRET', 32),
  PORT: process.env.PORT ? Number(process.env.PORT) : 3000,
  CORS_ORIGIN: parseCorsOrigin(process.env.CORS_ORIGIN),
  RATE_LIMIT_ENABLED: process.env.RATE_LIMIT_ENABLED !== 'false',
  TRUST_PROXY: process.env.TRUST_PROXY === 'true',
  AI_API_KEY: process.env.AI_API_KEY || (() => {
    if (IS_PRODUCTION) throw new Error('AI_API_KEY is required in production')
    console.warn('⚠ AI_API_KEY not set — AI endpoints will fail at runtime')
    return ''
  })(),
  AI_BASE_URL: process.env.AI_BASE_URL ?? '',
  AI_MODEL: process.env.AI_MODEL ?? 'gpt-4o',
}

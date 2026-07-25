import type { AppEnv } from '../types/app-env'

type Bindings = AppEnv['Bindings']

export type EnvConfig = {
  NODE_ENV: string
  IS_PRODUCTION: boolean
  JWT_ACCESS_SECRET: string
  JWT_REFRESH_SECRET: string
  CORS_ORIGIN: string | string[]
  RATE_LIMIT_ENABLED: boolean
  AI_API_KEY: string
  AI_BASE_URL: string
  AI_MODEL: string
}

let _env: EnvConfig | null = null

function parseCorsOrigin(raw: string | undefined): string | string[] {
  if (!raw || raw.trim() === '') return ['http://localhost:3000', 'http://localhost:8080']
  if (raw.trim() === '*') return '*'
  return raw.split(',').map((o) => o.trim()).filter(Boolean)
}

export function initEnv(bindings: Bindings): void {
  if (_env) return
  _env = {
    NODE_ENV: bindings.NODE_ENV ?? 'development',
    IS_PRODUCTION: bindings.NODE_ENV === 'production',
    JWT_ACCESS_SECRET: bindings.JWT_ACCESS_SECRET,
    JWT_REFRESH_SECRET: bindings.JWT_REFRESH_SECRET,
    CORS_ORIGIN: parseCorsOrigin(bindings.CORS_ORIGIN),
    RATE_LIMIT_ENABLED: bindings.RATE_LIMIT_ENABLED === 'true',
    AI_API_KEY: bindings.AI_API_KEY ?? '',
    AI_BASE_URL: bindings.AI_BASE_URL ?? '',
    AI_MODEL: bindings.AI_MODEL ?? 'gpt-4o',
  }
}

// Proxy delegating to the singleton: modules keep importing `env` unchanged.
export const env = new Proxy({} as EnvConfig, {
  get(_, prop: string | symbol) {
    if (!_env) throw new Error('Env not initialized. initEnv() must be called first.')
    return (_env as any)[prop]
  },
})

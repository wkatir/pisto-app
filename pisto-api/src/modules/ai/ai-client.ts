import OpenAI from 'openai'
import { env } from '../../config/env'

let _client: OpenAI | null = null

export function getAiClient(): OpenAI {
  if (!_client) {
    _client = new OpenAI({
      baseURL: env.AI_BASE_URL || undefined,
      apiKey: env.AI_API_KEY || 'no-key',
    })
  }
  return _client
}

export function getAiModel(): string {
  return env.AI_MODEL ?? 'gpt-4o'
}

// Backward compat — lazy proxy
export const client = new Proxy({} as OpenAI, {
  get(_t, prop) {
    return (getAiClient() as any)[prop]
  },
})

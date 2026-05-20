import OpenAI from 'openai'

const client = new OpenAI({
  baseURL: process.env.AI_BASE_URL || undefined,
  apiKey: process.env.AI_API_KEY || '',
})

export const AI_MODEL = process.env.AI_MODEL || 'gpt-4o'

export { client }

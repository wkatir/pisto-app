import { Hono } from 'hono'
import { vValidator } from '@hono/valibot-validator'
import type { AppEnv } from '../../types/app-env'
import { chatMessageSchema } from './ai.schemas'
import * as aiService from './ai.service'

const ai = new Hono<AppEnv>()

// In-memory conversation store (keyed by conversationId)
const conversations = new Map<string, { businessId: string; messages: Array<{ role: 'user' | 'assistant'; content: string }> }>()

ai.post('/chat', vValidator('json', chatMessageSchema), async (c) => {
  const businessId = c.get('businessId')
  const userId = c.get('userId')
  const { message, conversationId: existingId } = c.req.valid('json')

  const conversationId = existingId || crypto.randomUUID()

  const history = conversations.get(conversationId)
  const conversationHistory: Array<{ role: 'user' | 'assistant'; content: string }> = []

  if (history && history.businessId === businessId) {
    conversationHistory.push(...history.messages)
  }

  const response = await aiService.chat(businessId, userId, message, conversationHistory)

  const updatedMessages = [
    ...conversationHistory,
    { role: 'user' as const, content: message },
    { role: 'assistant' as const, content: response },
  ]
  conversations.set(conversationId, { businessId, messages: updatedMessages })

  if (conversations.size > 500) {
    const firstKey = conversations.keys().next().value
    if (firstKey) conversations.delete(firstKey)
  }

  return c.json({ response, conversationId })
})

export { ai }

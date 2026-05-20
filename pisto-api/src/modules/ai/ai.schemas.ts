import * as v from 'valibot'

export const chatMessageSchema = v.object({
  message: v.pipe(v.string(), v.minLength(1), v.maxLength(2000)),
  conversationId: v.optional(v.string()),
})

import * as v from 'valibot'

export const createPaymentSchema = v.object({
  paymentMethodId: v.pipe(v.number(), v.integer()),
  amount: v.pipe(v.string(), v.regex(/^\d+(\.\d{1,2})?$/)),
  reference: v.optional(v.string()),
  notes: v.optional(v.string()),
})

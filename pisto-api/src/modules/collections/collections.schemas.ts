import * as v from 'valibot'
import { decimalString } from '../../shared/schemas/common'

export const createPaymentSchema = v.object({
  paymentMethodId: v.pipe(v.string(), v.uuid()),
  amount: decimalString,
  reference: v.optional(v.string()),
  notes: v.optional(v.string()),
})

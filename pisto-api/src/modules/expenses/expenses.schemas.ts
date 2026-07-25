import * as v from 'valibot'
import { decimalString, optionalFileUrlSchema } from '../../shared/schemas/common'

export const createExpenseCategorySchema = v.object({
  name: v.pipe(v.string(), v.minLength(1), v.maxLength(80)),
  icon: v.optional(v.string()),
})

export const createExpenseSchema = v.object({
  categoryId: v.optional(v.string()),
  description: v.pipe(v.string(), v.minLength(1), v.maxLength(200)),
  amount: decimalString,
  expenseDate: v.pipe(v.string(), v.minLength(1)),
  paymentMethodId: v.optional(v.string()),
  notes: v.optional(v.string()),
  receiptUrl: optionalFileUrlSchema,
})

export const updateExpenseSchema = v.partial(createExpenseSchema)

export const expenseQuerySchema = v.object({
  startDate: v.optional(v.string()),
  endDate: v.optional(v.string()),
  categoryId: v.optional(v.string()),
  page: v.optional(v.pipe(v.string(), v.transform(Number), v.integer(), v.minValue(1)), '1'),
  limit: v.optional(v.pipe(v.string(), v.transform(Number), v.integer(), v.minValue(1), v.maxValue(100)), '50'),
})

import * as v from 'valibot'
import { optionalFileUrlSchema } from '../../shared/schemas/common'

export const updateBusinessSchema = v.object({
  name: v.optional(v.pipe(v.string(), v.minLength(1), v.maxLength(150))),
  tradeName: v.optional(v.pipe(v.string(), v.maxLength(150))),
  phone: v.optional(v.pipe(v.string(), v.maxLength(30))),
  email: v.optional(v.pipe(v.string(), v.email())),
  address: v.optional(v.pipe(v.string(), v.maxLength(300))),
  currencyCode: v.optional(v.pipe(v.string(), v.length(3))), // USD, GTQ, CRC, etc.
  logoUrl: optionalFileUrlSchema,
})

export const createTaxSchema = v.object({
  name: v.pipe(v.string(), v.minLength(1), v.maxLength(80)),
  rate: v.pipe(v.string(), v.minLength(1)), // decimal como string, ej: '13.00'
})

export const createPaymentMethodSchema = v.object({
  name: v.pipe(v.string(), v.minLength(1), v.maxLength(80)),
})

export const toggleActiveSchema = v.object({
  isActive: v.boolean('isActive debe ser true o false'),
})

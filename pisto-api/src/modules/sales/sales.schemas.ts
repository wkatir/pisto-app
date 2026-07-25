import * as v from 'valibot'
import { decimalString } from '../../shared/schemas/common'
import { paginationQuerySchema } from '../../shared/utils/pagination'

export const createCustomerSchema = v.object({
  customerType: v.optional(v.picklist(['person', 'company']), 'person'),
  firstName: v.optional(v.string()),
  lastName: v.optional(v.string()),
  companyName: v.optional(v.string()),
  taxId: v.optional(v.string()),
  taxReg: v.optional(v.string()),
  email: v.optional(v.pipe(v.string(), v.email())),
  phone: v.optional(v.string()),
  address: v.optional(v.string()),
  creditLimit: v.optional(decimalString, '0'),
  creditDays: v.optional(v.pipe(v.number(), v.integer()), 0),
})

export const updateCustomerSchema = v.partial(createCustomerSchema)

export const createSaleSchema = v.object({
  customerId: v.optional(v.pipe(v.string(), v.uuid())),
  documentTypeId: v.pipe(v.string(), v.uuid()),
  warehouseId: v.pipe(v.string(), v.uuid()),
  dueDate: v.optional(v.string()),
  notes: v.optional(v.string()),
  paymentStatus: v.optional(v.picklist(['paid', 'credit']), 'paid'),
  lines: v.pipe(
    v.array(v.object({
      productId: v.pipe(v.string(), v.uuid()),
      quantity: decimalString,
      unitPrice: decimalString,
      discountPct: v.optional(decimalString, '0'),
      taxId: v.optional(v.pipe(v.string(), v.uuid())),
    })),
    v.minLength(1, 'Al menos un producto'),
  ),
  payments: v.optional(v.array(v.object({
    paymentMethodId: v.pipe(v.string(), v.uuid()),
    amount: decimalString,
    reference: v.optional(v.string()),
  }))),
})

export const invoiceQuerySchema = v.object({
  ...paginationQuerySchema.entries,
  customerId: v.optional(v.pipe(v.string(), v.uuid())),
})

export const creditNoteSchema = v.object({
  reason: v.pipe(v.string(), v.minLength(1, 'Razón requerida')),
  lines: v.pipe(
    v.array(v.object({
      productId: v.pipe(v.string(), v.uuid()),
      quantity: decimalString,
      unitPrice: decimalString,
    })),
    v.minLength(1),
  ),
})

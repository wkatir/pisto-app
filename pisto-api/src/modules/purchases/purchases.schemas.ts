import * as v from 'valibot'
import { decimalString } from '../../shared/schemas/common'

export const createSupplierSchema = v.object({
  companyName: v.pipe(v.string(), v.minLength(1)),
  contactName: v.optional(v.string()),
  taxId: v.optional(v.string()),
  phone: v.optional(v.string()),
  email: v.optional(v.pipe(v.string(), v.email())),
  address: v.optional(v.string()),
  paymentTerms: v.optional(v.pipe(v.number(), v.integer()), 30),
})

export const updateSupplierSchema = v.partial(createSupplierSchema)

export const createPurchaseOrderSchema = v.object({
  supplierId: v.pipe(v.string(), v.uuid()),
  warehouseId: v.optional(v.pipe(v.string(), v.uuid())),
  expectedDate: v.optional(v.string()),
  notes: v.optional(v.string()),
  lines: v.optional(v.array(v.object({
    productId: v.pipe(v.string(), v.uuid()),
    quantityOrdered: decimalString,
    unitCost: decimalString,
    taxId: v.optional(v.pipe(v.string(), v.uuid())),
  })), []),
})

export const updatePurchaseOrderSchema = v.object({
  status: v.optional(v.picklist(['draft', 'approved', 'cancelled'])),
  expectedDate: v.optional(v.pipe(v.string(), v.isoDate())),
  notes: v.optional(v.string()),
})

export const receiveGoodsSchema = v.object({
  notes: v.optional(v.string()),
  lines: v.pipe(
    v.array(v.object({
      purchaseOrderLineId: v.pipe(v.string(), v.uuid()),
      productId: v.pipe(v.string(), v.uuid()),
      quantityReceived: decimalString,
    })),
    v.minLength(1),
  ),
})

export const createSupplierProductSchema = v.object({
  supplierId: v.pipe(v.string(), v.uuid()),
  productId: v.pipe(v.string(), v.uuid()),
  supplierSku: v.optional(v.string()),
  supplierPrice: v.optional(decimalString),
  leadTimeDays: v.optional(v.pipe(v.number(), v.integer(), v.minValue(0))),
})

export const updateSupplierProductSchema = v.partial(createSupplierProductSchema)

export const supplierPaymentSchema = v.object({
  paymentMethodId: v.pipe(v.string(), v.uuid()),
  amount: decimalString,
  reference: v.optional(v.string()),
  notes: v.optional(v.string()),
})

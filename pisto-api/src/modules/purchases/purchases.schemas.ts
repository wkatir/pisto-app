import * as v from 'valibot'

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
    quantityOrdered: v.pipe(v.string(), v.regex(/^\d+(\.\d{1,2})?$/)),
    unitCost: v.pipe(v.string(), v.regex(/^\d+(\.\d{1,2})?$/)),
    taxId: v.optional(v.pipe(v.string(), v.uuid())),
  })), []),
})

export const receiveGoodsSchema = v.object({
  notes: v.optional(v.string()),
  lines: v.pipe(
    v.array(v.object({
      purchaseOrderLineId: v.pipe(v.string(), v.uuid()),
      productId: v.pipe(v.string(), v.uuid()),
      quantityReceived: v.pipe(v.string(), v.regex(/^\d+(\.\d{1,2})?$/)),
    })),
    v.minLength(1),
  ),
})

export const createSupplierProductSchema = v.object({
  supplierId: v.pipe(v.string(), v.uuid()),
  productId: v.pipe(v.string(), v.uuid()),
  supplierSku: v.optional(v.string()),
  supplierPrice: v.optional(v.pipe(v.string(), v.regex(/^\d+(\.\d{1,2})?$/))),
  leadTimeDays: v.optional(v.pipe(v.number(), v.integer(), v.minValue(0))),
})

export const updateSupplierProductSchema = v.partial(createSupplierProductSchema)

export const supplierPaymentSchema = v.object({
  paymentMethodId: v.pipe(v.string(), v.uuid()),
  amount: v.pipe(v.string(), v.regex(/^\d+(\.\d{1,2})?$/)),
  reference: v.optional(v.string()),
  notes: v.optional(v.string()),
})

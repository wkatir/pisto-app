import * as v from 'valibot'
import { decimalString, optionalFileUrlSchema } from '../../shared/schemas/common'

export const createCategorySchema = v.object({
  name: v.pipe(v.string(), v.minLength(1, 'Nombre requerido')),
  parentId: v.optional(v.pipe(v.string(), v.uuid())),
  description: v.optional(v.string()),
})

export const updateCategorySchema = v.partial(createCategorySchema)

export const createWarehouseSchema = v.object({
  name: v.pipe(v.string(), v.minLength(1, 'Nombre requerido')),
  address: v.optional(v.string()),
})

export const updateWarehouseSchema = v.partial(createWarehouseSchema)

export const createProductSchema = v.object({
  categoryId: v.optional(v.pipe(v.string(), v.uuid())),
  unitId: v.pipe(v.string(), v.uuid()),
  sku: v.optional(v.string()),
  barcode: v.optional(v.string()),
  name: v.pipe(v.string(), v.minLength(1, 'Nombre requerido')),
  description: v.optional(v.string()),
  costPrice: v.optional(decimalString, '0'),
  salePrice: decimalString,
  minStock: v.optional(decimalString, '0'),
  maxStock: v.optional(decimalString),
  isService: v.optional(v.boolean(), false),
  isTaxable: v.optional(v.boolean(), true),
  imageUrl: optionalFileUrlSchema,
})

export const updateProductSchema = v.partial(createProductSchema)

export const productQuerySchema = v.object({
  page: v.optional(v.pipe(v.string(), v.transform(Number), v.integer(), v.minValue(1)), '1'),
  limit: v.optional(v.pipe(v.string(), v.transform(Number), v.integer(), v.minValue(1), v.maxValue(100)), '20'),
  search: v.optional(v.string()),
  categoryId: v.optional(v.string()),
  isActive: v.optional(v.pipe(v.string(), v.transform((v) => v === 'true'))),
  warehouseId: v.optional(v.string()),
})

export const adjustmentSchema = v.object({
  productId: v.pipe(v.string(), v.uuid()),
  warehouseId: v.pipe(v.string(), v.uuid()),
  type: v.picklist(['adjustment_in', 'adjustment_out']),
  quantity: decimalString,
  unitCost: v.optional(decimalString),
  notes: v.optional(v.string()),
})

export const createTransferSchema = v.object({
  fromWarehouseId: v.pipe(v.string(), v.uuid()),
  toWarehouseId: v.pipe(v.string(), v.uuid()),
  notes: v.optional(v.string()),
  lines: v.pipe(
    v.array(v.object({
      productId: v.pipe(v.string(), v.uuid()),
      quantity: decimalString,
    })),
    v.minLength(1, 'Al menos un producto'),
  ),
})

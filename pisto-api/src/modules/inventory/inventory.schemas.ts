import * as v from 'valibot'

export const createCategorySchema = v.object({
  name: v.pipe(v.string(), v.minLength(1, 'Nombre requerido')),
  parentId: v.optional(v.pipe(v.number(), v.integer())),
  description: v.optional(v.string()),
})

export const updateCategorySchema = v.partial(createCategorySchema)

export const createWarehouseSchema = v.object({
  name: v.pipe(v.string(), v.minLength(1, 'Nombre requerido')),
  address: v.optional(v.string()),
})

export const updateWarehouseSchema = v.partial(createWarehouseSchema)

export const createProductSchema = v.object({
  categoryId: v.optional(v.pipe(v.number(), v.integer())),
  unitId: v.pipe(v.number(), v.integer()),
  sku: v.optional(v.string()),
  barcode: v.optional(v.string()),
  name: v.pipe(v.string(), v.minLength(1, 'Nombre requerido')),
  description: v.optional(v.string()),
  costPrice: v.optional(v.pipe(v.string(), v.regex(/^\d+(\.\d{1,2})?$/, 'Precio inválido')), '0'),
  salePrice: v.pipe(v.string(), v.regex(/^\d+(\.\d{1,2})?$/, 'Precio inválido')),
  minStock: v.optional(v.pipe(v.string(), v.regex(/^\d+(\.\d{1,2})?$/)), '0'),
  maxStock: v.optional(v.pipe(v.string(), v.regex(/^\d+(\.\d{1,2})?$/))),
  isService: v.optional(v.boolean(), false),
  isTaxable: v.optional(v.boolean(), true),
  imageUrl: v.optional(v.pipe(v.string(), v.url())),
})

export const updateProductSchema = v.partial(createProductSchema)

export const productQuerySchema = v.object({
  page: v.optional(v.pipe(v.string(), v.transform(Number), v.integer(), v.minValue(1)), '1'),
  limit: v.optional(v.pipe(v.string(), v.transform(Number), v.integer(), v.minValue(1), v.maxValue(100)), '20'),
  search: v.optional(v.string()),
  categoryId: v.optional(v.pipe(v.string(), v.transform(Number), v.integer())),
  isActive: v.optional(v.pipe(v.string(), v.transform((v) => v === 'true'))),
  warehouseId: v.optional(v.pipe(v.string(), v.transform(Number), v.integer())),
})

export const adjustmentSchema = v.object({
  productId: v.pipe(v.string(), v.uuid()),
  warehouseId: v.pipe(v.number(), v.integer()),
  type: v.picklist(['adjustment_in', 'adjustment_out']),
  quantity: v.pipe(v.string(), v.regex(/^\d+(\.\d{1,2})?$/)),
  unitCost: v.optional(v.pipe(v.string(), v.regex(/^\d+(\.\d{1,2})?$/))),
  notes: v.optional(v.string()),
})

export const createTransferSchema = v.object({
  fromWarehouseId: v.pipe(v.number(), v.integer()),
  toWarehouseId: v.pipe(v.number(), v.integer()),
  notes: v.optional(v.string()),
  lines: v.pipe(
    v.array(v.object({
      productId: v.pipe(v.string(), v.uuid()),
      quantity: v.pipe(v.string(), v.regex(/^\d+(\.\d{1,2})?$/)),
    })),
    v.minLength(1, 'Al menos un producto'),
  ),
})

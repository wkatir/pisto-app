import * as v from 'valibot'

export const scanReceiptSchema = v.object({
  image: v.pipe(v.string(), v.minLength(1, 'La imagen es requerida')),
  mimeType: v.pipe(
    v.string(),
    v.minLength(1),
    v.regex(/^image\/(jpeg|png|gif|webp)$/, 'Tipo de imagen no soportado. Usa JPEG, PNG, GIF o WebP'),
  ),
})

export const categorizeExpenseSchema = v.object({
  description: v.pipe(v.string(), v.minLength(1, 'La descripcion es requerida')),
  amount: v.pipe(v.number(), v.minValue(0.01, 'El monto debe ser mayor a 0')),
  vendor: v.optional(v.string()),
})

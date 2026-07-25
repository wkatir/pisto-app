import * as v from 'valibot'

export const idSchema = v.pipe(v.string(), v.length(36, 'ID inválido'))

export const idParamSchema = v.object({ id: idSchema })

// Money and quantities travel as decimal strings (numeric in Postgres)
export const decimalString = v.pipe(v.string(), v.regex(/^\d+(\.\d{1,2})?$/, 'Monto inválido'))

// Matches the relative path POST /uploads/image returns (see uploads.routes.ts):
// /uploads/<folder>/<uuid>.<jpg|png|webp>
const uploadPathRegex = /^\/uploads\/[a-z]+\/[0-9a-f-]{36}\.(jpg|png|webp)$/i

// File fields (product images, receipts, avatars, logos) hold either the relative
// path our own upload endpoint returns or an absolute URL (external/legacy assets).
export const fileUrlSchema = v.union([
  v.pipe(v.string(), v.regex(uploadPathRegex, 'Ruta de archivo inválida')),
  v.pipe(v.string(), v.url('URL inválida')),
])

// Optional and clearable via '' (used by update endpoints to remove a file field)
export const optionalFileUrlSchema = v.optional(v.union([v.literal(''), fileUrlSchema]))

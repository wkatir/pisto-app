import * as v from 'valibot'

export const intParam = (min: number, max: number) =>
  v.pipe(
    v.string(),
    v.transform((s) => Number.parseInt(s, 10)),
    v.number('debe ser numérico'),
    v.integer(),
    v.minValue(min),
    v.maxValue(max),
  )

export const paginationQuerySchema = v.object({
  page: v.optional(intParam(1, 10000), '1'),
  limit: v.optional(intParam(1, 200), '20'),
  search: v.optional(v.string()),
})

export const dateRangeQuerySchema = v.object({
  from: v.optional(v.pipe(v.string(), v.isoDate('from debe ser YYYY-MM-DD'))),
  to: v.optional(v.pipe(v.string(), v.isoDate('to debe ser YYYY-MM-DD'))),
})

export type PaginationQuery = v.InferOutput<typeof paginationQuerySchema>
export type DateRangeQuery = v.InferOutput<typeof dateRangeQuerySchema>

export function paginatedResponse<T>(data: T[], total: number, page: number, limit: number) {
  return {
    data,
    meta: {
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
      hasNext: page * limit < total,
      hasPrev: page > 1,
    },
  }
}

import * as v from 'valibot'

const intParam = (min: number, max: number) =>
  v.optional(
    v.pipe(
      v.string(),
      v.transform((s) => Number.parseInt(s, 10)),
      v.number('debe ser numérico'),
      v.integer(),
      v.minValue(min),
      v.maxValue(max),
    ),
  )

export const paginationQuerySchema = v.object({
  page: intParam(1, 10000),
  limit: intParam(1, 200),
})

export const dateRangeQuerySchema = v.object({
  from: v.optional(v.pipe(v.string(), v.isoDate('from debe ser YYYY-MM-DD'))),
  to: v.optional(v.pipe(v.string(), v.isoDate('to debe ser YYYY-MM-DD'))),
})

export const paginationWithDatesSchema = v.object({
  ...paginationQuerySchema.entries,
  ...dateRangeQuerySchema.entries,
})

export { intParam }
export type PaginationQuery = v.InferOutput<typeof paginationQuerySchema>
export type DateRangeQuery = v.InferOutput<typeof dateRangeQuerySchema>

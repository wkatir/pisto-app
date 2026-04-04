import * as v from 'valibot'

export const paginationSchema = v.object({
  page: v.optional(v.pipe(v.string(), v.transform(Number), v.integer(), v.minValue(1)), '1'),
  limit: v.optional(v.pipe(v.string(), v.transform(Number), v.integer(), v.minValue(1), v.maxValue(100)), '20'),
  search: v.optional(v.string()),
  sortBy: v.optional(v.string()),
  sortOrder: v.optional(v.picklist(['asc', 'desc']), 'desc'),
})

export type PaginationParams = v.InferOutput<typeof paginationSchema>

export function paginate(params: PaginationParams) {
  const { page, limit } = params
  return {
    skip: (page - 1) * limit,
    take: limit,
  }
}

export function paginatedResponse<T>(data: T[], total: number, params: PaginationParams) {
  const { page, limit } = params
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

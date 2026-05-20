import * as v from 'valibot'

export const forecastQuerySchema = v.object({
  days: v.optional(
    v.pipe(
      v.string(),
      v.transform((s) => Number.parseInt(s, 10)),
      v.number('days debe ser numérico'),
      v.integer(),
      v.minValue(7),
      v.maxValue(90),
    ),
  ),
})

export type ForecastQuery = v.InferOutput<typeof forecastQuerySchema>

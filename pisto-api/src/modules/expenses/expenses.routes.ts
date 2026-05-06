import { Hono } from 'hono'
import { vValidator } from '@hono/valibot-validator'
import type { AppEnv } from '../../types/app-env'
import {
  createExpenseCategorySchema,
  createExpenseSchema,
  updateExpenseSchema,
  expenseQuerySchema,
} from './expenses.schemas'
import * as expenseService from './expenses.service'
import { dateRangeQuerySchema } from '../../shared/schemas/pagination'

const expenses = new Hono<AppEnv>()

expenses.get('/categories', async (c) => {
  const businessId = c.get('businessId')
  const data = await expenseService.listCategories(businessId)
  return c.json({ data })
})

expenses.post('/categories', vValidator('json', createExpenseCategorySchema), async (c) => {
  const businessId = c.get('businessId')
  const body = c.req.valid('json')
  const data = await expenseService.createCategory(businessId, body)
  return c.json({ data }, 201)
})

expenses.get('/summary', vValidator('query', dateRangeQuerySchema), async (c) => {
  const businessId = c.get('businessId')
  const { from, to } = c.req.valid('query')
  const data = await expenseService.getExpenseSummary(businessId, from, to)
  return c.json({ data })
})

expenses.get('/', vValidator('query', expenseQuerySchema), async (c) => {
  const businessId = c.get('businessId')
  const query = c.req.valid('query')
  const data = await expenseService.listExpenses(businessId, {
    startDate: query.startDate,
    endDate: query.endDate,
    categoryId: query.categoryId,
    page: query.page as number | undefined,
    limit: query.limit as number | undefined,
  })
  return c.json({ data })
})

expenses.get('/:id', async (c) => {
  const businessId = c.get('businessId')
  const id = c.req.param('id')
  const data = await expenseService.getExpense(businessId, id)
  if (!data) return c.json({ error: 'Gasto no encontrado' }, 404)
  return c.json({ data })
})

expenses.post('/', vValidator('json', createExpenseSchema), async (c) => {
  const businessId = c.get('businessId')
  const userId = c.get('userId')
  const body = c.req.valid('json')
  const data = await expenseService.createExpense(businessId, userId, body)
  return c.json({ data }, 201)
})

expenses.put('/:id', vValidator('json', updateExpenseSchema), async (c) => {
  const businessId = c.get('businessId')
  const id = c.req.param('id')
  const body = c.req.valid('json')
  const data = await expenseService.updateExpense(id, businessId, body as any)
  return c.json({ data })
})

expenses.delete('/:id', async (c) => {
  const businessId = c.get('businessId')
  const id = c.req.param('id')
  await expenseService.deleteExpense(id, businessId)
  return c.json({ message: 'Gasto eliminado' })
})

export { expenses }

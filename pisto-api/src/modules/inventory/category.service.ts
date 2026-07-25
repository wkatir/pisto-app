import { productCategory } from '../../db/schema'
import { crudService } from '../../shared/crud'

const categories = crudService(productCategory, {
  notFoundMessage: 'Categoría no encontrada',
})

export const listCategories = categories.listAll
export const createCategory = categories.create
export const updateCategory = categories.update
export const deleteCategory = categories.softDelete

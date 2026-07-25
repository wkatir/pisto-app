import { warehouse } from '../../db/schema'
import { crudService } from '../../shared/crud'

const warehouses = crudService(warehouse, {
  notFoundMessage: 'Bodega no encontrada',
})

export const listWarehouses = warehouses.listAll
export const createWarehouse = warehouses.create
export const updateWarehouse = warehouses.update
export const deleteWarehouse = warehouses.softDelete

import { customer } from '../../db/schema'
import { crudService } from '../../shared/crud'

const customers = crudService(customer, {
  notFoundMessage: 'Cliente no encontrado',
  searchColumns: [customer.firstName, customer.lastName, customer.companyName, customer.email],
  defaultOrder: customer.createdAt,
})

export const listCustomers = customers.list
export const getCustomer = customers.getById
export const createCustomer = customers.create
export const updateCustomer = customers.update

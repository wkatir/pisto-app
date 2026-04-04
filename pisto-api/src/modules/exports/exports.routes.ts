import { Hono } from 'hono'
import * as reportService from '../reports/report.service'
import { generateExcel } from './generators/excel.generator'
import { generatePDF } from './generators/pdf.generator'
import { generateCSV } from './generators/csv.generator'
import { AppError } from '../../shared/errors/app-error'
import type { AppEnv } from '../../types/app-env'

const exports_ = new Hono<AppEnv>()

const reportConfigs: Record<string, {
  title: string
  columns: { header: string; key: string; width?: number }[]
  getData: (businessId: string, from?: string, to?: string) => Promise<any>
}> = {
  'top-products': {
    title: 'Productos Más Vendidos',
    columns: [
      { header: 'SKU', key: 'sku', width: 15 },
      { header: 'Producto', key: 'name', width: 30 },
      { header: 'Cantidad', key: 'total_quantity', width: 12 },
      { header: 'Ingresos', key: 'total_revenue', width: 15 },
    ],
    getData: (bid, from, to) => reportService.getTopProducts(bid, 100, from, to),
  },
  'inventory-valuation': {
    title: 'Valuación de Inventario',
    columns: [
      { header: 'SKU', key: 'sku', width: 15 },
      { header: 'Producto', key: 'name', width: 30 },
      { header: 'Costo Unitario', key: 'cost_price', width: 15 },
      { header: 'Stock', key: 'total_stock', width: 12 },
      { header: 'Valuación', key: 'valuation', width: 15 },
    ],
    getData: (bid) => reportService.getInventoryValuation(bid),
  },
  'receivables-aging': {
    title: 'Antigüedad de Cuentas por Cobrar',
    columns: [
      { header: 'Cliente', key: 'customer_name', width: 25 },
      { header: 'Facturas Abiertas', key: 'open_invoices', width: 15 },
      { header: 'Saldo Total', key: 'total_balance', width: 15 },
      { header: 'Vencimiento Más Antiguo', key: 'oldest_due', width: 20 },
    ],
    getData: (bid) => reportService.getReceivablesAging(bid),
  },
  'purchases-by-supplier': {
    title: 'Compras por Proveedor',
    columns: [
      { header: 'Proveedor', key: 'company_name', width: 30 },
      { header: 'Total Órdenes', key: 'total_orders', width: 15 },
      { header: 'Monto Total', key: 'total_amount', width: 15 },
    ],
    getData: (bid, from, to) => reportService.getPurchasesBySupplier(bid, from, to),
  },
}

exports_.get('/:report/excel', async (c) => {
  const businessId = c.get('businessId')
  const report = c.req.param('report')
  const from = c.req.query('from')
  const to = c.req.query('to')

  const config = reportConfigs[report]
  if (!config) throw new AppError(404, 'Reporte no encontrado')

  const data = await config.getData(businessId, from, to)
  const buffer = await generateExcel(config.title, config.columns, data)

  c.header('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
  c.header('Content-Disposition', `attachment; filename="${report}.xlsx"`)
  return c.body(buffer as any)
})

exports_.get('/:report/pdf', async (c) => {
  const businessId = c.get('businessId')
  const report = c.req.param('report')
  const from = c.req.query('from')
  const to = c.req.query('to')

  const config = reportConfigs[report]
  if (!config) throw new AppError(404, 'Reporte no encontrado')

  const data = await config.getData(businessId, from, to)
  const buffer = await generatePDF(config.title, config.columns, data)

  c.header('Content-Type', 'application/pdf')
  c.header('Content-Disposition', `attachment; filename="${report}.pdf"`)
  return c.body(buffer as any)
})

exports_.get('/:report/csv', async (c) => {
  const businessId = c.get('businessId')
  const report = c.req.param('report')
  const from = c.req.query('from')
  const to = c.req.query('to')

  const config = reportConfigs[report]
  if (!config) throw new AppError(404, 'Reporte no encontrado')

  const data = await config.getData(businessId, from, to)
  const csv = await generateCSV(config.columns, data)

  c.header('Content-Type', 'text/csv')
  c.header('Content-Disposition', `attachment; filename="${report}.csv"`)
  return c.body(csv)
})

export { exports_ as exports }

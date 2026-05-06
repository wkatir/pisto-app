import { Hono } from 'hono'
import * as reportService from '../reports/report.service'
import * as invoiceService from '../sales/invoice.service'
import { generateExcel } from './generators/excel.generator'
import { generatePDF } from './generators/pdf.generator'
import { generateCSV } from './generators/csv.generator'
import { AppError } from '../../shared/errors/app-error'
import type { AppEnv } from '../../types/app-env'

const exports_ = new Hono<AppEnv>()

function safeFilename(name: string): string {
  return name.replace(/[^a-zA-Z0-9._-]/g, '_').slice(0, 80) || 'export'
}

const reportConfigs: Record<string, {
  title: string
  columns: { header: string; key: string; width?: number }[]
  getData: (businessId: string, from?: string, to?: string) => Promise<any[]>
}> = {
  'top-products': {
    title: 'Productos Más Vendidos',
    columns: [
      { header: 'SKU', key: 'sku', width: 15 },
      { header: 'Producto', key: 'name', width: 30 },
      { header: 'Cantidad', key: 'total_quantity', width: 12 },
      { header: 'Ingresos', key: 'total_revenue', width: 15 },
    ],
    getData: (bid, from, to) => reportService.getTopProducts(bid, 100, from, to) as unknown as Promise<any[]>,
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
    getData: (bid) => reportService.getInventoryValuation(bid) as unknown as Promise<any[]>,
  },
  'receivables-aging': {
    title: 'Antigüedad de Cuentas por Cobrar',
    columns: [
      { header: 'Cliente', key: 'customer_name', width: 25 },
      { header: 'Facturas Abiertas', key: 'open_invoices', width: 15 },
      { header: 'Saldo Total', key: 'total_balance', width: 15 },
      { header: 'Vencimiento Más Antiguo', key: 'oldest_due', width: 20 },
    ],
    getData: (bid) => reportService.getReceivablesAging(bid) as unknown as Promise<any[]>,
  },
  'purchases-by-supplier': {
    title: 'Compras por Proveedor',
    columns: [
      { header: 'Proveedor', key: 'company_name', width: 30 },
      { header: 'Total Órdenes', key: 'total_orders', width: 15 },
      { header: 'Monto Total', key: 'total_amount', width: 15 },
    ],
    getData: (bid, from, to) => reportService.getPurchasesBySupplier(bid, from, to) as unknown as Promise<any[]>,
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
  c.header('Content-Disposition', `attachment; filename="${safeFilename(report)}.xlsx"`)
  return c.body(new Uint8Array(buffer))
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
  c.header('Content-Disposition', `attachment; filename="${safeFilename(report)}.pdf"`)
  return c.body(buffer as unknown as ArrayBuffer)
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
  c.header('Content-Disposition', `attachment; filename="${safeFilename(report)}.csv"`)
  return c.body(csv)
})

exports_.get('/invoices/:id/pdf', async (c) => {
  const businessId = c.get('businessId')
  const id = c.req.param('id')

  const sale = await invoiceService.getSale(businessId, id)

  const columns = [
    { header: 'Producto', key: 'productName', width: 30 },
    { header: 'Cantidad', key: 'quantity', width: 12 },
    { header: 'Precio Unit.', key: 'unitPrice', width: 15 },
    { header: 'Descuento', key: 'discountAmount', width: 15 },
    { header: 'Impuesto', key: 'taxAmount', width: 15 },
    { header: 'Total', key: 'lineTotal', width: 15 },
  ]

  const rows = (sale.lines as any[]).map((l: any) => ({
    productName: l.productName ?? l.productId,
    quantity: l.quantity,
    unitPrice: l.unitPrice,
    discountAmount: l.discountAmount ?? '0.00',
    taxAmount: l.taxAmount ?? '0.00',
    lineTotal: l.lineTotal,
  }))

  rows.push(
    { productName: '', quantity: '', unitPrice: '', discountAmount: '', taxAmount: '', lineTotal: '' },
    { productName: 'Subtotal', quantity: '', unitPrice: '', discountAmount: '', taxAmount: '', lineTotal: String(sale.subtotal ?? '') },
    { productName: 'Impuestos', quantity: '', unitPrice: '', discountAmount: '', taxAmount: '', lineTotal: String(sale.taxAmount ?? '') },
    { productName: 'TOTAL', quantity: '', unitPrice: '', discountAmount: '', taxAmount: '', lineTotal: String(sale.total ?? '') },
  )

  const title = `Factura ${sale.saleNumber ?? id}`
  const buffer = await generatePDF(title, columns, rows)

  c.header('Content-Type', 'application/pdf')
  c.header('Content-Disposition', `attachment; filename="${safeFilename(`factura-${sale.saleNumber ?? id}`)}.pdf"`)
  return c.body(buffer as unknown as ArrayBuffer)
})

export { exports_ as exports }

import { Hono } from 'hono'
import { vValidator } from '@hono/valibot-validator'
import * as v from 'valibot'
import * as reportService from '../reports/report.service'
import * as invoiceService from '../sales/invoice.service'
import { generateExcel } from './generators/excel.generator'
import { generatePDF } from './generators/pdf.generator'
import { generateCSV } from './generators/csv.generator'
import { dateRangeQuerySchema } from '../../shared/utils/pagination'
import { idParamSchema } from '../../shared/schemas/common'
import type { AppEnv } from '../../types/app-env'

const exports_ = new Hono<AppEnv>()

const reportParamSchema = v.object({
  report: v.picklist(['top-products', 'inventory-valuation', 'receivables-aging', 'purchases-by-supplier'], 'Reporte no encontrado'),
  format: v.picklist(['excel', 'pdf', 'csv'], 'Formato no soportado'),
})

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

const formatConfigs: Record<string, {
  contentType: string
  extension: string
  generate: (config: (typeof reportConfigs)[string], data: any[]) => Promise<Uint8Array | ArrayBuffer | string>
}> = {
  excel: {
    contentType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    extension: 'xlsx',
    generate: async (config, data) => new Uint8Array(await generateExcel(config.title, config.columns, data)),
  },
  pdf: {
    contentType: 'application/pdf',
    extension: 'pdf',
    generate: (config, data) => generatePDF(config.title, config.columns, data) as unknown as Promise<ArrayBuffer>,
  },
  csv: {
    contentType: 'text/csv',
    extension: 'csv',
    generate: (config, data) => generateCSV(config.columns, data),
  },
}

exports_.get('/:report/:format', vValidator('param', reportParamSchema), vValidator('query', dateRangeQuerySchema), async (c) => {
  const businessId = c.get('businessId')
  const { report, format } = c.req.valid('param')
  const { from, to } = c.req.valid('query')

  const config = reportConfigs[report]!
  const formatConfig = formatConfigs[format]!
  const data = await config.getData(businessId, from, to)
  const body = await formatConfig.generate(config, data)

  c.header('Content-Type', formatConfig.contentType)
  c.header('Content-Disposition', `attachment; filename="${safeFilename(report)}.${formatConfig.extension}"`)
  return c.body(body as unknown as ArrayBuffer)
})

exports_.get('/invoices/:id/pdf', vValidator('param', idParamSchema), async (c) => {
  const businessId = c.get('businessId')
  const { id } = c.req.valid('param')

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
    // sale_line has no product_name column: falls back to the id until the query joins product.
    productName: l.productName ?? l.productId,
    quantity: l.quantity,
    unitPrice: l.unitPrice,
    discountAmount: l.discountAmount,
    taxAmount: l.taxAmount,
    lineTotal: l.lineTotal,
  }))

  rows.push(
    { productName: '', quantity: '', unitPrice: '', discountAmount: '', taxAmount: '', lineTotal: '' },
    { productName: 'Subtotal', quantity: '', unitPrice: '', discountAmount: '', taxAmount: '', lineTotal: String(sale.subtotal) },
    { productName: 'Impuestos', quantity: '', unitPrice: '', discountAmount: '', taxAmount: '', lineTotal: String(sale.taxAmount) },
    { productName: 'TOTAL', quantity: '', unitPrice: '', discountAmount: '', taxAmount: '', lineTotal: String(sale.total) },
  )

  const title = `Factura ${sale.saleNumber}`
  const buffer = await generatePDF(title, columns, rows)

  c.header('Content-Type', 'application/pdf')
  c.header('Content-Disposition', `attachment; filename="${safeFilename(`factura-${sale.saleNumber}`)}.pdf"`)
  return c.body(buffer as unknown as ArrayBuffer)
})

export { exports_ as exports }

import OpenAI from 'openai'
import { structuredCompletion } from './ai-client'
import { db } from '../../config/database'
import { expenseCategory } from '../../db/schema'
import { eq } from 'drizzle-orm'
import { AppError } from '../../shared/errors/app-error'

interface ReceiptItem {
  description: string | null
  quantity: number | null
  unitPrice: number | null
  total: number | null
}

interface ReceiptData {
  vendor: string | null
  date: string | null
  items: ReceiptItem[]
  subtotal: number | null
  tax: number | null
  total: number | null
  invoiceNumber: string | null
  nit: string | null
}

const receiptJsonSchema = {
  type: 'object',
  properties: {
    vendor: { type: ['string', 'null'] },
    date: { type: ['string', 'null'] },
    items: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          description: { type: ['string', 'null'] },
          quantity: { type: ['number', 'null'] },
          unitPrice: { type: ['number', 'null'] },
          total: { type: ['number', 'null'] },
        },
        required: ['description', 'quantity', 'unitPrice', 'total'],
        additionalProperties: false,
      },
    },
    subtotal: { type: ['number', 'null'] },
    tax: { type: ['number', 'null'] },
    total: { type: ['number', 'null'] },
    invoiceNumber: { type: ['string', 'null'] },
    nit: { type: ['string', 'null'] },
  },
  required: ['vendor', 'date', 'items', 'subtotal', 'tax', 'total', 'invoiceNumber', 'nit'],
  additionalProperties: false,
} as const

const categorizationJsonSchema = {
  type: 'object',
  properties: {
    category: { type: 'string' },
    confidence: { type: 'string', enum: ['alta', 'media', 'baja'] },
  },
  required: ['category', 'confidence'],
  additionalProperties: false,
} as const

const MAX_BASE64_SIZE = 5 * 1024 * 1024 * 1.37 // ~5MB file -> base64 is ~37% larger

export async function scanReceipt(
  imageBase64: string,
  mimeType: string,
): Promise<{ data: ReceiptData }> {
  if (imageBase64.length > MAX_BASE64_SIZE) {
    throw new AppError(413, 'La imagen excede el limite de 5MB')
  }

  try {
    const data = await structuredCompletion<ReceiptData>({
      name: 'receipt_data',
      schema: receiptJsonSchema,
      maxTokens: 2048,
      messages: [
        {
          role: 'user',
          content: [
            {
              type: 'image_url',
              image_url: {
                url: `data:${mimeType};base64,${imageBase64}`,
              },
            },
            {
              type: 'text',
              text: `Analiza esta imagen de una factura o recibo y extrae los datos: vendor (nombre del proveedor/vendedor), date (fecha en formato YYYY-MM-DD), items, subtotal, tax (IVA u otros impuestos), total, invoiceNumber (numero de factura si es visible), nit (NIT del proveedor si es visible). Si algun campo no es visible, ponlo como null.`,
            },
          ],
        },
      ],
    })
    return { data }
  } catch (err) {
    // WHY: the configured AI provider (DeepSeek) is text-only and rejects image content parts:
    // surface a clear, actionable error instead of letting the provider's raw 500 leak through.
    if (err instanceof OpenAI.APIError) {
      throw new AppError(502, 'El proveedor de IA configurado no admite el escaneo de imágenes. Contacta al administrador para habilitar un proveedor con soporte de visión.')
    }
    throw err
  }
}

export async function categorizeExpense(
  description: string,
  amount: number,
  vendor: string | undefined,
  businessId: string,
): Promise<{ category: string; confidence: string }> {
  const categories = await db
    .select({ name: expenseCategory.name })
    .from(expenseCategory)
    .where(eq(expenseCategory.businessId, businessId))

  if (categories.length === 0) {
    return { category: 'Sin categoria', confidence: 'baja' }
  }

  const categoryNames = categories.map((c) => c.name)
  const vendorPart = vendor ? ` de ${vendor}` : ''

  const parsed = await structuredCompletion<{ category: string; confidence: string }>({
    name: 'expense_categorization',
    schema: categorizationJsonSchema,
    maxTokens: 256,
    messages: [
      {
        role: 'user',
        content: `Categoriza este gasto: '${description}'${vendorPart} por $${amount.toFixed(2)}. Categorias disponibles: ${categoryNames.join(', ')}. Usa el nombre exacto de la lista.`,
      },
    ],
  })
  const match = categoryNames.find(
    (name) => name.toLowerCase() === parsed.category.toLowerCase(),
  )
  return {
    category: match ?? parsed.category,
    confidence: match ? parsed.confidence : 'baja',
  }
}

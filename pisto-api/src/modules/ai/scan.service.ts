import { client, getAiModel } from './ai-client'
import { db } from '../../config/database'
import { expenseCategory } from '../../db/schema'
import { eq } from 'drizzle-orm'

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

const MAX_BASE64_SIZE = 5 * 1024 * 1024 * 1.37 // ~5MB file -> base64 is ~37% larger

export async function scanReceipt(
  imageBase64: string,
  mimeType: string,
): Promise<{ data: ReceiptData; message?: string }> {
  if (imageBase64.length > MAX_BASE64_SIZE) {
    throw new Error('La imagen excede el limite de 5MB')
  }

  const response = await client.chat.completions.create({
    model: getAiModel(),
    max_tokens: 2048,
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
            text: `Analiza esta imagen de una factura o recibo. Extrae los siguientes datos en formato JSON:
- vendor (nombre del proveedor/vendedor)
- date (fecha en formato YYYY-MM-DD)
- items (array de { description, quantity, unitPrice, total })
- subtotal
- tax (IVA u otros impuestos)
- total
- invoiceNumber (numero de factura si es visible)
- nit (NIT del proveedor si es visible)
Si algun campo no es visible, ponlo como null. Responde SOLO con el JSON, sin explicacion.`,
          },
        ],
      },
    ],
  })

  const raw = response.choices[0]?.message?.content
  if (!raw) throw new Error('AI returned empty response for receipt scan')

  const cleaned = raw.replace(/^```(?:json)?\s*\n?/i, '').replace(/\n?```\s*$/i, '').trim()
  try {
    const parsed: ReceiptData = JSON.parse(cleaned)
    return { data: parsed }
  } catch (e) {
    throw new Error(`Failed to parse receipt JSON: ${(e as Error).message}\nRaw: ${cleaned.slice(0, 500)}`)
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

  const response = await client.chat.completions.create({
    model: getAiModel(),
    max_tokens: 256,
    messages: [
      {
        role: 'user',
        content: `Categoriza este gasto: '${description}'${vendorPart} por Q${amount.toFixed(2)}. Categorias disponibles: ${categoryNames.join(', ')}. Responde SOLO con un JSON asi: {"category":"nombre exacto","confidence":"alta|media|baja"}. Usa el nombre exacto de la lista.`,
      },
    ],
  })

  const raw = response.choices[0]?.message?.content
  if (!raw) throw new Error('AI returned empty response for categorization')

  const cleaned = raw.replace(/^```(?:json)?\s*\n?/i, '').replace(/\n?```\s*$/i, '').trim()
  try {
    const parsed = JSON.parse(cleaned) as { category: string; confidence: string }
    const match = categoryNames.find(
      (name) => name.toLowerCase() === parsed.category.toLowerCase(),
    )
    return {
      category: match ?? parsed.category,
      confidence: match ? parsed.confidence : 'baja',
    }
  } catch (e) {
    throw new Error(`Failed to parse categorization JSON: ${(e as Error).message}\nRaw: ${cleaned.slice(0, 500)}`)
  }
}

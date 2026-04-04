import Decimal from 'decimal.js'

Decimal.set({ precision: 20, rounding: Decimal.ROUND_HALF_UP })

export function toDecimal(value: number | string | Decimal): Decimal {
  return new Decimal(value)
}

export function calculateLineTotal(
  quantity: number | string,
  unitPrice: number | string,
  discountPct: number | string = 0,
): { lineTotal: Decimal; discountAmount: Decimal } {
  const qty = toDecimal(quantity)
  const price = toDecimal(unitPrice)
  const discount = toDecimal(discountPct)
  const subtotal = qty.mul(price)
  const discountAmount = subtotal.mul(discount).div(100)
  const lineTotal = subtotal.minus(discountAmount)
  return { lineTotal, discountAmount }
}

export function calculateTax(amount: number | string, rate: number | string): Decimal {
  return toDecimal(amount).mul(toDecimal(rate))
}

export function formatUSD(amount: number | string | Decimal): string {
  return `$${toDecimal(amount).toFixed(2)}`
}

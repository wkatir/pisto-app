export const SaleStatus = {
  DRAFT: 'draft',
  COMPLETED: 'completed',
  CANCELLED: 'cancelled',
} as const

export const PaymentStatus = {
  PAID: 'paid',
  CREDIT: 'credit',
} as const

export const ReceivableStatus = {
  PENDING: 'pending',
  PAID: 'paid',
} as const

export const PayableStatus = {
  PENDING: 'pending',
  PAID: 'paid',
} as const

export const TransferStatus = {
  PENDING: 'pending',
  COMPLETED: 'completed',
  CANCELLED: 'cancelled',
} as const

export const PurchaseOrderStatus = {
  DRAFT: 'draft',
  COMPLETED: 'completed',
  CANCELLED: 'cancelled',
  RECEIVED: 'received',
  PARTIAL: 'partial',
} as const

export const CreditNoteStatus = {
  ACTIVE: 'active',
  CANCELLED: 'cancelled',
} as const

export type SaleStatus = typeof SaleStatus[keyof typeof SaleStatus]
export type PaymentStatus = typeof PaymentStatus[keyof typeof PaymentStatus]
export type ReceivableStatus = typeof ReceivableStatus[keyof typeof ReceivableStatus]
export type PayableStatus = typeof PayableStatus[keyof typeof PayableStatus]
export type TransferStatus = typeof TransferStatus[keyof typeof TransferStatus]
export type PurchaseOrderStatus = typeof PurchaseOrderStatus[keyof typeof PurchaseOrderStatus]
export type CreditNoteStatus = typeof CreditNoteStatus[keyof typeof CreditNoteStatus]

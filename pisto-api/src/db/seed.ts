import 'dotenv/config'
import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'
import { eq, and } from 'drizzle-orm'
import { subDays, format } from 'date-fns'
import {
  business, appUser, role, permission, rolePermission, userRole,
  documentType, paymentMethod, tax, unitOfMeasure, warehouse,
  productCategory, product, productStock,
  customer, sale, saleLine, saleLineTax, salePayment,
  accountReceivable, collectionPayment,
  supplier, purchaseOrder, purchaseOrderLine,
  goodsReceipt, accountPayable,
} from './schema'

async function hashPassword(password: string): Promise<string> {
  const encoder = new TextEncoder()
  const salt = crypto.getRandomValues(new Uint8Array(16))
  const keyMaterial = await crypto.subtle.importKey('raw', encoder.encode(password), 'PBKDF2', false, ['deriveBits'])
  const hash = await crypto.subtle.deriveBits({ name: 'PBKDF2', salt, iterations: 100000, hash: 'SHA-256' }, keyMaterial, 256)
  const toHex = (arr: Uint8Array) => Array.from(arr).map(b => b.toString(16).padStart(2, '0')).join('')
  return `${toHex(salt)}:${toHex(new Uint8Array(hash))}`
}

const url = process.env.DATABASE_URL_DIRECT
if (!url) throw new Error('DATABASE_URL_DIRECT no definida en .dev.vars')

const client = postgres(url, { max: 1 })
const db = drizzle(client)

const BIZ_ID = '00000000-0000-0000-0000-000000000001'

function money(n: number): number {
  return parseFloat(n.toFixed(2))
}

function randomBetween(min: number, max: number): number {
  return Math.floor(Math.random() * (max - min + 1)) + min
}

function pick<T>(arr: T[]): T {
  return arr[Math.floor(Math.random() * arr.length)]!
}

async function tryInsertOne<T>(fn: () => Promise<T[]>): Promise<T | null> {
  try {
    const rows = await fn()
    return rows[0] ?? null
  } catch (e: any) {
    // Unique constraint violation en Postgres
    if (e?.code === '23505') return null
    throw e
  }
}

async function main() {
  console.log('Seeding database...\n')

  const unitDefs = [
    { code: 'UND', name: 'Unidad' },
    { code: 'KG', name: 'Kilogramo' },
    { code: 'LB', name: 'Libra' },
    { code: 'LT', name: 'Litro' },
    { code: 'MT', name: 'Metro' },
    { code: 'CJ', name: 'Caja' },
    { code: 'PAR', name: 'Par' },
    { code: 'DOC', name: 'Docena' },
    { code: 'GAL', name: 'Galón' },
    { code: 'SRV', name: 'Servicio' },
  ]
  for (const u of unitDefs) {
    await tryInsertOne(() => db.insert(unitOfMeasure).values(u).returning())
  }
  console.log(`  + ${unitDefs.length} units of measure`)

  const permCodes = [
    'inventory:read', 'inventory:create', 'inventory:update', 'inventory:delete',
    'inventory:adjust', 'inventory:transfer',
    'sales:read', 'sales:create', 'sales:cancel', 'sales:credit_note',
    'customers:read', 'customers:create', 'customers:update',
    'collections:read', 'collections:create',
    'purchases:read', 'purchases:create', 'purchases:update', 'purchases:receive',
    'suppliers:read', 'suppliers:create', 'suppliers:update',
    'reports:read', 'reports:export',
    'settings:read', 'settings:update',
    'users:read', 'users:create', 'users:update',
  ]
  for (const code of permCodes) {
    await tryInsertOne(() =>
      db.insert(permission).values({
        code,
        description: code.replace(':', ' - ').replace('_', ' '),
      }).returning()
    )
  }
  console.log(`  + ${permCodes.length} permissions`)

  const demoBusiness = await tryInsertOne(() =>
    db.insert(business).values({
      id: BIZ_ID,
      name: 'Empresa Demo',
      tradeName: 'Pisto Demo',
      currencyCode: 'USD',
      email: 'demo@pistoapp.com',
      phone: '2222-2222',
    } as any).returning()
  )

  let adminUserId: string

  if (demoBusiness) {
    const adminRole = await tryInsertOne(() =>
      db.insert(role).values({
        businessId: BIZ_ID,
        name: 'admin',
        description: 'Administrador con acceso total',
      } as any).returning()
    )

    if (adminRole) {
      const allPerms = await db.select().from(permission)
      for (const p of allPerms) {
        await tryInsertOne(() =>
          db.insert(rolePermission).values({ roleId: (adminRole as any).id, permissionId: p.id }).returning()
        )
      }

      const adminEmail = process.env.ADMIN_EMAIL ?? 'admin@pistoapp.com'
      const adminPassword = process.env.ADMIN_PASSWORD
        ?? `${crypto.randomUUID().replace(/-/g, '')}!Aa1`
      const passwordHash = await hashPassword(adminPassword)
      const adminUser = await tryInsertOne(() =>
        db.insert(appUser).values({
          businessId: BIZ_ID,
          email: adminEmail,
          passwordHash,
          firstName: 'Admin',
          lastName: 'Pisto',
        } as any).returning()
      )

      if (adminUser) {
        await tryInsertOne(() =>
          db.insert(userRole).values({ userId: (adminUser as any).id, roleId: (adminRole as any).id }).returning()
        )
        adminUserId = (adminUser as any).id
        console.log('  + Admin user created')
        console.log(`    email:    ${adminEmail}`)
        if (!process.env.ADMIN_PASSWORD) {
          console.log(`    password: ${adminPassword}`)
          console.log('    >> IMPORTANT: store this password now. It will not be shown again.')
        } else {
          console.log('    password: (from ADMIN_PASSWORD env)')
        }
      } else {
        const existing = await db.select().from(appUser).where(eq(appUser.email, 'admin@pistoapp.com'))
        adminUserId = existing[0]!.id
      }
    } else {
      const existing = await db.select().from(appUser).where(eq(appUser.email, 'admin@pistoapp.com'))
      adminUserId = existing[0]!.id
    }

    await tryInsertOne(() =>
      db.insert(tax).values({
        businessId: BIZ_ID,
        name: 'IVA 13%',
        rate: '13.00',
        isActive: true,
      } as any).returning()
    )

    await tryInsertOne(() =>
      db.insert(warehouse).values({
        businessId: BIZ_ID,
        name: 'Principal',
        address: 'Bodega principal',
      } as any).returning()
    )

    const docTypeDefs = [
      { businessId: BIZ_ID, code: 'FAC', name: 'Factura', isActive: true },
      { businessId: BIZ_ID, code: 'CCF', name: 'Comprobante de Crédito Fiscal', isActive: true },
      { businessId: BIZ_ID, code: 'TKT', name: 'Ticket', isActive: true },
      { businessId: BIZ_ID, code: 'NC', name: 'Nota de Crédito', isActive: true },
      { businessId: BIZ_ID, code: 'COT', name: 'Cotización', isActive: true },
    ]
    for (const dt of docTypeDefs) {
      await tryInsertOne(() => db.insert(documentType).values(dt as any).returning())
    }
    console.log(`  + ${docTypeDefs.length} document types`)

    const payMethodDefs = [
      { businessId: BIZ_ID, name: 'Efectivo', isActive: true },
      { businessId: BIZ_ID, name: 'Tarjeta de Crédito', isActive: true },
      { businessId: BIZ_ID, name: 'Tarjeta de Débito', isActive: true },
      { businessId: BIZ_ID, name: 'Transferencia Bancaria', isActive: true },
      { businessId: BIZ_ID, name: 'Cheque', isActive: true },
    ]
    for (const pm of payMethodDefs) {
      await tryInsertOne(() => db.insert(paymentMethod).values(pm as any).returning())
    }
    console.log(`  + ${payMethodDefs.length} payment methods`)
    console.log(`  + Demo business: Empresa Demo`)
  } else {
    const existing = await db.select().from(appUser).where(eq(appUser.email, 'admin@pistoapp.com'))
    adminUserId = existing[0]!.id
    console.log('  = Demo business already exists')
  }

  const [unitUND] = await db.select().from(unitOfMeasure).where(eq(unitOfMeasure.code, 'UND'))
  const [unitLB]  = await db.select().from(unitOfMeasure).where(eq(unitOfMeasure.code, 'LB'))
  const [unitLT]  = await db.select().from(unitOfMeasure).where(eq(unitOfMeasure.code, 'LT'))
  const [unitCJ]  = await db.select().from(unitOfMeasure).where(eq(unitOfMeasure.code, 'CJ'))
  const [unitGAL] = await db.select().from(unitOfMeasure).where(eq(unitOfMeasure.code, 'GAL'))

  const [docFAC]     = await db.select().from(documentType).where(and(eq(documentType.businessId, BIZ_ID), eq(documentType.code, 'FAC')))
  const [pmCash]     = await db.select().from(paymentMethod).where(and(eq(paymentMethod.businessId, BIZ_ID), eq(paymentMethod.name, 'Efectivo')))
  const [pmCard]     = await db.select().from(paymentMethod).where(and(eq(paymentMethod.businessId, BIZ_ID), eq(paymentMethod.name, 'Tarjeta de Crédito')))
  const [pmTransfer] = await db.select().from(paymentMethod).where(and(eq(paymentMethod.businessId, BIZ_ID), eq(paymentMethod.name, 'Transferencia Bancaria')))

  const [ivaTax] = await db.select().from(tax).where(eq(tax.businessId, BIZ_ID))

  const warehouses = await db.select().from(warehouse).where(eq(warehouse.businessId, BIZ_ID))
  const wh1 = warehouses.find(w => w.name === 'Principal')!

  const existingSales = await db.select().from(sale).where(eq(sale.businessId, BIZ_ID))
  if (existingSales.length > 0) {
    console.log('\n  = Demo data already seeded, skipping rich data.\n')
    console.log('Seed completed!')
    return
  }

  console.log('\n  Seeding rich demo data...\n')

  const wh2 = await tryInsertOne(() =>
    db.insert(warehouse).values({
      businessId: BIZ_ID,
      name: 'Sucursal Norte',
      address: 'Boulevard del Norte, Local 12',
    } as any).returning()
  )
  console.log('  + Warehouse: Sucursal Norte')

  const categoryDefs = [
    { businessId: BIZ_ID, name: 'Electrónica' },
    { businessId: BIZ_ID, name: 'Alimentos y Bebidas' },
    { businessId: BIZ_ID, name: 'Limpieza' },
    { businessId: BIZ_ID, name: 'Papelería y Oficina' },
    { businessId: BIZ_ID, name: 'Ferretería' },
    { businessId: BIZ_ID, name: 'Hogar' },
  ]

  const insertedCategories: { id: string; name: string }[] = []
  for (const cd of categoryDefs) {
    const row = await tryInsertOne(() => db.insert(productCategory).values(cd as any).returning())
    if (row) insertedCategories.push(row as any)
  }

  const cats = insertedCategories.length > 0
    ? insertedCategories
    : (await db.select().from(productCategory).where(eq(productCategory.businessId, BIZ_ID))) as any[]

  const catMap: Record<string, string> = {}
  for (const c of cats) catMap[c.name] = c.id
  console.log(`  + ${cats.length} categories`)

  const productDefs = [
    { name: 'Audífonos Bluetooth',    sku: 'ELEC-001', categoryId: catMap['Electrónica'],        unitId: unitUND!.id, costPrice: 12.50, salePrice: 24.99, minStock: 10 },
    { name: 'Cargador USB-C',         sku: 'ELEC-002', categoryId: catMap['Electrónica'],        unitId: unitUND!.id, costPrice:  5.00, salePrice: 12.99, minStock: 15 },
    { name: 'Cable HDMI 2m',          sku: 'ELEC-003', categoryId: catMap['Electrónica'],        unitId: unitUND!.id, costPrice:  3.50, salePrice:  8.99, minStock: 20 },
    { name: 'Mouse Inalámbrico',      sku: 'ELEC-004', categoryId: catMap['Electrónica'],        unitId: unitUND!.id, costPrice:  7.00, salePrice: 15.99, minStock: 10 },
    { name: 'Teclado USB',            sku: 'ELEC-005', categoryId: catMap['Electrónica'],        unitId: unitUND!.id, costPrice:  8.00, salePrice: 18.50, minStock:  8 },
    { name: 'Memoria USB 64GB',       sku: 'ELEC-006', categoryId: catMap['Electrónica'],        unitId: unitUND!.id, costPrice:  4.50, salePrice:  9.99, minStock: 25 },
    { name: 'Power Bank 10000mAh',    sku: 'ELEC-007', categoryId: catMap['Electrónica'],        unitId: unitUND!.id, costPrice: 10.00, salePrice: 22.99, minStock:  8 },
    { name: 'Café Molido 500g',       sku: 'ALIM-001', categoryId: catMap['Alimentos y Bebidas'],unitId: unitUND!.id, costPrice:  3.80, salePrice:  6.99, minStock: 30 },
    { name: 'Azúcar 2.5lb',           sku: 'ALIM-002', categoryId: catMap['Alimentos y Bebidas'],unitId: unitLB!.id,  costPrice:  1.20, salePrice:  2.49, minStock: 50 },
    { name: 'Aceite Vegetal 1L',      sku: 'ALIM-003', categoryId: catMap['Alimentos y Bebidas'],unitId: unitLT!.id,  costPrice:  2.00, salePrice:  3.99, minStock: 30 },
    { name: 'Arroz 5lb',              sku: 'ALIM-004', categoryId: catMap['Alimentos y Bebidas'],unitId: unitLB!.id,  costPrice:  2.50, salePrice:  4.99, minStock: 40 },
    { name: 'Galletas Surtidas',      sku: 'ALIM-005', categoryId: catMap['Alimentos y Bebidas'],unitId: unitCJ!.id,  costPrice:  1.80, salePrice:  3.49, minStock: 20 },
    { name: 'Agua Purificada Pack 24',sku: 'ALIM-006', categoryId: catMap['Alimentos y Bebidas'],unitId: unitCJ!.id,  costPrice:  4.50, salePrice:  7.99, minStock: 15 },
    { name: 'Jugo de Naranja 1L',     sku: 'ALIM-007', categoryId: catMap['Alimentos y Bebidas'],unitId: unitLT!.id,  costPrice:  1.50, salePrice:  2.99, minStock: 25 },
    { name: 'Detergente Líquido 1L',  sku: 'LIMP-001', categoryId: catMap['Limpieza'],           unitId: unitLT!.id,  costPrice:  2.80, salePrice:  5.49, minStock: 20 },
    { name: 'Cloro 1gal',             sku: 'LIMP-002', categoryId: catMap['Limpieza'],           unitId: unitGAL!.id, costPrice:  2.00, salePrice:  3.99, minStock: 15 },
    { name: 'Desinfectante Multiusos',sku: 'LIMP-003', categoryId: catMap['Limpieza'],           unitId: unitUND!.id, costPrice:  3.00, salePrice:  5.99, minStock: 15 },
    { name: 'Jabón Líquido 500ml',    sku: 'LIMP-004', categoryId: catMap['Limpieza'],           unitId: unitUND!.id, costPrice:  1.80, salePrice:  3.49, minStock: 20 },
    { name: 'Papel Toalla 6 Rollos',  sku: 'LIMP-005', categoryId: catMap['Limpieza'],           unitId: unitCJ!.id,  costPrice:  3.50, salePrice:  6.99, minStock: 10 },
    { name: 'Bolsas de Basura x25',   sku: 'LIMP-006', categoryId: catMap['Limpieza'],           unitId: unitCJ!.id,  costPrice:  2.20, salePrice:  4.49, minStock: 15 },
    { name: 'Resma Papel Bond',       sku: 'OFIC-001', categoryId: catMap['Papelería y Oficina'],unitId: unitUND!.id, costPrice:  3.50, salePrice:  5.99, minStock: 15 },
    { name: 'Lapiceros Caja x12',     sku: 'OFIC-002', categoryId: catMap['Papelería y Oficina'],unitId: unitCJ!.id,  costPrice:  1.50, salePrice:  3.49, minStock: 20 },
    { name: 'Folder Manila x25',      sku: 'OFIC-003', categoryId: catMap['Papelería y Oficina'],unitId: unitCJ!.id,  costPrice:  2.00, salePrice:  4.49, minStock: 10 },
    { name: 'Engrapadora',            sku: 'OFIC-004', categoryId: catMap['Papelería y Oficina'],unitId: unitUND!.id, costPrice:  3.00, salePrice:  6.99, minStock:  5 },
    { name: 'Cinta Adhesiva',         sku: 'OFIC-005', categoryId: catMap['Papelería y Oficina'],unitId: unitUND!.id, costPrice:  0.80, salePrice:  1.99, minStock: 30 },
    { name: 'Martillo',               sku: 'FERR-001', categoryId: catMap['Ferretería'],         unitId: unitUND!.id, costPrice:  5.00, salePrice: 11.99, minStock:  5 },
    { name: 'Destornillador Phillips', sku: 'FERR-002',categoryId: catMap['Ferretería'],         unitId: unitUND!.id, costPrice:  2.50, salePrice:  5.99, minStock:  8 },
    { name: 'Cinta Métrica 5m',       sku: 'FERR-003', categoryId: catMap['Ferretería'],         unitId: unitUND!.id, costPrice:  2.00, salePrice:  4.99, minStock: 10 },
    { name: 'Pintura Látex 1gal',     sku: 'FERR-004', categoryId: catMap['Ferretería'],         unitId: unitGAL!.id, costPrice: 12.00, salePrice: 24.99, minStock:  5 },
    { name: 'Brochas 3 pulgadas',     sku: 'FERR-005', categoryId: catMap['Ferretería'],         unitId: unitUND!.id, costPrice:  1.50, salePrice:  3.99, minStock: 10 },
    { name: 'Bombillo LED 9W',        sku: 'HOG-001',  categoryId: catMap['Hogar'],              unitId: unitUND!.id, costPrice:  1.20, salePrice:  2.99, minStock: 30 },
    { name: 'Extensión Eléctrica 3m', sku: 'HOG-002',  categoryId: catMap['Hogar'],              unitId: unitUND!.id, costPrice:  3.50, salePrice:  7.99, minStock: 10 },
    { name: 'Pilas AA Pack 4',        sku: 'HOG-003',  categoryId: catMap['Hogar'],              unitId: unitCJ!.id,  costPrice:  1.80, salePrice:  3.49, minStock: 25 },
  ]

  const insertedProducts: any[] = []
  for (const pd of productDefs) {
    const row = await tryInsertOne(() =>
      db.insert(product).values({ ...pd, businessId: BIZ_ID } as any).returning()
    )
    if (row) insertedProducts.push(row)
  }
  console.log(`  + ${insertedProducts.length} products`)

  for (const p of insertedProducts) {
    await tryInsertOne(() =>
      db.insert(productStock).values({
        productId: p.id,
        warehouseId: wh1.id,
        quantity: money(randomBetween(20, 150)),
      } as any).returning()
    )
  }

  if (wh2) {
    for (const p of insertedProducts.slice(0, 15)) {
      await tryInsertOne(() =>
        db.insert(productStock).values({
          productId: p.id,
          warehouseId: (wh2 as any).id,
          quantity: money(randomBetween(5, 40)),
        } as any).returning()
      )
    }
  }
  console.log('  + Product stock assigned')

  const customerDefs = [
    { businessId: BIZ_ID, customerType: 'company', companyName: 'Comercial El Buen Precio',   taxId: '0614-050390-104-2', email: 'ventas@buenprecio.sv',        phone: '2234-5678', creditLimit: 5000,  creditDays: 30 },
    { businessId: BIZ_ID, customerType: 'company', companyName: 'Distribuidora ABC',           taxId: '0614-120485-102-5', email: 'compras@abc.sv',              phone: '2245-6789', creditLimit: 10000, creditDays: 15 },
    { businessId: BIZ_ID, customerType: 'person',  firstName: 'María',   lastName: 'García',   email: 'maria.garcia@email.com',   phone: '7890-1234', creditLimit: 0,     creditDays: 0 },
    { businessId: BIZ_ID, customerType: 'person',  firstName: 'Juan',    lastName: 'Pérez',    email: 'juan.perez@email.com',     phone: '7891-2345', creditLimit: 500,   creditDays: 15 },
    { businessId: BIZ_ID, customerType: 'company', companyName: 'TechStore SA de CV',          taxId: '0614-080295-103-8', email: 'pedidos@techstore.sv',        phone: '2256-7890', creditLimit: 8000,  creditDays: 45 },
    { businessId: BIZ_ID, customerType: 'person',  firstName: 'Ana',     lastName: 'López',    email: 'ana.lopez@email.com',      phone: '7892-3456', creditLimit: 0,     creditDays: 0 },
    { businessId: BIZ_ID, customerType: 'company', companyName: 'Supermercado La Familia',     taxId: '0614-150190-105-1', email: 'admin@lafamilia.sv',          phone: '2267-8901', creditLimit: 15000, creditDays: 30 },
    { businessId: BIZ_ID, customerType: 'person',  firstName: 'Carlos',  lastName: 'Ramírez',  email: 'carlos.ramirez@email.com', phone: '7893-4567', creditLimit: 1000,  creditDays: 15 },
    { businessId: BIZ_ID, customerType: 'company', companyName: 'Oficinas Modernas',           taxId: '0614-200398-106-3', email: 'compras@oficinasmodernas.sv', phone: '2278-9012', creditLimit: 3000,  creditDays: 30 },
    { businessId: BIZ_ID, customerType: 'person',  firstName: 'Roberto', lastName: 'Hernández',                                   phone: '7894-5678', creditLimit: 0,     creditDays: 0 },
  ]

  const insertedCustomers: any[] = []
  for (const cd of customerDefs) {
    const row = await tryInsertOne(() => db.insert(customer).values(cd as any).returning())
    if (row) insertedCustomers.push(row)
  }
  console.log(`  + ${insertedCustomers.length} customers`)

  const supplierDefs = [
    { businessId: BIZ_ID, companyName: 'Distribuidora TechMax',    contactName: 'Roberto Flores',   email: 'ventas@techmax.sv',          phone: '2201-1234', paymentTerms: 30 },
    { businessId: BIZ_ID, companyName: 'Alimentos del Valle',      contactName: 'Patricia Morales', email: 'ventas@alimentosvalle.sv',   phone: '2202-2345', paymentTerms: 15 },
    { businessId: BIZ_ID, companyName: 'Productos de Limpieza SA', contactName: 'Fernando Rivas',   email: 'pedidos@limpieza-sa.sv',     phone: '2203-3456', paymentTerms: 30 },
    { businessId: BIZ_ID, companyName: 'Papelera Nacional',        contactName: 'Claudia Mejía',    email: 'ventas@papeleranacional.sv', phone: '2204-4567', paymentTerms: 45 },
    { businessId: BIZ_ID, companyName: 'Ferretería Industrial',    contactName: 'Miguel Castillo',  email: 'compras@ferrindustrial.sv',  phone: '2205-5678', paymentTerms: 30 },
  ]

  const insertedSuppliers: any[] = []
  for (const sd of supplierDefs) {
    const row = await tryInsertOne(() => db.insert(supplier).values(sd as any).returning())
    if (row) insertedSuppliers.push(row)
  }
  console.log(`  + ${insertedSuppliers.length} suppliers`)

  const today = new Date()
  const taxRate = 0.13
  let saleSeq = 0

  const creditCustomers = insertedCustomers.filter(c => c.creditDays > 0)
  const allCustomers = insertedCustomers

  for (let dayOffset = 30; dayOffset >= 0; dayOffset--) {
    const saleDate = format(subDays(today, dayOffset), 'yyyy-MM-dd')
    const salesThisDay = dayOffset === 0 ? 2 : randomBetween(0, 3)

    for (let s = 0; s < salesThisDay; s++) {
      saleSeq++
      const saleNumber = `FAC-2026-${String(saleSeq).padStart(6, '0')}`

      const isCredit = Math.random() < 0.4 && creditCustomers.length > 0
      const selectedCustomer = isCredit ? pick(creditCustomers) : pick(allCustomers)

      const numLines = randomBetween(1, 5)
      const selectedProducts: any[] = []
      const usedIndices = new Set<number>()
      for (let i = 0; i < numLines; i++) {
        let idx: number
        do { idx = randomBetween(0, insertedProducts.length - 1) } while (usedIndices.has(idx))
        usedIndices.add(idx)
        selectedProducts.push(insertedProducts[idx]!)
      }

      let subtotal = 0
      let totalTax = 0
      let totalDiscount = 0

      const lines = selectedProducts.map(prod => {
        const qty = randomBetween(1, 8)
        const unitPrice = prod.salePrice as number
        const discountPct = Math.random() < 0.2 ? randomBetween(5, 15) : 0
        const lineSubtotal = qty * unitPrice
        const discountAmt = lineSubtotal * (discountPct / 100)
        const taxableAmount = lineSubtotal - discountAmt
        const lineTax = taxableAmount * taxRate
        const lineTotal = taxableAmount + lineTax

        subtotal += taxableAmount
        totalTax += lineTax
        totalDiscount += discountAmt

        return {
          productId: prod.id,
          quantity: money(qty),
          unitPrice: money(unitPrice),
          discountPct: money(discountPct),
          discountAmount: money(discountAmt),
          taxId: ivaTax!.id,
          taxAmount: money(lineTax),
          lineTotal: money(lineTotal),
        }
      })

      const grandTotal = subtotal + totalTax
      const paymentStatus = isCredit ? 'credit' : 'paid'
      const dueDate = isCredit
        ? format(subDays(today, dayOffset - selectedCustomer.creditDays), 'yyyy-MM-dd')
        : undefined

      const insertedSale = await tryInsertOne(() =>
        db.insert(sale).values({
          businessId: BIZ_ID,
          customerId: selectedCustomer.id,
          documentTypeId: docFAC!.id,
          warehouseId: wh1.id,
          saleNumber,
          saleDate,
          dueDate,
          status: 'completed',
          paymentStatus,
          subtotal: money(subtotal),
          taxAmount: money(totalTax),
          discountAmount: money(totalDiscount),
          total: money(grandTotal),
          createdBy: adminUserId!,
        } as any).returning()
      )
      if (!insertedSale) continue

      const insertedLines: any[] = []
      for (const l of lines) {
        const sl = await tryInsertOne(() =>
          db.insert(saleLine).values({ ...l, saleId: (insertedSale as any).id } as any).returning()
        )
        if (sl) insertedLines.push(sl)
      }

      for (let i = 0; i < insertedLines.length; i++) {
        await tryInsertOne(() =>
          db.insert(saleLineTax).values({
            saleLineId: insertedLines[i].id,
            taxId: ivaTax!.id,
            taxBase: money(lines[i]!.lineTotal - lines[i]!.taxAmount),
            taxAmount: money(lines[i]!.taxAmount),
          } as any).returning()
        )
      }

      if (paymentStatus === 'paid') {
        const pm = pick([pmCash!, pmCard!, pmTransfer!])
        await tryInsertOne(() =>
          db.insert(salePayment).values({
            saleId: (insertedSale as any).id,
            paymentMethodId: pm.id,
            amount: money(grandTotal),
            paymentDate: saleDate,
          } as any).returning()
        )
      }

      if (paymentStatus === 'credit') {
        const isPastDue = dayOffset > selectedCustomer.creditDays
        const arStatus = isPastDue && Math.random() < 0.3 ? 'paid' : 'pending'
        const balance = arStatus === 'paid' ? 0 : money(grandTotal)

        const ar = await tryInsertOne(() =>
          db.insert(accountReceivable).values({
            businessId: BIZ_ID,
            customerId: selectedCustomer.id,
            saleId: (insertedSale as any).id,
            originalAmount: money(grandTotal),
            balance,
            dueDate: dueDate!,
            status: arStatus,
          } as any).returning()
        )

        if (ar && arStatus === 'paid') {
          await tryInsertOne(() =>
            db.insert(collectionPayment).values({
              businessId: BIZ_ID,
              accountReceivableId: (ar as any).id,
              paymentMethodId: pmTransfer!.id,
              receiptNumber: `REC-2026-${String(saleSeq).padStart(6, '0')}`,
              amount: money(grandTotal),
              paymentDate: format(subDays(today, Math.max(0, dayOffset - selectedCustomer.creditDays)), 'yyyy-MM-dd'),
              collectedBy: adminUserId!,
            } as any).returning()
          )
        }
      }
    }
  }

  console.log(`  + ${saleSeq} sales with line items, taxes, and payments`)

  const supplierProducts: Record<number, any[]> = {
    0: insertedProducts.filter((p: any) => p.sku?.startsWith('ELEC')),
    1: insertedProducts.filter((p: any) => p.sku?.startsWith('ALIM')),
    2: insertedProducts.filter((p: any) => p.sku?.startsWith('LIMP')),
    3: insertedProducts.filter((p: any) => p.sku?.startsWith('OFIC')),
    4: insertedProducts.filter((p: any) => p.sku?.startsWith('FERR')),
  }

  for (let i = 0; i < insertedSuppliers.length; i++) {
    const sup = insertedSuppliers[i]!
    const prods = supplierProducts[i] ?? insertedProducts.slice(0, 3)
    const orderDate = format(subDays(today, randomBetween(5, 20)), 'yyyy-MM-dd')
    const orderNumber = `OC-2026-${String(i + 1).padStart(6, '0')}`

    let poSubtotal = 0
    let poTax = 0

    const poLines = prods.slice(0, Math.min(prods.length, 4)).map((p: any) => {
      const qty = randomBetween(20, 100)
      const unitCost = p.costPrice as number
      const lineBase = qty * unitCost
      const lineTax = lineBase * taxRate
      poSubtotal += lineBase
      poTax += lineTax

      return {
        productId: p.id,
        quantityOrdered: money(qty),
        quantityReceived: money(qty),
        unitCost: money(unitCost),
        taxId: ivaTax!.id,
        taxAmount: money(lineTax),
        lineTotal: money(lineBase + lineTax),
      }
    })

    const poTotal = poSubtotal + poTax

    const po = await tryInsertOne(() =>
      db.insert(purchaseOrder).values({
        businessId: BIZ_ID,
        supplierId: sup.id,
        warehouseId: wh1.id,
        orderNumber,
        orderDate,
        status: 'received',
        subtotal: money(poSubtotal),
        taxAmount: money(poTax),
        total: money(poTotal),
        createdBy: adminUserId!,
      } as any).returning()
    )
    if (!po) continue

    for (const l of poLines) {
      await tryInsertOne(() =>
        db.insert(purchaseOrderLine).values({ ...l, purchaseOrderId: (po as any).id } as any).returning()
      )
    }

    const receiptNumber = `REC-C-2026-${String(i + 1).padStart(6, '0')}`
    await tryInsertOne(() =>
      db.insert(goodsReceipt).values({
        purchaseOrderId: (po as any).id,
        receiptNumber,
        receiptDate: orderDate,
        receivedBy: adminUserId!,
      } as any).returning()
    )

    const apDueDate = format(subDays(today, randomBetween(-10, 5)), 'yyyy-MM-dd')
    const apStatus = Math.random() < 0.4 ? 'paid' : 'pending'

    await tryInsertOne(() =>
      db.insert(accountPayable).values({
        businessId: BIZ_ID,
        supplierId: sup.id,
        purchaseOrderId: (po as any).id,
        originalAmount: money(poTotal),
        balance: apStatus === 'paid' ? 0 : money(poTotal),
        dueDate: apDueDate,
        status: apStatus,
      } as any).returning()
    )
  }

  console.log(`  + ${insertedSuppliers.length} purchase orders with goods receipts`)
  console.log('\nSeed completed!')
}

main()
  .catch((e) => {
    console.error('Seed error:', e)
    process.exit(1)
  })
  .finally(async () => {
    await client.end()
  })

/**
 * setup.ts — Crea todas las tablas en SQL Server si no existen.
 * Ejecutar: bun run src/db/setup.ts
 */
import { db } from '../config/database'
import { sql } from 'drizzle-orm'

const tables = [
  sql`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='business' AND xtype='U')
  CREATE TABLE business (
    id           VARCHAR(36)     NOT NULL PRIMARY KEY,
    name         NVARCHAR(150)   NOT NULL,
    trade_name   NVARCHAR(150),
    tax_id       NVARCHAR(20),
    phone        NVARCHAR(20),
    email        NVARCHAR(100),
    address      NVARCHAR(MAX),
    logo_url     NVARCHAR(MAX),
    currency_code NCHAR(3)       NOT NULL DEFAULT 'USD',
    created_at   DATETIMEOFFSET  NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    updated_at   DATETIMEOFFSET  NOT NULL DEFAULT SYSDATETIMEOFFSET()
  )`,

  sql`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='app_user' AND xtype='U')
  CREATE TABLE app_user (
    id            VARCHAR(36)    NOT NULL PRIMARY KEY,
    business_id   VARCHAR(36)    NOT NULL REFERENCES business(id),
    email         NVARCHAR(150)  NOT NULL UNIQUE,
    password_hash NVARCHAR(255)  NOT NULL,
    first_name    NVARCHAR(80)   NOT NULL,
    last_name     NVARCHAR(80)   NOT NULL,
    phone         NVARCHAR(20),
    is_active     BIT            NOT NULL DEFAULT 1,
    created_at    DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    updated_at    DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET()
  )`,

  sql`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='role' AND xtype='U')
  CREATE TABLE role (
    id          VARCHAR(36)    NOT NULL PRIMARY KEY,
    business_id VARCHAR(36)    NOT NULL REFERENCES business(id),
    name        NVARCHAR(50)   NOT NULL,
    description NVARCHAR(200)
  )`,

  sql`IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='role_business_name_idx')
  CREATE UNIQUE INDEX role_business_name_idx ON role(business_id, name)`,

  sql`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='permission' AND xtype='U')
  CREATE TABLE permission (
    id          VARCHAR(36)   NOT NULL PRIMARY KEY,
    code        NVARCHAR(80)  NOT NULL UNIQUE,
    description NVARCHAR(200)
  )`,

  sql`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='role_permission' AND xtype='U')
  CREATE TABLE role_permission (
    id            VARCHAR(36) NOT NULL PRIMARY KEY,
    role_id       VARCHAR(36) NOT NULL REFERENCES role(id) ON DELETE CASCADE,
    permission_id VARCHAR(36) NOT NULL REFERENCES permission(id) ON DELETE CASCADE
  )`,

  sql`IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='role_permission_pk')
  CREATE UNIQUE INDEX role_permission_pk ON role_permission(role_id, permission_id)`,

  sql`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='user_role' AND xtype='U')
  CREATE TABLE user_role (
    id          VARCHAR(36)    NOT NULL PRIMARY KEY,
    user_id     VARCHAR(36)    NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    role_id     VARCHAR(36)    NOT NULL REFERENCES role(id),
    assigned_at DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET()
  )`,

  sql`IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='user_role_pk')
  CREATE UNIQUE INDEX user_role_pk ON user_role(user_id, role_id)`,

  sql`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='refresh_token' AND xtype='U')
  CREATE TABLE refresh_token (
    id         VARCHAR(36)    NOT NULL PRIMARY KEY,
    user_id    VARCHAR(36)    NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    token_hash NVARCHAR(255)  NOT NULL UNIQUE,
    expires_at DATETIMEOFFSET NOT NULL,
    revoked_at DATETIMEOFFSET,
    created_at DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET()
  )`,

  sql`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='document_type' AND xtype='U')
  CREATE TABLE document_type (
    id          VARCHAR(36)    NOT NULL PRIMARY KEY,
    business_id VARCHAR(36)    NOT NULL REFERENCES business(id),
    name        NVARCHAR(50)   NOT NULL,
    code        NVARCHAR(20)   NOT NULL,
    is_active   BIT            NOT NULL DEFAULT 1,
    created_at  DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET()
  )`,

  sql`IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='doc_type_business_code_idx')
  CREATE UNIQUE INDEX doc_type_business_code_idx ON document_type(business_id, code)`,

  sql`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='payment_method' AND xtype='U')
  CREATE TABLE payment_method (
    id          VARCHAR(36)    NOT NULL PRIMARY KEY,
    business_id VARCHAR(36)    NOT NULL REFERENCES business(id),
    name        NVARCHAR(50)   NOT NULL,
    is_active   BIT            NOT NULL DEFAULT 1,
    created_at  DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET()
  )`,

  sql`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='tax' AND xtype='U')
  CREATE TABLE tax (
    id          VARCHAR(36)    NOT NULL PRIMARY KEY,
    business_id VARCHAR(36)    NOT NULL REFERENCES business(id),
    name        NVARCHAR(50)   NOT NULL,
    rate        DECIMAL(5,2)   NOT NULL,
    is_active   BIT            NOT NULL DEFAULT 1,
    created_at  DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET()
  )`,

  sql`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='product_category' AND xtype='U')
  CREATE TABLE product_category (
    id          VARCHAR(36)    NOT NULL PRIMARY KEY,
    business_id VARCHAR(36)    NOT NULL REFERENCES business(id),
    parent_id   VARCHAR(36),
    name        NVARCHAR(100)  NOT NULL,
    description NVARCHAR(MAX),
    is_active   BIT            NOT NULL DEFAULT 1
  )`,

  sql`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='unit_of_measure' AND xtype='U')
  CREATE TABLE unit_of_measure (
    id   VARCHAR(36)   NOT NULL PRIMARY KEY,
    code NVARCHAR(10)  NOT NULL UNIQUE,
    name NVARCHAR(50)  NOT NULL
  )`,

  sql`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='warehouse' AND xtype='U')
  CREATE TABLE warehouse (
    id          VARCHAR(36)    NOT NULL PRIMARY KEY,
    business_id VARCHAR(36)    NOT NULL REFERENCES business(id),
    name        NVARCHAR(100)  NOT NULL,
    address     NVARCHAR(MAX),
    is_active   BIT            NOT NULL DEFAULT 1
  )`,

  sql`IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='warehouse_business_name_idx')
  CREATE UNIQUE INDEX warehouse_business_name_idx ON warehouse(business_id, name)`,

  sql`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='product' AND xtype='U')
  CREATE TABLE product (
    id          VARCHAR(36)    NOT NULL PRIMARY KEY,
    business_id VARCHAR(36)    NOT NULL REFERENCES business(id),
    category_id VARCHAR(36)    REFERENCES product_category(id),
    unit_id     VARCHAR(36)    NOT NULL REFERENCES unit_of_measure(id),
    sku         NVARCHAR(50),
    barcode     NVARCHAR(50),
    name        NVARCHAR(200)  NOT NULL,
    description NVARCHAR(MAX),
    cost_price  DECIMAL(15,2)  NOT NULL DEFAULT 0,
    sale_price  DECIMAL(15,2)  NOT NULL,
    min_stock   DECIMAL(15,2)  NOT NULL DEFAULT 0,
    max_stock   DECIMAL(15,2),
    is_service  BIT            NOT NULL DEFAULT 0,
    is_taxable  BIT            NOT NULL DEFAULT 1,
    is_active   BIT            NOT NULL DEFAULT 1,
    image_url   NVARCHAR(MAX),
    created_at  DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    updated_at  DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET()
  )`,

  sql`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='product_stock' AND xtype='U')
  CREATE TABLE product_stock (
    id           VARCHAR(36)    NOT NULL PRIMARY KEY,
    product_id   VARCHAR(36)    NOT NULL REFERENCES product(id),
    warehouse_id VARCHAR(36)    NOT NULL REFERENCES warehouse(id),
    quantity     DECIMAL(15,2)  NOT NULL DEFAULT 0,
    updated_at   DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET()
  )`,

  sql`IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='product_stock_unique')
  CREATE UNIQUE INDEX product_stock_unique ON product_stock(product_id, warehouse_id)`,

  sql`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='inventory_movement' AND xtype='U')
  CREATE TABLE inventory_movement (
    id             VARCHAR(36)    NOT NULL PRIMARY KEY,
    product_id     VARCHAR(36)    NOT NULL REFERENCES product(id),
    warehouse_id   VARCHAR(36)    NOT NULL REFERENCES warehouse(id),
    movement_type  NVARCHAR(30)   NOT NULL,
    quantity       DECIMAL(15,2)  NOT NULL,
    unit_cost      DECIMAL(15,2),
    reference_type NVARCHAR(30),
    reference_id   VARCHAR(36),
    notes          NVARCHAR(MAX),
    created_by     VARCHAR(36)    REFERENCES app_user(id),
    created_at     DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET()
  )`,

  sql`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='inventory_transfer' AND xtype='U')
  CREATE TABLE inventory_transfer (
    id                 VARCHAR(36)    NOT NULL PRIMARY KEY,
    business_id        VARCHAR(36)    NOT NULL REFERENCES business(id),
    from_warehouse_id  VARCHAR(36)    NOT NULL REFERENCES warehouse(id),
    to_warehouse_id    VARCHAR(36)    NOT NULL REFERENCES warehouse(id),
    status             NVARCHAR(20)   NOT NULL DEFAULT 'pending',
    notes              NVARCHAR(MAX),
    created_by         VARCHAR(36)    REFERENCES app_user(id),
    created_at         DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    completed_at       DATETIMEOFFSET
  )`,

  sql`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='inventory_transfer_line' AND xtype='U')
  CREATE TABLE inventory_transfer_line (
    id          VARCHAR(36)   NOT NULL PRIMARY KEY,
    transfer_id VARCHAR(36)   NOT NULL REFERENCES inventory_transfer(id) ON DELETE CASCADE,
    product_id  VARCHAR(36)   NOT NULL REFERENCES product(id),
    quantity    DECIMAL(12,2) NOT NULL
  )`,

  sql`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='customer' AND xtype='U')
  CREATE TABLE customer (
    id            VARCHAR(36)    NOT NULL PRIMARY KEY,
    business_id   VARCHAR(36)    NOT NULL REFERENCES business(id),
    customer_type NVARCHAR(10)   NOT NULL DEFAULT 'person',
    first_name    NVARCHAR(80),
    last_name     NVARCHAR(80),
    company_name  NVARCHAR(150),
    tax_id        NVARCHAR(20),
    tax_reg       NVARCHAR(20),
    email         NVARCHAR(150),
    phone         NVARCHAR(20),
    address       NVARCHAR(MAX),
    credit_limit  DECIMAL(12,2)  NOT NULL DEFAULT 0,
    credit_days   INT            NOT NULL DEFAULT 0,
    is_active     BIT            NOT NULL DEFAULT 1,
    created_at    DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    updated_at    DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET()
  )`,

  sql`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='sale' AND xtype='U')
  CREATE TABLE sale (
    id               VARCHAR(36)    NOT NULL PRIMARY KEY,
    business_id      VARCHAR(36)    NOT NULL REFERENCES business(id),
    customer_id      VARCHAR(36)    REFERENCES customer(id),
    document_type_id VARCHAR(36)    NOT NULL REFERENCES document_type(id),
    warehouse_id     VARCHAR(36)    NOT NULL REFERENCES warehouse(id),
    sale_number      NVARCHAR(30)   NOT NULL,
    sale_date        DATE           NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    due_date         DATE,
    status           NVARCHAR(20)   NOT NULL DEFAULT 'completed',
    payment_status   NVARCHAR(20)   NOT NULL DEFAULT 'paid',
    subtotal         DECIMAL(12,2)  NOT NULL DEFAULT 0,
    tax_amount       DECIMAL(12,2)  NOT NULL DEFAULT 0,
    discount_amount  DECIMAL(12,2)  NOT NULL DEFAULT 0,
    total            DECIMAL(12,2)  NOT NULL DEFAULT 0,
    notes            NVARCHAR(MAX),
    created_by       VARCHAR(36)    REFERENCES app_user(id),
    created_at       DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    cancelled_at     DATETIMEOFFSET,
    cancelled_by     VARCHAR(36)    REFERENCES app_user(id)
  )`,

  sql`IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='sale_business_number_idx')
  CREATE UNIQUE INDEX sale_business_number_idx ON sale(business_id, sale_number)`,

  sql`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='sale_line' AND xtype='U')
  CREATE TABLE sale_line (
    id              VARCHAR(36)   NOT NULL PRIMARY KEY,
    sale_id         VARCHAR(36)   NOT NULL REFERENCES sale(id) ON DELETE CASCADE,
    product_id      VARCHAR(36)   NOT NULL REFERENCES product(id),
    quantity        DECIMAL(12,2) NOT NULL,
    unit_price      DECIMAL(12,2) NOT NULL,
    discount_pct    DECIMAL(5,2)  NOT NULL DEFAULT 0,
    discount_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    tax_id          VARCHAR(36)   REFERENCES tax(id),
    tax_amount      DECIMAL(12,2) NOT NULL DEFAULT 0,
    line_total      DECIMAL(12,2) NOT NULL
  )`,

  sql`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='sale_line_tax' AND xtype='U')
  CREATE TABLE sale_line_tax (
    id           VARCHAR(36)   NOT NULL PRIMARY KEY,
    sale_line_id VARCHAR(36)   NOT NULL REFERENCES sale_line(id) ON DELETE CASCADE,
    tax_id       VARCHAR(36)   NOT NULL REFERENCES tax(id),
    tax_base     DECIMAL(12,2) NOT NULL,
    tax_amount   DECIMAL(12,2) NOT NULL
  )`,

  sql`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='sale_payment' AND xtype='U')
  CREATE TABLE sale_payment (
    id                VARCHAR(36)   NOT NULL PRIMARY KEY,
    sale_id           VARCHAR(36)   NOT NULL REFERENCES sale(id) ON DELETE CASCADE,
    payment_method_id VARCHAR(36)   NOT NULL REFERENCES payment_method(id),
    amount            DECIMAL(12,2) NOT NULL,
    reference         NVARCHAR(100),
    payment_date      DATE          NOT NULL DEFAULT CAST(GETDATE() AS DATE)
  )`,

  sql`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='credit_note' AND xtype='U')
  CREATE TABLE credit_note (
    id          VARCHAR(36)    NOT NULL PRIMARY KEY,
    business_id VARCHAR(36)    NOT NULL REFERENCES business(id),
    sale_id     VARCHAR(36)    NOT NULL REFERENCES sale(id),
    customer_id VARCHAR(36)    NOT NULL REFERENCES customer(id),
    note_number NVARCHAR(30)   NOT NULL,
    reason      NVARCHAR(MAX)  NOT NULL,
    total       DECIMAL(12,2)  NOT NULL,
    status      NVARCHAR(20)   NOT NULL DEFAULT 'active',
    created_by  VARCHAR(36)    REFERENCES app_user(id),
    created_at  DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET()
  )`,

  sql`IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='credit_note_business_number_idx')
  CREATE UNIQUE INDEX credit_note_business_number_idx ON credit_note(business_id, note_number)`,

  sql`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='credit_note_line' AND xtype='U')
  CREATE TABLE credit_note_line (
    id             VARCHAR(36)   NOT NULL PRIMARY KEY,
    credit_note_id VARCHAR(36)   NOT NULL REFERENCES credit_note(id) ON DELETE CASCADE,
    product_id     VARCHAR(36)   NOT NULL REFERENCES product(id),
    quantity       DECIMAL(12,2) NOT NULL,
    unit_price     DECIMAL(12,2) NOT NULL,
    line_total     DECIMAL(12,2) NOT NULL
  )`,

  sql`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='supplier' AND xtype='U')
  CREATE TABLE supplier (
    id            VARCHAR(36)    NOT NULL PRIMARY KEY,
    business_id   VARCHAR(36)    NOT NULL REFERENCES business(id),
    company_name  NVARCHAR(150)  NOT NULL,
    contact_name  NVARCHAR(100),
    tax_id        NVARCHAR(20),
    phone         NVARCHAR(20),
    email         NVARCHAR(150),
    address       NVARCHAR(MAX),
    payment_terms INT            NOT NULL DEFAULT 30,
    is_active     BIT            NOT NULL DEFAULT 1,
    created_at    DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    updated_at    DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET()
  )`,

  sql`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='supplier_product' AND xtype='U')
  CREATE TABLE supplier_product (
    id             VARCHAR(36)   NOT NULL PRIMARY KEY,
    supplier_id    VARCHAR(36)   NOT NULL REFERENCES supplier(id),
    product_id     VARCHAR(36)   NOT NULL REFERENCES product(id),
    supplier_sku   NVARCHAR(50),
    supplier_price DECIMAL(12,2),
    lead_time_days INT
  )`,

  sql`IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='supplier_product_unique')
  CREATE UNIQUE INDEX supplier_product_unique ON supplier_product(supplier_id, product_id)`,

  sql`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='purchase_order' AND xtype='U')
  CREATE TABLE purchase_order (
    id           VARCHAR(36)    NOT NULL PRIMARY KEY,
    business_id  VARCHAR(36)    NOT NULL REFERENCES business(id),
    supplier_id  VARCHAR(36)    NOT NULL REFERENCES supplier(id),
    warehouse_id VARCHAR(36)    NOT NULL REFERENCES warehouse(id),
    order_number NVARCHAR(30)   NOT NULL,
    order_date   DATE           NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    expected_date DATE,
    status       NVARCHAR(20)   NOT NULL DEFAULT 'draft',
    subtotal     DECIMAL(12,2)  NOT NULL DEFAULT 0,
    tax_amount   DECIMAL(12,2)  NOT NULL DEFAULT 0,
    total        DECIMAL(12,2)  NOT NULL DEFAULT 0,
    notes        NVARCHAR(MAX),
    created_by   VARCHAR(36)    REFERENCES app_user(id),
    created_at   DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET()
  )`,

  sql`IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='po_business_number_idx')
  CREATE UNIQUE INDEX po_business_number_idx ON purchase_order(business_id, order_number)`,

  sql`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='purchase_order_line' AND xtype='U')
  CREATE TABLE purchase_order_line (
    id                VARCHAR(36)   NOT NULL PRIMARY KEY,
    purchase_order_id VARCHAR(36)   NOT NULL REFERENCES purchase_order(id) ON DELETE CASCADE,
    product_id        VARCHAR(36)   NOT NULL REFERENCES product(id),
    quantity_ordered  DECIMAL(12,2) NOT NULL,
    quantity_received DECIMAL(12,2) NOT NULL DEFAULT 0,
    unit_cost         DECIMAL(12,2) NOT NULL,
    tax_id            VARCHAR(36)   REFERENCES tax(id),
    tax_amount        DECIMAL(12,2) NOT NULL DEFAULT 0,
    line_total        DECIMAL(12,2) NOT NULL
  )`,

  sql`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='goods_receipt' AND xtype='U')
  CREATE TABLE goods_receipt (
    id                VARCHAR(36)    NOT NULL PRIMARY KEY,
    purchase_order_id VARCHAR(36)    NOT NULL REFERENCES purchase_order(id),
    receipt_number    NVARCHAR(30)   NOT NULL,
    receipt_date      DATE           NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    notes             NVARCHAR(MAX),
    received_by       VARCHAR(36)    REFERENCES app_user(id),
    created_at        DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET()
  )`,

  sql`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='goods_receipt_line' AND xtype='U')
  CREATE TABLE goods_receipt_line (
    id                    VARCHAR(36)   NOT NULL PRIMARY KEY,
    goods_receipt_id      VARCHAR(36)   NOT NULL REFERENCES goods_receipt(id) ON DELETE CASCADE,
    purchase_order_line_id VARCHAR(36)  NOT NULL REFERENCES purchase_order_line(id),
    product_id            VARCHAR(36)   NOT NULL REFERENCES product(id),
    quantity_received     DECIMAL(12,2) NOT NULL
  )`,

  sql`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='account_payable' AND xtype='U')
  CREATE TABLE account_payable (
    id                VARCHAR(36)    NOT NULL PRIMARY KEY,
    business_id       VARCHAR(36)    NOT NULL REFERENCES business(id),
    supplier_id       VARCHAR(36)    NOT NULL REFERENCES supplier(id),
    purchase_order_id VARCHAR(36)    NOT NULL REFERENCES purchase_order(id),
    original_amount   DECIMAL(12,2)  NOT NULL,
    balance           DECIMAL(12,2)  NOT NULL,
    due_date          DATE           NOT NULL,
    status            NVARCHAR(20)   NOT NULL DEFAULT 'pending',
    created_at        DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    updated_at        DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET()
  )`,

  sql`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='supplier_payment' AND xtype='U')
  CREATE TABLE supplier_payment (
    id                 VARCHAR(36)    NOT NULL PRIMARY KEY,
    business_id        VARCHAR(36)    NOT NULL REFERENCES business(id),
    account_payable_id VARCHAR(36)    NOT NULL REFERENCES account_payable(id),
    payment_method_id  VARCHAR(36)    NOT NULL REFERENCES payment_method(id),
    amount             DECIMAL(12,2)  NOT NULL,
    payment_date       DATE           NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    reference          NVARCHAR(100),
    notes              NVARCHAR(MAX),
    paid_by            VARCHAR(36)    REFERENCES app_user(id),
    created_at         DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET()
  )`,

  sql`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='account_receivable' AND xtype='U')
  CREATE TABLE account_receivable (
    id              VARCHAR(36)    NOT NULL PRIMARY KEY,
    business_id     VARCHAR(36)    NOT NULL REFERENCES business(id),
    customer_id     VARCHAR(36)    NOT NULL REFERENCES customer(id),
    sale_id         VARCHAR(36)    NOT NULL REFERENCES sale(id),
    original_amount DECIMAL(12,2)  NOT NULL,
    balance         DECIMAL(12,2)  NOT NULL,
    due_date        DATE           NOT NULL,
    status          NVARCHAR(20)   NOT NULL DEFAULT 'pending',
    created_at      DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    updated_at      DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET()
  )`,

  sql`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='collection_payment' AND xtype='U')
  CREATE TABLE collection_payment (
    id                     VARCHAR(36)    NOT NULL PRIMARY KEY,
    business_id            VARCHAR(36)    NOT NULL REFERENCES business(id),
    account_receivable_id  VARCHAR(36)    NOT NULL REFERENCES account_receivable(id),
    payment_method_id      VARCHAR(36)    NOT NULL REFERENCES payment_method(id),
    receipt_number         NVARCHAR(30),
    amount                 DECIMAL(12,2)  NOT NULL,
    payment_date           DATE           NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    reference              NVARCHAR(100),
    notes                  NVARCHAR(MAX),
    collected_by           VARCHAR(36)    REFERENCES app_user(id),
    created_at             DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET()
  )`,

  sql`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='statement_history' AND xtype='U')
  CREATE TABLE statement_history (
    id           VARCHAR(36)    NOT NULL PRIMARY KEY,
    customer_id  VARCHAR(36)    NOT NULL REFERENCES customer(id),
    sent_date    DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    sent_via     NVARCHAR(20),
    total_due    DECIMAL(12,2)  NOT NULL,
    generated_by VARCHAR(36)    REFERENCES app_user(id)
  )`,
]

console.log(`Creando ${tables.length} objetos en SQL Server...`)
let created = 0
for (const stmt of tables) {
  try {
    await db.execute(stmt)
    created++
  } catch (err: any) {
    console.error(`Error: ${err.message?.split('\n')[0]}`)
  }
}
console.log(`✓ ${created}/${tables.length} objetos procesados`)
process.exit(0)

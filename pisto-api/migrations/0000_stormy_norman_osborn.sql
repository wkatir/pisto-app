CREATE TABLE "account_receivable" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"business_id" varchar(36) NOT NULL,
	"customer_id" varchar(36) NOT NULL,
	"sale_id" varchar(36) NOT NULL,
	"original_amount" numeric(12, 2) NOT NULL,
	"balance" numeric(12, 2) NOT NULL,
	"due_date" date NOT NULL,
	"status" varchar(20) DEFAULT 'pending' NOT NULL,
	"created_at" timestamp NOT NULL,
	"updated_at" timestamp NOT NULL
);
--> statement-breakpoint
CREATE TABLE "collection_payment" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"business_id" varchar(36) NOT NULL,
	"account_receivable_id" varchar(36) NOT NULL,
	"payment_method_id" varchar(36) NOT NULL,
	"receipt_number" varchar(30),
	"amount" numeric(12, 2) NOT NULL,
	"payment_date" date NOT NULL,
	"reference" varchar(100),
	"notes" text,
	"collected_by" varchar(36),
	"created_at" timestamp NOT NULL
);
--> statement-breakpoint
CREATE TABLE "statement_history" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"customer_id" varchar(36) NOT NULL,
	"sent_date" timestamp NOT NULL,
	"sent_via" varchar(20),
	"total_due" numeric(12, 2) NOT NULL,
	"generated_by" varchar(36)
);
--> statement-breakpoint
CREATE TABLE "app_user" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"business_id" varchar(36) NOT NULL,
	"email" varchar(150) NOT NULL,
	"password_hash" varchar(255) NOT NULL,
	"first_name" varchar(80) NOT NULL,
	"last_name" varchar(80) NOT NULL,
	"phone" varchar(20),
	"avatar_url" text,
	"is_active" boolean DEFAULT true NOT NULL,
	"created_at" timestamp NOT NULL,
	"updated_at" timestamp NOT NULL,
	CONSTRAINT "app_user_email_unique" UNIQUE("email")
);
--> statement-breakpoint
CREATE TABLE "business" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"name" varchar(150) NOT NULL,
	"trade_name" varchar(150),
	"tax_id" varchar(20),
	"phone" varchar(20),
	"email" varchar(100),
	"address" text,
	"logo_url" text,
	"currency_code" varchar(3) DEFAULT 'USD' NOT NULL,
	"created_at" timestamp NOT NULL,
	"updated_at" timestamp NOT NULL
);
--> statement-breakpoint
CREATE TABLE "document_type" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"business_id" varchar(36) NOT NULL,
	"name" varchar(50) NOT NULL,
	"code" varchar(20) NOT NULL,
	"is_active" boolean DEFAULT true NOT NULL,
	"created_at" timestamp NOT NULL
);
--> statement-breakpoint
CREATE TABLE "payment_method" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"business_id" varchar(36) NOT NULL,
	"name" varchar(50) NOT NULL,
	"is_active" boolean DEFAULT true NOT NULL,
	"created_at" timestamp NOT NULL
);
--> statement-breakpoint
CREATE TABLE "permission" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"code" varchar(80) NOT NULL,
	"description" varchar(200),
	CONSTRAINT "permission_code_unique" UNIQUE("code")
);
--> statement-breakpoint
CREATE TABLE "refresh_token" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"user_id" varchar(36) NOT NULL,
	"token_hash" varchar(255) NOT NULL,
	"expires_at" timestamp NOT NULL,
	"revoked_at" timestamp,
	"created_at" timestamp NOT NULL
);
--> statement-breakpoint
CREATE TABLE "role" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"business_id" varchar(36) NOT NULL,
	"name" varchar(50) NOT NULL,
	"description" varchar(200)
);
--> statement-breakpoint
CREATE TABLE "role_permission" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"role_id" varchar(36) NOT NULL,
	"permission_id" varchar(36) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "tax" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"business_id" varchar(36) NOT NULL,
	"name" varchar(50) NOT NULL,
	"rate" numeric(5, 2) NOT NULL,
	"is_active" boolean DEFAULT true NOT NULL,
	"created_at" timestamp NOT NULL
);
--> statement-breakpoint
CREATE TABLE "user_role" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"user_id" varchar(36) NOT NULL,
	"role_id" varchar(36) NOT NULL,
	"assigned_at" timestamp NOT NULL
);
--> statement-breakpoint
CREATE TABLE "expense" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"business_id" varchar(36) NOT NULL,
	"category_id" varchar(36),
	"description" varchar(500) NOT NULL,
	"amount" numeric(12, 2) NOT NULL,
	"expense_date" date NOT NULL,
	"payment_method_id" varchar(36),
	"notes" varchar(500),
	"receipt_url" text,
	"created_by" varchar(36),
	"created_at" timestamp NOT NULL
);
--> statement-breakpoint
CREATE TABLE "expense_category" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"business_id" varchar(36) NOT NULL,
	"name" varchar(80) NOT NULL,
	"icon" varchar(40),
	"created_at" timestamp NOT NULL
);
--> statement-breakpoint
CREATE TABLE "inventory_movement" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"product_id" varchar(36) NOT NULL,
	"warehouse_id" varchar(36) NOT NULL,
	"movement_type" varchar(30) NOT NULL,
	"quantity" numeric(15, 2) NOT NULL,
	"unit_cost" numeric(15, 2),
	"reference_type" varchar(30),
	"reference_id" varchar(36),
	"notes" text,
	"created_by" varchar(36),
	"created_at" timestamp NOT NULL
);
--> statement-breakpoint
CREATE TABLE "inventory_transfer" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"business_id" varchar(36) NOT NULL,
	"from_warehouse_id" varchar(36) NOT NULL,
	"to_warehouse_id" varchar(36) NOT NULL,
	"status" varchar(20) DEFAULT 'pending' NOT NULL,
	"notes" text,
	"created_by" varchar(36),
	"created_at" timestamp NOT NULL,
	"completed_at" timestamp
);
--> statement-breakpoint
CREATE TABLE "inventory_transfer_line" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"transfer_id" varchar(36) NOT NULL,
	"product_id" varchar(36) NOT NULL,
	"quantity" numeric(12, 2) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "product" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"business_id" varchar(36) NOT NULL,
	"category_id" varchar(36),
	"unit_id" varchar(36) NOT NULL,
	"sku" varchar(50),
	"barcode" varchar(50),
	"name" varchar(200) NOT NULL,
	"description" text,
	"cost_price" numeric(15, 2) DEFAULT 0 NOT NULL,
	"sale_price" numeric(15, 2) NOT NULL,
	"min_stock" numeric(15, 2) DEFAULT 0 NOT NULL,
	"max_stock" numeric(15, 2),
	"is_service" boolean DEFAULT false NOT NULL,
	"is_taxable" boolean DEFAULT true NOT NULL,
	"is_active" boolean DEFAULT true NOT NULL,
	"image_url" text,
	"created_at" timestamp NOT NULL,
	"updated_at" timestamp NOT NULL
);
--> statement-breakpoint
CREATE TABLE "product_category" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"business_id" varchar(36) NOT NULL,
	"parent_id" varchar(36),
	"name" varchar(100) NOT NULL,
	"description" text,
	"is_active" boolean DEFAULT true NOT NULL
);
--> statement-breakpoint
CREATE TABLE "product_stock" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"product_id" varchar(36) NOT NULL,
	"warehouse_id" varchar(36) NOT NULL,
	"quantity" numeric(15, 2) DEFAULT 0 NOT NULL,
	"updated_at" timestamp NOT NULL
);
--> statement-breakpoint
CREATE TABLE "unit_of_measure" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"code" varchar(10) NOT NULL,
	"name" varchar(50) NOT NULL,
	CONSTRAINT "unit_of_measure_code_unique" UNIQUE("code")
);
--> statement-breakpoint
CREATE TABLE "warehouse" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"business_id" varchar(36) NOT NULL,
	"name" varchar(100) NOT NULL,
	"address" text,
	"is_active" boolean DEFAULT true NOT NULL
);
--> statement-breakpoint
CREATE TABLE "credit_note" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"business_id" varchar(36) NOT NULL,
	"sale_id" varchar(36) NOT NULL,
	"customer_id" varchar(36) NOT NULL,
	"note_number" varchar(30) NOT NULL,
	"reason" text NOT NULL,
	"total" numeric(12, 2) NOT NULL,
	"status" varchar(20) DEFAULT 'active' NOT NULL,
	"created_by" varchar(36),
	"created_at" timestamp NOT NULL
);
--> statement-breakpoint
CREATE TABLE "credit_note_line" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"credit_note_id" varchar(36) NOT NULL,
	"product_id" varchar(36) NOT NULL,
	"quantity" numeric(12, 2) NOT NULL,
	"unit_price" numeric(12, 2) NOT NULL,
	"line_total" numeric(12, 2) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "customer" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"business_id" varchar(36) NOT NULL,
	"customer_type" varchar(10) DEFAULT 'person' NOT NULL,
	"first_name" varchar(80),
	"last_name" varchar(80),
	"company_name" varchar(150),
	"tax_id" varchar(20),
	"tax_reg" varchar(20),
	"email" varchar(150),
	"phone" varchar(20),
	"address" text,
	"credit_limit" numeric(12, 2) DEFAULT 0 NOT NULL,
	"credit_days" integer DEFAULT 0 NOT NULL,
	"is_active" boolean DEFAULT true NOT NULL,
	"created_at" timestamp NOT NULL,
	"updated_at" timestamp NOT NULL
);
--> statement-breakpoint
CREATE TABLE "sale" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"business_id" varchar(36) NOT NULL,
	"customer_id" varchar(36),
	"document_type_id" varchar(36) NOT NULL,
	"warehouse_id" varchar(36) NOT NULL,
	"sale_number" varchar(30) NOT NULL,
	"sale_date" date NOT NULL,
	"due_date" date,
	"status" varchar(20) DEFAULT 'completed' NOT NULL,
	"payment_status" varchar(20) DEFAULT 'paid' NOT NULL,
	"subtotal" numeric(12, 2) DEFAULT 0 NOT NULL,
	"tax_amount" numeric(12, 2) DEFAULT 0 NOT NULL,
	"discount_amount" numeric(12, 2) DEFAULT 0 NOT NULL,
	"total" numeric(12, 2) DEFAULT 0 NOT NULL,
	"notes" text,
	"created_by" varchar(36),
	"created_at" timestamp NOT NULL,
	"cancelled_at" timestamp,
	"cancelled_by" varchar(36)
);
--> statement-breakpoint
CREATE TABLE "sale_line" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"sale_id" varchar(36) NOT NULL,
	"product_id" varchar(36) NOT NULL,
	"quantity" numeric(12, 2) NOT NULL,
	"unit_price" numeric(12, 2) NOT NULL,
	"discount_pct" numeric(5, 2) DEFAULT 0 NOT NULL,
	"discount_amount" numeric(12, 2) DEFAULT 0 NOT NULL,
	"tax_id" varchar(36),
	"tax_amount" numeric(12, 2) DEFAULT 0 NOT NULL,
	"line_total" numeric(12, 2) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "sale_line_tax" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"sale_line_id" varchar(36) NOT NULL,
	"tax_id" varchar(36) NOT NULL,
	"tax_base" numeric(12, 2) NOT NULL,
	"tax_amount" numeric(12, 2) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "sale_payment" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"sale_id" varchar(36) NOT NULL,
	"payment_method_id" varchar(36) NOT NULL,
	"amount" numeric(12, 2) NOT NULL,
	"reference" varchar(100),
	"payment_date" date NOT NULL
);
--> statement-breakpoint
CREATE TABLE "account_payable" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"business_id" varchar(36) NOT NULL,
	"supplier_id" varchar(36) NOT NULL,
	"purchase_order_id" varchar(36) NOT NULL,
	"original_amount" numeric(12, 2) NOT NULL,
	"balance" numeric(12, 2) NOT NULL,
	"due_date" date NOT NULL,
	"status" varchar(20) DEFAULT 'pending' NOT NULL,
	"created_at" timestamp NOT NULL,
	"updated_at" timestamp NOT NULL
);
--> statement-breakpoint
CREATE TABLE "goods_receipt" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"purchase_order_id" varchar(36) NOT NULL,
	"receipt_number" varchar(30) NOT NULL,
	"receipt_date" date NOT NULL,
	"notes" text,
	"received_by" varchar(36),
	"created_at" timestamp NOT NULL
);
--> statement-breakpoint
CREATE TABLE "goods_receipt_line" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"goods_receipt_id" varchar(36) NOT NULL,
	"purchase_order_line_id" varchar(36) NOT NULL,
	"product_id" varchar(36) NOT NULL,
	"quantity_received" numeric(12, 2) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "purchase_order" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"business_id" varchar(36) NOT NULL,
	"supplier_id" varchar(36) NOT NULL,
	"warehouse_id" varchar(36) NOT NULL,
	"order_number" varchar(30) NOT NULL,
	"order_date" date NOT NULL,
	"expected_date" date,
	"status" varchar(20) DEFAULT 'draft' NOT NULL,
	"subtotal" numeric(12, 2) DEFAULT 0 NOT NULL,
	"tax_amount" numeric(12, 2) DEFAULT 0 NOT NULL,
	"total" numeric(12, 2) DEFAULT 0 NOT NULL,
	"notes" text,
	"created_by" varchar(36),
	"created_at" timestamp NOT NULL
);
--> statement-breakpoint
CREATE TABLE "purchase_order_line" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"purchase_order_id" varchar(36) NOT NULL,
	"product_id" varchar(36) NOT NULL,
	"quantity_ordered" numeric(12, 2) NOT NULL,
	"quantity_received" numeric(12, 2) DEFAULT 0 NOT NULL,
	"unit_cost" numeric(12, 2) NOT NULL,
	"tax_id" varchar(36),
	"tax_amount" numeric(12, 2) DEFAULT 0 NOT NULL,
	"line_total" numeric(12, 2) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "supplier" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"business_id" varchar(36) NOT NULL,
	"company_name" varchar(150) NOT NULL,
	"contact_name" varchar(100),
	"tax_id" varchar(20),
	"phone" varchar(20),
	"email" varchar(150),
	"address" text,
	"payment_terms" integer DEFAULT 30 NOT NULL,
	"is_active" boolean DEFAULT true NOT NULL,
	"created_at" timestamp NOT NULL,
	"updated_at" timestamp NOT NULL
);
--> statement-breakpoint
CREATE TABLE "supplier_payment" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"business_id" varchar(36) NOT NULL,
	"account_payable_id" varchar(36) NOT NULL,
	"payment_method_id" varchar(36) NOT NULL,
	"amount" numeric(12, 2) NOT NULL,
	"payment_date" date NOT NULL,
	"reference" varchar(100),
	"notes" text,
	"paid_by" varchar(36),
	"created_at" timestamp NOT NULL
);
--> statement-breakpoint
CREATE TABLE "supplier_product" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"supplier_id" varchar(36) NOT NULL,
	"product_id" varchar(36) NOT NULL,
	"supplier_sku" varchar(50),
	"supplier_price" numeric(12, 2),
	"lead_time_days" integer
);
--> statement-breakpoint
ALTER TABLE "account_receivable" ADD CONSTRAINT "account_receivable_business_id_business_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."business"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "account_receivable" ADD CONSTRAINT "account_receivable_customer_id_customer_id_fk" FOREIGN KEY ("customer_id") REFERENCES "public"."customer"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "account_receivable" ADD CONSTRAINT "account_receivable_sale_id_sale_id_fk" FOREIGN KEY ("sale_id") REFERENCES "public"."sale"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "collection_payment" ADD CONSTRAINT "collection_payment_business_id_business_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."business"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "collection_payment" ADD CONSTRAINT "collection_payment_account_receivable_id_account_receivable_id_fk" FOREIGN KEY ("account_receivable_id") REFERENCES "public"."account_receivable"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "collection_payment" ADD CONSTRAINT "collection_payment_payment_method_id_payment_method_id_fk" FOREIGN KEY ("payment_method_id") REFERENCES "public"."payment_method"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "collection_payment" ADD CONSTRAINT "collection_payment_collected_by_app_user_id_fk" FOREIGN KEY ("collected_by") REFERENCES "public"."app_user"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "statement_history" ADD CONSTRAINT "statement_history_customer_id_customer_id_fk" FOREIGN KEY ("customer_id") REFERENCES "public"."customer"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "statement_history" ADD CONSTRAINT "statement_history_generated_by_app_user_id_fk" FOREIGN KEY ("generated_by") REFERENCES "public"."app_user"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "app_user" ADD CONSTRAINT "app_user_business_id_business_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."business"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "document_type" ADD CONSTRAINT "document_type_business_id_business_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."business"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "payment_method" ADD CONSTRAINT "payment_method_business_id_business_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."business"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "refresh_token" ADD CONSTRAINT "refresh_token_user_id_app_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."app_user"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "role" ADD CONSTRAINT "role_business_id_business_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."business"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "role_permission" ADD CONSTRAINT "role_permission_role_id_role_id_fk" FOREIGN KEY ("role_id") REFERENCES "public"."role"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "role_permission" ADD CONSTRAINT "role_permission_permission_id_permission_id_fk" FOREIGN KEY ("permission_id") REFERENCES "public"."permission"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "tax" ADD CONSTRAINT "tax_business_id_business_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."business"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_role" ADD CONSTRAINT "user_role_user_id_app_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."app_user"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_role" ADD CONSTRAINT "user_role_role_id_role_id_fk" FOREIGN KEY ("role_id") REFERENCES "public"."role"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "expense" ADD CONSTRAINT "expense_business_id_business_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."business"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "expense" ADD CONSTRAINT "expense_category_id_expense_category_id_fk" FOREIGN KEY ("category_id") REFERENCES "public"."expense_category"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "expense" ADD CONSTRAINT "expense_payment_method_id_payment_method_id_fk" FOREIGN KEY ("payment_method_id") REFERENCES "public"."payment_method"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "expense" ADD CONSTRAINT "expense_created_by_app_user_id_fk" FOREIGN KEY ("created_by") REFERENCES "public"."app_user"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "expense_category" ADD CONSTRAINT "expense_category_business_id_business_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."business"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "inventory_movement" ADD CONSTRAINT "inventory_movement_product_id_product_id_fk" FOREIGN KEY ("product_id") REFERENCES "public"."product"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "inventory_movement" ADD CONSTRAINT "inventory_movement_warehouse_id_warehouse_id_fk" FOREIGN KEY ("warehouse_id") REFERENCES "public"."warehouse"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "inventory_movement" ADD CONSTRAINT "inventory_movement_created_by_app_user_id_fk" FOREIGN KEY ("created_by") REFERENCES "public"."app_user"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "inventory_transfer" ADD CONSTRAINT "inventory_transfer_business_id_business_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."business"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "inventory_transfer" ADD CONSTRAINT "inventory_transfer_from_warehouse_id_warehouse_id_fk" FOREIGN KEY ("from_warehouse_id") REFERENCES "public"."warehouse"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "inventory_transfer" ADD CONSTRAINT "inventory_transfer_to_warehouse_id_warehouse_id_fk" FOREIGN KEY ("to_warehouse_id") REFERENCES "public"."warehouse"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "inventory_transfer" ADD CONSTRAINT "inventory_transfer_created_by_app_user_id_fk" FOREIGN KEY ("created_by") REFERENCES "public"."app_user"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "inventory_transfer_line" ADD CONSTRAINT "inventory_transfer_line_transfer_id_inventory_transfer_id_fk" FOREIGN KEY ("transfer_id") REFERENCES "public"."inventory_transfer"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "inventory_transfer_line" ADD CONSTRAINT "inventory_transfer_line_product_id_product_id_fk" FOREIGN KEY ("product_id") REFERENCES "public"."product"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "product" ADD CONSTRAINT "product_business_id_business_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."business"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "product" ADD CONSTRAINT "product_category_id_product_category_id_fk" FOREIGN KEY ("category_id") REFERENCES "public"."product_category"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "product" ADD CONSTRAINT "product_unit_id_unit_of_measure_id_fk" FOREIGN KEY ("unit_id") REFERENCES "public"."unit_of_measure"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "product_category" ADD CONSTRAINT "product_category_business_id_business_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."business"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "product_stock" ADD CONSTRAINT "product_stock_product_id_product_id_fk" FOREIGN KEY ("product_id") REFERENCES "public"."product"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "product_stock" ADD CONSTRAINT "product_stock_warehouse_id_warehouse_id_fk" FOREIGN KEY ("warehouse_id") REFERENCES "public"."warehouse"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "warehouse" ADD CONSTRAINT "warehouse_business_id_business_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."business"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "credit_note" ADD CONSTRAINT "credit_note_business_id_business_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."business"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "credit_note" ADD CONSTRAINT "credit_note_sale_id_sale_id_fk" FOREIGN KEY ("sale_id") REFERENCES "public"."sale"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "credit_note" ADD CONSTRAINT "credit_note_customer_id_customer_id_fk" FOREIGN KEY ("customer_id") REFERENCES "public"."customer"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "credit_note" ADD CONSTRAINT "credit_note_created_by_app_user_id_fk" FOREIGN KEY ("created_by") REFERENCES "public"."app_user"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "credit_note_line" ADD CONSTRAINT "credit_note_line_credit_note_id_credit_note_id_fk" FOREIGN KEY ("credit_note_id") REFERENCES "public"."credit_note"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "credit_note_line" ADD CONSTRAINT "credit_note_line_product_id_product_id_fk" FOREIGN KEY ("product_id") REFERENCES "public"."product"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "customer" ADD CONSTRAINT "customer_business_id_business_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."business"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sale" ADD CONSTRAINT "sale_business_id_business_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."business"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sale" ADD CONSTRAINT "sale_customer_id_customer_id_fk" FOREIGN KEY ("customer_id") REFERENCES "public"."customer"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sale" ADD CONSTRAINT "sale_document_type_id_document_type_id_fk" FOREIGN KEY ("document_type_id") REFERENCES "public"."document_type"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sale" ADD CONSTRAINT "sale_warehouse_id_warehouse_id_fk" FOREIGN KEY ("warehouse_id") REFERENCES "public"."warehouse"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sale" ADD CONSTRAINT "sale_created_by_app_user_id_fk" FOREIGN KEY ("created_by") REFERENCES "public"."app_user"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sale" ADD CONSTRAINT "sale_cancelled_by_app_user_id_fk" FOREIGN KEY ("cancelled_by") REFERENCES "public"."app_user"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sale_line" ADD CONSTRAINT "sale_line_sale_id_sale_id_fk" FOREIGN KEY ("sale_id") REFERENCES "public"."sale"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sale_line" ADD CONSTRAINT "sale_line_product_id_product_id_fk" FOREIGN KEY ("product_id") REFERENCES "public"."product"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sale_line" ADD CONSTRAINT "sale_line_tax_id_tax_id_fk" FOREIGN KEY ("tax_id") REFERENCES "public"."tax"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sale_line_tax" ADD CONSTRAINT "sale_line_tax_sale_line_id_sale_line_id_fk" FOREIGN KEY ("sale_line_id") REFERENCES "public"."sale_line"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sale_line_tax" ADD CONSTRAINT "sale_line_tax_tax_id_tax_id_fk" FOREIGN KEY ("tax_id") REFERENCES "public"."tax"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sale_payment" ADD CONSTRAINT "sale_payment_sale_id_sale_id_fk" FOREIGN KEY ("sale_id") REFERENCES "public"."sale"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sale_payment" ADD CONSTRAINT "sale_payment_payment_method_id_payment_method_id_fk" FOREIGN KEY ("payment_method_id") REFERENCES "public"."payment_method"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "account_payable" ADD CONSTRAINT "account_payable_business_id_business_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."business"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "account_payable" ADD CONSTRAINT "account_payable_supplier_id_supplier_id_fk" FOREIGN KEY ("supplier_id") REFERENCES "public"."supplier"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "account_payable" ADD CONSTRAINT "account_payable_purchase_order_id_purchase_order_id_fk" FOREIGN KEY ("purchase_order_id") REFERENCES "public"."purchase_order"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "goods_receipt" ADD CONSTRAINT "goods_receipt_purchase_order_id_purchase_order_id_fk" FOREIGN KEY ("purchase_order_id") REFERENCES "public"."purchase_order"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "goods_receipt" ADD CONSTRAINT "goods_receipt_received_by_app_user_id_fk" FOREIGN KEY ("received_by") REFERENCES "public"."app_user"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "goods_receipt_line" ADD CONSTRAINT "goods_receipt_line_goods_receipt_id_goods_receipt_id_fk" FOREIGN KEY ("goods_receipt_id") REFERENCES "public"."goods_receipt"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "goods_receipt_line" ADD CONSTRAINT "goods_receipt_line_purchase_order_line_id_purchase_order_line_id_fk" FOREIGN KEY ("purchase_order_line_id") REFERENCES "public"."purchase_order_line"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "goods_receipt_line" ADD CONSTRAINT "goods_receipt_line_product_id_product_id_fk" FOREIGN KEY ("product_id") REFERENCES "public"."product"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "purchase_order" ADD CONSTRAINT "purchase_order_business_id_business_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."business"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "purchase_order" ADD CONSTRAINT "purchase_order_supplier_id_supplier_id_fk" FOREIGN KEY ("supplier_id") REFERENCES "public"."supplier"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "purchase_order" ADD CONSTRAINT "purchase_order_warehouse_id_warehouse_id_fk" FOREIGN KEY ("warehouse_id") REFERENCES "public"."warehouse"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "purchase_order" ADD CONSTRAINT "purchase_order_created_by_app_user_id_fk" FOREIGN KEY ("created_by") REFERENCES "public"."app_user"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "purchase_order_line" ADD CONSTRAINT "purchase_order_line_purchase_order_id_purchase_order_id_fk" FOREIGN KEY ("purchase_order_id") REFERENCES "public"."purchase_order"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "purchase_order_line" ADD CONSTRAINT "purchase_order_line_product_id_product_id_fk" FOREIGN KEY ("product_id") REFERENCES "public"."product"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "purchase_order_line" ADD CONSTRAINT "purchase_order_line_tax_id_tax_id_fk" FOREIGN KEY ("tax_id") REFERENCES "public"."tax"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "supplier" ADD CONSTRAINT "supplier_business_id_business_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."business"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "supplier_payment" ADD CONSTRAINT "supplier_payment_business_id_business_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."business"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "supplier_payment" ADD CONSTRAINT "supplier_payment_account_payable_id_account_payable_id_fk" FOREIGN KEY ("account_payable_id") REFERENCES "public"."account_payable"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "supplier_payment" ADD CONSTRAINT "supplier_payment_payment_method_id_payment_method_id_fk" FOREIGN KEY ("payment_method_id") REFERENCES "public"."payment_method"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "supplier_payment" ADD CONSTRAINT "supplier_payment_paid_by_app_user_id_fk" FOREIGN KEY ("paid_by") REFERENCES "public"."app_user"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "supplier_product" ADD CONSTRAINT "supplier_product_supplier_id_supplier_id_fk" FOREIGN KEY ("supplier_id") REFERENCES "public"."supplier"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "supplier_product" ADD CONSTRAINT "supplier_product_product_id_product_id_fk" FOREIGN KEY ("product_id") REFERENCES "public"."product"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "ar_customer_idx" ON "account_receivable" USING btree ("customer_id");--> statement-breakpoint
CREATE INDEX "ar_business_status_idx" ON "account_receivable" USING btree ("business_id","status");--> statement-breakpoint
CREATE INDEX "ar_due_date_idx" ON "account_receivable" USING btree ("due_date");--> statement-breakpoint
CREATE UNIQUE INDEX "collection_payment_receipt_idx" ON "collection_payment" USING btree ("business_id","receipt_number");--> statement-breakpoint
CREATE UNIQUE INDEX "doc_type_business_code_idx" ON "document_type" USING btree ("business_id","code");--> statement-breakpoint
CREATE UNIQUE INDEX "refresh_token_hash_idx" ON "refresh_token" USING btree ("token_hash");--> statement-breakpoint
CREATE INDEX "refresh_token_user_idx" ON "refresh_token" USING btree ("user_id");--> statement-breakpoint
CREATE UNIQUE INDEX "role_business_name_idx" ON "role" USING btree ("business_id","name");--> statement-breakpoint
CREATE UNIQUE INDEX "role_permission_pk" ON "role_permission" USING btree ("role_id","permission_id");--> statement-breakpoint
CREATE UNIQUE INDEX "user_role_pk" ON "user_role" USING btree ("user_id","role_id");--> statement-breakpoint
CREATE INDEX "inv_movement_product_date_idx" ON "inventory_movement" USING btree ("product_id","created_at");--> statement-breakpoint
CREATE INDEX "inv_transfer_business_idx" ON "inventory_transfer" USING btree ("business_id");--> statement-breakpoint
CREATE UNIQUE INDEX "product_business_sku_idx" ON "product" USING btree ("business_id","sku");--> statement-breakpoint
CREATE INDEX "product_business_idx" ON "product" USING btree ("business_id");--> statement-breakpoint
CREATE INDEX "product_barcode_idx" ON "product" USING btree ("barcode");--> statement-breakpoint
CREATE UNIQUE INDEX "product_category_unique" ON "product_category" USING btree ("business_id","name","parent_id");--> statement-breakpoint
CREATE UNIQUE INDEX "product_stock_unique" ON "product_stock" USING btree ("product_id","warehouse_id");--> statement-breakpoint
CREATE INDEX "product_stock_product_idx" ON "product_stock" USING btree ("product_id");--> statement-breakpoint
CREATE INDEX "product_stock_warehouse_idx" ON "product_stock" USING btree ("warehouse_id");--> statement-breakpoint
CREATE UNIQUE INDEX "warehouse_business_name_idx" ON "warehouse" USING btree ("business_id","name");--> statement-breakpoint
CREATE UNIQUE INDEX "credit_note_business_number_idx" ON "credit_note" USING btree ("business_id","note_number");--> statement-breakpoint
CREATE UNIQUE INDEX "sale_business_number_idx" ON "sale" USING btree ("business_id","sale_number");--> statement-breakpoint
CREATE INDEX "sale_business_date_idx" ON "sale" USING btree ("business_id","sale_date");--> statement-breakpoint
CREATE INDEX "sale_customer_idx" ON "sale" USING btree ("customer_id");--> statement-breakpoint
CREATE INDEX "sale_payment_status_idx" ON "sale" USING btree ("business_id","payment_status");--> statement-breakpoint
CREATE INDEX "ap_business_status_idx" ON "account_payable" USING btree ("business_id","status");--> statement-breakpoint
CREATE UNIQUE INDEX "po_business_number_idx" ON "purchase_order" USING btree ("business_id","order_number");--> statement-breakpoint
CREATE INDEX "po_supplier_idx" ON "purchase_order" USING btree ("supplier_id");--> statement-breakpoint
CREATE UNIQUE INDEX "supplier_product_unique" ON "supplier_product" USING btree ("supplier_id","product_id");
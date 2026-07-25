CREATE TABLE "notification" (
	"id" varchar(36) PRIMARY KEY NOT NULL,
	"business_id" varchar(36) NOT NULL,
	"type" varchar(30) NOT NULL,
	"title" varchar(200) NOT NULL,
	"body" text NOT NULL,
	"entity_type" varchar(30),
	"entity_id" varchar(36),
	"read_at" timestamp,
	"created_at" timestamp NOT NULL
);
--> statement-breakpoint
ALTER TABLE "product" ALTER COLUMN "cost_price" SET DEFAULT '0';--> statement-breakpoint
ALTER TABLE "product" ALTER COLUMN "min_stock" SET DEFAULT '0';--> statement-breakpoint
ALTER TABLE "product_stock" ALTER COLUMN "quantity" SET DEFAULT '0';--> statement-breakpoint
ALTER TABLE "customer" ALTER COLUMN "credit_limit" SET DEFAULT '0';--> statement-breakpoint
ALTER TABLE "sale" ALTER COLUMN "subtotal" SET DEFAULT '0';--> statement-breakpoint
ALTER TABLE "sale" ALTER COLUMN "tax_amount" SET DEFAULT '0';--> statement-breakpoint
ALTER TABLE "sale" ALTER COLUMN "discount_amount" SET DEFAULT '0';--> statement-breakpoint
ALTER TABLE "sale" ALTER COLUMN "total" SET DEFAULT '0';--> statement-breakpoint
ALTER TABLE "sale_line" ALTER COLUMN "discount_pct" SET DEFAULT '0';--> statement-breakpoint
ALTER TABLE "sale_line" ALTER COLUMN "discount_amount" SET DEFAULT '0';--> statement-breakpoint
ALTER TABLE "sale_line" ALTER COLUMN "tax_amount" SET DEFAULT '0';--> statement-breakpoint
ALTER TABLE "purchase_order" ALTER COLUMN "subtotal" SET DEFAULT '0';--> statement-breakpoint
ALTER TABLE "purchase_order" ALTER COLUMN "tax_amount" SET DEFAULT '0';--> statement-breakpoint
ALTER TABLE "purchase_order" ALTER COLUMN "total" SET DEFAULT '0';--> statement-breakpoint
ALTER TABLE "purchase_order_line" ALTER COLUMN "quantity_received" SET DEFAULT '0';--> statement-breakpoint
ALTER TABLE "purchase_order_line" ALTER COLUMN "tax_amount" SET DEFAULT '0';--> statement-breakpoint
ALTER TABLE "notification" ADD CONSTRAINT "notification_business_id_business_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."business"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "notification_business_read_idx" ON "notification" USING btree ("business_id","read_at");
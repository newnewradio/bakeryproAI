drop extension if exists "pg_net";

create sequence "public"."delivery_note_seq";

create sequence "public"."order_number_seq";

create sequence "public"."session_number_seq";

create sequence "public"."transaction_number_seq";


  create table "public"."camera_events" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "camera_id" text not null,
    "event_type" text not null,
    "event_data" jsonb default '{}'::jsonb,
    "timestamp" timestamp with time zone default now(),
    "acknowledged" boolean default false,
    "acknowledged_at" timestamp with time zone,
    "acknowledged_by" uuid,
    "severity" text default 'info'::text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."camera_events" enable row level security;


  create table "public"."camera_settings" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "camera_id" text not null,
    "camera_name" text not null,
    "server_url" text not null,
    "username" text default ''::text,
    "password" text default ''::text,
    "enabled" boolean default true,
    "recording_enabled" boolean default false,
    "alerts_enabled" boolean default true,
    "stream_quality" integer default 75,
    "stream_fps" integer default 15,
    "stream_format" text default 'mjpeg'::text,
    "position_x" integer default 0,
    "position_y" integer default 0,
    "grid_size" text default 'medium'::text,
    "settings" jsonb default '{}'::jsonb,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."camera_settings" enable row level security;


  create table "public"."cash_movements" (
    "id" uuid not null default gen_random_uuid(),
    "session_id" uuid,
    "location_id" uuid,
    "cashier_id" uuid,
    "type" text not null,
    "amount" numeric(10,2) not null,
    "reason" text,
    "receipt_photo" text,
    "notes" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."cash_movements" enable row level security;


  create table "public"."chat_messages" (
    "id" uuid not null default gen_random_uuid(),
    "sender_id" uuid not null,
    "receiver_id" uuid,
    "content" text not null,
    "read" boolean default false,
    "attachments" text[],
    "created_at" timestamp with time zone default now()
      );


alter table "public"."chat_messages" enable row level security;


  create table "public"."delivery_notes" (
    "id" uuid not null default gen_random_uuid(),
    "order_id" uuid,
    "order_number" text not null,
    "batch_id" uuid,
    "status" text not null default 'pending'::text,
    "driver_id" uuid,
    "vehicle_id" uuid,
    "customer_name" text not null,
    "customer_address" text,
    "items" jsonb not null default '[]'::jsonb,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "delivery_date" timestamp with time zone,
    "notes" text,
    "location_id" uuid
      );


alter table "public"."delivery_notes" enable row level security;


  create table "public"."documents" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "type" text not null,
    "category" text not null,
    "file_path" text not null,
    "file_size" bigint,
    "mime_type" text,
    "description" text,
    "tags" text[],
    "version" integer default 1,
    "status" text default 'active'::text,
    "expiry_date" date,
    "uploaded_by" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."documents" enable row level security;


  create table "public"."email_templates" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "subject" text not null,
    "body" text not null,
    "variables" jsonb default '[]'::jsonb,
    "category" text,
    "created_by" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."email_templates" enable row level security;


  create table "public"."employees" (
    "id" uuid not null,
    "employee_number" text not null,
    "department" text,
    "position" text,
    "manager_id" uuid,
    "work_schedule" jsonb default '{}'::jsonb,
    "skills" text[],
    "certifications" text[],
    "performance_rating" numeric(3,2),
    "last_review" date,
    "next_review" date,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."employees" enable row level security;


  create table "public"."feedback" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "message" text not null,
    "status" text default 'pending'::text,
    "admin_response" text,
    "responded_by" uuid,
    "responded_at" timestamp with time zone,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."feedback" enable row level security;


  create table "public"."inventory" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "category" text not null,
    "current_stock" numeric(10,2) not null default 0,
    "unit" text not null default 'kg'::text,
    "min_threshold" numeric(10,2) not null default 0,
    "max_threshold" numeric(10,2),
    "cost_per_unit" numeric(10,2) not null default 0,
    "supplier" text,
    "supplier_contact" text,
    "supplier_email" text,
    "last_restocked" timestamp with time zone,
    "expiry_date" date,
    "location_id" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "barcode" text,
    "qr_code" text,
    "product_id" uuid,
    "store_id" uuid,
    "price" numeric(10,2),
    "vat_percentage" numeric(5,2)
      );


alter table "public"."inventory" enable row level security;


  create table "public"."invoice_templates" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "description" text,
    "template_data" jsonb not null,
    "is_default" boolean default false,
    "created_by" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."invoice_templates" enable row level security;


  create table "public"."invoices" (
    "id" uuid not null default gen_random_uuid(),
    "invoice_number" text not null,
    "partner_id" uuid,
    "partner_name" text,
    "customer_name" text not null,
    "customer_address" text,
    "customer_tax_number" text,
    "order_id" uuid,
    "order_number" text,
    "subtotal" numeric(15,2) not null default 0,
    "tax_amount" numeric(15,2) not null default 0,
    "discount_amount" numeric(15,2) not null default 0,
    "total_amount" numeric(15,2) not null default 0,
    "issue_date" date not null default CURRENT_DATE,
    "due_date" date not null,
    "payment_method" text default 'not_specified'::text,
    "payment_status" text default 'pending'::text,
    "created_by" uuid,
    "notes" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."invoices" enable row level security;


  create table "public"."locations" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "type" text not null,
    "address" text not null,
    "city" text not null,
    "postal_code" text,
    "country" text default 'Hungary'::text,
    "phone" text,
    "email" text,
    "manager_id" uuid,
    "opening_hours" text,
    "coordinates" jsonb,
    "status" text default 'active'::text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "partner_id" uuid,
    "has_pos_terminal" boolean default false
      );


alter table "public"."locations" enable row level security;


  create table "public"."network_connections" (
    "id" uuid not null default gen_random_uuid(),
    "client_id" text not null,
    "ip_address" text not null,
    "user_agent" text,
    "connected_at" timestamp with time zone default now(),
    "last_ping" timestamp with time zone default now(),
    "status" text default 'connected'::text,
    "api_key_id" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."network_connections" enable row level security;


  create table "public"."network_devices" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "device_type" text not null default 'unknown'::text,
    "ip" text not null,
    "mac" text default '00:00:00:00:00:00'::text,
    "status" text default 'offline'::text,
    "last_seen" timestamp with time zone default now(),
    "manufacturer" text,
    "model" text,
    "capabilities" jsonb default '[]'::jsonb,
    "port" integer,
    "location" text,
    "api_key_id" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."network_devices" enable row level security;


  create table "public"."network_logs" (
    "id" uuid not null default gen_random_uuid(),
    "timestamp" timestamp with time zone default now(),
    "level" text default 'info'::text,
    "message" text not null,
    "ip_address" text,
    "endpoint" text,
    "api_key_id" uuid,
    "details" jsonb default '{}'::jsonb,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."network_logs" enable row level security;


  create table "public"."notification_settings" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "email_notifications" boolean default true,
    "sms_notifications" boolean default false,
    "voice_notifications" boolean default false,
    "min_priority_for_email" character varying(20) default 'high'::character varying,
    "min_priority_for_sms" character varying(20) default 'urgent'::character varying,
    "min_priority_for_voice" character varying(20) default 'urgent'::character varying,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."notification_settings" enable row level security;


  create table "public"."notifications" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "title" text not null,
    "message" text not null,
    "type" text default 'info'::text,
    "priority" text default 'normal'::text,
    "read" boolean default false,
    "action_url" text,
    "metadata" jsonb default '{}'::jsonb,
    "expires_at" timestamp with time zone,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."notifications" enable row level security;


  create table "public"."orders" (
    "id" uuid not null default gen_random_uuid(),
    "order_number" text not null default nextval('public.order_number_seq'::regclass),
    "customer_name" text not null,
    "customer_email" text,
    "customer_phone" text,
    "customer_address" text,
    "items" jsonb not null default '[]'::jsonb,
    "total_amount" numeric(10,2) not null default 0,
    "tax_amount" numeric(10,2) default 0,
    "discount_amount" numeric(10,2) default 0,
    "status" text default 'pending'::text,
    "order_date" timestamp with time zone default now(),
    "delivery_date" timestamp with time zone,
    "delivery_address" text,
    "payment_method" text,
    "payment_status" text default 'pending'::text,
    "notes" text,
    "location_id" uuid,
    "created_by" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "driver_id" uuid,
    "vehicle_id" uuid,
    "created_by_user" uuid,
    "customer_id" uuid,
    "location_name" text,
    "webshop_order_id" text,
    "delivery_note_generated" boolean default false
      );


alter table "public"."orders" enable row level security;


  create table "public"."partner_companies" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "tax_number" text,
    "address" text,
    "city" text,
    "postal_code" text,
    "country" text default 'Hungary'::text,
    "phone" text,
    "email" text,
    "contact_person" text,
    "status" text default 'active'::text,
    "discount_percentage" numeric(5,2),
    "payment_terms" text,
    "notes" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."partner_companies" enable row level security;


  create table "public"."partner_users" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "partner_id" uuid not null,
    "role" text not null default 'member'::text,
    "is_admin" boolean default false,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."partner_users" enable row level security;


  create table "public"."partners" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "email" text,
    "created_at" timestamp with time zone default now()
      );



  create table "public"."payment_items" (
    "id" uuid not null default gen_random_uuid(),
    "payment_id" uuid not null,
    "name" character varying(255) not null,
    "amount" numeric(10,2) not null,
    "quantity" integer not null default 1,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."payment_items" enable row level security;


  create table "public"."payment_methods" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "description" text,
    "is_active" boolean default true,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."payment_methods" enable row level security;


  create table "public"."payments" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "amount" numeric(10,2) not null,
    "currency" character varying(3) not null default 'HUF'::character varying,
    "status" character varying(20) not null default 'pending'::character varying,
    "payment_method" character varying(20) not null,
    "description" text,
    "reference_id" character varying(100),
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."payments" enable row level security;


  create table "public"."pos_return_items" (
    "id" uuid not null default gen_random_uuid(),
    "return_id" uuid not null,
    "product_id" uuid not null,
    "quantity" integer not null,
    "unit_price" numeric(10,2) not null,
    "total_price" numeric(10,2) not null,
    "reason" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "condition" text,
    "total_amount" text,
    "original_transaction_item_id" uuid
      );


alter table "public"."pos_return_items" enable row level security;


  create table "public"."pos_returns" (
    "id" uuid not null default gen_random_uuid(),
    "return_number" text not null,
    "session_id" uuid,
    "location_id" uuid not null,
    "cashier_id" uuid not null,
    "customer_name" text,
    "customer_email" text,
    "customer_phone" text,
    "subtotal" numeric(10,2) not null default 0,
    "tax_amount" numeric(10,2) default 0,
    "total_amount" numeric(10,2) not null default 0,
    "payment_method" text not null default 'cash'::text,
    "payment_reference" text,
    "status" text not null default 'completed'::text,
    "notes" text,
    "created_at" timestamp with time zone default now(),
    "closed_at" timestamp with time zone,
    "updated_at" timestamp with time zone default now(),
    "original_transaction_id" uuid,
    "reason" text,
    "refund_method" text
      );


alter table "public"."pos_returns" enable row level security;


  create table "public"."pos_sessions" (
    "id" uuid not null default gen_random_uuid(),
    "location_id" uuid not null,
    "cashier_id" uuid not null,
    "terminal_id" text not null default ('term_'::text || substr(md5((random())::text), 0, 12)),
    "opening_amount" numeric(10,2) not null default 0,
    "closing_amount" numeric(10,2),
    "cash_sales" numeric(10,2) default 0,
    "card_sales" numeric(10,2) default 0,
    "other_sales" numeric(10,2) default 0,
    "total_sales" numeric(10,2) default 0,
    "total_returns" numeric(10,2) default 0,
    "discrepancy" numeric(10,2),
    "notes" text,
    "status" text not null default 'open'::text,
    "opened_at" timestamp with time zone not null default now(),
    "closed_at" timestamp with time zone,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "session_number" text,
    "start_time" timestamp with time zone,
    "end_time" timestamp with time zone,
    "is_active" boolean default true,
    "terminal_name" text
      );


alter table "public"."pos_sessions" enable row level security;


  create table "public"."pos_transaction_items" (
    "id" uuid not null default gen_random_uuid(),
    "transaction_id" uuid not null,
    "product_id" uuid,
    "quantity" integer not null,
    "unit_price" numeric(10,2) not null,
    "total_price" numeric(10,2) not null,
    "created_at" timestamp with time zone default CURRENT_TIMESTAMP,
    "updated_at" timestamp with time zone default CURRENT_TIMESTAMP,
    "discount_amount" numeric(10,2) default 0
      );


alter table "public"."pos_transaction_items" enable row level security;


  create table "public"."pos_transactions" (
    "id" uuid not null default gen_random_uuid(),
    "transaction_number" text not null,
    "session_id" uuid,
    "location_id" uuid not null,
    "cashier_id" uuid not null,
    "customer_name" text,
    "customer_email" text,
    "customer_phone" text,
    "subtotal" numeric(10,2) not null default 0,
    "discount_amount" numeric(10,2) default 0,
    "tax_amount" numeric(10,2) default 0,
    "total_amount" numeric(10,2) not null default 0,
    "payment_method" text not null default 'cash'::text,
    "payment_reference" text,
    "status" text not null default 'completed'::text,
    "notes" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "receipt_data" jsonb
      );


alter table "public"."pos_transactions" enable row level security;


  create table "public"."product_inventory" (
    "id" uuid not null default gen_random_uuid(),
    "product_id" uuid not null,
    "location_id" uuid not null,
    "current_stock" integer not null default 0,
    "min_threshold" integer not null default 0,
    "max_threshold" integer,
    "last_restock_date" timestamp with time zone,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."product_inventory" enable row level security;


  create table "public"."production_batches" (
    "id" uuid not null default gen_random_uuid(),
    "batch_number" text not null,
    "recipe_id" uuid not null,
    "batch_size" integer not null,
    "status" text default 'planned'::text,
    "start_time" timestamp with time zone,
    "end_time" timestamp with time zone,
    "actual_yield" integer,
    "quality_score" integer,
    "temperature" numeric(5,2),
    "humidity" numeric(5,2),
    "notes" text,
    "location_id" uuid,
    "baker_id" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "webshop_order_id" text
      );


alter table "public"."production_batches" enable row level security;


  create table "public"."production_batches_orders" (
    "id" uuid not null default gen_random_uuid(),
    "batch_id" uuid not null,
    "order_id" uuid not null,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."production_batches_orders" enable row level security;


  create table "public"."production_steps" (
    "id" bigint generated always as identity not null,
    "order_id" bigint not null,
    "step_description" text not null,
    "status" text default 'pending'::text,
    "created_at" timestamp with time zone default now(),
    "created_by" uuid,
    "recipe_id" uuid,
    "sequence_order" integer default 1,
    "step_name" text,
    "estimated_duration" integer default 0,
    "temperature" numeric(5,2),
    "humidity" numeric(5,2),
    "department" text,
    "is_critical" boolean default false,
    "alert_message" text,
    "notes" text,
    "batch_id" uuid,
    "start_time" timestamp with time zone,
    "end_time" timestamp with time zone,
    "actual_duration" integer,
    "recipes" text,
    "user_id" uuid,
    "recipe_step_id" uuid
      );


alter table "public"."production_steps" enable row level security;


  create table "public"."products" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "description" text,
    "ingredients" jsonb default '[]'::jsonb,
    "instructions" text[] default '{}'::text[],
    "prep_time" integer not null default 0,
    "bake_time" integer not null default 0,
    "difficulty" text default 'medium'::text,
    "category" text not null default 'bread'::text,
    "yield_amount" integer not null default 1,
    "cost_per_unit" numeric(10,2) default 0,
    "ai_generated" boolean default false,
    "created_by" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "shelf_life" integer default 1,
    "weight_per_unit" integer default 0,
    "allergens" text[] default '{}'::text[],
    "nutritional_info" jsonb default '{}'::jsonb,
    "image_url" text,
    "wholesale_price" numeric(10,2) default 0,
    "retail_price" numeric(10,2) default 0,
    "avg_rating" numeric(3,2) default 0,
    "review_count" integer default 0,
    "is_gluten_free" boolean default false,
    "is_dairy_free" boolean default false,
    "is_egg_free" boolean default false,
    "is_vegan" boolean default false,
    "vat_percentage" numeric(5,2) default 18.0,
    "allergen_names" jsonb default '{"soy": "szója", "eggs": "tojás", "fish": "hal", "nuts": "diófélék", "dairy": "tej", "gluten": "glutén", "sesame": "szezámmag", "peanuts": "földimogyoró", "shellfish": "rákfélék"}'::jsonb,
    "category_names" jsonb default '{"cake": "torta", "bread": "kenyér", "other": "egyéb", "pizza": "pizza", "cookie": "keksz", "pastry": "sütemény", "sandwich": "szendvics"}'::jsonb,
    "barcode" text,
    "qr_code" text,
    "is_deleted" text,
    "price" text,
    "base_recipe_id" uuid,
    "brand" jsonb
      );


alter table "public"."products" enable row level security;


  create table "public"."profiles" (
    "id" uuid not null,
    "email" text not null,
    "full_name" text,
    "role" text not null default 'baker'::text,
    "phone" text,
    "address" text,
    "emergency_contact" text,
    "emergency_phone" text,
    "hire_date" date default CURRENT_DATE,
    "hourly_wage" numeric(10,2),
    "status" text default 'active'::text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "avatar_url" text,
    "provider" text default 'email'::text,
    "bank_account" text,
    "tax_number" text,
    "social_security_number" text,
    "mother_name" text,
    "last_active" timestamp with time zone default now(),
    "permissions" text[],
    "default_location_id" uuid,
    "sender_id" uuid,
    "chat_messages" bigint
      );


alter table "public"."profiles" enable row level security;


  create table "public"."recipe_steps" (
    "id" uuid not null default gen_random_uuid(),
    "recipe_id" uuid not null,
    "step_number" integer not null,
    "title" text not null,
    "description" text not null,
    "duration_minutes" integer default 0,
    "temperature" integer,
    "humidity" integer,
    "equipment" text[],
    "ingredients" jsonb default '[]'::jsonb,
    "notes" text,
    "created_at" timestamp with time zone default now(),
    "image_url" text,
    "alert_message" text,
    "alert_threshold_minutes" integer default 5,
    "is_critical" boolean default false,
    "recipe_step_id" uuid
      );


alter table "public"."recipe_steps" enable row level security;


  create table "public"."recipes" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "description" text,
    "ingredients" jsonb default '[]'::jsonb,
    "instructions" text[] default '{}'::text[],
    "prep_time" integer not null default 0,
    "bake_time" integer not null default 0,
    "difficulty" text default 'medium'::text,
    "category" text not null default 'bread'::text,
    "yield_amount" integer not null default 1,
    "cost_per_unit" numeric(10,2) default 0,
    "ai_generated" boolean default false,
    "created_by" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "wholesale_price" numeric(10,2) default 0,
    "retail_price" numeric(10,2) default 0,
    "image_url" text,
    "preparation_notes" text,
    "allergens" text[],
    "nutritional_info" jsonb default '{}'::jsonb,
    "vat_percentage" numeric(5,2) default 18.0,
    "is_active" boolean default true,
    "barcode" text,
    "qr_code" text,
    "recipe_step_id" uuid
      );


alter table "public"."recipes" enable row level security;


  create table "public"."scheduled_emails" (
    "id" uuid not null default gen_random_uuid(),
    "recipient_email" text not null,
    "recipient_name" text,
    "subject" text not null,
    "body" text not null,
    "scheduled_for" timestamp with time zone not null,
    "status" text default 'pending'::text,
    "created_by" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "template_id" uuid,
    "related_entity_id" uuid,
    "related_entity_type" text
      );


alter table "public"."scheduled_emails" enable row level security;


  create table "public"."schedules" (
    "id" uuid not null default gen_random_uuid(),
    "employee_id" uuid not null,
    "date" date not null,
    "shift_type" text not null,
    "start_time" time without time zone not null,
    "end_time" time without time zone not null,
    "location_id" uuid,
    "status" text not null default 'scheduled'::text,
    "notes" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "actual_start_time" timestamp with time zone,
    "actual_end_time" timestamp with time zone,
    "break_duration" integer default 30,
    "created_by" uuid
      );


alter table "public"."schedules" enable row level security;


  create table "public"."security_logs" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "action" text not null,
    "resource_type" text default 'camera'::text,
    "resource_id" text,
    "ip_address" text,
    "user_agent" text,
    "details" jsonb default '{}'::jsonb,
    "timestamp" timestamp with time zone default now(),
    "created_at" timestamp with time zone default now()
      );


alter table "public"."security_logs" enable row level security;


  create table "public"."sensor_data" (
    "id" uuid not null default gen_random_uuid(),
    "device_id" text not null,
    "device_name" text,
    "location_id" uuid,
    "temperature" numeric(5,2),
    "humidity" numeric(5,2),
    "power" numeric(10,2),
    "voltage" numeric(6,2),
    "current" numeric(6,2),
    "energy" numeric(10,3),
    "timestamp" timestamp with time zone not null,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."sensor_data" enable row level security;


  create table "public"."sent_emails" (
    "id" uuid not null default gen_random_uuid(),
    "recipient_email" text not null,
    "recipient_name" text,
    "subject" text not null,
    "body" text not null,
    "status" text default 'sent'::text,
    "sent_at" timestamp with time zone default now(),
    "sent_by" uuid,
    "template_id" uuid,
    "related_entity_id" uuid,
    "related_entity_type" text,
    "recipient_id" uuid
      );


alter table "public"."sent_emails" enable row level security;


  create table "public"."settings" (
    "id" uuid not null default gen_random_uuid(),
    "category" text not null,
    "key" text not null,
    "value" text not null,
    "description" text,
    "is_public" boolean default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."settings" enable row level security;


  create table "public"."store_inventory" (
    "id" uuid not null default gen_random_uuid(),
    "product_id" uuid,
    "location_id" uuid,
    "current_stock" integer not null default 0,
    "min_threshold" integer not null default 0,
    "max_threshold" integer,
    "last_restock_date" timestamp with time zone,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "price" numeric,
    "vat_percentage" numeric,
    "category" text,
    "name" text,
    "store_id" uuid,
    "barcode" text,
    "qr_code" text,
    "unit" text default 'db'::text,
    "supplier" text,
    "cost_per_unit" text,
    "expiry_date" text,
    "supplier_contact" text,
    "supplier_email" text
      );


alter table "public"."store_inventory" enable row level security;


  create table "public"."stream_sessions" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "camera_id" text not null,
    "session_token" text not null,
    "stream_url" text,
    "quality" integer default 75,
    "fps" integer default 15,
    "format" text default 'mjpeg'::text,
    "started_at" timestamp with time zone default now(),
    "last_activity" timestamp with time zone default now(),
    "ended_at" timestamp with time zone,
    "active" boolean default true,
    "metadata" jsonb default '{}'::jsonb
      );


alter table "public"."stream_sessions" enable row level security;


  create table "public"."survey_questions" (
    "id" uuid not null default gen_random_uuid(),
    "survey_id" uuid not null,
    "question" text not null,
    "type" text not null,
    "options" jsonb,
    "required" boolean default true,
    "order_index" integer default 0,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."survey_questions" enable row level security;


  create table "public"."survey_responses" (
    "id" uuid not null default gen_random_uuid(),
    "survey_id" uuid not null,
    "question_id" uuid not null,
    "user_id" uuid not null,
    "response" jsonb not null,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."survey_responses" enable row level security;


  create table "public"."surveys" (
    "id" uuid not null default gen_random_uuid(),
    "title" text not null,
    "description" text,
    "status" text not null default 'draft'::text,
    "created_by" uuid,
    "start_date" timestamp with time zone,
    "end_date" timestamp with time zone,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."surveys" enable row level security;


  create table "public"."transactions" (
    "id" uuid not null default gen_random_uuid(),
    "order_id" uuid,
    "order_number" text,
    "batch_id" uuid,
    "status" text,
    "driver_id" uuid,
    "vehicle_id" uuid,
    "customer_name" text,
    "customer_address" text,
    "items" jsonb,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "delivery_date" timestamp with time zone,
    "notes" text,
    "location_id" uuid
      );



  create table "public"."vehicle_damage_reports" (
    "id" uuid not null default gen_random_uuid(),
    "vehicle_id" uuid not null,
    "report_date" date not null,
    "description" text not null,
    "location" text not null,
    "reporter_id" uuid not null,
    "status" text not null default 'reported'::text,
    "images" text[] default '{}'::text[],
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."vehicle_damage_reports" enable row level security;


  create table "public"."vehicles" (
    "id" uuid not null default gen_random_uuid(),
    "license_plate" text not null,
    "make" text not null,
    "model" text not null,
    "year" integer not null,
    "color" text not null,
    "status" text not null default 'active'::text,
    "last_service_date" date,
    "next_service_date" date,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "driver_id" uuid,
    "type" text,
    "capacity" numeric(10,2),
    "fuel_type" text default 'diesel'::text,
    "fuel_consumption" numeric(5,2),
    "insurance_expiry" date,
    "technical_inspection" date,
    "mileage" integer default 0,
    "gps_tracker_id" text,
    "location_id" uuid,
    "image_url" text,
    "last_service" date,
    "next_service" date
      );


alter table "public"."vehicles" enable row level security;


  create table "public"."webshop_carts" (
    "id" uuid not null default gen_random_uuid(),
    "customer_id" uuid,
    "items" jsonb not null default '[]'::jsonb,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "expires_at" timestamp with time zone default (now() + '30 days'::interval)
      );


alter table "public"."webshop_carts" enable row level security;


  create table "public"."webshop_customers" (
    "id" uuid not null,
    "customer_number" text not null,
    "shipping_addresses" jsonb default '[]'::jsonb,
    "billing_addresses" jsonb default '[]'::jsonb,
    "favorite_products" uuid[] default '{}'::uuid[],
    "marketing_preferences" jsonb default '{"sms": false, "push": false, "email": false}'::jsonb,
    "last_login" timestamp with time zone,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."webshop_customers" enable row level security;


  create table "public"."webshop_orders" (
    "id" uuid not null default gen_random_uuid(),
    "order_number" text not null,
    "customer_id" uuid,
    "customer_name" text not null,
    "customer_email" text,
    "customer_phone" text,
    "customer_address" text,
    "items" jsonb not null default '[]'::jsonb,
    "total_amount" numeric(10,2) not null default 0,
    "tax_amount" numeric(10,2) default 0,
    "discount_amount" numeric(10,2) default 0,
    "status" text default 'pending'::text,
    "payment_method" text,
    "payment_status" text default 'pending'::text,
    "transaction_id" text,
    "notes" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "pickup_location_id" uuid,
    "pickup_date" timestamp with time zone,
    "need_invoice" boolean default false,
    "invoice_data" jsonb default '{}'::jsonb
      );


alter table "public"."webshop_orders" enable row level security;


  create table "public"."webshop_pickup_locations" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "address" text not null,
    "description" text,
    "is_active" boolean default true,
    "opens_at" time without time zone,
    "closes_at" time without time zone,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."webshop_pickup_locations" enable row level security;


  create table "public"."webshop_product_reviews" (
    "id" uuid not null default gen_random_uuid(),
    "product_id" uuid not null,
    "customer_id" uuid not null,
    "rating" integer not null,
    "title" text,
    "content" text,
    "is_verified_purchase" boolean default false,
    "is_approved" boolean default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."webshop_product_reviews" enable row level security;


  create table "public"."work_logs" (
    "id" uuid not null default gen_random_uuid(),
    "employee_id" uuid not null,
    "start_time" timestamp with time zone not null,
    "end_time" timestamp with time zone,
    "duration" integer,
    "status" text default 'active'::text,
    "notes" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."work_logs" enable row level security;

CREATE UNIQUE INDEX camera_events_pkey ON public.camera_events USING btree (id);

CREATE UNIQUE INDEX camera_settings_pkey ON public.camera_settings USING btree (id);

CREATE UNIQUE INDEX camera_settings_user_id_camera_id_key ON public.camera_settings USING btree (user_id, camera_id);

CREATE UNIQUE INDEX cash_movements_pkey ON public.cash_movements USING btree (id);

CREATE UNIQUE INDEX chat_messages_pkey ON public.chat_messages USING btree (id);

CREATE UNIQUE INDEX delivery_notes_pkey ON public.delivery_notes USING btree (id);

CREATE UNIQUE INDEX documents_pkey ON public.documents USING btree (id);

CREATE UNIQUE INDEX email_templates_pkey ON public.email_templates USING btree (id);

CREATE UNIQUE INDEX employees_employee_number_key ON public.employees USING btree (employee_number);

CREATE UNIQUE INDEX employees_pkey ON public.employees USING btree (id);

CREATE UNIQUE INDEX feedback_pkey ON public.feedback USING btree (id);

CREATE INDEX idx_camera_events_camera_id ON public.camera_events USING btree (camera_id);

CREATE INDEX idx_camera_events_timestamp ON public.camera_events USING btree ("timestamp" DESC);

CREATE INDEX idx_camera_events_type ON public.camera_events USING btree (event_type);

CREATE INDEX idx_camera_events_user_id ON public.camera_events USING btree (user_id);

CREATE INDEX idx_camera_settings_camera_id ON public.camera_settings USING btree (camera_id);

CREATE INDEX idx_camera_settings_user_id ON public.camera_settings USING btree (user_id);

CREATE INDEX idx_cash_movements_created_at ON public.cash_movements USING btree (created_at);

CREATE INDEX idx_cash_movements_session_id ON public.cash_movements USING btree (session_id);

CREATE INDEX idx_cash_movements_type ON public.cash_movements USING btree (type);

CREATE INDEX idx_chat_messages_receiver_id ON public.chat_messages USING btree (receiver_id);

CREATE INDEX idx_chat_messages_sender_id ON public.chat_messages USING btree (sender_id);

CREATE INDEX idx_delivery_notes_batch_id ON public.delivery_notes USING btree (batch_id);

CREATE INDEX idx_delivery_notes_driver_id ON public.delivery_notes USING btree (driver_id);

CREATE INDEX idx_delivery_notes_order_id ON public.delivery_notes USING btree (order_id);

CREATE INDEX idx_delivery_notes_status ON public.delivery_notes USING btree (status);

CREATE INDEX idx_delivery_notes_vehicle_id ON public.delivery_notes USING btree (vehicle_id);

CREATE INDEX idx_documents_category ON public.documents USING btree (category);

CREATE INDEX idx_documents_type ON public.documents USING btree (type);

CREATE INDEX idx_documents_uploaded_by ON public.documents USING btree (uploaded_by);

CREATE INDEX idx_email_templates_category ON public.email_templates USING btree (category);

CREATE INDEX idx_employees_manager_id ON public.employees USING btree (manager_id);

CREATE INDEX idx_feedback_status ON public.feedback USING btree (status);

CREATE INDEX idx_feedback_user_id ON public.feedback USING btree (user_id);

CREATE INDEX idx_inventory_barcode ON public.inventory USING btree (barcode);

CREATE INDEX idx_inventory_category ON public.inventory USING btree (category);

CREATE INDEX idx_inventory_current_stock ON public.inventory USING btree (current_stock);

CREATE INDEX idx_inventory_product_id ON public.inventory USING btree (product_id);

CREATE INDEX idx_inventory_qr_code ON public.inventory USING btree (qr_code);

CREATE INDEX idx_inventory_store_id ON public.inventory USING btree (store_id);

CREATE INDEX idx_invoices_created_by ON public.invoices USING btree (created_by);

CREATE INDEX idx_invoices_invoice_number ON public.invoices USING btree (invoice_number);

CREATE INDEX idx_invoices_issue_date ON public.invoices USING btree (issue_date);

CREATE INDEX idx_invoices_order_id ON public.invoices USING btree (order_id);

CREATE INDEX idx_locations_status ON public.locations USING btree (status);

CREATE INDEX idx_locations_type ON public.locations USING btree (type);

CREATE INDEX idx_network_connections_client_id ON public.network_connections USING btree (client_id);

CREATE INDEX idx_network_connections_connected_at ON public.network_connections USING btree (connected_at);

CREATE INDEX idx_network_connections_status ON public.network_connections USING btree (status);

CREATE INDEX idx_network_devices_ip ON public.network_devices USING btree (ip);

CREATE INDEX idx_network_devices_last_seen ON public.network_devices USING btree (last_seen);

CREATE INDEX idx_network_devices_status ON public.network_devices USING btree (status);

CREATE INDEX idx_network_devices_type ON public.network_devices USING btree (device_type);

CREATE INDEX idx_network_logs_ip ON public.network_logs USING btree (ip_address);

CREATE INDEX idx_network_logs_level ON public.network_logs USING btree (level);

CREATE INDEX idx_network_logs_timestamp ON public.network_logs USING btree ("timestamp");

CREATE INDEX idx_notifications_read ON public.notifications USING btree (read);

CREATE INDEX idx_notifications_user_id ON public.notifications USING btree (user_id);

CREATE INDEX idx_orders_customer_id ON public.orders USING btree (customer_id);

CREATE INDEX idx_orders_order_date ON public.orders USING btree (order_date);

CREATE INDEX idx_orders_status ON public.orders USING btree (status);

CREATE INDEX idx_partner_companies_status ON public.partner_companies USING btree (status);

CREATE INDEX idx_partner_users_partner_id ON public.partner_users USING btree (partner_id);

CREATE INDEX idx_partner_users_user_id ON public.partner_users USING btree (user_id);

CREATE INDEX idx_payment_items_payment_id ON public.payment_items USING btree (payment_id);

CREATE INDEX idx_payments_created_at ON public.payments USING btree (created_at);

CREATE INDEX idx_payments_reference_id ON public.payments USING btree (reference_id);

CREATE INDEX idx_payments_status ON public.payments USING btree (status);

CREATE INDEX idx_payments_user_id ON public.payments USING btree (user_id);

CREATE INDEX idx_pos_return_items_product_id ON public.pos_return_items USING btree (product_id);

CREATE INDEX idx_pos_return_items_return_id ON public.pos_return_items USING btree (return_id);

CREATE INDEX idx_pos_returns_cashier_id ON public.pos_returns USING btree (cashier_id);

CREATE INDEX idx_pos_returns_created_at ON public.pos_returns USING btree (created_at);

CREATE INDEX idx_pos_returns_location_id ON public.pos_returns USING btree (location_id);

CREATE INDEX idx_pos_returns_session_id ON public.pos_returns USING btree (session_id);

CREATE INDEX idx_pos_sessions_cashier_id ON public.pos_sessions USING btree (cashier_id);

CREATE INDEX idx_pos_sessions_location_id ON public.pos_sessions USING btree (location_id);

CREATE INDEX idx_pos_sessions_status ON public.pos_sessions USING btree (status);

CREATE INDEX idx_pos_transaction_items_product_id ON public.pos_transaction_items USING btree (product_id);

CREATE INDEX idx_pos_transaction_items_transaction_id ON public.pos_transaction_items USING btree (transaction_id);

CREATE INDEX idx_pos_transactions_cashier_id ON public.pos_transactions USING btree (cashier_id);

CREATE INDEX idx_pos_transactions_created_at ON public.pos_transactions USING btree (created_at);

CREATE INDEX idx_pos_transactions_location_id ON public.pos_transactions USING btree (location_id);

CREATE INDEX idx_pos_transactions_session_id ON public.pos_transactions USING btree (session_id);

CREATE INDEX idx_product_inventory_location_id ON public.product_inventory USING btree (location_id);

CREATE INDEX idx_product_inventory_product_id ON public.product_inventory USING btree (product_id);

CREATE INDEX idx_production_batches_recipe_id ON public.production_batches USING btree (recipe_id);

CREATE INDEX idx_production_batches_status ON public.production_batches USING btree (status);

CREATE INDEX idx_production_steps_batch_id ON public.production_steps USING btree (batch_id);

CREATE INDEX idx_production_steps_created_by ON public.production_steps USING btree (created_by);

CREATE INDEX idx_production_steps_order_id ON public.production_steps USING btree (order_id);

CREATE INDEX idx_production_steps_recipe_id ON public.production_steps USING btree (recipe_id);

CREATE INDEX idx_production_steps_recipe_step_id ON public.production_steps USING btree (recipe_step_id);

CREATE INDEX idx_production_steps_sequence_order ON public.production_steps USING btree (sequence_order);

CREATE INDEX idx_production_steps_status ON public.production_steps USING btree (status);

CREATE INDEX idx_products_category ON public.products USING btree (category);

CREATE INDEX idx_products_created_by ON public.products USING btree (created_by);

CREATE INDEX idx_profiles_role ON public.profiles USING btree (role);

CREATE INDEX idx_profiles_status ON public.profiles USING btree (status);

CREATE INDEX idx_recipe_steps_recipe_id ON public.recipe_steps USING btree (recipe_id);

CREATE INDEX idx_recipe_steps_step_number ON public.recipe_steps USING btree (step_number);

CREATE INDEX idx_recipes_category ON public.recipes USING btree (category);

CREATE INDEX idx_recipes_created_by ON public.recipes USING btree (created_by);

CREATE INDEX idx_scheduled_emails_scheduled_for ON public.scheduled_emails USING btree (scheduled_for);

CREATE INDEX idx_scheduled_emails_status ON public.scheduled_emails USING btree (status);

CREATE INDEX idx_schedules_date ON public.schedules USING btree (date);

CREATE INDEX idx_schedules_employee_id ON public.schedules USING btree (employee_id);

CREATE INDEX idx_security_logs_timestamp ON public.security_logs USING btree ("timestamp" DESC);

CREATE INDEX idx_security_logs_user_id ON public.security_logs USING btree (user_id);

CREATE INDEX idx_sensor_data_created_at ON public.sensor_data USING btree (created_at);

CREATE INDEX idx_sensor_data_device_id ON public.sensor_data USING btree (device_id);

CREATE INDEX idx_sensor_data_timestamp ON public.sensor_data USING btree ("timestamp");

CREATE INDEX idx_sent_emails_recipient_email ON public.sent_emails USING btree (recipient_email);

CREATE INDEX idx_sent_emails_status ON public.sent_emails USING btree (status);

CREATE INDEX idx_settings_category_key ON public.settings USING btree (category, key);

CREATE INDEX idx_store_inventory_barcode ON public.store_inventory USING btree (barcode);

CREATE INDEX idx_store_inventory_location_id ON public.store_inventory USING btree (location_id);

CREATE INDEX idx_store_inventory_product_id ON public.store_inventory USING btree (product_id);

CREATE INDEX idx_store_inventory_qr_code ON public.store_inventory USING btree (qr_code);

CREATE INDEX idx_stream_sessions_active ON public.stream_sessions USING btree (active);

CREATE INDEX idx_stream_sessions_user_id ON public.stream_sessions USING btree (user_id);

CREATE INDEX idx_survey_questions_survey_id ON public.survey_questions USING btree (survey_id);

CREATE INDEX idx_survey_responses_survey_id ON public.survey_responses USING btree (survey_id);

CREATE INDEX idx_survey_responses_user_id ON public.survey_responses USING btree (user_id);

CREATE INDEX idx_surveys_status ON public.surveys USING btree (status);

CREATE INDEX idx_transactions_delivery_date ON public.transactions USING btree (delivery_date);

CREATE INDEX idx_transactions_location_id ON public.transactions USING btree (location_id);

CREATE INDEX idx_transactions_order_number ON public.transactions USING btree (order_number);

CREATE INDEX idx_transactions_status ON public.transactions USING btree (status);

CREATE INDEX idx_vehicle_damage_reports_reporter_id ON public.vehicle_damage_reports USING btree (reporter_id);

CREATE INDEX idx_vehicle_damage_reports_status ON public.vehicle_damage_reports USING btree (status);

CREATE INDEX idx_vehicle_damage_reports_vehicle_id ON public.vehicle_damage_reports USING btree (vehicle_id);

CREATE INDEX idx_vehicles_driver_id ON public.vehicles USING btree (driver_id);

CREATE INDEX idx_vehicles_status ON public.vehicles USING btree (status);

CREATE INDEX idx_webshop_carts_customer_id ON public.webshop_carts USING btree (customer_id);

CREATE INDEX idx_webshop_customers_customer_number ON public.webshop_customers USING btree (customer_number);

CREATE INDEX idx_webshop_orders_customer_id ON public.webshop_orders USING btree (customer_id);

CREATE INDEX idx_webshop_orders_status ON public.webshop_orders USING btree (status);

CREATE INDEX idx_webshop_product_reviews_customer_id ON public.webshop_product_reviews USING btree (customer_id);

CREATE INDEX idx_webshop_product_reviews_product_id ON public.webshop_product_reviews USING btree (product_id);

CREATE INDEX idx_work_logs_employee_id ON public.work_logs USING btree (employee_id);

CREATE INDEX idx_work_logs_status ON public.work_logs USING btree (status);

CREATE UNIQUE INDEX inventory_pkey ON public.inventory USING btree (id);

CREATE UNIQUE INDEX invoice_templates_pkey ON public.invoice_templates USING btree (id);

CREATE UNIQUE INDEX invoices_invoice_number_key ON public.invoices USING btree (invoice_number);

CREATE UNIQUE INDEX invoices_pkey ON public.invoices USING btree (id);

CREATE UNIQUE INDEX locations_pkey ON public.locations USING btree (id);

CREATE UNIQUE INDEX network_connections_pkey ON public.network_connections USING btree (id);

CREATE UNIQUE INDEX network_devices_pkey ON public.network_devices USING btree (id);

CREATE UNIQUE INDEX network_logs_pkey ON public.network_logs USING btree (id);

CREATE UNIQUE INDEX notification_settings_pkey ON public.notification_settings USING btree (id);

CREATE UNIQUE INDEX notifications_pkey ON public.notifications USING btree (id);

CREATE UNIQUE INDEX orders_order_number_key ON public.orders USING btree (order_number);

CREATE UNIQUE INDEX orders_pkey ON public.orders USING btree (id);

CREATE UNIQUE INDEX partner_companies_pkey ON public.partner_companies USING btree (id);

CREATE UNIQUE INDEX partner_users_pkey ON public.partner_users USING btree (id);

CREATE UNIQUE INDEX partners_pkey ON public.partners USING btree (id);

CREATE UNIQUE INDEX payment_items_pkey ON public.payment_items USING btree (id);

CREATE UNIQUE INDEX payment_methods_pkey ON public.payment_methods USING btree (id);

CREATE UNIQUE INDEX payments_pkey ON public.payments USING btree (id);

CREATE UNIQUE INDEX pos_return_items_pkey ON public.pos_return_items USING btree (id);

CREATE UNIQUE INDEX pos_returns_pkey ON public.pos_returns USING btree (id);

CREATE UNIQUE INDEX pos_sessions_pkey ON public.pos_sessions USING btree (id);

CREATE UNIQUE INDEX pos_transaction_items_pkey ON public.pos_transaction_items USING btree (id);

CREATE UNIQUE INDEX pos_transactions_pkey ON public.pos_transactions USING btree (id);

CREATE UNIQUE INDEX pos_transactions_transaction_number_key ON public.pos_transactions USING btree (transaction_number);

CREATE UNIQUE INDEX product_inventory_pkey ON public.product_inventory USING btree (id);

CREATE UNIQUE INDEX product_inventory_product_location_unique ON public.product_inventory USING btree (product_id, location_id);

CREATE UNIQUE INDEX production_batches_batch_number_key ON public.production_batches USING btree (batch_number);

CREATE UNIQUE INDEX production_batches_orders_batch_id_order_id_key ON public.production_batches_orders USING btree (batch_id, order_id);

CREATE UNIQUE INDEX production_batches_orders_pkey ON public.production_batches_orders USING btree (id);

CREATE UNIQUE INDEX production_batches_pkey ON public.production_batches USING btree (id);

CREATE UNIQUE INDEX production_steps_pkey ON public.production_steps USING btree (id);

CREATE UNIQUE INDEX products_pkey ON public.products USING btree (id);

CREATE UNIQUE INDEX profiles_pkey ON public.profiles USING btree (id);

CREATE UNIQUE INDEX recipe_steps_pkey ON public.recipe_steps USING btree (id);

CREATE UNIQUE INDEX recipes_pkey ON public.recipes USING btree (id);

CREATE UNIQUE INDEX scheduled_emails_pkey ON public.scheduled_emails USING btree (id);

CREATE UNIQUE INDEX schedules_pkey ON public.schedules USING btree (id);

CREATE UNIQUE INDEX security_logs_pkey ON public.security_logs USING btree (id);

CREATE UNIQUE INDEX sensor_data_pkey ON public.sensor_data USING btree (id);

CREATE UNIQUE INDEX sent_emails_pkey ON public.sent_emails USING btree (id);

CREATE UNIQUE INDEX settings_category_key_key ON public.settings USING btree (category, key);

CREATE UNIQUE INDEX settings_pkey ON public.settings USING btree (id);

CREATE UNIQUE INDEX store_inventory_pkey ON public.store_inventory USING btree (id);

CREATE UNIQUE INDEX stream_sessions_pkey ON public.stream_sessions USING btree (id);

CREATE UNIQUE INDEX survey_questions_pkey ON public.survey_questions USING btree (id);

CREATE UNIQUE INDEX survey_responses_pkey ON public.survey_responses USING btree (id);

CREATE UNIQUE INDEX surveys_pkey ON public.surveys USING btree (id);

CREATE UNIQUE INDEX transactions_pkey ON public.transactions USING btree (id);

CREATE UNIQUE INDEX unique_product_location ON public.store_inventory USING btree (product_id, location_id);

CREATE UNIQUE INDEX vehicle_damage_reports_pkey ON public.vehicle_damage_reports USING btree (id);

CREATE UNIQUE INDEX vehicles_pkey ON public.vehicles USING btree (id);

CREATE UNIQUE INDEX webshop_carts_pkey ON public.webshop_carts USING btree (id);

CREATE UNIQUE INDEX webshop_customers_customer_number_key ON public.webshop_customers USING btree (customer_number);

CREATE UNIQUE INDEX webshop_customers_pkey ON public.webshop_customers USING btree (id);

CREATE UNIQUE INDEX webshop_orders_order_number_key ON public.webshop_orders USING btree (order_number);

CREATE UNIQUE INDEX webshop_orders_pkey ON public.webshop_orders USING btree (id);

CREATE UNIQUE INDEX webshop_pickup_locations_pkey ON public.webshop_pickup_locations USING btree (id);

CREATE UNIQUE INDEX webshop_product_reviews_pkey ON public.webshop_product_reviews USING btree (id);

CREATE UNIQUE INDEX work_logs_pkey ON public.work_logs USING btree (id);

alter table "public"."camera_events" add constraint "camera_events_pkey" PRIMARY KEY using index "camera_events_pkey";

alter table "public"."camera_settings" add constraint "camera_settings_pkey" PRIMARY KEY using index "camera_settings_pkey";

alter table "public"."cash_movements" add constraint "cash_movements_pkey" PRIMARY KEY using index "cash_movements_pkey";

alter table "public"."chat_messages" add constraint "chat_messages_pkey" PRIMARY KEY using index "chat_messages_pkey";

alter table "public"."delivery_notes" add constraint "delivery_notes_pkey" PRIMARY KEY using index "delivery_notes_pkey";

alter table "public"."documents" add constraint "documents_pkey" PRIMARY KEY using index "documents_pkey";

alter table "public"."email_templates" add constraint "email_templates_pkey" PRIMARY KEY using index "email_templates_pkey";

alter table "public"."employees" add constraint "employees_pkey" PRIMARY KEY using index "employees_pkey";

alter table "public"."feedback" add constraint "feedback_pkey" PRIMARY KEY using index "feedback_pkey";

alter table "public"."inventory" add constraint "inventory_pkey" PRIMARY KEY using index "inventory_pkey";

alter table "public"."invoice_templates" add constraint "invoice_templates_pkey" PRIMARY KEY using index "invoice_templates_pkey";

alter table "public"."invoices" add constraint "invoices_pkey" PRIMARY KEY using index "invoices_pkey";

alter table "public"."locations" add constraint "locations_pkey" PRIMARY KEY using index "locations_pkey";

alter table "public"."network_connections" add constraint "network_connections_pkey" PRIMARY KEY using index "network_connections_pkey";

alter table "public"."network_devices" add constraint "network_devices_pkey" PRIMARY KEY using index "network_devices_pkey";

alter table "public"."network_logs" add constraint "network_logs_pkey" PRIMARY KEY using index "network_logs_pkey";

alter table "public"."notification_settings" add constraint "notification_settings_pkey" PRIMARY KEY using index "notification_settings_pkey";

alter table "public"."notifications" add constraint "notifications_pkey" PRIMARY KEY using index "notifications_pkey";

alter table "public"."orders" add constraint "orders_pkey" PRIMARY KEY using index "orders_pkey";

alter table "public"."partner_companies" add constraint "partner_companies_pkey" PRIMARY KEY using index "partner_companies_pkey";

alter table "public"."partner_users" add constraint "partner_users_pkey" PRIMARY KEY using index "partner_users_pkey";

alter table "public"."partners" add constraint "partners_pkey" PRIMARY KEY using index "partners_pkey";

alter table "public"."payment_items" add constraint "payment_items_pkey" PRIMARY KEY using index "payment_items_pkey";

alter table "public"."payment_methods" add constraint "payment_methods_pkey" PRIMARY KEY using index "payment_methods_pkey";

alter table "public"."payments" add constraint "payments_pkey" PRIMARY KEY using index "payments_pkey";

alter table "public"."pos_return_items" add constraint "pos_return_items_pkey" PRIMARY KEY using index "pos_return_items_pkey";

alter table "public"."pos_returns" add constraint "pos_returns_pkey" PRIMARY KEY using index "pos_returns_pkey";

alter table "public"."pos_sessions" add constraint "pos_sessions_pkey" PRIMARY KEY using index "pos_sessions_pkey";

alter table "public"."pos_transaction_items" add constraint "pos_transaction_items_pkey" PRIMARY KEY using index "pos_transaction_items_pkey";

alter table "public"."pos_transactions" add constraint "pos_transactions_pkey" PRIMARY KEY using index "pos_transactions_pkey";

alter table "public"."product_inventory" add constraint "product_inventory_pkey" PRIMARY KEY using index "product_inventory_pkey";

alter table "public"."production_batches" add constraint "production_batches_pkey" PRIMARY KEY using index "production_batches_pkey";

alter table "public"."production_batches_orders" add constraint "production_batches_orders_pkey" PRIMARY KEY using index "production_batches_orders_pkey";

alter table "public"."production_steps" add constraint "production_steps_pkey" PRIMARY KEY using index "production_steps_pkey";

alter table "public"."products" add constraint "products_pkey" PRIMARY KEY using index "products_pkey";

alter table "public"."profiles" add constraint "profiles_pkey" PRIMARY KEY using index "profiles_pkey";

alter table "public"."recipe_steps" add constraint "recipe_steps_pkey" PRIMARY KEY using index "recipe_steps_pkey";

alter table "public"."recipes" add constraint "recipes_pkey" PRIMARY KEY using index "recipes_pkey";

alter table "public"."scheduled_emails" add constraint "scheduled_emails_pkey" PRIMARY KEY using index "scheduled_emails_pkey";

alter table "public"."schedules" add constraint "schedules_pkey" PRIMARY KEY using index "schedules_pkey";

alter table "public"."security_logs" add constraint "security_logs_pkey" PRIMARY KEY using index "security_logs_pkey";

alter table "public"."sensor_data" add constraint "sensor_data_pkey" PRIMARY KEY using index "sensor_data_pkey";

alter table "public"."sent_emails" add constraint "sent_emails_pkey" PRIMARY KEY using index "sent_emails_pkey";

alter table "public"."settings" add constraint "settings_pkey" PRIMARY KEY using index "settings_pkey";

alter table "public"."store_inventory" add constraint "store_inventory_pkey" PRIMARY KEY using index "store_inventory_pkey";

alter table "public"."stream_sessions" add constraint "stream_sessions_pkey" PRIMARY KEY using index "stream_sessions_pkey";

alter table "public"."survey_questions" add constraint "survey_questions_pkey" PRIMARY KEY using index "survey_questions_pkey";

alter table "public"."survey_responses" add constraint "survey_responses_pkey" PRIMARY KEY using index "survey_responses_pkey";

alter table "public"."surveys" add constraint "surveys_pkey" PRIMARY KEY using index "surveys_pkey";

alter table "public"."transactions" add constraint "transactions_pkey" PRIMARY KEY using index "transactions_pkey";

alter table "public"."vehicle_damage_reports" add constraint "vehicle_damage_reports_pkey" PRIMARY KEY using index "vehicle_damage_reports_pkey";

alter table "public"."vehicles" add constraint "vehicles_pkey" PRIMARY KEY using index "vehicles_pkey";

alter table "public"."webshop_carts" add constraint "webshop_carts_pkey" PRIMARY KEY using index "webshop_carts_pkey";

alter table "public"."webshop_customers" add constraint "webshop_customers_pkey" PRIMARY KEY using index "webshop_customers_pkey";

alter table "public"."webshop_orders" add constraint "webshop_orders_pkey" PRIMARY KEY using index "webshop_orders_pkey";

alter table "public"."webshop_pickup_locations" add constraint "webshop_pickup_locations_pkey" PRIMARY KEY using index "webshop_pickup_locations_pkey";

alter table "public"."webshop_product_reviews" add constraint "webshop_product_reviews_pkey" PRIMARY KEY using index "webshop_product_reviews_pkey";

alter table "public"."work_logs" add constraint "work_logs_pkey" PRIMARY KEY using index "work_logs_pkey";

alter table "public"."camera_events" add constraint "camera_events_acknowledged_by_fkey" FOREIGN KEY (acknowledged_by) REFERENCES auth.users(id) not valid;

alter table "public"."camera_events" validate constraint "camera_events_acknowledged_by_fkey";

alter table "public"."camera_events" add constraint "camera_events_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."camera_events" validate constraint "camera_events_user_id_fkey";

alter table "public"."camera_settings" add constraint "camera_settings_user_id_camera_id_key" UNIQUE using index "camera_settings_user_id_camera_id_key";

alter table "public"."camera_settings" add constraint "camera_settings_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."camera_settings" validate constraint "camera_settings_user_id_fkey";

alter table "public"."cash_movements" add constraint "cash_movements_cashier_id_fkey" FOREIGN KEY (cashier_id) REFERENCES public.profiles(id) not valid;

alter table "public"."cash_movements" validate constraint "cash_movements_cashier_id_fkey";

alter table "public"."cash_movements" add constraint "cash_movements_location_id_fkey" FOREIGN KEY (location_id) REFERENCES public.locations(id) not valid;

alter table "public"."cash_movements" validate constraint "cash_movements_location_id_fkey";

alter table "public"."cash_movements" add constraint "cash_movements_session_id_fkey" FOREIGN KEY (session_id) REFERENCES public.pos_sessions(id) ON DELETE CASCADE not valid;

alter table "public"."cash_movements" validate constraint "cash_movements_session_id_fkey";

alter table "public"."cash_movements" add constraint "cash_movements_type_check" CHECK ((type = ANY (ARRAY['opening'::text, 'closing'::text, 'deposit'::text, 'withdrawal'::text, 'adjustment'::text]))) not valid;

alter table "public"."cash_movements" validate constraint "cash_movements_type_check";

alter table "public"."chat_messages" add constraint "chat_messages_receiver_id_fkey" FOREIGN KEY (receiver_id) REFERENCES public.profiles(id) not valid;

alter table "public"."chat_messages" validate constraint "chat_messages_receiver_id_fkey";

alter table "public"."chat_messages" add constraint "chat_messages_sender_id_fkey" FOREIGN KEY (sender_id) REFERENCES public.profiles(id) not valid;

alter table "public"."chat_messages" validate constraint "chat_messages_sender_id_fkey";

alter table "public"."delivery_notes" add constraint "delivery_notes_batch_id_fkey" FOREIGN KEY (batch_id) REFERENCES public.production_batches(id) not valid;

alter table "public"."delivery_notes" validate constraint "delivery_notes_batch_id_fkey";

alter table "public"."delivery_notes" add constraint "delivery_notes_driver_id_fkey" FOREIGN KEY (driver_id) REFERENCES public.profiles(id) not valid;

alter table "public"."delivery_notes" validate constraint "delivery_notes_driver_id_fkey";

alter table "public"."delivery_notes" add constraint "delivery_notes_location_id_fkey" FOREIGN KEY (location_id) REFERENCES public.locations(id) not valid;

alter table "public"."delivery_notes" validate constraint "delivery_notes_location_id_fkey";

alter table "public"."delivery_notes" add constraint "delivery_notes_order_id_fkey" FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE not valid;

alter table "public"."delivery_notes" validate constraint "delivery_notes_order_id_fkey";

alter table "public"."delivery_notes" add constraint "delivery_notes_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'in_progress'::text, 'delivered'::text, 'cancelled'::text]))) not valid;

alter table "public"."delivery_notes" validate constraint "delivery_notes_status_check";

alter table "public"."delivery_notes" add constraint "delivery_notes_vehicle_id_fkey" FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(id) not valid;

alter table "public"."delivery_notes" validate constraint "delivery_notes_vehicle_id_fkey";

alter table "public"."documents" add constraint "documents_status_check" CHECK ((status = ANY (ARRAY['active'::text, 'archived'::text, 'expired'::text]))) not valid;

alter table "public"."documents" validate constraint "documents_status_check";

alter table "public"."documents" add constraint "documents_type_check" CHECK ((type = ANY (ARRAY['contract'::text, 'invoice'::text, 'permit'::text, 'certificate'::text, 'recipe'::text, 'manual'::text, 'other'::text]))) not valid;

alter table "public"."documents" validate constraint "documents_type_check";

alter table "public"."documents" add constraint "documents_uploaded_by_fkey" FOREIGN KEY (uploaded_by) REFERENCES public.profiles(id) not valid;

alter table "public"."documents" validate constraint "documents_uploaded_by_fkey";

alter table "public"."email_templates" add constraint "email_templates_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.profiles(id) not valid;

alter table "public"."email_templates" validate constraint "email_templates_created_by_fkey";

alter table "public"."employees" add constraint "employees_employee_number_key" UNIQUE using index "employees_employee_number_key";

alter table "public"."employees" add constraint "employees_id_fkey" FOREIGN KEY (id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."employees" validate constraint "employees_id_fkey";

alter table "public"."employees" add constraint "employees_manager_id_fkey" FOREIGN KEY (manager_id) REFERENCES public.profiles(id) not valid;

alter table "public"."employees" validate constraint "employees_manager_id_fkey";

alter table "public"."employees" add constraint "employees_performance_rating_check" CHECK (((performance_rating >= (0)::numeric) AND (performance_rating <= (5)::numeric))) not valid;

alter table "public"."employees" validate constraint "employees_performance_rating_check";

alter table "public"."feedback" add constraint "feedback_responded_by_fkey" FOREIGN KEY (responded_by) REFERENCES public.profiles(id) not valid;

alter table "public"."feedback" validate constraint "feedback_responded_by_fkey";

alter table "public"."feedback" add constraint "feedback_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'in_progress'::text, 'resolved'::text, 'rejected'::text]))) not valid;

alter table "public"."feedback" validate constraint "feedback_status_check";

alter table "public"."feedback" add constraint "feedback_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) not valid;

alter table "public"."feedback" validate constraint "feedback_user_id_fkey";

alter table "public"."inventory" add constraint "inventory_location_id_fkey" FOREIGN KEY (location_id) REFERENCES public.locations(id) not valid;

alter table "public"."inventory" validate constraint "inventory_location_id_fkey";

alter table "public"."invoices" add constraint "fk_invoice_partner" FOREIGN KEY (partner_id) REFERENCES public.partners(id) not valid;

alter table "public"."invoices" validate constraint "fk_invoice_partner";

alter table "public"."invoices" add constraint "invoices_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "public"."invoices" validate constraint "invoices_created_by_fkey";

alter table "public"."invoices" add constraint "invoices_invoice_number_key" UNIQUE using index "invoices_invoice_number_key";

alter table "public"."invoices" add constraint "invoices_order_id_fkey" FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE SET NULL not valid;

alter table "public"."invoices" validate constraint "invoices_order_id_fkey";

alter table "public"."locations" add constraint "locations_status_check" CHECK ((status = ANY (ARRAY['active'::text, 'inactive'::text]))) not valid;

alter table "public"."locations" validate constraint "locations_status_check";

alter table "public"."locations" add constraint "locations_type_check" CHECK ((type = ANY (ARRAY['store'::text, 'warehouse'::text, 'production'::text, 'partner'::text]))) not valid;

alter table "public"."locations" validate constraint "locations_type_check";

alter table "public"."network_connections" add constraint "network_connections_status_check" CHECK ((status = ANY (ARRAY['connected'::text, 'disconnected'::text]))) not valid;

alter table "public"."network_connections" validate constraint "network_connections_status_check";

alter table "public"."network_devices" add constraint "network_devices_status_check" CHECK ((status = ANY (ARRAY['online'::text, 'offline'::text, 'connecting'::text]))) not valid;

alter table "public"."network_devices" validate constraint "network_devices_status_check";

alter table "public"."network_logs" add constraint "network_logs_level_check" CHECK ((level = ANY (ARRAY['info'::text, 'success'::text, 'warning'::text, 'error'::text]))) not valid;

alter table "public"."network_logs" validate constraint "network_logs_level_check";

alter table "public"."notification_settings" add constraint "notification_settings_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."notification_settings" validate constraint "notification_settings_user_id_fkey";

alter table "public"."notifications" add constraint "notifications_priority_check" CHECK ((priority = ANY (ARRAY['low'::text, 'normal'::text, 'high'::text, 'urgent'::text]))) not valid;

alter table "public"."notifications" validate constraint "notifications_priority_check";

alter table "public"."notifications" add constraint "notifications_type_check" CHECK ((type = ANY (ARRAY['info'::text, 'warning'::text, 'error'::text, 'success'::text]))) not valid;

alter table "public"."notifications" validate constraint "notifications_type_check";

alter table "public"."notifications" add constraint "notifications_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) not valid;

alter table "public"."notifications" validate constraint "notifications_user_id_fkey";

alter table "public"."orders" add constraint "orders_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.profiles(id) not valid;

alter table "public"."orders" validate constraint "orders_created_by_fkey";

alter table "public"."orders" add constraint "orders_driver_id_fkey" FOREIGN KEY (driver_id) REFERENCES public.profiles(id) not valid;

alter table "public"."orders" validate constraint "orders_driver_id_fkey";

alter table "public"."orders" add constraint "orders_location_id_fkey" FOREIGN KEY (location_id) REFERENCES public.locations(id) not valid;

alter table "public"."orders" validate constraint "orders_location_id_fkey";

alter table "public"."orders" add constraint "orders_order_number_key" UNIQUE using index "orders_order_number_key";

alter table "public"."orders" add constraint "orders_payment_status_check" CHECK ((payment_status = ANY (ARRAY['pending'::text, 'paid'::text, 'failed'::text, 'refunded'::text]))) not valid;

alter table "public"."orders" validate constraint "orders_payment_status_check";

alter table "public"."orders" add constraint "orders_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'processing'::text, 'completed'::text, 'cancelled'::text, 'failed'::text, 'delivered'::text, 'returned'::text, 'new'::text]))) not valid;

alter table "public"."orders" validate constraint "orders_status_check";

alter table "public"."orders" add constraint "orders_vehicle_id_fkey" FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(id) not valid;

alter table "public"."orders" validate constraint "orders_vehicle_id_fkey";

alter table "public"."partner_companies" add constraint "partner_companies_status_check" CHECK ((status = ANY (ARRAY['active'::text, 'inactive'::text, 'suspended'::text]))) not valid;

alter table "public"."partner_companies" validate constraint "partner_companies_status_check";

alter table "public"."partner_users" add constraint "partner_users_partner_id_fkey" FOREIGN KEY (partner_id) REFERENCES public.partner_companies(id) not valid;

alter table "public"."partner_users" validate constraint "partner_users_partner_id_fkey";

alter table "public"."partner_users" add constraint "partner_users_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) not valid;

alter table "public"."partner_users" validate constraint "partner_users_user_id_fkey";

alter table "public"."payment_items" add constraint "fk_payment_items_payment_id" FOREIGN KEY (payment_id) REFERENCES public.payments(id) ON DELETE CASCADE not valid;

alter table "public"."payment_items" validate constraint "fk_payment_items_payment_id";

alter table "public"."payments" add constraint "fk_payments_user_id" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."payments" validate constraint "fk_payments_user_id";

alter table "public"."payments" add constraint "payments_payment_method_check" CHECK (((payment_method)::text = ANY ((ARRAY['cash'::character varying, 'card'::character varying, 'transfer'::character varying, 'other'::character varying])::text[]))) not valid;

alter table "public"."payments" validate constraint "payments_payment_method_check";

alter table "public"."payments" add constraint "payments_status_check" CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'completed'::character varying, 'failed'::character varying, 'refunded'::character varying])::text[]))) not valid;

alter table "public"."payments" validate constraint "payments_status_check";

alter table "public"."payments" add constraint "payments_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."payments" validate constraint "payments_user_id_fkey";

alter table "public"."pos_return_items" add constraint "pos_return_items_product_id_fkey" FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE not valid;

alter table "public"."pos_return_items" validate constraint "pos_return_items_product_id_fkey";

alter table "public"."pos_return_items" add constraint "pos_return_items_quantity_check" CHECK ((quantity > 0)) not valid;

alter table "public"."pos_return_items" validate constraint "pos_return_items_quantity_check";

alter table "public"."pos_return_items" add constraint "pos_return_items_return_id_fkey" FOREIGN KEY (return_id) REFERENCES public.pos_returns(id) ON DELETE CASCADE not valid;

alter table "public"."pos_return_items" validate constraint "pos_return_items_return_id_fkey";

alter table "public"."pos_returns" add constraint "pos_returns_cashier_id_fkey" FOREIGN KEY (cashier_id) REFERENCES public.profiles(id) not valid;

alter table "public"."pos_returns" validate constraint "pos_returns_cashier_id_fkey";

alter table "public"."pos_returns" add constraint "pos_returns_location_id_fkey" FOREIGN KEY (location_id) REFERENCES public.locations(id) not valid;

alter table "public"."pos_returns" validate constraint "pos_returns_location_id_fkey";

alter table "public"."pos_returns" add constraint "pos_returns_payment_method_check" CHECK ((payment_method = ANY (ARRAY['cash'::text, 'card'::text, 'transfer'::text, 'other'::text]))) not valid;

alter table "public"."pos_returns" validate constraint "pos_returns_payment_method_check";

alter table "public"."pos_returns" add constraint "pos_returns_session_id_fkey" FOREIGN KEY (session_id) REFERENCES public.pos_sessions(id) not valid;

alter table "public"."pos_returns" validate constraint "pos_returns_session_id_fkey";

alter table "public"."pos_returns" add constraint "pos_returns_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'completed'::text, 'voided'::text]))) not valid;

alter table "public"."pos_returns" validate constraint "pos_returns_status_check";

alter table "public"."pos_sessions" add constraint "pos_sessions_cashier_id_fkey" FOREIGN KEY (cashier_id) REFERENCES public.profiles(id) not valid;

alter table "public"."pos_sessions" validate constraint "pos_sessions_cashier_id_fkey";

alter table "public"."pos_sessions" add constraint "pos_sessions_location_id_fkey" FOREIGN KEY (location_id) REFERENCES public.locations(id) not valid;

alter table "public"."pos_sessions" validate constraint "pos_sessions_location_id_fkey";

alter table "public"."pos_sessions" add constraint "pos_sessions_status_check" CHECK ((status = ANY (ARRAY['open'::text, 'closed'::text]))) not valid;

alter table "public"."pos_sessions" validate constraint "pos_sessions_status_check";

alter table "public"."pos_transaction_items" add constraint "pos_transaction_items_product_id_fkey" FOREIGN KEY (product_id) REFERENCES public.products(id) not valid;

alter table "public"."pos_transaction_items" validate constraint "pos_transaction_items_product_id_fkey";

alter table "public"."pos_transaction_items" add constraint "pos_transaction_items_quantity_check" CHECK ((quantity > 0)) not valid;

alter table "public"."pos_transaction_items" validate constraint "pos_transaction_items_quantity_check";

alter table "public"."pos_transaction_items" add constraint "pos_transaction_items_total_price_check" CHECK ((total_price >= (0)::numeric)) not valid;

alter table "public"."pos_transaction_items" validate constraint "pos_transaction_items_total_price_check";

alter table "public"."pos_transaction_items" add constraint "pos_transaction_items_transaction_id_fkey" FOREIGN KEY (transaction_id) REFERENCES public.pos_transactions(id) ON DELETE CASCADE not valid;

alter table "public"."pos_transaction_items" validate constraint "pos_transaction_items_transaction_id_fkey";

alter table "public"."pos_transaction_items" add constraint "pos_transaction_items_unit_price_check" CHECK ((unit_price >= (0)::numeric)) not valid;

alter table "public"."pos_transaction_items" validate constraint "pos_transaction_items_unit_price_check";

alter table "public"."pos_transactions" add constraint "pos_transactions_cashier_id_fkey" FOREIGN KEY (cashier_id) REFERENCES public.profiles(id) not valid;

alter table "public"."pos_transactions" validate constraint "pos_transactions_cashier_id_fkey";

alter table "public"."pos_transactions" add constraint "pos_transactions_location_id_fkey" FOREIGN KEY (location_id) REFERENCES public.locations(id) not valid;

alter table "public"."pos_transactions" validate constraint "pos_transactions_location_id_fkey";

alter table "public"."pos_transactions" add constraint "pos_transactions_payment_method_check" CHECK ((payment_method = ANY (ARRAY['cash'::text, 'card'::text, 'transfer'::text, 'other'::text]))) not valid;

alter table "public"."pos_transactions" validate constraint "pos_transactions_payment_method_check";

alter table "public"."pos_transactions" add constraint "pos_transactions_session_id_fkey" FOREIGN KEY (session_id) REFERENCES public.pos_sessions(id) ON DELETE CASCADE not valid;

alter table "public"."pos_transactions" validate constraint "pos_transactions_session_id_fkey";

alter table "public"."pos_transactions" add constraint "pos_transactions_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'completed'::text, 'voided'::text]))) not valid;

alter table "public"."pos_transactions" validate constraint "pos_transactions_status_check";

alter table "public"."pos_transactions" add constraint "pos_transactions_transaction_number_key" UNIQUE using index "pos_transactions_transaction_number_key";

alter table "public"."product_inventory" add constraint "product_inventory_location_id_fkey" FOREIGN KEY (location_id) REFERENCES public.locations(id) not valid;

alter table "public"."product_inventory" validate constraint "product_inventory_location_id_fkey";

alter table "public"."product_inventory" add constraint "product_inventory_product_id_fkey" FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE not valid;

alter table "public"."product_inventory" validate constraint "product_inventory_product_id_fkey";

alter table "public"."product_inventory" add constraint "product_inventory_product_location_unique" UNIQUE using index "product_inventory_product_location_unique";

alter table "public"."production_batches" add constraint "fk_production_batches_recipe_id" FOREIGN KEY (recipe_id) REFERENCES public.products(id) ON DELETE SET NULL not valid;

alter table "public"."production_batches" validate constraint "fk_production_batches_recipe_id";

alter table "public"."production_batches" add constraint "production_batches_baker_id_fkey" FOREIGN KEY (baker_id) REFERENCES public.profiles(id) not valid;

alter table "public"."production_batches" validate constraint "production_batches_baker_id_fkey";

alter table "public"."production_batches" add constraint "production_batches_batch_number_key" UNIQUE using index "production_batches_batch_number_key";

alter table "public"."production_batches" add constraint "production_batches_location_id_fkey" FOREIGN KEY (location_id) REFERENCES public.locations(id) not valid;

alter table "public"."production_batches" validate constraint "production_batches_location_id_fkey";

alter table "public"."production_batches" add constraint "production_batches_quality_score_check" CHECK (((quality_score >= 0) AND (quality_score <= 100))) not valid;

alter table "public"."production_batches" validate constraint "production_batches_quality_score_check";

alter table "public"."production_batches" add constraint "production_batches_status_check" CHECK ((status = ANY (ARRAY['planned'::text, 'in_progress'::text, 'completed'::text, 'failed'::text]))) not valid;

alter table "public"."production_batches" validate constraint "production_batches_status_check";

alter table "public"."production_batches_orders" add constraint "production_batches_orders_batch_id_fkey" FOREIGN KEY (batch_id) REFERENCES public.production_batches(id) ON DELETE CASCADE not valid;

alter table "public"."production_batches_orders" validate constraint "production_batches_orders_batch_id_fkey";

alter table "public"."production_batches_orders" add constraint "production_batches_orders_batch_id_order_id_key" UNIQUE using index "production_batches_orders_batch_id_order_id_key";

alter table "public"."production_batches_orders" add constraint "production_batches_orders_order_id_fkey" FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE not valid;

alter table "public"."production_batches_orders" validate constraint "production_batches_orders_order_id_fkey";

alter table "public"."production_steps" add constraint "fk_production_steps_recipe_id" FOREIGN KEY (recipe_id) REFERENCES public.recipes(id) ON DELETE SET NULL not valid;

alter table "public"."production_steps" validate constraint "fk_production_steps_recipe_id";

alter table "public"."production_steps" add constraint "production_steps_batch_id_fkey" FOREIGN KEY (batch_id) REFERENCES public.production_batches(id) ON DELETE CASCADE not valid;

alter table "public"."production_steps" validate constraint "production_steps_batch_id_fkey";

alter table "public"."production_steps" add constraint "production_steps_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "public"."production_steps" validate constraint "production_steps_created_by_fkey";

alter table "public"."production_steps" add constraint "production_steps_recipe_id_fkey" FOREIGN KEY (recipe_id) REFERENCES public.products(id) ON DELETE CASCADE not valid;

alter table "public"."production_steps" validate constraint "production_steps_recipe_id_fkey";

alter table "public"."production_steps" add constraint "production_steps_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'in_progress'::text, 'completed'::text]))) not valid;

alter table "public"."production_steps" validate constraint "production_steps_status_check";

alter table "public"."products" add constraint "products_base_recipe_id_fkey" FOREIGN KEY (base_recipe_id) REFERENCES public.recipes(id) not valid;

alter table "public"."products" validate constraint "products_base_recipe_id_fkey";

alter table "public"."products" add constraint "products_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.profiles(id) not valid;

alter table "public"."products" validate constraint "products_created_by_fkey";

alter table "public"."profiles" add constraint "profiles_default_location_id_fkey" FOREIGN KEY (default_location_id) REFERENCES public.locations(id) not valid;

alter table "public"."profiles" validate constraint "profiles_default_location_id_fkey";

alter table "public"."profiles" add constraint "profiles_id_fkey" FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."profiles" validate constraint "profiles_id_fkey";

alter table "public"."profiles" add constraint "profiles_role_check" CHECK ((role = ANY (ARRAY['admin'::text, 'salesperson'::text, 'driver'::text, 'baker'::text, 'partner'::text]))) not valid;

alter table "public"."profiles" validate constraint "profiles_role_check";

alter table "public"."profiles" add constraint "profiles_status_check" CHECK ((status = ANY (ARRAY['active'::text, 'inactive'::text]))) not valid;

alter table "public"."profiles" validate constraint "profiles_status_check";

alter table "public"."recipe_steps" add constraint "recipe_steps_recipe_id_fkey" FOREIGN KEY (recipe_id) REFERENCES public.products(id) ON DELETE CASCADE not valid;

alter table "public"."recipe_steps" validate constraint "recipe_steps_recipe_id_fkey";

alter table "public"."recipes" add constraint "recipes_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.profiles(id) not valid;

alter table "public"."recipes" validate constraint "recipes_created_by_fkey";

alter table "public"."recipes" add constraint "recipes_difficulty_check" CHECK ((difficulty = ANY (ARRAY['easy'::text, 'medium'::text, 'hard'::text]))) not valid;

alter table "public"."recipes" validate constraint "recipes_difficulty_check";

alter table "public"."scheduled_emails" add constraint "scheduled_emails_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.profiles(id) not valid;

alter table "public"."scheduled_emails" validate constraint "scheduled_emails_created_by_fkey";

alter table "public"."scheduled_emails" add constraint "scheduled_emails_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'sent'::text, 'cancelled'::text, 'failed'::text]))) not valid;

alter table "public"."scheduled_emails" validate constraint "scheduled_emails_status_check";

alter table "public"."scheduled_emails" add constraint "scheduled_emails_template_id_fkey" FOREIGN KEY (template_id) REFERENCES public.email_templates(id) not valid;

alter table "public"."scheduled_emails" validate constraint "scheduled_emails_template_id_fkey";

alter table "public"."schedules" add constraint "schedules_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.profiles(id) not valid;

alter table "public"."schedules" validate constraint "schedules_created_by_fkey";

alter table "public"."schedules" add constraint "schedules_employee_id_fkey" FOREIGN KEY (employee_id) REFERENCES public.profiles(id) not valid;

alter table "public"."schedules" validate constraint "schedules_employee_id_fkey";

alter table "public"."schedules" add constraint "schedules_location_id_fkey" FOREIGN KEY (location_id) REFERENCES public.locations(id) not valid;

alter table "public"."schedules" validate constraint "schedules_location_id_fkey";

alter table "public"."schedules" add constraint "schedules_shift_type_check" CHECK ((shift_type = ANY (ARRAY['morning'::text, 'day'::text, 'afternoon'::text, 'night'::text]))) not valid;

alter table "public"."schedules" validate constraint "schedules_shift_type_check";

alter table "public"."schedules" add constraint "schedules_status_check" CHECK ((status = ANY (ARRAY['scheduled'::text, 'confirmed'::text, 'completed'::text, 'absent'::text, 'cancelled'::text]))) not valid;

alter table "public"."schedules" validate constraint "schedules_status_check";

alter table "public"."security_logs" add constraint "security_logs_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."security_logs" validate constraint "security_logs_user_id_fkey";

alter table "public"."sensor_data" add constraint "sensor_data_location_id_fkey" FOREIGN KEY (location_id) REFERENCES public.locations(id) not valid;

alter table "public"."sensor_data" validate constraint "sensor_data_location_id_fkey";

alter table "public"."sent_emails" add constraint "sent_emails_sent_by_fkey" FOREIGN KEY (sent_by) REFERENCES public.profiles(id) not valid;

alter table "public"."sent_emails" validate constraint "sent_emails_sent_by_fkey";

alter table "public"."sent_emails" add constraint "sent_emails_status_check" CHECK ((status = ANY (ARRAY['sent'::text, 'delivered'::text, 'failed'::text, 'bounced'::text, 'opened'::text]))) not valid;

alter table "public"."sent_emails" validate constraint "sent_emails_status_check";

alter table "public"."sent_emails" add constraint "sent_emails_template_id_fkey" FOREIGN KEY (template_id) REFERENCES public.email_templates(id) not valid;

alter table "public"."sent_emails" validate constraint "sent_emails_template_id_fkey";

alter table "public"."settings" add constraint "settings_category_key_key" UNIQUE using index "settings_category_key_key";

alter table "public"."store_inventory" add constraint "store_inventory_location_id_fkey" FOREIGN KEY (location_id) REFERENCES public.locations(id) not valid;

alter table "public"."store_inventory" validate constraint "store_inventory_location_id_fkey";

alter table "public"."store_inventory" add constraint "store_inventory_product_id_fkey" FOREIGN KEY (product_id) REFERENCES public.products(id) not valid;

alter table "public"."store_inventory" validate constraint "store_inventory_product_id_fkey";

alter table "public"."store_inventory" add constraint "unique_product_location" UNIQUE using index "unique_product_location";

alter table "public"."stream_sessions" add constraint "stream_sessions_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."stream_sessions" validate constraint "stream_sessions_user_id_fkey";

alter table "public"."survey_questions" add constraint "survey_questions_survey_id_fkey" FOREIGN KEY (survey_id) REFERENCES public.surveys(id) ON DELETE CASCADE not valid;

alter table "public"."survey_questions" validate constraint "survey_questions_survey_id_fkey";

alter table "public"."survey_questions" add constraint "survey_questions_type_check" CHECK ((type = ANY (ARRAY['text'::text, 'multiple_choice'::text, 'checkbox'::text, 'rating'::text, 'date'::text]))) not valid;

alter table "public"."survey_questions" validate constraint "survey_questions_type_check";

alter table "public"."survey_responses" add constraint "survey_responses_question_id_fkey" FOREIGN KEY (question_id) REFERENCES public.survey_questions(id) ON DELETE CASCADE not valid;

alter table "public"."survey_responses" validate constraint "survey_responses_question_id_fkey";

alter table "public"."survey_responses" add constraint "survey_responses_survey_id_fkey" FOREIGN KEY (survey_id) REFERENCES public.surveys(id) ON DELETE CASCADE not valid;

alter table "public"."survey_responses" validate constraint "survey_responses_survey_id_fkey";

alter table "public"."survey_responses" add constraint "survey_responses_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) not valid;

alter table "public"."survey_responses" validate constraint "survey_responses_user_id_fkey";

alter table "public"."surveys" add constraint "surveys_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.profiles(id) not valid;

alter table "public"."surveys" validate constraint "surveys_created_by_fkey";

alter table "public"."surveys" add constraint "surveys_status_check" CHECK ((status = ANY (ARRAY['draft'::text, 'active'::text, 'completed'::text, 'archived'::text]))) not valid;

alter table "public"."surveys" validate constraint "surveys_status_check";

alter table "public"."vehicle_damage_reports" add constraint "vehicle_damage_reports_reporter_id_fkey" FOREIGN KEY (reporter_id) REFERENCES public.profiles(id) not valid;

alter table "public"."vehicle_damage_reports" validate constraint "vehicle_damage_reports_reporter_id_fkey";

alter table "public"."vehicle_damage_reports" add constraint "vehicle_damage_reports_status_check" CHECK ((status = ANY (ARRAY['reported'::text, 'in_review'::text, 'approved'::text, 'rejected'::text, 'fixed'::text]))) not valid;

alter table "public"."vehicle_damage_reports" validate constraint "vehicle_damage_reports_status_check";

alter table "public"."vehicle_damage_reports" add constraint "vehicle_damage_reports_vehicle_id_fkey" FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(id) ON DELETE CASCADE not valid;

alter table "public"."vehicle_damage_reports" validate constraint "vehicle_damage_reports_vehicle_id_fkey";

alter table "public"."vehicles" add constraint "vehicles_driver_id_fkey" FOREIGN KEY (driver_id) REFERENCES public.profiles(id) not valid;

alter table "public"."vehicles" validate constraint "vehicles_driver_id_fkey";

alter table "public"."vehicles" add constraint "vehicles_location_id_fkey" FOREIGN KEY (location_id) REFERENCES public.locations(id) not valid;

alter table "public"."vehicles" validate constraint "vehicles_location_id_fkey";

alter table "public"."vehicles" add constraint "vehicles_status_check" CHECK ((status = ANY (ARRAY['active'::text, 'inactive'::text, 'maintenance'::text]))) not valid;

alter table "public"."vehicles" validate constraint "vehicles_status_check";

alter table "public"."webshop_carts" add constraint "webshop_carts_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."webshop_carts" validate constraint "webshop_carts_customer_id_fkey";

alter table "public"."webshop_customers" add constraint "webshop_customers_customer_number_key" UNIQUE using index "webshop_customers_customer_number_key";

alter table "public"."webshop_customers" add constraint "webshop_customers_id_fkey" FOREIGN KEY (id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."webshop_customers" validate constraint "webshop_customers_id_fkey";

alter table "public"."webshop_orders" add constraint "webshop_orders_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES public.profiles(id) not valid;

alter table "public"."webshop_orders" validate constraint "webshop_orders_customer_id_fkey";

alter table "public"."webshop_orders" add constraint "webshop_orders_order_number_key" UNIQUE using index "webshop_orders_order_number_key";

alter table "public"."webshop_orders" add constraint "webshop_orders_payment_status_check" CHECK ((payment_status = ANY (ARRAY['pending'::text, 'paid'::text, 'failed'::text, 'refunded'::text]))) not valid;

alter table "public"."webshop_orders" validate constraint "webshop_orders_payment_status_check";

alter table "public"."webshop_orders" add constraint "webshop_orders_pickup_location_id_fkey" FOREIGN KEY (pickup_location_id) REFERENCES public.locations(id) not valid;

alter table "public"."webshop_orders" validate constraint "webshop_orders_pickup_location_id_fkey";

alter table "public"."webshop_orders" add constraint "webshop_orders_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'confirmed'::text, 'in_production'::text, 'ready'::text, 'completed'::text, 'cancelled'::text]))) not valid;

alter table "public"."webshop_orders" validate constraint "webshop_orders_status_check";

alter table "public"."webshop_product_reviews" add constraint "webshop_product_reviews_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES public.profiles(id) not valid;

alter table "public"."webshop_product_reviews" validate constraint "webshop_product_reviews_customer_id_fkey";

alter table "public"."webshop_product_reviews" add constraint "webshop_product_reviews_product_id_fkey" FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE not valid;

alter table "public"."webshop_product_reviews" validate constraint "webshop_product_reviews_product_id_fkey";

alter table "public"."webshop_product_reviews" add constraint "webshop_product_reviews_rating_check" CHECK (((rating >= 1) AND (rating <= 5))) not valid;

alter table "public"."webshop_product_reviews" validate constraint "webshop_product_reviews_rating_check";

alter table "public"."work_logs" add constraint "work_logs_employee_id_fkey" FOREIGN KEY (employee_id) REFERENCES public.profiles(id) not valid;

alter table "public"."work_logs" validate constraint "work_logs_employee_id_fkey";

alter table "public"."work_logs" add constraint "work_logs_status_check" CHECK ((status = ANY (ARRAY['active'::text, 'completed'::text, 'cancelled'::text]))) not valid;

alter table "public"."work_logs" validate constraint "work_logs_status_check";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.add_stock_on_return()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    UPDATE public.store_inventory
    SET current_stock = current_stock + NEW.quantity
    WHERE 
        product_id = NEW.product_id AND 
        location_id = (SELECT location_id FROM public.pos_returns WHERE id = NEW.return_id);

    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.calculate_batch_ingredients(batch_id uuid)
 RETURNS TABLE(ingredient_name text, required_amount numeric, unit text)
 LANGUAGE plpgsql
AS $function$
DECLARE
  recipe_id UUID;
  batch_size INTEGER;
  recipe_ingredients JSONB;
BEGIN
  -- Get the recipe ID and batch size
  SELECT pb.recipe_id, pb.batch_size INTO recipe_id, batch_size
  FROM production_batches pb
  WHERE pb.id = batch_id;
  
  -- Get the recipe ingredients
  SELECT p.ingredients INTO recipe_ingredients
  FROM products p
  WHERE p.id = recipe_id;
  
  -- Calculate required ingredients based on batch size
  RETURN QUERY
  SELECT 
    (ingredient->>'name')::TEXT AS ingredient_name,
    (ingredient->>'amount')::NUMERIC * batch_size AS required_amount,
    (ingredient->>'unit')::TEXT AS unit
  FROM jsonb_array_elements(recipe_ingredients) AS ingredient;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.calculate_pay(hours_worked numeric, hourly_wage numeric)
 RETURNS numeric
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN hours_worked * hourly_wage;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.calculate_payment_from_work_logs(employee_id uuid, start_date date, end_date date)
 RETURNS TABLE(total_hours numeric, hourly_wage numeric, total_amount numeric, work_sessions integer)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    employee_wage NUMERIC;
    total_minutes INTEGER := 0;
    calculated_hours NUMERIC;
    session_count INTEGER := 0;
BEGIN
    -- Ellenőrizzük, hogy létezik-e az alkalmazott
    SELECT p.hourly_wage INTO employee_wage 
    FROM profiles p 
    WHERE p.id = employee_id;
    
    IF employee_wage IS NULL THEN
        RAISE EXCEPTION 'Employee not found or hourly wage not set for employee_id: %', employee_id;
    END IF;
    
    -- Kiszámoljuk az összes munkaidőt a megadott időszakban
    SELECT 
        COALESCE(SUM(
            CASE 
                WHEN wl.end_time IS NOT NULL THEN 
                    EXTRACT(EPOCH FROM (wl.end_time - wl.start_time)) / 60
                WHEN wl.duration IS NOT NULL THEN 
                    wl.duration
                ELSE 0
            END
        ), 0)::INTEGER,
        COUNT(*)
    INTO total_minutes, session_count
    FROM work_logs wl
    WHERE wl.employee_id = calculate_payment_from_work_logs.employee_id
      AND wl.status = 'completed'
      AND DATE(wl.start_time) >= start_date
      AND DATE(wl.start_time) <= end_date;
    
    -- Perceket órákra konvertáljuk
    calculated_hours := total_minutes / 60.0;
    
    -- Visszaadjuk az eredményeket
    RETURN QUERY SELECT 
        calculated_hours,
        employee_wage,
        calculated_hours * employee_wage,
        session_count;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.check_active_session(p_location_id uuid, p_cashier_id uuid)
 RETURNS TABLE(session_id uuid, is_active boolean)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT ps.id, ps.status = 'open' as is_active
  FROM pos_sessions ps
  WHERE ps.location_id = p_location_id 
    AND ps.cashier_id = p_cashier_id
    AND ps.status = 'open'
  ORDER BY ps.opened_at DESC
  LIMIT 1;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.check_product_exists()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    matching_product_count INTEGER;
BEGIN
    -- Pontos ID egyezés vagy részleges egyezés vizsgálata
    SELECT COUNT(*) INTO matching_product_count
    FROM products 
    WHERE 
        id = NEW.product_id OR 
        name = (SELECT name FROM products WHERE id = NEW.product_id);
    
    IF matching_product_count = 0 THEN
        RAISE EXCEPTION 'Nem létező termék: %', NEW.product_id 
        USING ERRCODE = 'P0001', 
        DETAIL = 'Ellenőrizze a termék-azonosítót és nevét';
    END IF;
    
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.cleanup_expired_carts()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
  DELETE FROM webshop_carts
  WHERE expires_at < now();
END;
$function$
;

CREATE OR REPLACE FUNCTION public.cleanup_old_sensor_data()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  DELETE FROM sensor_data
  WHERE created_at < (NOW() - INTERVAL '24 hours');
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.cleanup_old_stream_sessions()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Deaktiválja a 1 órás inaktivitás után a session-öket
  UPDATE stream_sessions 
  SET active = false, ended_at = now()
  WHERE active = true 
    AND last_activity < now() - interval '1 hour';
    
  -- Töröl 24 órás inaktív session-öket
  DELETE FROM stream_sessions
  WHERE active = false 
    AND (ended_at < now() - interval '24 hours' OR started_at < now() - interval '24 hours');
END;
$function$
;

CREATE OR REPLACE FUNCTION public.clear_database()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    table_name text;
BEGIN
    -- Delete data from all tables except auth tables and admin users
    
    -- Delete from vehicle_damage_reports if it exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'vehicle_damage_reports') THEN
        DELETE FROM vehicle_damage_reports;
    END IF;
    
    -- Delete from vehicles if it exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'vehicles') THEN
        DELETE FROM vehicles;
    END IF;
    
    -- Delete from production_steps if it exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'production_steps') THEN
        DELETE FROM production_steps;
    END IF;
    
    -- Delete from recipe_steps if it exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'recipe_steps') THEN
        DELETE FROM recipe_steps;
    END IF;
    
    -- Delete from order_items if it exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'order_items') THEN
        DELETE FROM order_items;
    END IF;
    
    -- Delete from orders if it exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'orders') THEN
        DELETE FROM orders;
    END IF;
    
    -- Delete from sensor_data if it exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'sensor_data') THEN
        DELETE FROM sensor_data;
    END IF;
    
    -- Delete from documents if it exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'documents') THEN
        DELETE FROM documents;
    END IF;
    
    -- Delete from notifications if it exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'notifications') THEN
        DELETE FROM notifications;
    END IF;
    
    -- Delete from settings where not critical if it exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'settings') THEN
        DELETE FROM settings WHERE category NOT IN ('auth', 'system');
    END IF;
    
    -- Delete from inventory if it exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'inventory') THEN
        DELETE FROM inventory;
    END IF;
    
    -- Delete from production_batches if it exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'production_batches') THEN
        DELETE FROM production_batches;
    END IF;
    
    -- Delete from recipes if it exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'recipes') THEN
        DELETE FROM recipes;
    END IF;
    
    -- Delete from products if it exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'products') THEN
        DELETE FROM products;
    END IF;
    
    -- Delete from feedback if it exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'feedback') THEN
        DELETE FROM feedback;
    END IF;
    
    -- Delete from work_logs if it exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'work_logs') THEN
        DELETE FROM work_logs;
    END IF;
    
    -- Delete from schedules if it exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'schedules') THEN
        DELETE FROM schedules;
    END IF;
    
    -- Delete from survey_responses if it exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'survey_responses') THEN
        DELETE FROM survey_responses;
    END IF;
    
    -- Delete from survey_questions if it exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'survey_questions') THEN
        DELETE FROM survey_questions;
    END IF;
    
    -- Delete from surveys if it exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'surveys') THEN
        DELETE FROM surveys;
    END IF;
    
    -- Delete from locations if it exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'locations') THEN
        DELETE FROM locations;
    END IF;
    
    -- Delete from employees if it exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'employees') THEN
        DELETE FROM employees;
    END IF;
    
    -- Keep profiles for admin users only
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'profiles') THEN
        DELETE FROM profiles WHERE role != 'admin';
    END IF;
    
    RAISE NOTICE 'Database cleared successfully. Admin users preserved.';
END;
$function$
;

CREATE OR REPLACE FUNCTION public.clear_mock_data()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Delete mock data from various tables
  DELETE FROM orders WHERE id != '00000000-0000-0000-0000-000000000000';
  DELETE FROM order_items WHERE id != '00000000-0000-0000-0000-000000000000';
  DELETE FROM production_batches WHERE id != '00000000-0000-0000-0000-000000000000';
  DELETE FROM production_steps WHERE id != '00000000-0000-0000-0000-000000000000';
  DELETE FROM inventory WHERE id != '00000000-0000-0000-0000-000000000000';
  DELETE FROM work_logs WHERE id != '00000000-0000-0000-0000-000000000000';
  DELETE FROM schedules WHERE id != '00000000-0000-0000-0000-000000000000';
  DELETE FROM notifications WHERE id != '00000000-0000-0000-0000-000000000000';
  DELETE FROM feedback WHERE id != '00000000-0000-0000-0000-000000000000';
  DELETE FROM documents WHERE id != '00000000-0000-0000-0000-000000000000';
  DELETE FROM sensor_data WHERE id != '00000000-0000-0000-0000-000000000000';
  DELETE FROM vehicles WHERE id != '00000000-0000-0000-0000-000000000000';
  DELETE FROM locations WHERE id != '00000000-0000-0000-0000-000000000000';
  DELETE FROM recipes WHERE id != '00000000-0000-0000-0000-000000000000';
  DELETE FROM products WHERE id != '00000000-0000-0000-0000-000000000000';
  DELETE FROM surveys WHERE id != '00000000-0000-0000-0000-000000000000';
  DELETE FROM survey_questions WHERE id != '00000000-0000-0000-0000-000000000000';
  DELETE FROM survey_responses WHERE id != '00000000-0000-0000-0000-000000000000';
END;
$function$
;

CREATE OR REPLACE FUNCTION public.clear_session_storage()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    -- This function doesn't actually modify the database
    -- It's a placeholder for client-side functionality
    RAISE NOTICE 'Session storage clear function created';
END;
$function$
;

CREATE OR REPLACE FUNCTION public.clear_table(table_name text)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    EXECUTE 'DELETE FROM ' || quote_ident(table_name);
    RAISE NOTICE 'Table % cleared successfully', table_name;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.create_delivery_note(p_order_id uuid DEFAULT NULL::uuid, p_batch_id uuid DEFAULT NULL::uuid, p_driver_id uuid DEFAULT NULL::uuid, p_vehicle_id uuid DEFAULT NULL::uuid, p_location_id uuid DEFAULT NULL::uuid, p_customer_name text DEFAULT NULL::text, p_customer_address text DEFAULT NULL::text, p_items jsonb DEFAULT '[]'::jsonb, p_status text DEFAULT 'pending'::text)
 RETURNS TABLE(delivery_note_id uuid, order_number text, status text)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  v_delivery_note_id UUID;
  v_order_number TEXT;
BEGIN
  -- Generate a unique delivery note number
  v_order_number := 'DN-' || to_char(NOW(), 'YYYYMMDD') || '-' || 
                    LPAD(
                      CAST(
                        COALESCE(
                          (SELECT COUNT(*) + 1 FROM delivery_notes 
                           WHERE created_at::date = CURRENT_DATE), 
                          1
                        ) AS TEXT
                      ), 
                      4, '0'
                    );

  -- Insert the delivery note
  INSERT INTO delivery_notes (
    order_id,
    batch_id,
    driver_id,
    vehicle_id,
    location_id,
    customer_name,
    customer_address,
    items,
    status,
    order_number
  ) VALUES (
    p_order_id,
    p_batch_id,
    p_driver_id,
    p_vehicle_id,
    p_location_id,
    p_customer_name,
    p_customer_address,
    p_items,
    p_status,
    v_order_number
  ) RETURNING id, order_number, status INTO v_delivery_note_id, v_order_number, p_status;

  -- Update related order's delivery note status if applicable
  IF p_order_id IS NOT NULL THEN
    UPDATE orders 
    SET delivery_note_generated = TRUE 
    WHERE id = p_order_id;
  END IF;

  -- Return the created delivery note details
  RETURN QUERY 
  SELECT v_delivery_note_id, v_order_number, p_status;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.create_partner_user(p_email text, p_password text, p_full_name text, p_partner_id uuid, p_is_admin boolean DEFAULT false)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  new_user_id UUID;
  user_exists BOOLEAN;
BEGIN
  -- Check if user already exists
  SELECT EXISTS (
    SELECT 1 FROM auth.users WHERE email = p_email
  ) INTO user_exists;
  
  IF user_exists THEN
    -- Get existing user ID
    SELECT id INTO new_user_id FROM auth.users WHERE email = p_email;
  ELSE
    -- Generate a new UUID for the user
    new_user_id := gen_random_uuid();
    
    -- Insert into auth.users with the pre-generated UUID
    INSERT INTO auth.users (
      id,
      instance_id,
      email,
      encrypted_password,
      email_confirmed_at,
      raw_user_meta_data,
      created_at,
      updated_at,
      last_sign_in_at,
      confirmation_token,
      recovery_token,
      email_change_token_new,
      email_change,
      confirmation_sent_at,
      recovery_sent_at,
      email_change_sent_at,
      aud,
      role
    ) VALUES (
      new_user_id,
      '00000000-0000-0000-0000-000000000000',
      p_email,
      crypt(p_password, gen_salt('bf')),
      now(),
      jsonb_build_object(
        'full_name', p_full_name,
        'partner_id', p_partner_id,
        'is_partner', true
      ),
      now(),
      now(),
      now(),
      '',
      '',
      '',
      '',
      now(),
      now(),
      now(),
      'authenticated',
      'authenticated'
    );
  END IF;
  
  -- Check if profile exists
  IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = new_user_id) THEN
    -- Create profile
    INSERT INTO public.profiles (
      id,
      full_name,
      email,
      role,
      status
    ) VALUES (
      new_user_id,
      p_full_name,
      p_email,
      'partner',
      'active'
    );
  END IF;
  
  -- Check if partner_user association exists
  IF NOT EXISTS (
    SELECT 1 FROM public.partner_users 
    WHERE user_id = new_user_id AND partner_id = p_partner_id
  ) THEN
    -- Create partner_user association
    INSERT INTO public.partner_users (
      user_id,
      partner_id,
      role,
      is_admin
    ) VALUES (
      new_user_id,
      p_partner_id,
      CASE WHEN p_is_admin THEN 'admin' ELSE 'member' END,
      p_is_admin
    );
  END IF;
  
  RETURN new_user_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.create_payment_from_work_logs(employee_id uuid, start_date date, end_date date, payment_method character varying DEFAULT 'transfer'::character varying, description text DEFAULT NULL::text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    calculation_result RECORD;
    new_payment_id UUID;
    payment_description TEXT;
BEGIN
    -- Kiszámoljuk a fizetést
    SELECT * INTO calculation_result 
    FROM calculate_payment_from_work_logs(employee_id, start_date, end_date);
    
    IF calculation_result.total_amount <= 0 THEN
        RAISE EXCEPTION 'No valid work hours found for the specified period';
    END IF;
    
    -- Leírás generálása ha nincs megadva
    IF description IS NULL THEN
        payment_description := FORMAT('Work payment for %s to %s (%s hours)', 
            start_date, end_date, calculation_result.total_hours);
    ELSE
        payment_description := description;
    END IF;
    
    -- Új fizetés létrehozása
    INSERT INTO payments (
        user_id, 
        amount, 
        currency, 
        status, 
        payment_method, 
        description,
        reference_id
    ) VALUES (
        employee_id,
        calculation_result.total_amount,
        'HUF',
        'pending',
        payment_method,
        payment_description,
        FORMAT('WORK-%s-%s', TO_CHAR(start_date, 'YYYYMMDD'), TO_CHAR(end_date, 'YYYYMMDD'))
    ) RETURNING id INTO new_payment_id;
    
    -- Fizetési tétel hozzáadása
    INSERT INTO payment_items (
        payment_id,
        name,
        amount,
        quantity
    ) VALUES (
        new_payment_id,
        FORMAT('Work hours: %s hrs @ %s HUF/hr', 
            calculation_result.total_hours, calculation_result.hourly_wage),
        calculation_result.total_amount,
        1
    );
    
    RETURN new_payment_id;
END;
$function$
;

CREATE OR REPLACE PROCEDURE public.debug_notice(IN msg text)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
  RAISE NOTICE '%', msg;
END;
$procedure$
;

CREATE OR REPLACE FUNCTION public.decrement_stock(p_product_id uuid, p_location_id uuid, p_quantity integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
  UPDATE store_inventory
  SET current_stock = current_stock - p_quantity
  WHERE product_id = p_product_id AND location_id = p_location_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.example_function()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE 
    location_id INTEGER;
    vehicle_location_id UUID;
BEGIN
    -- Your function logic here
    RAISE NOTICE 'Variables declared successfully';
END;
$function$
;

CREATE OR REPLACE FUNCTION public.force_logout_all_users()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    -- This is a placeholder function
    -- In a real implementation, this would invalidate all sessions
    RAISE NOTICE 'Force logout function created';
END;
$function$
;

CREATE OR REPLACE FUNCTION public.generate_batch_number()
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
  new_number TEXT;
  counter INTEGER;
BEGIN
  SELECT COALESCE(MAX(CAST(SUBSTRING(batch_number FROM 9) AS INTEGER)), 0) + 1
  INTO counter
  FROM production_batches
  WHERE batch_number LIKE 'B' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '%';
  
  new_number := 'B' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || LPAD(counter::TEXT, 3, '0');
  RETURN new_number;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.generate_customer_number()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.customer_number := 'CUST-' || to_char(NOW(), 'YYYYMMDD') || '-' || 
                         LPAD(CAST(floor(random() * 10000) AS TEXT), 4, '0');
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.generate_delivery_note_on_batch_completion()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_order_id UUID;
  v_order_number TEXT;
  v_customer_name TEXT;
  v_customer_address TEXT;
  v_items JSONB;
  v_location_id UUID;
BEGIN
  -- Check if this batch is linked to an order
  SELECT order_id INTO v_order_id
  FROM production_batches_orders
  WHERE batch_id = NEW.id
  LIMIT 1;
  
  -- If no direct order link, check if there's a webshop order
  IF v_order_id IS NULL AND NEW.webshop_order_id IS NOT NULL THEN
    -- Try to find a regular order linked to this webshop order
    SELECT id INTO v_order_id
    FROM orders
    WHERE webshop_order_id = NEW.webshop_order_id
    LIMIT 1;
  END IF;
  
  -- If we have an order, get its details
  IF v_order_id IS NOT NULL THEN
    SELECT 
      order_number, 
      customer_name, 
      customer_address,
      items,
      location_id
    INTO 
      v_order_number, 
      v_customer_name, 
      v_customer_address,
      v_items,
      v_location_id
    FROM orders
    WHERE id = v_order_id;
  ELSE
    -- No order found, use batch information
    v_order_number := 'SZL-' || to_char(now(), 'YYYYMMDD') || '-' || floor(random() * 10000)::text;
    
    -- Get product name from recipe
    SELECT 
      p.name INTO v_customer_name
    FROM 
      products p
    WHERE 
      p.id = NEW.recipe_id;
      
    v_customer_name := COALESCE(v_customer_name, 'Belső gyártás');
    v_customer_address := NULL;
    
    -- Create items array with the product
    v_items := json_build_array(
      json_build_object(
        'product_id', NEW.recipe_id,
        'product_name', v_customer_name,
        'quantity', NEW.batch_size
      )
    )::jsonb;
    
    v_location_id := NEW.location_id;
  END IF;
  
  -- Create delivery note
  INSERT INTO delivery_notes (
    order_id,
    order_number,
    batch_id,
    status,
    customer_name,
    customer_address,
    items,
    location_id
  ) VALUES (
    v_order_id,
    v_order_number,
    NEW.id,
    'pending',
    v_customer_name,
    v_customer_address,
    v_items,
    v_location_id
  );
  
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.generate_inventory_barcode()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Only generate if barcode is null
  IF NEW.barcode IS NULL THEN
    -- Generate a simple barcode format: INV-{timestamp}-{random}
    NEW.barcode := 'INV-' || extract(epoch from now())::text || '-' || floor(random() * 1000)::text;
  END IF;
  
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.generate_inventory_qr_code()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Generate a JSON structure with inventory details
  NEW.qr_code := json_build_object(
    'type', 'inventory',
    'id', NEW.id,
    'name', NEW.name,
    'category', NEW.category,
    'unit', NEW.unit
  )::text;
  
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.generate_invoice_number()
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
  current_year TEXT := TO_CHAR(CURRENT_DATE, 'YYYY');
  next_number INTEGER := FLOOR(RANDOM() * 100000);
BEGIN
  RETURN 'INV-' || current_year || '-' || LPAD(next_number::TEXT, 5, '0');
END;
$function$
;

CREATE OR REPLACE FUNCTION public.generate_order_number()
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
  new_number TEXT;
  counter INTEGER;
BEGIN
  SELECT COALESCE(MAX(CAST(SUBSTRING(order_number FROM 9) AS INTEGER)), 0) + 1
  INTO counter
  FROM orders
  WHERE order_number LIKE TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '%';
  
  new_number := TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || LPAD(counter::TEXT, 4, '0');
  RETURN new_number;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.generate_payment_number()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  payment_prefix TEXT := 'PAY';
  payment_date TEXT;
  payment_count INT;
BEGIN
  -- Format: PAY-YYYYMMDD-XXXX
  payment_date := to_char(CURRENT_DATE, 'YYYYMMDD');
  
  -- Get count of payments for today
  SELECT COUNT(*) + 1 INTO payment_count
  FROM payments
  WHERE payment_number LIKE 'PAY-' || payment_date || '-%';
  
  -- Set the payment number
  NEW.payment_number := payment_prefix || '-' || payment_date || '-' || LPAD(payment_count::TEXT, 4, '0');
  
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.generate_product_barcode()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Only generate if barcode is null
  IF NEW.barcode IS NULL THEN
    -- Generate a simple barcode format: PRD-{timestamp}-{random}
    NEW.barcode := 'PRD-' || extract(epoch from now())::text || '-' || floor(random() * 1000)::text;
  END IF;
  
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.generate_product_qr_code()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Generate a JSON structure with product details
  NEW.qr_code := json_build_object(
    'type', 'product',
    'id', NEW.id,
    'name', NEW.name,
    'category', NEW.category,
    'price', NEW.retail_price
  )::text;
  
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.generate_return_number()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  location_code TEXT;
  date_part TEXT;
  counter INTEGER;
  new_return_number TEXT;
BEGIN
  -- Get location code (first 3 letters of location name)
  SELECT SUBSTRING(UPPER(name) FROM 1 FOR 3) INTO location_code
  FROM locations
  WHERE id = NEW.location_id;
  
  IF location_code IS NULL THEN
    location_code := 'POS';
  END IF;
  
  -- Get date part (YYMMDD)
  date_part := TO_CHAR(CURRENT_DATE, 'YYMMDD');
  
  -- Get counter (number of returns for this location today)
  SELECT COUNT(*) + 1 INTO counter
  FROM pos_returns
  WHERE location_id = NEW.location_id
    AND DATE(created_at) = CURRENT_DATE;
  
  -- Generate return number
  new_return_number := 'RET-' || location_code || '-' || date_part || '-' || LPAD(counter::TEXT, 4, '0');
  
  -- Set the return number
  NEW.return_number := new_return_number;
  
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.generate_session_number()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.session_number := 'S-' || TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDD') || '-' || LPAD(NEXTVAL('session_number_seq')::TEXT, 4, '0');
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.generate_transaction_number()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.transaction_number := 'TX-' || TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDD') || '-' || LPAD(NEXTVAL('transaction_number_seq')::TEXT, 4, '0');
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_all_tables()
 RETURNS TABLE(table_name text)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT t.table_name::TEXT
  FROM information_schema.tables t
  WHERE t.table_schema = 'public'
  AND t.table_type = 'BASE TABLE'
  ORDER BY t.table_name;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_current_user_id()
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
BEGIN
  RETURN (SELECT id FROM auth.users WHERE auth.uid() = id);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_daily_orders(p_date date DEFAULT CURRENT_DATE)
 RETURNS TABLE(id uuid, order_number text, customer_name text, items jsonb, total_amount numeric, status text, delivery_date timestamp with time zone, created_at timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT 
    o.id,
    o.order_number,
    o.customer_name,
    o.items,
    o.total_amount,
    o.status,
    o.delivery_date,
    o.created_at
  FROM orders o
  WHERE DATE(o.delivery_date) = p_date
    OR (o.delivery_date IS NULL AND DATE(o.created_at) = p_date)
  ORDER BY o.created_at DESC;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_delivery_note_details(p_delivery_note_id uuid)
 RETURNS TABLE(delivery_note_id uuid, order_number text, status text, customer_name text, customer_address text, driver_name text, vehicle_info text, location_name text, items jsonb, delivery_date timestamp with time zone)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  RETURN QUERY
  SELECT 
    dn.id,
    dn.order_number,
    dn.status,
    dn.customer_name,
    dn.customer_address,
    p.full_name AS driver_name,
    v.license_plate || ' (' || v.make || ' ' || v.model || ')' AS vehicle_info,
    l.name AS location_name,
    dn.items,
    dn.delivery_date
  FROM delivery_notes dn
  LEFT JOIN profiles p ON dn.driver_id = p.id
  LEFT JOIN vehicles v ON dn.vehicle_id = v.id
  LEFT JOIN locations l ON dn.location_id = l.id
  WHERE dn.id = p_delivery_note_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_low_stock_items()
 RETURNS TABLE(id uuid, name text, category text, current_stock numeric, unit text, min_threshold numeric, supplier text, supplier_email text)
 LANGUAGE sql
AS $function$
  SELECT 
    id, 
    name, 
    category, 
    current_stock, 
    unit, 
    min_threshold,
    supplier,
    supplier_email
  FROM 
    inventory
  WHERE 
    current_stock <= min_threshold
  ORDER BY 
    CASE WHEN min_threshold = 0 THEN 0 ELSE current_stock / min_threshold END ASC
  LIMIT 10;
$function$
;

CREATE OR REPLACE FUNCTION public.handle_oauth_user_metadata()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  -- Update profile with OAuth metadata if available
  IF NEW.raw_user_meta_data->>'avatar_url' IS NOT NULL THEN
    UPDATE profiles
    SET 
      avatar_url = NEW.raw_user_meta_data->>'avatar_url',
      provider = 'google'
    WHERE id = NEW.id;
  END IF;
  
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.handle_return_inventory_update()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Készlet visszaállítása visszáru esetén
  IF TG_OP = 'INSERT' THEN
    UPDATE store_inventory 
    SET current_stock = current_stock + NEW.quantity
    WHERE product_id = NEW.product_id;
  END IF;
  
  RETURN COALESCE(NEW, OLD);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.handle_webhook_response(webhook_id text, response_status integer, response_body text DEFAULT NULL::text)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Webhook válasz naplózása
  INSERT INTO network_logs (level, message, endpoint, details)
  VALUES (
    CASE 
      WHEN response_status BETWEEN 200 AND 299 THEN 'success'
      WHEN response_status BETWEEN 400 AND 499 THEN 'warning'
      ELSE 'error'
    END,
    'Webhook response: ' || response_status,
    'webhook_response',
    jsonb_build_object(
      'webhook_id', webhook_id,
      'status_code', response_status,
      'response_body', response_body
    )
  );
  
  -- Webhook utolsó trigger idő frissítése
  UPDATE settings 
  SET value = jsonb_set(
    value::jsonb, 
    '{last_triggered}', 
    to_jsonb(now()::text)
  ),
  updated_at = now()
  WHERE category = 'network_webhooks' 
    AND key = webhook_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.increment_stock(p_product_id uuid, p_location_id uuid, p_quantity integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
  INSERT INTO store_inventory (product_id, location_id, current_stock, min_threshold, unit)
  VALUES (p_product_id, p_location_id, p_quantity, 5, 'db')
  ON CONFLICT (product_id, location_id) 
  DO UPDATE SET
    current_stock = store_inventory.current_stock + EXCLUDED.current_stock;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.insert_production_step(p_order_id bigint, p_step_description text, p_status text DEFAULT 'pending'::text)
 RETURNS public.production_steps
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    v_inserted_step public.production_steps;
BEGIN
    -- Check if user is a baker
    IF NOT public.is_baker() THEN
        RAISE EXCEPTION 'Only bakers can insert production steps';
    END IF;

    -- Insert the production step with the current user's ID
    INSERT INTO public.production_steps (
        order_id, 
        step_description, 
        status, 
        created_by
    ) VALUES (
        p_order_id, 
        p_step_description, 
        p_status, 
        auth.uid()
    ) RETURNING * INTO v_inserted_step;

    RETURN v_inserted_step;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.is_admin()
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM auth.users
    WHERE id = auth.uid()
    AND raw_user_meta_data ->> 'role' = 'admin'
  );
END;
$function$
;

CREATE OR REPLACE FUNCTION public.is_baker()
 RETURNS boolean
 LANGUAGE sql
 SECURITY DEFINER
AS $function$
  SELECT EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = auth.uid() 
    AND profiles.role IN ('baker', 'admin')
  );
$function$
;

CREATE OR REPLACE FUNCTION public.is_session_valid(session_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM auth.sessions 
        WHERE id = session_id AND expires_at > now()
    );
END;
$function$
;

CREATE OR REPLACE FUNCTION public.least_value(a text, b text)
 RETURNS numeric
 LANGUAGE plpgsql
AS $function$
    DECLARE
      val_a numeric;
      val_b numeric;
    BEGIN
      EXECUTE 'SELECT ' || quote_ident(a) || ' FROM inventory LIMIT 1' INTO val_a;
      EXECUTE 'SELECT ' || quote_ident(b) || ' FROM inventory LIMIT 1' INTO val_b;
      RETURN LEAST(val_a, val_b);
    END;
    $function$
;

create or replace view "public"."low_stock_items" as  SELECT id,
    name,
    current_stock,
    min_threshold,
    category,
    (min_threshold - current_stock) AS stock_deficit
   FROM public.store_inventory
  WHERE (current_stock <= min_threshold);


CREATE OR REPLACE FUNCTION public.process_delivery_note_stock_in(p_delivery_note_id uuid, p_user_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    note RECORD;
    item JSONB;
BEGIN
    SELECT * INTO note FROM public.delivery_notes WHERE id = p_delivery_note_id;

    IF NOT FOUND OR note.status = 'completed' THEN
        RETURN;
    END IF;

    FOR item IN SELECT * FROM jsonb_array_elements(note.items)
    LOOP
        INSERT INTO public.store_inventory (location_id, product_id, current_stock)
        VALUES (note.location_id, (item->>'product_id')::UUID, (item->>'quantity')::NUMERIC)
        ON CONFLICT (location_id, product_id)
        DO UPDATE SET
            current_stock = store_inventory.current_stock + (item->>'quantity')::NUMERIC,
            updated_at = now();
    END LOOP;

    UPDATE public.delivery_notes
    SET status = 'completed', updated_at = now()
    WHERE id = p_delivery_note_id;

END;
$function$
;

CREATE OR REPLACE FUNCTION public.process_pos_payment(p_session_id uuid, p_location_id uuid, p_cashier_id uuid, p_customer_name text, p_payment_method text, p_discount_percentage numeric, p_cart_items jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
DECLARE
    calculated_subtotal NUMERIC := 0;
    calculated_tax NUMERIC := 0;
    total_discount_amount NUMERIC := 0;
    new_transaction_id UUID;
    item RECORD;
    product_vat NUMERIC;
BEGIN
    -- 1. Számoljuk ki a végösszegeket a kosár alapján
    FOR item IN SELECT * FROM jsonb_to_recordset(p_cart_items) AS x(product_id UUID, quantity INT, price NUMERIC)
    LOOP
        calculated_subtotal := calculated_subtotal + (item.price * item.quantity);
    END LOOP;

    total_discount_amount := calculated_subtotal * (p_discount_percentage / 100);
    calculated_subtotal := calculated_subtotal - total_discount_amount;

    -- Itt egy egyszerűsített ÁFA számítás, a valóságban termékenként kellene
    -- Feltételezzük, hogy az ár bruttó, és 18%-os az ÁFA
    calculated_tax := calculated_subtotal - (calculated_subtotal / 1.18);

    -- 2. Hozzuk létre a fő tranzakciót
    INSERT INTO pos_transactions (session_id, location_id, cashier_id, customer_name, subtotal, tax_amount, total_amount, payment_method, discount_amount, status)
    VALUES (p_session_id, p_location_id, p_cashier_id, p_customer_name, calculated_subtotal, calculated_tax, calculated_subtotal, p_payment_method, total_discount_amount, 'completed')
    RETURNING id INTO new_transaction_id;

    -- 3. Hozzuk létre a tranzakciós tételeket és csökkentsük a készletet
    FOR item IN SELECT * FROM jsonb_to_recordset(p_cart_items) AS x(product_id UUID, quantity INT, price NUMERIC, name TEXT)
    LOOP
        -- Tranzakciós tétel beszúrása
        INSERT INTO pos_transaction_items (transaction_id, product_id, quantity, unit_price, total_price)
        VALUES (new_transaction_id, item.product_id, item.quantity, item.price, item.price * item.quantity);

        -- Készlet csökkentése
        UPDATE store_inventory
        SET current_stock = current_stock - item.quantity
        WHERE product_id = item.product_id AND location_id = p_location_id;
    END LOOP;
    
    -- 4. Frissítsük a kassza-munkamenet összegzőit
    UPDATE pos_sessions
    SET total_sales = total_sales + calculated_subtotal
    WHERE id = p_session_id;

    -- 5. Visszaadjuk az új tranzakció adatait
    RETURN (SELECT row_to_json(t) FROM pos_transactions t WHERE id = new_transaction_id);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.production_from_webshop_order()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  item_record RECORD;
  batch_id UUID;
BEGIN
  -- Only process when status changes to 'confirmed'
  IF (NEW.status = 'confirmed' AND OLD.status != 'confirmed') THEN
    -- Process each item in the order
    FOR item_record IN SELECT * FROM jsonb_array_elements(NEW.items) AS item
    LOOP
      -- Create a production batch for this item
      INSERT INTO production_batches (
        batch_number,
        recipe_id,
        batch_size,
        status,
        location_id
      ) VALUES (
        'WEB-' || NEW.order_number || '-' || item_record.value->>'id',
        (item_record.value->>'id')::uuid,
        (item_record.value->>'quantity')::integer,
        'planned',
        NEW.location_id
      )
      RETURNING id INTO batch_id;
      
      -- Create a link between the batch and the order
      INSERT INTO production_batches_orders (
        batch_id,
        order_id
      ) VALUES (
        batch_id,
        NEW.id
      );
    END LOOP;
    
    -- Update order status to in_production
    UPDATE orders SET status = 'in_production' WHERE id = NEW.id;
  END IF;
  
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.safe_insert()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- your insert/update/delete logic
EXCEPTION
  WHEN others THEN
    RAISE NOTICE 'Something went wrong: %', SQLERRM;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.save_previous_order()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Only save completed orders for partners
  IF NEW.status = 'completed' AND NEW.customer_id IS NOT NULL THEN
    -- Insert into previous_orders
    INSERT INTO previous_orders (
      partner_id,
      order_id,
      order_date,
      items
    ) VALUES (
      NEW.customer_id,
      NEW.id,
      CURRENT_DATE,
      NEW.items
    );
  END IF;
  
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.send_order_notification()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  partner_email text;
  partner_name text;
BEGIN
  -- Get partner details
  SELECT email, name INTO partner_email, partner_name
  FROM partner_companies
  WHERE id = NEW.customer_id;
  
  -- If partner email exists, create a record in sent_emails
  IF partner_email IS NOT NULL THEN
    INSERT INTO sent_emails (
      recipient_id,
      recipient_email,
      recipient_name,
      subject,
      body,
      status
    ) VALUES (
      NEW.customer_id,
      partner_email,
      partner_name,
      'Új rendelés visszaigazolás - ' || NEW.order_number,
      '<h1>Rendelés visszaigazolás</h1><p>Tisztelt ' || partner_name || '!</p><p>Köszönjük rendelését! Az alábbiakban találja a rendelés részleteit:</p><p><strong>Rendelésszám:</strong> ' || NEW.order_number || '</p><p><strong>Rendelés dátuma:</strong> ' || NEW.created_at || '</p>',
      'sent'
    );
  END IF;
  
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.set_default_password()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  -- Only set password if it's not already set
  IF NEW.encrypted_password IS NULL OR NEW.encrypted_password = '' THEN
    -- Set default password to "12345678"
    NEW.encrypted_password := crypt('12345678', gen_salt('bf'));
  END IF;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.set_invoice_number()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF NEW.invoice_number IS NULL OR NEW.invoice_number = '' THEN
        NEW.invoice_number := generate_invoice_number();
    END IF;
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.trigger_device_status_webhook()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  webhook_config jsonb;
  webhook_url text;
  api_key text;
  payload jsonb;
BEGIN
  -- Existing logic remains the same...
  
  -- Safer log insertion with exception handling
  BEGIN
    INSERT INTO network_logs (level, message, endpoint, details)
    VALUES (
      'info',
      'Webhook triggered: device status update for ' || NEW.name,
      webhook_url,
      jsonb_build_object(
        'device_id', NEW.id,
        'old_status', OLD.status,
        'new_status', NEW.status,
        'webhook_url', webhook_url
      )
    );
  EXCEPTION 
    WHEN OTHERS THEN
      -- Fallback logging (e.g., to a separate table or external system)
      RAISE WARNING 'Failed to log webhook trigger: %', SQLERRM;
  END;
  
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_cart_expiration()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.expires_at := now() + interval '30 days';
  NEW.updated_at := now();
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_cash_movements_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_dashboard_stats()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  daily_revenue NUMERIC := 0;
  completed_orders INTEGER := 0;
  low_stock_count INTEGER := 0;
  active_vehicles INTEGER := 0;
  total_vehicles INTEGER := 0;
  active_employees INTEGER := 0;
  employees_in_shift INTEGER := 0;
BEGIN
  -- Calculate daily revenue
  SELECT COALESCE(SUM(total_amount), 0) INTO daily_revenue
  FROM orders
  WHERE DATE(created_at) = CURRENT_DATE
  AND status = 'completed';
  
  -- Count completed orders
  SELECT COUNT(*) INTO completed_orders
  FROM orders
  WHERE DATE(created_at) = CURRENT_DATE
  AND status = 'completed';
  
  -- Count low stock items
  SELECT COUNT(*) INTO low_stock_count
  FROM inventory
  WHERE current_stock <= min_threshold;
  
  -- Count active vehicles
  SELECT COUNT(*) INTO active_vehicles
  FROM vehicles
  WHERE status = 'active';
  
  -- Count total vehicles
  SELECT COUNT(*) INTO total_vehicles
  FROM vehicles;
  
  -- Count active employees
  SELECT COUNT(*) INTO active_employees
  FROM profiles
  WHERE status = 'active';
  
  -- Count employees in shift today
  SELECT COUNT(*) INTO employees_in_shift
  FROM schedules
  WHERE date = CURRENT_DATE
  AND status = 'confirmed';
  
  -- Update dashboard stats
  -- Daily revenue
  INSERT INTO settings (category, key, value, description, is_public)
  VALUES ('dashboard', 'daily_revenue', to_jsonb(daily_revenue), 'Daily revenue for dashboard', true)
  ON CONFLICT (category, key) 
  DO UPDATE SET 
    value = to_jsonb(daily_revenue),
    updated_at = now();
  
  -- Completed orders
  INSERT INTO settings (category, key, value, description, is_public)
  VALUES ('dashboard', 'completed_orders', to_jsonb(completed_orders), 'Completed orders count for dashboard', true)
  ON CONFLICT (category, key) 
  DO UPDATE SET 
    value = to_jsonb(completed_orders),
    updated_at = now();
  
  -- Low stock items
  INSERT INTO settings (category, key, value, description, is_public)
  VALUES ('dashboard', 'low_stock_count', to_jsonb(low_stock_count), 'Low stock items count for dashboard', true)
  ON CONFLICT (category, key) 
  DO UPDATE SET 
    value = to_jsonb(low_stock_count),
    updated_at = now();
  
  -- Active vehicles - convert to string first to avoid jsonb issues
  INSERT INTO settings (category, key, value, description, is_public)
  VALUES ('dashboard', 'active_vehicles', to_jsonb(active_vehicles || '/' || total_vehicles), 'Active vehicles for dashboard', true)
  ON CONFLICT (category, key) 
  DO UPDATE SET 
    value = to_jsonb(active_vehicles || '/' || total_vehicles),
    updated_at = now();
  
  -- Active employees
  INSERT INTO settings (category, key, value, description, is_public)
  VALUES ('dashboard', 'active_employees', to_jsonb(active_employees), 'Active employees for dashboard', true)
  ON CONFLICT (category, key) 
  DO UPDATE SET 
    value = to_jsonb(active_employees),
    updated_at = now();
  
  -- Employees in shift
  INSERT INTO settings (category, key, value, description, is_public)
  VALUES ('dashboard', 'employees_in_shift', to_jsonb(employees_in_shift), 'Employees in shift for dashboard', true)
  ON CONFLICT (category, key) 
  DO UPDATE SET 
    value = to_jsonb(employees_in_shift),
    updated_at = now();
  
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_delivery_note_status(p_delivery_note_id uuid, p_new_status text, p_delivery_date timestamp with time zone DEFAULT NULL::timestamp with time zone, p_notes text DEFAULT NULL::text)
 RETURNS TABLE(id uuid, old_status text, new_status text)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  v_old_status TEXT;
BEGIN
  -- Get the current status
  SELECT status INTO v_old_status 
  FROM delivery_notes 
  WHERE id = p_delivery_note_id;

  -- Update the delivery note
  UPDATE delivery_notes
  SET 
    status = p_new_status,
    delivery_date = COALESCE(p_delivery_date, delivery_date),
    notes = COALESCE(p_notes, notes)
  WHERE id = p_delivery_note_id;

  -- Return the status change
  RETURN QUERY 
  SELECT 
    p_delivery_note_id, 
    v_old_status, 
    p_new_status;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_inventory_on_batch_completion()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  ingredient RECORD;
  inventory_item_id UUID;
  low_stock_count INTEGER := 0;
BEGIN
  -- Only proceed if status changed to 'completed'
  IF (TG_OP = 'UPDATE' AND NEW.status = 'completed' AND OLD.status != 'completed') THEN
    -- Loop through each required ingredient
    FOR ingredient IN 
      SELECT * FROM calculate_batch_ingredients(NEW.id)
    LOOP
      -- Find the inventory item
      SELECT id INTO inventory_item_id
      FROM inventory
      WHERE name ILIKE ingredient.ingredient_name
      AND unit = ingredient.unit
      LIMIT 1;
      
      -- If inventory item exists, update it
      IF inventory_item_id IS NOT NULL THEN
        UPDATE inventory
        SET current_stock = current_stock - ingredient.required_amount
        WHERE id = inventory_item_id;
        
        -- Log the action
        RAISE NOTICE 'Updated inventory for %: reduced by % %', 
          ingredient.ingredient_name, 
          ingredient.required_amount,
          ingredient.unit;
      END IF;
    END LOOP;
    
    -- Count low stock items
    SELECT COUNT(*) INTO low_stock_count
    FROM inventory
    WHERE current_stock <= min_threshold;
    
    -- Update dashboard stats for low stock
    INSERT INTO settings (category, key, value, description, is_public)
    VALUES ('dashboard', 'low_stock_count', low_stock_count::text, 'Low stock items count for dashboard', true)
    ON CONFLICT (category, key) 
    DO UPDATE SET 
      value = low_stock_count::text,
      updated_at = now();
    
    -- Create a notification for inventory manager if any items are below threshold
    INSERT INTO notifications (
      user_id,
      title,
      message,
      type,
      priority,
      read,
      action_url
    )
    SELECT 
      profiles.id,
      'Alacsony készlet figyelmeztetés',
      'Egy gyártási tétel befejezése után egyes alapanyagok készlete a minimum szint alá csökkent.',
      'warning',
      'high',
      false,
      '/inventory'
    FROM profiles
    WHERE role = 'admin'
    AND EXISTS (
      SELECT 1 FROM inventory
      WHERE current_stock <= min_threshold
    )
    LIMIT 1;
  END IF;
  
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_inventory_on_transaction()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF NEW.transaction_type = 'addition' OR NEW.transaction_type = 'return' THEN
    -- Increase inventory
    UPDATE inventory
    SET current_stock = current_stock + NEW.quantity,
        last_restocked = CURRENT_TIMESTAMP
    WHERE id = NEW.inventory_id;
  ELSIF NEW.transaction_type = 'reduction' THEN
    -- Decrease inventory
    UPDATE inventory
    SET current_stock = GREATEST(0, current_stock - NEW.quantity)
    WHERE id = NEW.inventory_id;
  ELSIF NEW.transaction_type = 'adjustment' THEN
    -- Direct adjustment (set to specific value)
    UPDATE inventory
    SET current_stock = NEW.quantity,
        last_restocked = CURRENT_TIMESTAMP
    WHERE id = NEW.inventory_id;
  END IF;
  
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_modified_column()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_network_updated_at_column()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_pickup_location_modified_column()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_pos_transaction_items_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    -- Létrehozunk egy változót a tranzakció helyszínének tárolására, hogy egyértelmű legyen.
    transaction_location_id UUID;
BEGIN
    -- Lekérdezzük a tranzakcióhoz tartozó helyszín ID-t a 'pos_transactions' táblából
    -- az ÚJ ('NEW') tranzakciós tétel 'transaction_id'-ja alapján.
    SELECT location_id INTO transaction_location_id
    FROM public.pos_transactions
    WHERE id = NEW.transaction_id;

    -- Frissítjük a bolti készletet ('store_inventory').
    -- Csökkentjük a 'current_stock'-ot az eladott mennyiséggel ('NEW.quantity').
    UPDATE public.store_inventory
    SET current_stock = current_stock - NEW.quantity
    WHERE
        -- A termék ID-nak egyeznie kell az eladott termék ID-jával.
        product_id = NEW.product_id
        -- ÉS a helyszín ID-nak egyeznie kell a tranzakció helyszínével.
        -- Ez a sor oldja meg a "kétértelmű" hibát.
        AND location_id = transaction_location_id;

    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_product_rating()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  avg_rating NUMERIC;
BEGIN
  -- Calculate the average rating for the product
  SELECT AVG(rating)::NUMERIC(3,2) INTO avg_rating
  FROM webshop_product_reviews
  WHERE product_id = NEW.product_id
  AND is_approved = true;
  
  -- Update the product's rating in a custom field (we'll add this to the products table)
  UPDATE products
  SET 
    avg_rating = avg_rating,
    review_count = (
      SELECT COUNT(*) 
      FROM webshop_product_reviews 
      WHERE product_id = NEW.product_id 
      AND is_approved = true
    )
  WHERE id = NEW.product_id;
  
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_production_batch(p_batch_id uuid, p_status text, p_end_time timestamp with time zone, p_actual_yield integer, p_quality_score integer, p_temperature numeric, p_humidity numeric, p_notes text)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_batch production_batches;
BEGIN
  -- Update the batch
  UPDATE production_batches
  SET 
    status = p_status,
    end_time = p_end_time,
    actual_yield = p_actual_yield,
    quality_score = p_quality_score,
    temperature = p_temperature,
    humidity = p_humidity,
    notes = p_notes,
    updated_at = now()
  WHERE id = p_batch_id
  RETURNING * INTO v_batch;
  
  -- Check if batch was found
  IF v_batch.id IS NULL THEN
    RAISE EXCEPTION 'Batch with ID % not found', p_batch_id;
  END IF;
  
  -- Return the updated batch
  RETURN row_to_json(v_batch)::jsonb;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_production_batch_simple(p_batch_id uuid, p_status text, p_end_time timestamp with time zone DEFAULT NULL::timestamp with time zone)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  -- Simple update without any JSONB operations
  UPDATE production_batches 
  SET 
    status = p_status,
    end_time = CASE 
      WHEN p_end_time IS NOT NULL THEN p_end_time 
      ELSE end_time 
    END,
    start_time = CASE 
      WHEN p_status = 'in_progress' AND start_time IS NULL THEN NOW() 
      ELSE start_time 
    END,
    updated_at = NOW()
  WHERE id = p_batch_id;
  
  -- Check if the update affected any rows
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Production batch with ID % not found', p_batch_id;
  END IF;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_store_inventory_on_transaction()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    -- Létrehozunk egy változót, hogy egyértelműsítsük a helyszínt.
    transaction_location_id UUID;
BEGIN
    -- Lekérdezzük a tranzakció helyszínét a 'pos_transactions' táblából.
    -- Az 'NEW' a most beillesztett 'pos_transaction_items' sorra hivatkozik.
    SELECT location_id INTO transaction_location_id
    FROM public.pos_transactions
    WHERE id = NEW.transaction_id;

    -- Frissítjük a bolti készletet a megfelelő helyszínen.
    UPDATE public.store_inventory
    SET current_stock = current_stock - NEW.quantity
    WHERE
        product_id = NEW.product_id
        -- Itt már a változót használjuk, így a hivatkozás egyértelmű.
        AND location_id = transaction_location_id;

    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_store_inventory_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.validate_product_id()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    -- Ellenőrizzük, hogy a termék létezik-e
    IF NOT EXISTS (SELECT 1 FROM products WHERE id = NEW.product_id) THEN
        RAISE EXCEPTION 'Nem létező termék-azonosító: %', NEW.product_id
        USING ERRCODE = 'P0001',
        DETAIL = 'A megadott termék nem szerepel a terméklistában',
        HINT = 'Ellenőrizze a termék-azonosítót vagy vegye fel a terméket a products táblába';
    END IF;
    RETURN NEW;
END;
$function$
;

grant delete on table "public"."camera_events" to "anon";

grant insert on table "public"."camera_events" to "anon";

grant references on table "public"."camera_events" to "anon";

grant select on table "public"."camera_events" to "anon";

grant trigger on table "public"."camera_events" to "anon";

grant truncate on table "public"."camera_events" to "anon";

grant update on table "public"."camera_events" to "anon";

grant delete on table "public"."camera_events" to "authenticated";

grant insert on table "public"."camera_events" to "authenticated";

grant references on table "public"."camera_events" to "authenticated";

grant select on table "public"."camera_events" to "authenticated";

grant trigger on table "public"."camera_events" to "authenticated";

grant truncate on table "public"."camera_events" to "authenticated";

grant update on table "public"."camera_events" to "authenticated";

grant delete on table "public"."camera_events" to "service_role";

grant insert on table "public"."camera_events" to "service_role";

grant references on table "public"."camera_events" to "service_role";

grant select on table "public"."camera_events" to "service_role";

grant trigger on table "public"."camera_events" to "service_role";

grant truncate on table "public"."camera_events" to "service_role";

grant update on table "public"."camera_events" to "service_role";

grant delete on table "public"."camera_settings" to "anon";

grant insert on table "public"."camera_settings" to "anon";

grant references on table "public"."camera_settings" to "anon";

grant select on table "public"."camera_settings" to "anon";

grant trigger on table "public"."camera_settings" to "anon";

grant truncate on table "public"."camera_settings" to "anon";

grant update on table "public"."camera_settings" to "anon";

grant delete on table "public"."camera_settings" to "authenticated";

grant insert on table "public"."camera_settings" to "authenticated";

grant references on table "public"."camera_settings" to "authenticated";

grant select on table "public"."camera_settings" to "authenticated";

grant trigger on table "public"."camera_settings" to "authenticated";

grant truncate on table "public"."camera_settings" to "authenticated";

grant update on table "public"."camera_settings" to "authenticated";

grant delete on table "public"."camera_settings" to "service_role";

grant insert on table "public"."camera_settings" to "service_role";

grant references on table "public"."camera_settings" to "service_role";

grant select on table "public"."camera_settings" to "service_role";

grant trigger on table "public"."camera_settings" to "service_role";

grant truncate on table "public"."camera_settings" to "service_role";

grant update on table "public"."camera_settings" to "service_role";

grant delete on table "public"."cash_movements" to "anon";

grant insert on table "public"."cash_movements" to "anon";

grant references on table "public"."cash_movements" to "anon";

grant select on table "public"."cash_movements" to "anon";

grant trigger on table "public"."cash_movements" to "anon";

grant truncate on table "public"."cash_movements" to "anon";

grant update on table "public"."cash_movements" to "anon";

grant delete on table "public"."cash_movements" to "authenticated";

grant insert on table "public"."cash_movements" to "authenticated";

grant references on table "public"."cash_movements" to "authenticated";

grant select on table "public"."cash_movements" to "authenticated";

grant trigger on table "public"."cash_movements" to "authenticated";

grant truncate on table "public"."cash_movements" to "authenticated";

grant update on table "public"."cash_movements" to "authenticated";

grant delete on table "public"."cash_movements" to "service_role";

grant insert on table "public"."cash_movements" to "service_role";

grant references on table "public"."cash_movements" to "service_role";

grant select on table "public"."cash_movements" to "service_role";

grant trigger on table "public"."cash_movements" to "service_role";

grant truncate on table "public"."cash_movements" to "service_role";

grant update on table "public"."cash_movements" to "service_role";

grant delete on table "public"."chat_messages" to "anon";

grant insert on table "public"."chat_messages" to "anon";

grant references on table "public"."chat_messages" to "anon";

grant select on table "public"."chat_messages" to "anon";

grant trigger on table "public"."chat_messages" to "anon";

grant truncate on table "public"."chat_messages" to "anon";

grant update on table "public"."chat_messages" to "anon";

grant delete on table "public"."chat_messages" to "authenticated";

grant insert on table "public"."chat_messages" to "authenticated";

grant references on table "public"."chat_messages" to "authenticated";

grant select on table "public"."chat_messages" to "authenticated";

grant trigger on table "public"."chat_messages" to "authenticated";

grant truncate on table "public"."chat_messages" to "authenticated";

grant update on table "public"."chat_messages" to "authenticated";

grant delete on table "public"."chat_messages" to "service_role";

grant insert on table "public"."chat_messages" to "service_role";

grant references on table "public"."chat_messages" to "service_role";

grant select on table "public"."chat_messages" to "service_role";

grant trigger on table "public"."chat_messages" to "service_role";

grant truncate on table "public"."chat_messages" to "service_role";

grant update on table "public"."chat_messages" to "service_role";

grant delete on table "public"."delivery_notes" to "anon";

grant insert on table "public"."delivery_notes" to "anon";

grant references on table "public"."delivery_notes" to "anon";

grant select on table "public"."delivery_notes" to "anon";

grant trigger on table "public"."delivery_notes" to "anon";

grant truncate on table "public"."delivery_notes" to "anon";

grant update on table "public"."delivery_notes" to "anon";

grant delete on table "public"."delivery_notes" to "authenticated";

grant insert on table "public"."delivery_notes" to "authenticated";

grant references on table "public"."delivery_notes" to "authenticated";

grant select on table "public"."delivery_notes" to "authenticated";

grant trigger on table "public"."delivery_notes" to "authenticated";

grant truncate on table "public"."delivery_notes" to "authenticated";

grant update on table "public"."delivery_notes" to "authenticated";

grant delete on table "public"."delivery_notes" to "service_role";

grant insert on table "public"."delivery_notes" to "service_role";

grant references on table "public"."delivery_notes" to "service_role";

grant select on table "public"."delivery_notes" to "service_role";

grant trigger on table "public"."delivery_notes" to "service_role";

grant truncate on table "public"."delivery_notes" to "service_role";

grant update on table "public"."delivery_notes" to "service_role";

grant delete on table "public"."documents" to "anon";

grant insert on table "public"."documents" to "anon";

grant references on table "public"."documents" to "anon";

grant select on table "public"."documents" to "anon";

grant trigger on table "public"."documents" to "anon";

grant truncate on table "public"."documents" to "anon";

grant update on table "public"."documents" to "anon";

grant delete on table "public"."documents" to "authenticated";

grant insert on table "public"."documents" to "authenticated";

grant references on table "public"."documents" to "authenticated";

grant select on table "public"."documents" to "authenticated";

grant trigger on table "public"."documents" to "authenticated";

grant truncate on table "public"."documents" to "authenticated";

grant update on table "public"."documents" to "authenticated";

grant delete on table "public"."documents" to "service_role";

grant insert on table "public"."documents" to "service_role";

grant references on table "public"."documents" to "service_role";

grant select on table "public"."documents" to "service_role";

grant trigger on table "public"."documents" to "service_role";

grant truncate on table "public"."documents" to "service_role";

grant update on table "public"."documents" to "service_role";

grant delete on table "public"."email_templates" to "anon";

grant insert on table "public"."email_templates" to "anon";

grant references on table "public"."email_templates" to "anon";

grant select on table "public"."email_templates" to "anon";

grant trigger on table "public"."email_templates" to "anon";

grant truncate on table "public"."email_templates" to "anon";

grant update on table "public"."email_templates" to "anon";

grant delete on table "public"."email_templates" to "authenticated";

grant insert on table "public"."email_templates" to "authenticated";

grant references on table "public"."email_templates" to "authenticated";

grant select on table "public"."email_templates" to "authenticated";

grant trigger on table "public"."email_templates" to "authenticated";

grant truncate on table "public"."email_templates" to "authenticated";

grant update on table "public"."email_templates" to "authenticated";

grant delete on table "public"."email_templates" to "service_role";

grant insert on table "public"."email_templates" to "service_role";

grant references on table "public"."email_templates" to "service_role";

grant select on table "public"."email_templates" to "service_role";

grant trigger on table "public"."email_templates" to "service_role";

grant truncate on table "public"."email_templates" to "service_role";

grant update on table "public"."email_templates" to "service_role";

grant delete on table "public"."employees" to "anon";

grant insert on table "public"."employees" to "anon";

grant references on table "public"."employees" to "anon";

grant select on table "public"."employees" to "anon";

grant trigger on table "public"."employees" to "anon";

grant truncate on table "public"."employees" to "anon";

grant update on table "public"."employees" to "anon";

grant delete on table "public"."employees" to "authenticated";

grant insert on table "public"."employees" to "authenticated";

grant references on table "public"."employees" to "authenticated";

grant select on table "public"."employees" to "authenticated";

grant trigger on table "public"."employees" to "authenticated";

grant truncate on table "public"."employees" to "authenticated";

grant update on table "public"."employees" to "authenticated";

grant delete on table "public"."employees" to "service_role";

grant insert on table "public"."employees" to "service_role";

grant references on table "public"."employees" to "service_role";

grant select on table "public"."employees" to "service_role";

grant trigger on table "public"."employees" to "service_role";

grant truncate on table "public"."employees" to "service_role";

grant update on table "public"."employees" to "service_role";

grant delete on table "public"."feedback" to "anon";

grant insert on table "public"."feedback" to "anon";

grant references on table "public"."feedback" to "anon";

grant select on table "public"."feedback" to "anon";

grant trigger on table "public"."feedback" to "anon";

grant truncate on table "public"."feedback" to "anon";

grant update on table "public"."feedback" to "anon";

grant delete on table "public"."feedback" to "authenticated";

grant insert on table "public"."feedback" to "authenticated";

grant references on table "public"."feedback" to "authenticated";

grant select on table "public"."feedback" to "authenticated";

grant trigger on table "public"."feedback" to "authenticated";

grant truncate on table "public"."feedback" to "authenticated";

grant update on table "public"."feedback" to "authenticated";

grant delete on table "public"."feedback" to "service_role";

grant insert on table "public"."feedback" to "service_role";

grant references on table "public"."feedback" to "service_role";

grant select on table "public"."feedback" to "service_role";

grant trigger on table "public"."feedback" to "service_role";

grant truncate on table "public"."feedback" to "service_role";

grant update on table "public"."feedback" to "service_role";

grant delete on table "public"."inventory" to "anon";

grant insert on table "public"."inventory" to "anon";

grant references on table "public"."inventory" to "anon";

grant select on table "public"."inventory" to "anon";

grant trigger on table "public"."inventory" to "anon";

grant truncate on table "public"."inventory" to "anon";

grant update on table "public"."inventory" to "anon";

grant delete on table "public"."inventory" to "authenticated";

grant insert on table "public"."inventory" to "authenticated";

grant references on table "public"."inventory" to "authenticated";

grant select on table "public"."inventory" to "authenticated";

grant trigger on table "public"."inventory" to "authenticated";

grant truncate on table "public"."inventory" to "authenticated";

grant update on table "public"."inventory" to "authenticated";

grant delete on table "public"."inventory" to "service_role";

grant insert on table "public"."inventory" to "service_role";

grant references on table "public"."inventory" to "service_role";

grant select on table "public"."inventory" to "service_role";

grant trigger on table "public"."inventory" to "service_role";

grant truncate on table "public"."inventory" to "service_role";

grant update on table "public"."inventory" to "service_role";

grant delete on table "public"."invoice_templates" to "anon";

grant insert on table "public"."invoice_templates" to "anon";

grant references on table "public"."invoice_templates" to "anon";

grant select on table "public"."invoice_templates" to "anon";

grant trigger on table "public"."invoice_templates" to "anon";

grant truncate on table "public"."invoice_templates" to "anon";

grant update on table "public"."invoice_templates" to "anon";

grant delete on table "public"."invoice_templates" to "authenticated";

grant insert on table "public"."invoice_templates" to "authenticated";

grant references on table "public"."invoice_templates" to "authenticated";

grant select on table "public"."invoice_templates" to "authenticated";

grant trigger on table "public"."invoice_templates" to "authenticated";

grant truncate on table "public"."invoice_templates" to "authenticated";

grant update on table "public"."invoice_templates" to "authenticated";

grant delete on table "public"."invoice_templates" to "service_role";

grant insert on table "public"."invoice_templates" to "service_role";

grant references on table "public"."invoice_templates" to "service_role";

grant select on table "public"."invoice_templates" to "service_role";

grant trigger on table "public"."invoice_templates" to "service_role";

grant truncate on table "public"."invoice_templates" to "service_role";

grant update on table "public"."invoice_templates" to "service_role";

grant delete on table "public"."invoices" to "anon";

grant insert on table "public"."invoices" to "anon";

grant references on table "public"."invoices" to "anon";

grant select on table "public"."invoices" to "anon";

grant trigger on table "public"."invoices" to "anon";

grant truncate on table "public"."invoices" to "anon";

grant update on table "public"."invoices" to "anon";

grant delete on table "public"."invoices" to "authenticated";

grant insert on table "public"."invoices" to "authenticated";

grant references on table "public"."invoices" to "authenticated";

grant select on table "public"."invoices" to "authenticated";

grant trigger on table "public"."invoices" to "authenticated";

grant truncate on table "public"."invoices" to "authenticated";

grant update on table "public"."invoices" to "authenticated";

grant delete on table "public"."invoices" to "service_role";

grant insert on table "public"."invoices" to "service_role";

grant references on table "public"."invoices" to "service_role";

grant select on table "public"."invoices" to "service_role";

grant trigger on table "public"."invoices" to "service_role";

grant truncate on table "public"."invoices" to "service_role";

grant update on table "public"."invoices" to "service_role";

grant delete on table "public"."locations" to "anon";

grant insert on table "public"."locations" to "anon";

grant references on table "public"."locations" to "anon";

grant select on table "public"."locations" to "anon";

grant trigger on table "public"."locations" to "anon";

grant truncate on table "public"."locations" to "anon";

grant update on table "public"."locations" to "anon";

grant delete on table "public"."locations" to "authenticated";

grant insert on table "public"."locations" to "authenticated";

grant references on table "public"."locations" to "authenticated";

grant select on table "public"."locations" to "authenticated";

grant trigger on table "public"."locations" to "authenticated";

grant truncate on table "public"."locations" to "authenticated";

grant update on table "public"."locations" to "authenticated";

grant delete on table "public"."locations" to "service_role";

grant insert on table "public"."locations" to "service_role";

grant references on table "public"."locations" to "service_role";

grant select on table "public"."locations" to "service_role";

grant trigger on table "public"."locations" to "service_role";

grant truncate on table "public"."locations" to "service_role";

grant update on table "public"."locations" to "service_role";

grant delete on table "public"."network_connections" to "anon";

grant insert on table "public"."network_connections" to "anon";

grant references on table "public"."network_connections" to "anon";

grant select on table "public"."network_connections" to "anon";

grant trigger on table "public"."network_connections" to "anon";

grant truncate on table "public"."network_connections" to "anon";

grant update on table "public"."network_connections" to "anon";

grant delete on table "public"."network_connections" to "authenticated";

grant insert on table "public"."network_connections" to "authenticated";

grant references on table "public"."network_connections" to "authenticated";

grant select on table "public"."network_connections" to "authenticated";

grant trigger on table "public"."network_connections" to "authenticated";

grant truncate on table "public"."network_connections" to "authenticated";

grant update on table "public"."network_connections" to "authenticated";

grant delete on table "public"."network_connections" to "service_role";

grant insert on table "public"."network_connections" to "service_role";

grant references on table "public"."network_connections" to "service_role";

grant select on table "public"."network_connections" to "service_role";

grant trigger on table "public"."network_connections" to "service_role";

grant truncate on table "public"."network_connections" to "service_role";

grant update on table "public"."network_connections" to "service_role";

grant delete on table "public"."network_devices" to "anon";

grant insert on table "public"."network_devices" to "anon";

grant references on table "public"."network_devices" to "anon";

grant select on table "public"."network_devices" to "anon";

grant trigger on table "public"."network_devices" to "anon";

grant truncate on table "public"."network_devices" to "anon";

grant update on table "public"."network_devices" to "anon";

grant delete on table "public"."network_devices" to "authenticated";

grant insert on table "public"."network_devices" to "authenticated";

grant references on table "public"."network_devices" to "authenticated";

grant select on table "public"."network_devices" to "authenticated";

grant trigger on table "public"."network_devices" to "authenticated";

grant truncate on table "public"."network_devices" to "authenticated";

grant update on table "public"."network_devices" to "authenticated";

grant delete on table "public"."network_devices" to "service_role";

grant insert on table "public"."network_devices" to "service_role";

grant references on table "public"."network_devices" to "service_role";

grant select on table "public"."network_devices" to "service_role";

grant trigger on table "public"."network_devices" to "service_role";

grant truncate on table "public"."network_devices" to "service_role";

grant update on table "public"."network_devices" to "service_role";

grant delete on table "public"."network_logs" to "anon";

grant insert on table "public"."network_logs" to "anon";

grant references on table "public"."network_logs" to "anon";

grant select on table "public"."network_logs" to "anon";

grant trigger on table "public"."network_logs" to "anon";

grant truncate on table "public"."network_logs" to "anon";

grant update on table "public"."network_logs" to "anon";

grant delete on table "public"."network_logs" to "authenticated";

grant insert on table "public"."network_logs" to "authenticated";

grant references on table "public"."network_logs" to "authenticated";

grant select on table "public"."network_logs" to "authenticated";

grant trigger on table "public"."network_logs" to "authenticated";

grant truncate on table "public"."network_logs" to "authenticated";

grant update on table "public"."network_logs" to "authenticated";

grant delete on table "public"."network_logs" to "service_role";

grant insert on table "public"."network_logs" to "service_role";

grant references on table "public"."network_logs" to "service_role";

grant select on table "public"."network_logs" to "service_role";

grant trigger on table "public"."network_logs" to "service_role";

grant truncate on table "public"."network_logs" to "service_role";

grant update on table "public"."network_logs" to "service_role";

grant delete on table "public"."notification_settings" to "anon";

grant insert on table "public"."notification_settings" to "anon";

grant references on table "public"."notification_settings" to "anon";

grant select on table "public"."notification_settings" to "anon";

grant trigger on table "public"."notification_settings" to "anon";

grant truncate on table "public"."notification_settings" to "anon";

grant update on table "public"."notification_settings" to "anon";

grant delete on table "public"."notification_settings" to "authenticated";

grant insert on table "public"."notification_settings" to "authenticated";

grant references on table "public"."notification_settings" to "authenticated";

grant select on table "public"."notification_settings" to "authenticated";

grant trigger on table "public"."notification_settings" to "authenticated";

grant truncate on table "public"."notification_settings" to "authenticated";

grant update on table "public"."notification_settings" to "authenticated";

grant delete on table "public"."notification_settings" to "service_role";

grant insert on table "public"."notification_settings" to "service_role";

grant references on table "public"."notification_settings" to "service_role";

grant select on table "public"."notification_settings" to "service_role";

grant trigger on table "public"."notification_settings" to "service_role";

grant truncate on table "public"."notification_settings" to "service_role";

grant update on table "public"."notification_settings" to "service_role";

grant delete on table "public"."notifications" to "anon";

grant insert on table "public"."notifications" to "anon";

grant references on table "public"."notifications" to "anon";

grant select on table "public"."notifications" to "anon";

grant trigger on table "public"."notifications" to "anon";

grant truncate on table "public"."notifications" to "anon";

grant update on table "public"."notifications" to "anon";

grant delete on table "public"."notifications" to "authenticated";

grant insert on table "public"."notifications" to "authenticated";

grant references on table "public"."notifications" to "authenticated";

grant select on table "public"."notifications" to "authenticated";

grant trigger on table "public"."notifications" to "authenticated";

grant truncate on table "public"."notifications" to "authenticated";

grant update on table "public"."notifications" to "authenticated";

grant delete on table "public"."notifications" to "service_role";

grant insert on table "public"."notifications" to "service_role";

grant references on table "public"."notifications" to "service_role";

grant select on table "public"."notifications" to "service_role";

grant trigger on table "public"."notifications" to "service_role";

grant truncate on table "public"."notifications" to "service_role";

grant update on table "public"."notifications" to "service_role";

grant delete on table "public"."orders" to "anon";

grant insert on table "public"."orders" to "anon";

grant references on table "public"."orders" to "anon";

grant select on table "public"."orders" to "anon";

grant trigger on table "public"."orders" to "anon";

grant truncate on table "public"."orders" to "anon";

grant update on table "public"."orders" to "anon";

grant delete on table "public"."orders" to "authenticated";

grant insert on table "public"."orders" to "authenticated";

grant references on table "public"."orders" to "authenticated";

grant select on table "public"."orders" to "authenticated";

grant trigger on table "public"."orders" to "authenticated";

grant truncate on table "public"."orders" to "authenticated";

grant update on table "public"."orders" to "authenticated";

grant delete on table "public"."orders" to "service_role";

grant insert on table "public"."orders" to "service_role";

grant references on table "public"."orders" to "service_role";

grant select on table "public"."orders" to "service_role";

grant trigger on table "public"."orders" to "service_role";

grant truncate on table "public"."orders" to "service_role";

grant update on table "public"."orders" to "service_role";

grant delete on table "public"."partner_companies" to "anon";

grant insert on table "public"."partner_companies" to "anon";

grant references on table "public"."partner_companies" to "anon";

grant select on table "public"."partner_companies" to "anon";

grant trigger on table "public"."partner_companies" to "anon";

grant truncate on table "public"."partner_companies" to "anon";

grant update on table "public"."partner_companies" to "anon";

grant delete on table "public"."partner_companies" to "authenticated";

grant insert on table "public"."partner_companies" to "authenticated";

grant references on table "public"."partner_companies" to "authenticated";

grant select on table "public"."partner_companies" to "authenticated";

grant trigger on table "public"."partner_companies" to "authenticated";

grant truncate on table "public"."partner_companies" to "authenticated";

grant update on table "public"."partner_companies" to "authenticated";

grant delete on table "public"."partner_companies" to "service_role";

grant insert on table "public"."partner_companies" to "service_role";

grant references on table "public"."partner_companies" to "service_role";

grant select on table "public"."partner_companies" to "service_role";

grant trigger on table "public"."partner_companies" to "service_role";

grant truncate on table "public"."partner_companies" to "service_role";

grant update on table "public"."partner_companies" to "service_role";

grant delete on table "public"."partner_users" to "anon";

grant insert on table "public"."partner_users" to "anon";

grant references on table "public"."partner_users" to "anon";

grant select on table "public"."partner_users" to "anon";

grant trigger on table "public"."partner_users" to "anon";

grant truncate on table "public"."partner_users" to "anon";

grant update on table "public"."partner_users" to "anon";

grant delete on table "public"."partner_users" to "authenticated";

grant insert on table "public"."partner_users" to "authenticated";

grant references on table "public"."partner_users" to "authenticated";

grant select on table "public"."partner_users" to "authenticated";

grant trigger on table "public"."partner_users" to "authenticated";

grant truncate on table "public"."partner_users" to "authenticated";

grant update on table "public"."partner_users" to "authenticated";

grant delete on table "public"."partner_users" to "service_role";

grant insert on table "public"."partner_users" to "service_role";

grant references on table "public"."partner_users" to "service_role";

grant select on table "public"."partner_users" to "service_role";

grant trigger on table "public"."partner_users" to "service_role";

grant truncate on table "public"."partner_users" to "service_role";

grant update on table "public"."partner_users" to "service_role";

grant delete on table "public"."partners" to "anon";

grant insert on table "public"."partners" to "anon";

grant references on table "public"."partners" to "anon";

grant select on table "public"."partners" to "anon";

grant trigger on table "public"."partners" to "anon";

grant truncate on table "public"."partners" to "anon";

grant update on table "public"."partners" to "anon";

grant delete on table "public"."partners" to "authenticated";

grant insert on table "public"."partners" to "authenticated";

grant references on table "public"."partners" to "authenticated";

grant select on table "public"."partners" to "authenticated";

grant trigger on table "public"."partners" to "authenticated";

grant truncate on table "public"."partners" to "authenticated";

grant update on table "public"."partners" to "authenticated";

grant delete on table "public"."partners" to "service_role";

grant insert on table "public"."partners" to "service_role";

grant references on table "public"."partners" to "service_role";

grant select on table "public"."partners" to "service_role";

grant trigger on table "public"."partners" to "service_role";

grant truncate on table "public"."partners" to "service_role";

grant update on table "public"."partners" to "service_role";

grant delete on table "public"."payment_items" to "anon";

grant insert on table "public"."payment_items" to "anon";

grant references on table "public"."payment_items" to "anon";

grant select on table "public"."payment_items" to "anon";

grant trigger on table "public"."payment_items" to "anon";

grant truncate on table "public"."payment_items" to "anon";

grant update on table "public"."payment_items" to "anon";

grant delete on table "public"."payment_items" to "authenticated";

grant insert on table "public"."payment_items" to "authenticated";

grant references on table "public"."payment_items" to "authenticated";

grant select on table "public"."payment_items" to "authenticated";

grant trigger on table "public"."payment_items" to "authenticated";

grant truncate on table "public"."payment_items" to "authenticated";

grant update on table "public"."payment_items" to "authenticated";

grant delete on table "public"."payment_items" to "service_role";

grant insert on table "public"."payment_items" to "service_role";

grant references on table "public"."payment_items" to "service_role";

grant select on table "public"."payment_items" to "service_role";

grant trigger on table "public"."payment_items" to "service_role";

grant truncate on table "public"."payment_items" to "service_role";

grant update on table "public"."payment_items" to "service_role";

grant delete on table "public"."payment_methods" to "anon";

grant insert on table "public"."payment_methods" to "anon";

grant references on table "public"."payment_methods" to "anon";

grant select on table "public"."payment_methods" to "anon";

grant trigger on table "public"."payment_methods" to "anon";

grant truncate on table "public"."payment_methods" to "anon";

grant update on table "public"."payment_methods" to "anon";

grant delete on table "public"."payment_methods" to "authenticated";

grant insert on table "public"."payment_methods" to "authenticated";

grant references on table "public"."payment_methods" to "authenticated";

grant select on table "public"."payment_methods" to "authenticated";

grant trigger on table "public"."payment_methods" to "authenticated";

grant truncate on table "public"."payment_methods" to "authenticated";

grant update on table "public"."payment_methods" to "authenticated";

grant delete on table "public"."payment_methods" to "service_role";

grant insert on table "public"."payment_methods" to "service_role";

grant references on table "public"."payment_methods" to "service_role";

grant select on table "public"."payment_methods" to "service_role";

grant trigger on table "public"."payment_methods" to "service_role";

grant truncate on table "public"."payment_methods" to "service_role";

grant update on table "public"."payment_methods" to "service_role";

grant delete on table "public"."payments" to "anon";

grant insert on table "public"."payments" to "anon";

grant references on table "public"."payments" to "anon";

grant select on table "public"."payments" to "anon";

grant trigger on table "public"."payments" to "anon";

grant truncate on table "public"."payments" to "anon";

grant update on table "public"."payments" to "anon";

grant delete on table "public"."payments" to "authenticated";

grant insert on table "public"."payments" to "authenticated";

grant references on table "public"."payments" to "authenticated";

grant select on table "public"."payments" to "authenticated";

grant trigger on table "public"."payments" to "authenticated";

grant truncate on table "public"."payments" to "authenticated";

grant update on table "public"."payments" to "authenticated";

grant delete on table "public"."payments" to "service_role";

grant insert on table "public"."payments" to "service_role";

grant references on table "public"."payments" to "service_role";

grant select on table "public"."payments" to "service_role";

grant trigger on table "public"."payments" to "service_role";

grant truncate on table "public"."payments" to "service_role";

grant update on table "public"."payments" to "service_role";

grant delete on table "public"."pos_return_items" to "anon";

grant insert on table "public"."pos_return_items" to "anon";

grant references on table "public"."pos_return_items" to "anon";

grant select on table "public"."pos_return_items" to "anon";

grant trigger on table "public"."pos_return_items" to "anon";

grant truncate on table "public"."pos_return_items" to "anon";

grant update on table "public"."pos_return_items" to "anon";

grant delete on table "public"."pos_return_items" to "authenticated";

grant insert on table "public"."pos_return_items" to "authenticated";

grant references on table "public"."pos_return_items" to "authenticated";

grant select on table "public"."pos_return_items" to "authenticated";

grant trigger on table "public"."pos_return_items" to "authenticated";

grant truncate on table "public"."pos_return_items" to "authenticated";

grant update on table "public"."pos_return_items" to "authenticated";

grant delete on table "public"."pos_return_items" to "service_role";

grant insert on table "public"."pos_return_items" to "service_role";

grant references on table "public"."pos_return_items" to "service_role";

grant select on table "public"."pos_return_items" to "service_role";

grant trigger on table "public"."pos_return_items" to "service_role";

grant truncate on table "public"."pos_return_items" to "service_role";

grant update on table "public"."pos_return_items" to "service_role";

grant delete on table "public"."pos_returns" to "anon";

grant insert on table "public"."pos_returns" to "anon";

grant references on table "public"."pos_returns" to "anon";

grant select on table "public"."pos_returns" to "anon";

grant trigger on table "public"."pos_returns" to "anon";

grant truncate on table "public"."pos_returns" to "anon";

grant update on table "public"."pos_returns" to "anon";

grant delete on table "public"."pos_returns" to "authenticated";

grant insert on table "public"."pos_returns" to "authenticated";

grant references on table "public"."pos_returns" to "authenticated";

grant select on table "public"."pos_returns" to "authenticated";

grant trigger on table "public"."pos_returns" to "authenticated";

grant truncate on table "public"."pos_returns" to "authenticated";

grant update on table "public"."pos_returns" to "authenticated";

grant delete on table "public"."pos_returns" to "service_role";

grant insert on table "public"."pos_returns" to "service_role";

grant references on table "public"."pos_returns" to "service_role";

grant select on table "public"."pos_returns" to "service_role";

grant trigger on table "public"."pos_returns" to "service_role";

grant truncate on table "public"."pos_returns" to "service_role";

grant update on table "public"."pos_returns" to "service_role";

grant delete on table "public"."pos_sessions" to "anon";

grant insert on table "public"."pos_sessions" to "anon";

grant references on table "public"."pos_sessions" to "anon";

grant select on table "public"."pos_sessions" to "anon";

grant trigger on table "public"."pos_sessions" to "anon";

grant truncate on table "public"."pos_sessions" to "anon";

grant update on table "public"."pos_sessions" to "anon";

grant delete on table "public"."pos_sessions" to "authenticated";

grant insert on table "public"."pos_sessions" to "authenticated";

grant references on table "public"."pos_sessions" to "authenticated";

grant select on table "public"."pos_sessions" to "authenticated";

grant trigger on table "public"."pos_sessions" to "authenticated";

grant truncate on table "public"."pos_sessions" to "authenticated";

grant update on table "public"."pos_sessions" to "authenticated";

grant delete on table "public"."pos_sessions" to "service_role";

grant insert on table "public"."pos_sessions" to "service_role";

grant references on table "public"."pos_sessions" to "service_role";

grant select on table "public"."pos_sessions" to "service_role";

grant trigger on table "public"."pos_sessions" to "service_role";

grant truncate on table "public"."pos_sessions" to "service_role";

grant update on table "public"."pos_sessions" to "service_role";

grant delete on table "public"."pos_transaction_items" to "anon";

grant insert on table "public"."pos_transaction_items" to "anon";

grant references on table "public"."pos_transaction_items" to "anon";

grant select on table "public"."pos_transaction_items" to "anon";

grant trigger on table "public"."pos_transaction_items" to "anon";

grant truncate on table "public"."pos_transaction_items" to "anon";

grant update on table "public"."pos_transaction_items" to "anon";

grant delete on table "public"."pos_transaction_items" to "authenticated";

grant insert on table "public"."pos_transaction_items" to "authenticated";

grant references on table "public"."pos_transaction_items" to "authenticated";

grant select on table "public"."pos_transaction_items" to "authenticated";

grant trigger on table "public"."pos_transaction_items" to "authenticated";

grant truncate on table "public"."pos_transaction_items" to "authenticated";

grant update on table "public"."pos_transaction_items" to "authenticated";

grant delete on table "public"."pos_transaction_items" to "service_role";

grant insert on table "public"."pos_transaction_items" to "service_role";

grant references on table "public"."pos_transaction_items" to "service_role";

grant select on table "public"."pos_transaction_items" to "service_role";

grant trigger on table "public"."pos_transaction_items" to "service_role";

grant truncate on table "public"."pos_transaction_items" to "service_role";

grant update on table "public"."pos_transaction_items" to "service_role";

grant delete on table "public"."pos_transactions" to "anon";

grant insert on table "public"."pos_transactions" to "anon";

grant references on table "public"."pos_transactions" to "anon";

grant select on table "public"."pos_transactions" to "anon";

grant trigger on table "public"."pos_transactions" to "anon";

grant truncate on table "public"."pos_transactions" to "anon";

grant update on table "public"."pos_transactions" to "anon";

grant delete on table "public"."pos_transactions" to "authenticated";

grant insert on table "public"."pos_transactions" to "authenticated";

grant references on table "public"."pos_transactions" to "authenticated";

grant select on table "public"."pos_transactions" to "authenticated";

grant trigger on table "public"."pos_transactions" to "authenticated";

grant truncate on table "public"."pos_transactions" to "authenticated";

grant update on table "public"."pos_transactions" to "authenticated";

grant delete on table "public"."pos_transactions" to "service_role";

grant insert on table "public"."pos_transactions" to "service_role";

grant references on table "public"."pos_transactions" to "service_role";

grant select on table "public"."pos_transactions" to "service_role";

grant trigger on table "public"."pos_transactions" to "service_role";

grant truncate on table "public"."pos_transactions" to "service_role";

grant update on table "public"."pos_transactions" to "service_role";

grant delete on table "public"."product_inventory" to "anon";

grant insert on table "public"."product_inventory" to "anon";

grant references on table "public"."product_inventory" to "anon";

grant select on table "public"."product_inventory" to "anon";

grant trigger on table "public"."product_inventory" to "anon";

grant truncate on table "public"."product_inventory" to "anon";

grant update on table "public"."product_inventory" to "anon";

grant delete on table "public"."product_inventory" to "authenticated";

grant insert on table "public"."product_inventory" to "authenticated";

grant references on table "public"."product_inventory" to "authenticated";

grant select on table "public"."product_inventory" to "authenticated";

grant trigger on table "public"."product_inventory" to "authenticated";

grant truncate on table "public"."product_inventory" to "authenticated";

grant update on table "public"."product_inventory" to "authenticated";

grant delete on table "public"."product_inventory" to "service_role";

grant insert on table "public"."product_inventory" to "service_role";

grant references on table "public"."product_inventory" to "service_role";

grant select on table "public"."product_inventory" to "service_role";

grant trigger on table "public"."product_inventory" to "service_role";

grant truncate on table "public"."product_inventory" to "service_role";

grant update on table "public"."product_inventory" to "service_role";

grant delete on table "public"."production_batches" to "anon";

grant insert on table "public"."production_batches" to "anon";

grant references on table "public"."production_batches" to "anon";

grant select on table "public"."production_batches" to "anon";

grant trigger on table "public"."production_batches" to "anon";

grant truncate on table "public"."production_batches" to "anon";

grant update on table "public"."production_batches" to "anon";

grant delete on table "public"."production_batches" to "authenticated";

grant insert on table "public"."production_batches" to "authenticated";

grant references on table "public"."production_batches" to "authenticated";

grant select on table "public"."production_batches" to "authenticated";

grant trigger on table "public"."production_batches" to "authenticated";

grant truncate on table "public"."production_batches" to "authenticated";

grant update on table "public"."production_batches" to "authenticated";

grant delete on table "public"."production_batches" to "service_role";

grant insert on table "public"."production_batches" to "service_role";

grant references on table "public"."production_batches" to "service_role";

grant select on table "public"."production_batches" to "service_role";

grant trigger on table "public"."production_batches" to "service_role";

grant truncate on table "public"."production_batches" to "service_role";

grant update on table "public"."production_batches" to "service_role";

grant delete on table "public"."production_batches_orders" to "anon";

grant insert on table "public"."production_batches_orders" to "anon";

grant references on table "public"."production_batches_orders" to "anon";

grant select on table "public"."production_batches_orders" to "anon";

grant trigger on table "public"."production_batches_orders" to "anon";

grant truncate on table "public"."production_batches_orders" to "anon";

grant update on table "public"."production_batches_orders" to "anon";

grant delete on table "public"."production_batches_orders" to "authenticated";

grant insert on table "public"."production_batches_orders" to "authenticated";

grant references on table "public"."production_batches_orders" to "authenticated";

grant select on table "public"."production_batches_orders" to "authenticated";

grant trigger on table "public"."production_batches_orders" to "authenticated";

grant truncate on table "public"."production_batches_orders" to "authenticated";

grant update on table "public"."production_batches_orders" to "authenticated";

grant delete on table "public"."production_batches_orders" to "service_role";

grant insert on table "public"."production_batches_orders" to "service_role";

grant references on table "public"."production_batches_orders" to "service_role";

grant select on table "public"."production_batches_orders" to "service_role";

grant trigger on table "public"."production_batches_orders" to "service_role";

grant truncate on table "public"."production_batches_orders" to "service_role";

grant update on table "public"."production_batches_orders" to "service_role";

grant delete on table "public"."production_steps" to "anon";

grant insert on table "public"."production_steps" to "anon";

grant references on table "public"."production_steps" to "anon";

grant select on table "public"."production_steps" to "anon";

grant trigger on table "public"."production_steps" to "anon";

grant truncate on table "public"."production_steps" to "anon";

grant update on table "public"."production_steps" to "anon";

grant delete on table "public"."production_steps" to "authenticated";

grant insert on table "public"."production_steps" to "authenticated";

grant references on table "public"."production_steps" to "authenticated";

grant select on table "public"."production_steps" to "authenticated";

grant trigger on table "public"."production_steps" to "authenticated";

grant truncate on table "public"."production_steps" to "authenticated";

grant update on table "public"."production_steps" to "authenticated";

grant delete on table "public"."production_steps" to "service_role";

grant insert on table "public"."production_steps" to "service_role";

grant references on table "public"."production_steps" to "service_role";

grant select on table "public"."production_steps" to "service_role";

grant trigger on table "public"."production_steps" to "service_role";

grant truncate on table "public"."production_steps" to "service_role";

grant update on table "public"."production_steps" to "service_role";

grant delete on table "public"."products" to "anon";

grant insert on table "public"."products" to "anon";

grant references on table "public"."products" to "anon";

grant select on table "public"."products" to "anon";

grant trigger on table "public"."products" to "anon";

grant truncate on table "public"."products" to "anon";

grant update on table "public"."products" to "anon";

grant delete on table "public"."products" to "authenticated";

grant insert on table "public"."products" to "authenticated";

grant references on table "public"."products" to "authenticated";

grant select on table "public"."products" to "authenticated";

grant trigger on table "public"."products" to "authenticated";

grant truncate on table "public"."products" to "authenticated";

grant update on table "public"."products" to "authenticated";

grant delete on table "public"."products" to "service_role";

grant insert on table "public"."products" to "service_role";

grant references on table "public"."products" to "service_role";

grant select on table "public"."products" to "service_role";

grant trigger on table "public"."products" to "service_role";

grant truncate on table "public"."products" to "service_role";

grant update on table "public"."products" to "service_role";

grant delete on table "public"."profiles" to "anon";

grant insert on table "public"."profiles" to "anon";

grant references on table "public"."profiles" to "anon";

grant select on table "public"."profiles" to "anon";

grant trigger on table "public"."profiles" to "anon";

grant truncate on table "public"."profiles" to "anon";

grant update on table "public"."profiles" to "anon";

grant delete on table "public"."profiles" to "authenticated";

grant insert on table "public"."profiles" to "authenticated";

grant references on table "public"."profiles" to "authenticated";

grant select on table "public"."profiles" to "authenticated";

grant trigger on table "public"."profiles" to "authenticated";

grant truncate on table "public"."profiles" to "authenticated";

grant update on table "public"."profiles" to "authenticated";

grant delete on table "public"."profiles" to "service_role";

grant insert on table "public"."profiles" to "service_role";

grant references on table "public"."profiles" to "service_role";

grant select on table "public"."profiles" to "service_role";

grant trigger on table "public"."profiles" to "service_role";

grant truncate on table "public"."profiles" to "service_role";

grant update on table "public"."profiles" to "service_role";

grant delete on table "public"."recipe_steps" to "anon";

grant insert on table "public"."recipe_steps" to "anon";

grant references on table "public"."recipe_steps" to "anon";

grant select on table "public"."recipe_steps" to "anon";

grant trigger on table "public"."recipe_steps" to "anon";

grant truncate on table "public"."recipe_steps" to "anon";

grant update on table "public"."recipe_steps" to "anon";

grant delete on table "public"."recipe_steps" to "authenticated";

grant insert on table "public"."recipe_steps" to "authenticated";

grant references on table "public"."recipe_steps" to "authenticated";

grant select on table "public"."recipe_steps" to "authenticated";

grant trigger on table "public"."recipe_steps" to "authenticated";

grant truncate on table "public"."recipe_steps" to "authenticated";

grant update on table "public"."recipe_steps" to "authenticated";

grant delete on table "public"."recipe_steps" to "service_role";

grant insert on table "public"."recipe_steps" to "service_role";

grant references on table "public"."recipe_steps" to "service_role";

grant select on table "public"."recipe_steps" to "service_role";

grant trigger on table "public"."recipe_steps" to "service_role";

grant truncate on table "public"."recipe_steps" to "service_role";

grant update on table "public"."recipe_steps" to "service_role";

grant delete on table "public"."recipes" to "anon";

grant insert on table "public"."recipes" to "anon";

grant references on table "public"."recipes" to "anon";

grant select on table "public"."recipes" to "anon";

grant trigger on table "public"."recipes" to "anon";

grant truncate on table "public"."recipes" to "anon";

grant update on table "public"."recipes" to "anon";

grant delete on table "public"."recipes" to "authenticated";

grant insert on table "public"."recipes" to "authenticated";

grant references on table "public"."recipes" to "authenticated";

grant select on table "public"."recipes" to "authenticated";

grant trigger on table "public"."recipes" to "authenticated";

grant truncate on table "public"."recipes" to "authenticated";

grant update on table "public"."recipes" to "authenticated";

grant delete on table "public"."recipes" to "service_role";

grant insert on table "public"."recipes" to "service_role";

grant references on table "public"."recipes" to "service_role";

grant select on table "public"."recipes" to "service_role";

grant trigger on table "public"."recipes" to "service_role";

grant truncate on table "public"."recipes" to "service_role";

grant update on table "public"."recipes" to "service_role";

grant delete on table "public"."scheduled_emails" to "anon";

grant insert on table "public"."scheduled_emails" to "anon";

grant references on table "public"."scheduled_emails" to "anon";

grant select on table "public"."scheduled_emails" to "anon";

grant trigger on table "public"."scheduled_emails" to "anon";

grant truncate on table "public"."scheduled_emails" to "anon";

grant update on table "public"."scheduled_emails" to "anon";

grant delete on table "public"."scheduled_emails" to "authenticated";

grant insert on table "public"."scheduled_emails" to "authenticated";

grant references on table "public"."scheduled_emails" to "authenticated";

grant select on table "public"."scheduled_emails" to "authenticated";

grant trigger on table "public"."scheduled_emails" to "authenticated";

grant truncate on table "public"."scheduled_emails" to "authenticated";

grant update on table "public"."scheduled_emails" to "authenticated";

grant delete on table "public"."scheduled_emails" to "service_role";

grant insert on table "public"."scheduled_emails" to "service_role";

grant references on table "public"."scheduled_emails" to "service_role";

grant select on table "public"."scheduled_emails" to "service_role";

grant trigger on table "public"."scheduled_emails" to "service_role";

grant truncate on table "public"."scheduled_emails" to "service_role";

grant update on table "public"."scheduled_emails" to "service_role";

grant delete on table "public"."schedules" to "anon";

grant insert on table "public"."schedules" to "anon";

grant references on table "public"."schedules" to "anon";

grant select on table "public"."schedules" to "anon";

grant trigger on table "public"."schedules" to "anon";

grant truncate on table "public"."schedules" to "anon";

grant update on table "public"."schedules" to "anon";

grant delete on table "public"."schedules" to "authenticated";

grant insert on table "public"."schedules" to "authenticated";

grant references on table "public"."schedules" to "authenticated";

grant select on table "public"."schedules" to "authenticated";

grant trigger on table "public"."schedules" to "authenticated";

grant truncate on table "public"."schedules" to "authenticated";

grant update on table "public"."schedules" to "authenticated";

grant delete on table "public"."schedules" to "service_role";

grant insert on table "public"."schedules" to "service_role";

grant references on table "public"."schedules" to "service_role";

grant select on table "public"."schedules" to "service_role";

grant trigger on table "public"."schedules" to "service_role";

grant truncate on table "public"."schedules" to "service_role";

grant update on table "public"."schedules" to "service_role";

grant delete on table "public"."security_logs" to "anon";

grant insert on table "public"."security_logs" to "anon";

grant references on table "public"."security_logs" to "anon";

grant select on table "public"."security_logs" to "anon";

grant trigger on table "public"."security_logs" to "anon";

grant truncate on table "public"."security_logs" to "anon";

grant update on table "public"."security_logs" to "anon";

grant delete on table "public"."security_logs" to "authenticated";

grant insert on table "public"."security_logs" to "authenticated";

grant references on table "public"."security_logs" to "authenticated";

grant select on table "public"."security_logs" to "authenticated";

grant trigger on table "public"."security_logs" to "authenticated";

grant truncate on table "public"."security_logs" to "authenticated";

grant update on table "public"."security_logs" to "authenticated";

grant delete on table "public"."security_logs" to "service_role";

grant insert on table "public"."security_logs" to "service_role";

grant references on table "public"."security_logs" to "service_role";

grant select on table "public"."security_logs" to "service_role";

grant trigger on table "public"."security_logs" to "service_role";

grant truncate on table "public"."security_logs" to "service_role";

grant update on table "public"."security_logs" to "service_role";

grant delete on table "public"."sensor_data" to "anon";

grant insert on table "public"."sensor_data" to "anon";

grant references on table "public"."sensor_data" to "anon";

grant select on table "public"."sensor_data" to "anon";

grant trigger on table "public"."sensor_data" to "anon";

grant truncate on table "public"."sensor_data" to "anon";

grant update on table "public"."sensor_data" to "anon";

grant delete on table "public"."sensor_data" to "authenticated";

grant insert on table "public"."sensor_data" to "authenticated";

grant references on table "public"."sensor_data" to "authenticated";

grant select on table "public"."sensor_data" to "authenticated";

grant trigger on table "public"."sensor_data" to "authenticated";

grant truncate on table "public"."sensor_data" to "authenticated";

grant update on table "public"."sensor_data" to "authenticated";

grant delete on table "public"."sensor_data" to "service_role";

grant insert on table "public"."sensor_data" to "service_role";

grant references on table "public"."sensor_data" to "service_role";

grant select on table "public"."sensor_data" to "service_role";

grant trigger on table "public"."sensor_data" to "service_role";

grant truncate on table "public"."sensor_data" to "service_role";

grant update on table "public"."sensor_data" to "service_role";

grant delete on table "public"."sent_emails" to "anon";

grant insert on table "public"."sent_emails" to "anon";

grant references on table "public"."sent_emails" to "anon";

grant select on table "public"."sent_emails" to "anon";

grant trigger on table "public"."sent_emails" to "anon";

grant truncate on table "public"."sent_emails" to "anon";

grant update on table "public"."sent_emails" to "anon";

grant delete on table "public"."sent_emails" to "authenticated";

grant insert on table "public"."sent_emails" to "authenticated";

grant references on table "public"."sent_emails" to "authenticated";

grant select on table "public"."sent_emails" to "authenticated";

grant trigger on table "public"."sent_emails" to "authenticated";

grant truncate on table "public"."sent_emails" to "authenticated";

grant update on table "public"."sent_emails" to "authenticated";

grant delete on table "public"."sent_emails" to "service_role";

grant insert on table "public"."sent_emails" to "service_role";

grant references on table "public"."sent_emails" to "service_role";

grant select on table "public"."sent_emails" to "service_role";

grant trigger on table "public"."sent_emails" to "service_role";

grant truncate on table "public"."sent_emails" to "service_role";

grant update on table "public"."sent_emails" to "service_role";

grant delete on table "public"."settings" to "anon";

grant insert on table "public"."settings" to "anon";

grant references on table "public"."settings" to "anon";

grant select on table "public"."settings" to "anon";

grant trigger on table "public"."settings" to "anon";

grant truncate on table "public"."settings" to "anon";

grant update on table "public"."settings" to "anon";

grant delete on table "public"."settings" to "authenticated";

grant insert on table "public"."settings" to "authenticated";

grant references on table "public"."settings" to "authenticated";

grant select on table "public"."settings" to "authenticated";

grant trigger on table "public"."settings" to "authenticated";

grant truncate on table "public"."settings" to "authenticated";

grant update on table "public"."settings" to "authenticated";

grant delete on table "public"."settings" to "service_role";

grant insert on table "public"."settings" to "service_role";

grant references on table "public"."settings" to "service_role";

grant select on table "public"."settings" to "service_role";

grant trigger on table "public"."settings" to "service_role";

grant truncate on table "public"."settings" to "service_role";

grant update on table "public"."settings" to "service_role";

grant delete on table "public"."store_inventory" to "anon";

grant insert on table "public"."store_inventory" to "anon";

grant references on table "public"."store_inventory" to "anon";

grant select on table "public"."store_inventory" to "anon";

grant trigger on table "public"."store_inventory" to "anon";

grant truncate on table "public"."store_inventory" to "anon";

grant update on table "public"."store_inventory" to "anon";

grant delete on table "public"."store_inventory" to "authenticated";

grant insert on table "public"."store_inventory" to "authenticated";

grant references on table "public"."store_inventory" to "authenticated";

grant select on table "public"."store_inventory" to "authenticated";

grant trigger on table "public"."store_inventory" to "authenticated";

grant truncate on table "public"."store_inventory" to "authenticated";

grant update on table "public"."store_inventory" to "authenticated";

grant delete on table "public"."store_inventory" to "service_role";

grant insert on table "public"."store_inventory" to "service_role";

grant references on table "public"."store_inventory" to "service_role";

grant select on table "public"."store_inventory" to "service_role";

grant trigger on table "public"."store_inventory" to "service_role";

grant truncate on table "public"."store_inventory" to "service_role";

grant update on table "public"."store_inventory" to "service_role";

grant delete on table "public"."stream_sessions" to "anon";

grant insert on table "public"."stream_sessions" to "anon";

grant references on table "public"."stream_sessions" to "anon";

grant select on table "public"."stream_sessions" to "anon";

grant trigger on table "public"."stream_sessions" to "anon";

grant truncate on table "public"."stream_sessions" to "anon";

grant update on table "public"."stream_sessions" to "anon";

grant delete on table "public"."stream_sessions" to "authenticated";

grant insert on table "public"."stream_sessions" to "authenticated";

grant references on table "public"."stream_sessions" to "authenticated";

grant select on table "public"."stream_sessions" to "authenticated";

grant trigger on table "public"."stream_sessions" to "authenticated";

grant truncate on table "public"."stream_sessions" to "authenticated";

grant update on table "public"."stream_sessions" to "authenticated";

grant delete on table "public"."stream_sessions" to "service_role";

grant insert on table "public"."stream_sessions" to "service_role";

grant references on table "public"."stream_sessions" to "service_role";

grant select on table "public"."stream_sessions" to "service_role";

grant trigger on table "public"."stream_sessions" to "service_role";

grant truncate on table "public"."stream_sessions" to "service_role";

grant update on table "public"."stream_sessions" to "service_role";

grant delete on table "public"."survey_questions" to "anon";

grant insert on table "public"."survey_questions" to "anon";

grant references on table "public"."survey_questions" to "anon";

grant select on table "public"."survey_questions" to "anon";

grant trigger on table "public"."survey_questions" to "anon";

grant truncate on table "public"."survey_questions" to "anon";

grant update on table "public"."survey_questions" to "anon";

grant delete on table "public"."survey_questions" to "authenticated";

grant insert on table "public"."survey_questions" to "authenticated";

grant references on table "public"."survey_questions" to "authenticated";

grant select on table "public"."survey_questions" to "authenticated";

grant trigger on table "public"."survey_questions" to "authenticated";

grant truncate on table "public"."survey_questions" to "authenticated";

grant update on table "public"."survey_questions" to "authenticated";

grant delete on table "public"."survey_questions" to "service_role";

grant insert on table "public"."survey_questions" to "service_role";

grant references on table "public"."survey_questions" to "service_role";

grant select on table "public"."survey_questions" to "service_role";

grant trigger on table "public"."survey_questions" to "service_role";

grant truncate on table "public"."survey_questions" to "service_role";

grant update on table "public"."survey_questions" to "service_role";

grant delete on table "public"."survey_responses" to "anon";

grant insert on table "public"."survey_responses" to "anon";

grant references on table "public"."survey_responses" to "anon";

grant select on table "public"."survey_responses" to "anon";

grant trigger on table "public"."survey_responses" to "anon";

grant truncate on table "public"."survey_responses" to "anon";

grant update on table "public"."survey_responses" to "anon";

grant delete on table "public"."survey_responses" to "authenticated";

grant insert on table "public"."survey_responses" to "authenticated";

grant references on table "public"."survey_responses" to "authenticated";

grant select on table "public"."survey_responses" to "authenticated";

grant trigger on table "public"."survey_responses" to "authenticated";

grant truncate on table "public"."survey_responses" to "authenticated";

grant update on table "public"."survey_responses" to "authenticated";

grant delete on table "public"."survey_responses" to "service_role";

grant insert on table "public"."survey_responses" to "service_role";

grant references on table "public"."survey_responses" to "service_role";

grant select on table "public"."survey_responses" to "service_role";

grant trigger on table "public"."survey_responses" to "service_role";

grant truncate on table "public"."survey_responses" to "service_role";

grant update on table "public"."survey_responses" to "service_role";

grant delete on table "public"."surveys" to "anon";

grant insert on table "public"."surveys" to "anon";

grant references on table "public"."surveys" to "anon";

grant select on table "public"."surveys" to "anon";

grant trigger on table "public"."surveys" to "anon";

grant truncate on table "public"."surveys" to "anon";

grant update on table "public"."surveys" to "anon";

grant delete on table "public"."surveys" to "authenticated";

grant insert on table "public"."surveys" to "authenticated";

grant references on table "public"."surveys" to "authenticated";

grant select on table "public"."surveys" to "authenticated";

grant trigger on table "public"."surveys" to "authenticated";

grant truncate on table "public"."surveys" to "authenticated";

grant update on table "public"."surveys" to "authenticated";

grant delete on table "public"."surveys" to "service_role";

grant insert on table "public"."surveys" to "service_role";

grant references on table "public"."surveys" to "service_role";

grant select on table "public"."surveys" to "service_role";

grant trigger on table "public"."surveys" to "service_role";

grant truncate on table "public"."surveys" to "service_role";

grant update on table "public"."surveys" to "service_role";

grant delete on table "public"."transactions" to "anon";

grant insert on table "public"."transactions" to "anon";

grant references on table "public"."transactions" to "anon";

grant select on table "public"."transactions" to "anon";

grant trigger on table "public"."transactions" to "anon";

grant truncate on table "public"."transactions" to "anon";

grant update on table "public"."transactions" to "anon";

grant delete on table "public"."transactions" to "authenticated";

grant insert on table "public"."transactions" to "authenticated";

grant references on table "public"."transactions" to "authenticated";

grant select on table "public"."transactions" to "authenticated";

grant trigger on table "public"."transactions" to "authenticated";

grant truncate on table "public"."transactions" to "authenticated";

grant update on table "public"."transactions" to "authenticated";

grant delete on table "public"."transactions" to "service_role";

grant insert on table "public"."transactions" to "service_role";

grant references on table "public"."transactions" to "service_role";

grant select on table "public"."transactions" to "service_role";

grant trigger on table "public"."transactions" to "service_role";

grant truncate on table "public"."transactions" to "service_role";

grant update on table "public"."transactions" to "service_role";

grant delete on table "public"."vehicle_damage_reports" to "anon";

grant insert on table "public"."vehicle_damage_reports" to "anon";

grant references on table "public"."vehicle_damage_reports" to "anon";

grant select on table "public"."vehicle_damage_reports" to "anon";

grant trigger on table "public"."vehicle_damage_reports" to "anon";

grant truncate on table "public"."vehicle_damage_reports" to "anon";

grant update on table "public"."vehicle_damage_reports" to "anon";

grant delete on table "public"."vehicle_damage_reports" to "authenticated";

grant insert on table "public"."vehicle_damage_reports" to "authenticated";

grant references on table "public"."vehicle_damage_reports" to "authenticated";

grant select on table "public"."vehicle_damage_reports" to "authenticated";

grant trigger on table "public"."vehicle_damage_reports" to "authenticated";

grant truncate on table "public"."vehicle_damage_reports" to "authenticated";

grant update on table "public"."vehicle_damage_reports" to "authenticated";

grant delete on table "public"."vehicle_damage_reports" to "service_role";

grant insert on table "public"."vehicle_damage_reports" to "service_role";

grant references on table "public"."vehicle_damage_reports" to "service_role";

grant select on table "public"."vehicle_damage_reports" to "service_role";

grant trigger on table "public"."vehicle_damage_reports" to "service_role";

grant truncate on table "public"."vehicle_damage_reports" to "service_role";

grant update on table "public"."vehicle_damage_reports" to "service_role";

grant delete on table "public"."vehicles" to "anon";

grant insert on table "public"."vehicles" to "anon";

grant references on table "public"."vehicles" to "anon";

grant select on table "public"."vehicles" to "anon";

grant trigger on table "public"."vehicles" to "anon";

grant truncate on table "public"."vehicles" to "anon";

grant update on table "public"."vehicles" to "anon";

grant delete on table "public"."vehicles" to "authenticated";

grant insert on table "public"."vehicles" to "authenticated";

grant references on table "public"."vehicles" to "authenticated";

grant select on table "public"."vehicles" to "authenticated";

grant trigger on table "public"."vehicles" to "authenticated";

grant truncate on table "public"."vehicles" to "authenticated";

grant update on table "public"."vehicles" to "authenticated";

grant delete on table "public"."vehicles" to "service_role";

grant insert on table "public"."vehicles" to "service_role";

grant references on table "public"."vehicles" to "service_role";

grant select on table "public"."vehicles" to "service_role";

grant trigger on table "public"."vehicles" to "service_role";

grant truncate on table "public"."vehicles" to "service_role";

grant update on table "public"."vehicles" to "service_role";

grant delete on table "public"."webshop_carts" to "anon";

grant insert on table "public"."webshop_carts" to "anon";

grant references on table "public"."webshop_carts" to "anon";

grant select on table "public"."webshop_carts" to "anon";

grant trigger on table "public"."webshop_carts" to "anon";

grant truncate on table "public"."webshop_carts" to "anon";

grant update on table "public"."webshop_carts" to "anon";

grant delete on table "public"."webshop_carts" to "authenticated";

grant insert on table "public"."webshop_carts" to "authenticated";

grant references on table "public"."webshop_carts" to "authenticated";

grant select on table "public"."webshop_carts" to "authenticated";

grant trigger on table "public"."webshop_carts" to "authenticated";

grant truncate on table "public"."webshop_carts" to "authenticated";

grant update on table "public"."webshop_carts" to "authenticated";

grant delete on table "public"."webshop_carts" to "service_role";

grant insert on table "public"."webshop_carts" to "service_role";

grant references on table "public"."webshop_carts" to "service_role";

grant select on table "public"."webshop_carts" to "service_role";

grant trigger on table "public"."webshop_carts" to "service_role";

grant truncate on table "public"."webshop_carts" to "service_role";

grant update on table "public"."webshop_carts" to "service_role";

grant delete on table "public"."webshop_customers" to "anon";

grant insert on table "public"."webshop_customers" to "anon";

grant references on table "public"."webshop_customers" to "anon";

grant select on table "public"."webshop_customers" to "anon";

grant trigger on table "public"."webshop_customers" to "anon";

grant truncate on table "public"."webshop_customers" to "anon";

grant update on table "public"."webshop_customers" to "anon";

grant delete on table "public"."webshop_customers" to "authenticated";

grant insert on table "public"."webshop_customers" to "authenticated";

grant references on table "public"."webshop_customers" to "authenticated";

grant select on table "public"."webshop_customers" to "authenticated";

grant trigger on table "public"."webshop_customers" to "authenticated";

grant truncate on table "public"."webshop_customers" to "authenticated";

grant update on table "public"."webshop_customers" to "authenticated";

grant delete on table "public"."webshop_customers" to "service_role";

grant insert on table "public"."webshop_customers" to "service_role";

grant references on table "public"."webshop_customers" to "service_role";

grant select on table "public"."webshop_customers" to "service_role";

grant trigger on table "public"."webshop_customers" to "service_role";

grant truncate on table "public"."webshop_customers" to "service_role";

grant update on table "public"."webshop_customers" to "service_role";

grant delete on table "public"."webshop_orders" to "anon";

grant insert on table "public"."webshop_orders" to "anon";

grant references on table "public"."webshop_orders" to "anon";

grant select on table "public"."webshop_orders" to "anon";

grant trigger on table "public"."webshop_orders" to "anon";

grant truncate on table "public"."webshop_orders" to "anon";

grant update on table "public"."webshop_orders" to "anon";

grant delete on table "public"."webshop_orders" to "authenticated";

grant insert on table "public"."webshop_orders" to "authenticated";

grant references on table "public"."webshop_orders" to "authenticated";

grant select on table "public"."webshop_orders" to "authenticated";

grant trigger on table "public"."webshop_orders" to "authenticated";

grant truncate on table "public"."webshop_orders" to "authenticated";

grant update on table "public"."webshop_orders" to "authenticated";

grant delete on table "public"."webshop_orders" to "service_role";

grant insert on table "public"."webshop_orders" to "service_role";

grant references on table "public"."webshop_orders" to "service_role";

grant select on table "public"."webshop_orders" to "service_role";

grant trigger on table "public"."webshop_orders" to "service_role";

grant truncate on table "public"."webshop_orders" to "service_role";

grant update on table "public"."webshop_orders" to "service_role";

grant delete on table "public"."webshop_pickup_locations" to "anon";

grant insert on table "public"."webshop_pickup_locations" to "anon";

grant references on table "public"."webshop_pickup_locations" to "anon";

grant select on table "public"."webshop_pickup_locations" to "anon";

grant trigger on table "public"."webshop_pickup_locations" to "anon";

grant truncate on table "public"."webshop_pickup_locations" to "anon";

grant update on table "public"."webshop_pickup_locations" to "anon";

grant delete on table "public"."webshop_pickup_locations" to "authenticated";

grant insert on table "public"."webshop_pickup_locations" to "authenticated";

grant references on table "public"."webshop_pickup_locations" to "authenticated";

grant select on table "public"."webshop_pickup_locations" to "authenticated";

grant trigger on table "public"."webshop_pickup_locations" to "authenticated";

grant truncate on table "public"."webshop_pickup_locations" to "authenticated";

grant update on table "public"."webshop_pickup_locations" to "authenticated";

grant delete on table "public"."webshop_pickup_locations" to "service_role";

grant insert on table "public"."webshop_pickup_locations" to "service_role";

grant references on table "public"."webshop_pickup_locations" to "service_role";

grant select on table "public"."webshop_pickup_locations" to "service_role";

grant trigger on table "public"."webshop_pickup_locations" to "service_role";

grant truncate on table "public"."webshop_pickup_locations" to "service_role";

grant update on table "public"."webshop_pickup_locations" to "service_role";

grant delete on table "public"."webshop_product_reviews" to "anon";

grant insert on table "public"."webshop_product_reviews" to "anon";

grant references on table "public"."webshop_product_reviews" to "anon";

grant select on table "public"."webshop_product_reviews" to "anon";

grant trigger on table "public"."webshop_product_reviews" to "anon";

grant truncate on table "public"."webshop_product_reviews" to "anon";

grant update on table "public"."webshop_product_reviews" to "anon";

grant delete on table "public"."webshop_product_reviews" to "authenticated";

grant insert on table "public"."webshop_product_reviews" to "authenticated";

grant references on table "public"."webshop_product_reviews" to "authenticated";

grant select on table "public"."webshop_product_reviews" to "authenticated";

grant trigger on table "public"."webshop_product_reviews" to "authenticated";

grant truncate on table "public"."webshop_product_reviews" to "authenticated";

grant update on table "public"."webshop_product_reviews" to "authenticated";

grant delete on table "public"."webshop_product_reviews" to "service_role";

grant insert on table "public"."webshop_product_reviews" to "service_role";

grant references on table "public"."webshop_product_reviews" to "service_role";

grant select on table "public"."webshop_product_reviews" to "service_role";

grant trigger on table "public"."webshop_product_reviews" to "service_role";

grant truncate on table "public"."webshop_product_reviews" to "service_role";

grant update on table "public"."webshop_product_reviews" to "service_role";

grant delete on table "public"."work_logs" to "anon";

grant insert on table "public"."work_logs" to "anon";

grant references on table "public"."work_logs" to "anon";

grant select on table "public"."work_logs" to "anon";

grant trigger on table "public"."work_logs" to "anon";

grant truncate on table "public"."work_logs" to "anon";

grant update on table "public"."work_logs" to "anon";

grant delete on table "public"."work_logs" to "authenticated";

grant insert on table "public"."work_logs" to "authenticated";

grant references on table "public"."work_logs" to "authenticated";

grant select on table "public"."work_logs" to "authenticated";

grant trigger on table "public"."work_logs" to "authenticated";

grant truncate on table "public"."work_logs" to "authenticated";

grant update on table "public"."work_logs" to "authenticated";

grant delete on table "public"."work_logs" to "service_role";

grant insert on table "public"."work_logs" to "service_role";

grant references on table "public"."work_logs" to "service_role";

grant select on table "public"."work_logs" to "service_role";

grant trigger on table "public"."work_logs" to "service_role";

grant truncate on table "public"."work_logs" to "service_role";

grant update on table "public"."work_logs" to "service_role";


  create policy "System can insert camera events"
  on "public"."camera_events"
  as permissive
  for insert
  to authenticated
with check ((auth.uid() = user_id));



  create policy "Users can acknowledge own camera events"
  on "public"."camera_events"
  as permissive
  for update
  to authenticated
using ((auth.uid() = user_id))
with check ((auth.uid() = user_id));



  create policy "Users can view own camera events"
  on "public"."camera_events"
  as permissive
  for select
  to authenticated
using ((auth.uid() = user_id));



  create policy "Users can manage own camera settings"
  on "public"."camera_settings"
  as permissive
  for all
  to authenticated
using ((auth.uid() = user_id))
with check ((auth.uid() = user_id));



  create policy "admin_cash_movements"
  on "public"."cash_movements"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "salesperson_cash_movements"
  on "public"."cash_movements"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'salesperson'::text)))));



  create policy "Adminok olvashatják az összes üzenetet"
  on "public"."chat_messages"
  as permissive
  for select
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Felhasználók frissíthetik saját üzeneteiket"
  on "public"."chat_messages"
  as permissive
  for update
  to authenticated
using ((sender_id = auth.uid()))
with check ((sender_id = auth.uid()));



  create policy "Felhasználók létrehozhatják saját üzeneteiket"
  on "public"."chat_messages"
  as permissive
  for insert
  to authenticated
with check ((sender_id = auth.uid()));



  create policy "Felhasználók olvashatják saját üzeneteiket"
  on "public"."chat_messages"
  as permissive
  for select
  to authenticated
using (((sender_id = auth.uid()) OR (receiver_id = auth.uid()) OR (receiver_id IS NULL)));



  create policy "Admins can manage all delivery notes"
  on "public"."delivery_notes"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))))
with check ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Bakers can create delivery notes"
  on "public"."delivery_notes"
  as permissive
  for insert
  to authenticated
with check ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = ANY (ARRAY['baker'::text, 'admin'::text]))))));



  create policy "Drivers can update their delivery notes"
  on "public"."delivery_notes"
  as permissive
  for update
  to authenticated
using (((driver_id = auth.uid()) OR (EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = ANY (ARRAY['admin'::text, 'baker'::text])))))))
with check (((driver_id = auth.uid()) OR (EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = ANY (ARRAY['admin'::text, 'baker'::text])))))));



  create policy "Staff can view delivery notes"
  on "public"."delivery_notes"
  as permissive
  for select
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = ANY (ARRAY['baker'::text, 'admin'::text, 'driver'::text, 'salesperson'::text]))))));



  create policy "Adminok kezelhetik a dokumentumokat"
  on "public"."documents"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Mindenki olvashatja a dokumentumokat"
  on "public"."documents"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Adminok kezelhetik az email sablonokat"
  on "public"."email_templates"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Mindenki olvashatja az email sablonokat"
  on "public"."email_templates"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Adminok kezelhetik az alkalmazottakat"
  on "public"."employees"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Mindenki olvashatja az alkalmazottakat"
  on "public"."employees"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Adminok kezelhetik az összes visszajelzést"
  on "public"."feedback"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Felhasználók kezelhetik saját visszajelzéseiket"
  on "public"."feedback"
  as permissive
  for all
  to authenticated
using ((user_id = auth.uid()));



  create policy "AI asszisztens hozzáférhet minden adathoz"
  on "public"."inventory"
  as permissive
  for select
  to service_role
using (true);



  create policy "Adminok kezelhetik az összes készletet"
  on "public"."inventory"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Hitelesített felhasználók kezelhetik a készletet"
  on "public"."inventory"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "Mindenki olvashatja a készletet"
  on "public"."inventory"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Adminok kezelhetik a számla sablonokat"
  on "public"."invoice_templates"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "All users can view invoice templates"
  on "public"."invoice_templates"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Admins can do everything"
  on "public"."invoices"
  as permissive
  for all
  to public
using ((EXISTS ( SELECT 1
   FROM auth.users
  WHERE ((users.id = auth.uid()) AND ((users.raw_user_meta_data ->> 'role'::text) = 'admin'::text)))));



  create policy "Users can manage own invoices"
  on "public"."invoices"
  as permissive
  for all
  to public
using ((created_by = auth.uid()));



  create policy "AI asszisztens hozzáférhet minden adathoz"
  on "public"."locations"
  as permissive
  for select
  to service_role
using (true);



  create policy "Adminok kezelhetik a helyszíneket"
  on "public"."locations"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Hitelesített felhasználók olvashatják a helyszíneket"
  on "public"."locations"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Allow internal logging"
  on "public"."network_logs"
  as permissive
  for insert
  to public
with check (true);



  create policy "admin_notification_settings"
  on "public"."notification_settings"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "user_notification_settings"
  on "public"."notification_settings"
  as permissive
  for all
  to authenticated
using ((user_id = auth.uid()));



  create policy "Adminok kezelhetik az összes értesítést"
  on "public"."notifications"
  as permissive
  for all
  to authenticated
using (true);



  create policy "Felhasználók frissíthetik saját értesítéseiket"
  on "public"."notifications"
  as permissive
  for update
  to authenticated
using ((user_id = auth.uid()))
with check ((user_id = auth.uid()));



  create policy "Felhasználók láthatják saját értesítéseiket"
  on "public"."notifications"
  as permissive
  for select
  to authenticated
using ((user_id = auth.uid()));



  create policy "AI asszisztens hozzáférhet minden adathoz"
  on "public"."orders"
  as permissive
  for select
  to service_role
using (true);



  create policy "Adminok kezelhetik az összes rendelést"
  on "public"."orders"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Adminok és eladók kezelhetik a rendeléseket"
  on "public"."orders"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = ANY (ARRAY['admin'::text, 'salesperson'::text]))))));



  create policy "Mindenki olvashatja a rendeléseket"
  on "public"."orders"
  as permissive
  for select
  to authenticated
using (true);



  create policy "AI asszisztens hozzáférhet minden adathoz"
  on "public"."partner_companies"
  as permissive
  for select
  to service_role
using (true);



  create policy "Adminok kezelhetik a partner cégeket"
  on "public"."partner_companies"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Adminok kezelhetik az összes partner céget"
  on "public"."partner_companies"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Mindenki olvashatja a partner cégeket"
  on "public"."partner_companies"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Adminok kezelhetik az összes partner kapcsolatot"
  on "public"."partner_users"
  as permissive
  for all
  to authenticated
using (true);



  create policy "Felhasználók olvashatják saját partner kapcsolataikat"
  on "public"."partner_users"
  as permissive
  for select
  to authenticated
using ((user_id = auth.uid()));



  create policy "Payment items access policy"
  on "public"."payment_items"
  as permissive
  for all
  to public
using ((EXISTS ( SELECT 1
   FROM public.payments
  WHERE ((payments.id = payment_items.payment_id) AND ((EXISTS ( SELECT 1
           FROM public.profiles
          WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))) OR ((payments.user_id = auth.uid()) AND (EXISTS ( SELECT 1
           FROM public.profiles
          WHERE ((profiles.id = auth.uid()) AND (profiles.role = ANY (ARRAY['baker'::text, 'salesperson'::text, 'driver'::text])))))))))))
with check ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Admins can manage payment methods"
  on "public"."payment_methods"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Everyone can view active payment methods"
  on "public"."payment_methods"
  as permissive
  for select
  to authenticated
using ((is_active = true));



  create policy "Payment access policy"
  on "public"."payments"
  as permissive
  for all
  to public
using (
CASE
    WHEN (EXISTS ( SELECT 1
       FROM public.profiles
      WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))) THEN true
    WHEN (EXISTS ( SELECT 1
       FROM public.profiles
      WHERE ((profiles.id = auth.uid()) AND (profiles.role = ANY (ARRAY['baker'::text, 'salesperson'::text, 'driver'::text]))))) THEN (auth.uid() = user_id)
    ELSE false
END)
with check ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "admin_pos_return_items"
  on "public"."pos_return_items"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "salesperson_pos_return_items"
  on "public"."pos_return_items"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'salesperson'::text)))));



  create policy "admin_pos_returns"
  on "public"."pos_returns"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "salesperson_pos_returns"
  on "public"."pos_returns"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'salesperson'::text)))));



  create policy "Adminok kezelhetik az összes POS munkamenetet"
  on "public"."pos_sessions"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Eladók kezelhetik a saját POS munkameneteiket"
  on "public"."pos_sessions"
  as permissive
  for all
  to authenticated
using (((cashier_id = auth.uid()) OR (EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'salesperson'::text))))));



  create policy "Mindenki olvashatja a POS munkameneteket"
  on "public"."pos_sessions"
  as permissive
  for select
  to authenticated
using (true);



  create policy "admin_pos_sessions"
  on "public"."pos_sessions"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "salesperson_pos_sessions"
  on "public"."pos_sessions"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'salesperson'::text)))));



  create policy "admin_pos_transaction_items"
  on "public"."pos_transaction_items"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "salesperson_pos_transaction_items"
  on "public"."pos_transaction_items"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'salesperson'::text)))));



  create policy "Adminok kezelhetik az összes POS tranzakciót"
  on "public"."pos_transactions"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Eladók kezelhetik a saját POS tranzakcióikat"
  on "public"."pos_transactions"
  as permissive
  for all
  to authenticated
using (((cashier_id = auth.uid()) OR (EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'salesperson'::text))))));



  create policy "Mindenki olvashatja a POS tranzakciókat"
  on "public"."pos_transactions"
  as permissive
  for select
  to authenticated
using (true);



  create policy "admin_pos_transactions"
  on "public"."pos_transactions"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "salesperson_pos_transactions"
  on "public"."pos_transactions"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'salesperson'::text)))));



  create policy "Adminok kezelhetik az összes termék készletet"
  on "public"."product_inventory"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Hitelesített felhasználók kezelhetik a termék készletet"
  on "public"."product_inventory"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "Mindenki olvashatja a termék készletet"
  on "public"."product_inventory"
  as permissive
  for select
  to authenticated
using (true);



  create policy "AI asszisztens hozzáférhet minden adathoz"
  on "public"."production_batches"
  as permissive
  for select
  to service_role
using (true);



  create policy "Adminok kezelhetik az összes gyártási tételt"
  on "public"."production_batches"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Mindenki olvashatja a gyártási tételeket"
  on "public"."production_batches"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Pékek és adminok kezelhetik a gyártási tételeket"
  on "public"."production_batches"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = ANY (ARRAY['admin'::text, 'baker'::text]))))));



  create policy "Adminok kezelhetik az összes gyártási tétel-rendelés kapcs"
  on "public"."production_batches_orders"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Admins can manage all production steps"
  on "public"."production_steps"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))))
with check ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Bakers can manage production steps"
  on "public"."production_steps"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = ANY (ARRAY['baker'::text, 'admin'::text]))))))
with check ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = ANY (ARRAY['baker'::text, 'admin'::text]))))));



  create policy "Salespersons can view production steps"
  on "public"."production_steps"
  as permissive
  for select
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = ANY (ARRAY['salesperson'::text, 'baker'::text, 'admin'::text]))))));



  create policy "Users can insert production steps"
  on "public"."production_steps"
  as permissive
  for insert
  to authenticated
with check (true);



  create policy "Users can read production steps"
  on "public"."production_steps"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Users can update production steps"
  on "public"."production_steps"
  as permissive
  for update
  to authenticated
using (true);



  create policy "AI asszisztens hozzáférhet minden adathoz"
  on "public"."products"
  as permissive
  for select
  to service_role
using (true);



  create policy "Adminok kezelhetik az összes terméket"
  on "public"."products"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Mindenki olvashatja a termékeket"
  on "public"."products"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Névtelen felhasználók olvashatják a termékeket"
  on "public"."products"
  as permissive
  for select
  to anon
using (true);



  create policy "Pékek és adminok kezelhetik a termékeket"
  on "public"."products"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = ANY (ARRAY['admin'::text, 'baker'::text]))))));



  create policy "AI asszisztens hozzáférhet minden adathoz"
  on "public"."profiles"
  as permissive
  for select
  to service_role
using (true);



  create policy "Adminok kezelhetik az összes profilt"
  on "public"."profiles"
  as permissive
  for all
  to authenticated
using (true);



  create policy "Felhasználók olvashatják és frissíthetik saját profiljuka"
  on "public"."profiles"
  as permissive
  for all
  to authenticated
using ((auth.uid() = id))
with check ((auth.uid() = id));



  create policy "Adminok kezelhetik az összes recept lépést"
  on "public"."recipe_steps"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Mindenki olvashatja a recept lépéseket"
  on "public"."recipe_steps"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Pékek és adminok kezelhetik a recept lépéseket"
  on "public"."recipe_steps"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = ANY (ARRAY['admin'::text, 'baker'::text]))))));



  create policy "Users can insert recipe steps"
  on "public"."recipe_steps"
  as permissive
  for insert
  to authenticated
with check (true);



  create policy "Users can read recipe steps"
  on "public"."recipe_steps"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Users can update recipe steps"
  on "public"."recipe_steps"
  as permissive
  for update
  to authenticated
using (true);



  create policy "Mindenki olvashatja a recepteket"
  on "public"."recipes"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Pékek és adminok kezelhetik a recepteket"
  on "public"."recipes"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = ANY (ARRAY['admin'::text, 'baker'::text]))))));



  create policy "Adminok kezelhetik az ütemezett emaileket"
  on "public"."scheduled_emails"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Adminok olvashatják az ütemezett emaileket"
  on "public"."scheduled_emails"
  as permissive
  for select
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Adminok kezelhetik az összes beosztást"
  on "public"."schedules"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Felhasználók olvashatják saját beosztásukat"
  on "public"."schedules"
  as permissive
  for select
  to authenticated
using ((employee_id = auth.uid()));



  create policy "System can insert security logs"
  on "public"."security_logs"
  as permissive
  for insert
  to authenticated
with check ((auth.uid() = user_id));



  create policy "Users can view own security logs"
  on "public"."security_logs"
  as permissive
  for select
  to authenticated
using ((auth.uid() = user_id));



  create policy "Adminok kezelhetik az érzékelő adatokat"
  on "public"."sensor_data"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Mindenki olvashatja az érzékelő adatokat"
  on "public"."sensor_data"
  as permissive
  for select
  to authenticated
using (true);



  create policy "admin_sensor_data"
  on "public"."sensor_data"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = ( SELECT auth.uid() AS uid)) AND (profiles.role = 'admin'::text)))));



  create policy "read_sensor_data"
  on "public"."sensor_data"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Adminok kezelhetik az elküldött emaileket"
  on "public"."sent_emails"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Adminok olvashatják az elküldött emaileket"
  on "public"."sent_emails"
  as permissive
  for select
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Adminok kezelhetik az összes beállítást"
  on "public"."settings"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Minden felhasználó olvashatja az összes beállítást"
  on "public"."settings"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Adminok kezelhetik az összes bolti készletet"
  on "public"."store_inventory"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Hitelesített felhasználók kezelhetik a bolti készletet"
  on "public"."store_inventory"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "Mindenki olvashatja a bolti készletet"
  on "public"."store_inventory"
  as permissive
  for select
  to authenticated
using (true);



  create policy "admin_store_inventory"
  on "public"."store_inventory"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "salesperson_store_inventory"
  on "public"."store_inventory"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'salesperson'::text)))));



  create policy "Users can manage own stream sessions"
  on "public"."stream_sessions"
  as permissive
  for all
  to authenticated
using ((auth.uid() = user_id))
with check ((auth.uid() = user_id));



  create policy "Adminok kezelhetik a felmérés kérdéseket"
  on "public"."survey_questions"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Mindenki olvashatja a felmérés kérdéseket"
  on "public"."survey_questions"
  as permissive
  for select
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.surveys
  WHERE ((surveys.id = survey_questions.survey_id) AND ((surveys.status = 'active'::text) OR (surveys.status = 'completed'::text))))));



  create policy "Adminok olvashatják az összes választ"
  on "public"."survey_responses"
  as permissive
  for select
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Felhasználók létrehozhatják saját válaszaikat"
  on "public"."survey_responses"
  as permissive
  for insert
  to authenticated
with check ((user_id = auth.uid()));



  create policy "Felhasználók olvashatják saját válaszaikat"
  on "public"."survey_responses"
  as permissive
  for select
  to authenticated
using ((user_id = auth.uid()));



  create policy "Adminok kezelhetik a felméréseket"
  on "public"."surveys"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Mindenki olvashatja az aktív felméréseket"
  on "public"."surveys"
  as permissive
  for select
  to authenticated
using (((status = 'active'::text) OR (status = 'completed'::text)));



  create policy "Adminok kezelhetik az összes kárjelentést"
  on "public"."vehicle_damage_reports"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Felhasználók láthatják saját kárjelentéseiket"
  on "public"."vehicle_damage_reports"
  as permissive
  for select
  to authenticated
using ((reporter_id = auth.uid()));



  create policy "Felhasználók létrehozhatják saját kárjelentéseiket"
  on "public"."vehicle_damage_reports"
  as permissive
  for insert
  to authenticated
with check ((reporter_id = auth.uid()));



  create policy "Adminok kezelhetik az összes járművet"
  on "public"."vehicles"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Adminok és sofőrök kezelhetik a járműveket"
  on "public"."vehicles"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = ANY (ARRAY['admin'::text, 'driver'::text]))))));



  create policy "Mindenki olvashatja a járműveket"
  on "public"."vehicles"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Adminok láthatják az összes kosarat"
  on "public"."webshop_carts"
  as permissive
  for select
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Ügyfelek kezelhetik saját kosaraikat"
  on "public"."webshop_carts"
  as permissive
  for all
  to authenticated
using ((customer_id = auth.uid()))
with check ((customer_id = auth.uid()));



  create policy "Adminok láthatják az összes ügyfél adatát"
  on "public"."webshop_customers"
  as permissive
  for select
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Ügyfelek kezelhetik saját adataikat"
  on "public"."webshop_customers"
  as permissive
  for all
  to authenticated
using ((id = auth.uid()))
with check ((id = auth.uid()));



  create policy "Adminok kezelhetik az összes webshop rendelést"
  on "public"."webshop_orders"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Adminok és eladók kezelhetik az összes webshop rendelést"
  on "public"."webshop_orders"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = ANY (ARRAY['admin'::text, 'salesperson'::text]))))));



  create policy "Ügyfelek láthatják saját rendeléseiket"
  on "public"."webshop_orders"
  as permissive
  for select
  to authenticated
using ((customer_id = auth.uid()));



  create policy "view_pickup_locations"
  on "public"."webshop_pickup_locations"
  as permissive
  for select
  to public
using (true);



  create policy "Adminok kezelhetik az összes értékelést"
  on "public"."webshop_product_reviews"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Mindenki olvashatja a jóváhagyott értékeléseket"
  on "public"."webshop_product_reviews"
  as permissive
  for select
  to authenticated
using ((is_approved = true));



  create policy "Ügyfelek kezelhetik saját értékeléseiket"
  on "public"."webshop_product_reviews"
  as permissive
  for all
  to authenticated
using ((customer_id = auth.uid()))
with check ((customer_id = auth.uid()));



  create policy "Adminok kezelhetik az összes munkanaplót"
  on "public"."work_logs"
  as permissive
  for all
  to authenticated
using (true);



  create policy "Admins can manage all work logs"
  on "public"."work_logs"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text)))));



  create policy "Felhasználók kezelhetik saját munkanaplójukat"
  on "public"."work_logs"
  as permissive
  for all
  to authenticated
using ((employee_id = auth.uid()))
with check ((employee_id = auth.uid()));



  create policy "Minden felhasználó olvashatja az összes munkanaplót"
  on "public"."work_logs"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Service role can manage all work logs"
  on "public"."work_logs"
  as permissive
  for all
  to service_role
using (true)
with check (true);



  create policy "Users can manage own work logs"
  on "public"."work_logs"
  as permissive
  for all
  to authenticated
using ((employee_id = auth.uid()))
with check ((employee_id = auth.uid()));


CREATE TRIGGER update_camera_settings_updated_at BEFORE UPDATE ON public.camera_settings FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_cash_movements_updated_at BEFORE UPDATE ON public.cash_movements FOR EACH ROW EXECUTE FUNCTION public.update_cash_movements_updated_at();

CREATE TRIGGER update_delivery_notes_updated_at BEFORE UPDATE ON public.delivery_notes FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_documents_updated_at BEFORE UPDATE ON public.documents FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_email_templates_updated_at BEFORE UPDATE ON public.email_templates FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_employees_updated_at BEFORE UPDATE ON public.employees FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_inventory_updated_at BEFORE UPDATE ON public.inventory FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_invoice_number_trigger BEFORE INSERT ON public.invoices FOR EACH ROW EXECUTE FUNCTION public.set_invoice_number();

CREATE TRIGGER update_invoices_modtime BEFORE UPDATE ON public.invoices FOR EACH ROW EXECUTE FUNCTION public.update_modified_column();

CREATE TRIGGER update_locations_updated_at BEFORE UPDATE ON public.locations FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_network_connections_updated_at BEFORE UPDATE ON public.network_connections FOR EACH ROW EXECUTE FUNCTION public.update_network_updated_at_column();

CREATE TRIGGER device_status_webhook_trigger AFTER UPDATE OF status ON public.network_devices FOR EACH ROW WHEN ((old.status IS DISTINCT FROM new.status)) EXECUTE FUNCTION public.trigger_device_status_webhook();

CREATE TRIGGER update_network_devices_updated_at BEFORE UPDATE ON public.network_devices FOR EACH ROW EXECUTE FUNCTION public.update_network_updated_at_column();

CREATE TRIGGER update_notification_settings_updated_at BEFORE UPDATE ON public.notification_settings FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_partner_companies_updated_at BEFORE UPDATE ON public.partner_companies FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON public.payments FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER on_pos_return_item_insert AFTER INSERT ON public.pos_return_items FOR EACH ROW EXECUTE FUNCTION public.add_stock_on_return();

CREATE TRIGGER trigger_return_inventory_update AFTER INSERT ON public.pos_return_items FOR EACH ROW EXECUTE FUNCTION public.handle_return_inventory_update();

CREATE TRIGGER update_pos_return_items_updated_at BEFORE UPDATE ON public.pos_return_items FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER generate_return_number_trigger BEFORE INSERT ON public.pos_returns FOR EACH ROW EXECUTE FUNCTION public.generate_return_number();

CREATE TRIGGER update_pos_returns_updated_at BEFORE UPDATE ON public.pos_returns FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER generate_session_number_trigger BEFORE INSERT ON public.pos_sessions FOR EACH ROW EXECUTE FUNCTION public.generate_session_number();

CREATE TRIGGER update_pos_sessions_updated_at BEFORE UPDATE ON public.pos_sessions FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER enforce_product_exists BEFORE INSERT OR UPDATE ON public.pos_transaction_items FOR EACH ROW EXECUTE FUNCTION public.validate_product_id();

CREATE TRIGGER update_pos_transaction_items_updated_at BEFORE UPDATE ON public.pos_transaction_items FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_store_inventory_on_transaction AFTER INSERT ON public.pos_transaction_items FOR EACH ROW EXECUTE FUNCTION public.update_store_inventory_on_transaction();

CREATE TRIGGER generate_transaction_number_trigger BEFORE INSERT ON public.pos_transactions FOR EACH ROW EXECUTE FUNCTION public.generate_transaction_number();

CREATE TRIGGER update_pos_transactions_updated_at BEFORE UPDATE ON public.pos_transactions FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_product_inventory_updated_at BEFORE UPDATE ON public.product_inventory FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_production_batches_updated_at BEFORE UPDATE ON public.production_batches FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_recipes_updated_at BEFORE UPDATE ON public.recipes FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_scheduled_emails_updated_at BEFORE UPDATE ON public.scheduled_emails FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_schedules_updated_at BEFORE UPDATE ON public.schedules FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER trigger_cleanup_old_sensor_data AFTER INSERT ON public.sensor_data FOR EACH STATEMENT EXECUTE FUNCTION public.cleanup_old_sensor_data();

CREATE TRIGGER update_settings_updated_at BEFORE UPDATE ON public.settings FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_store_inventory_updated_at BEFORE UPDATE ON public.store_inventory FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_surveys_updated_at BEFORE UPDATE ON public.surveys FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_vehicle_damage_reports_updated_at BEFORE UPDATE ON public.vehicle_damage_reports FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_vehicles_updated_at BEFORE UPDATE ON public.vehicles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_webshop_carts_updated_at BEFORE UPDATE ON public.webshop_carts FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_webshop_customers_updated_at BEFORE UPDATE ON public.webshop_customers FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_webshop_orders_updated_at BEFORE UPDATE ON public.webshop_orders FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_webshop_pickup_locations_modtime BEFORE UPDATE ON public.webshop_pickup_locations FOR EACH ROW EXECUTE FUNCTION public.update_pickup_location_modified_column();

CREATE TRIGGER update_webshop_product_reviews_updated_at BEFORE UPDATE ON public.webshop_product_reviews FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_work_logs_updated_at BEFORE UPDATE ON public.work_logs FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_oauth_user_metadata();

CREATE TRIGGER set_default_password_trigger BEFORE INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.set_default_password();


  create policy "Allow authenticated users to manage their own files"
  on "storage"."objects"
  as permissive
  for delete
  to public
using ((auth.uid() = owner));



  create policy "Allow authenticated users to upload"
  on "storage"."objects"
  as permissive
  for insert
  to public
with check ((auth.role() = 'authenticated'::text));



  create policy "Anyone can view avatars"
  on "storage"."objects"
  as permissive
  for select
  to public
using ((bucket_id = 'avatars'::text));



  create policy "Anyone can view images"
  on "storage"."objects"
  as permissive
  for select
  to public
using ((bucket_id = 'images'::text));



  create policy "Authenticated users can delete their own images"
  on "storage"."objects"
  as permissive
  for delete
  to authenticated
using ((bucket_id = 'images'::text));



  create policy "Authenticated users can update their own images"
  on "storage"."objects"
  as permissive
  for update
  to authenticated
using ((bucket_id = 'images'::text))
with check ((bucket_id = 'images'::text));



  create policy "Authenticated users can upload images"
  on "storage"."objects"
  as permissive
  for insert
  to authenticated
with check ((bucket_id = 'images'::text));



  create policy "Owners can delete their images"
  on "storage"."objects"
  as permissive
  for delete
  to authenticated
using (((bucket_id = 'images'::text) AND (owner = auth.uid())));



  create policy "Owners can update and delete their images"
  on "storage"."objects"
  as permissive
  for update
  to authenticated
using (((bucket_id = 'images'::text) AND (owner = auth.uid())));



  create policy "Public Access"
  on "storage"."objects"
  as permissive
  for select
  to public
using ((bucket_id = 'images'::text));



  create policy "Public read access for product images"
  on "storage"."objects"
  as permissive
  for select
  to public
using ((bucket_id = 'products'::text));



  create policy "Users can delete their own avatar"
  on "storage"."objects"
  as permissive
  for delete
  to public
using (((bucket_id = 'avatars'::text) AND ((auth.uid())::text = (storage.foldername(name))[1])));



  create policy "Users can delete their own product images"
  on "storage"."objects"
  as permissive
  for delete
  to public
using (((bucket_id = 'products'::text) AND (auth.uid() = owner)));



  create policy "Users can update their own avatar"
  on "storage"."objects"
  as permissive
  for update
  to public
using (((bucket_id = 'avatars'::text) AND ((auth.uid())::text = (storage.foldername(name))[1])));



  create policy "Users can upload their own avatar"
  on "storage"."objects"
  as permissive
  for insert
  to public
with check (((bucket_id = 'avatars'::text) AND ((auth.uid())::text = (storage.foldername(name))[1])));



  create policy "Users can upload their own images"
  on "storage"."objects"
  as permissive
  for insert
  to public
with check (((bucket_id = 'products'::text) AND (auth.uid() IS NOT NULL)));



  create policy "Users can view their own files"
  on "storage"."objects"
  as permissive
  for select
  to public
using ((auth.uid() = owner));




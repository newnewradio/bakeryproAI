create extension if not exists "pg_net" with schema "extensions";

create sequence "public"."pos_tx_number_seq";

alter table "public"."payments" drop constraint "payments_payment_method_check";

alter table "public"."payments" drop constraint "payments_status_check";


  create table "public"."cashmatic_logs" (
    "id" uuid not null default gen_random_uuid(),
    "device_id" text not null default 'default'::text,
    "event_type" text not null,
    "amount" numeric(10,2),
    "currency" text default 'HUF'::text,
    "status" text,
    "message" text,
    "raw_data" jsonb,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."cashmatic_logs" enable row level security;


  create table "public"."pos_transaction_items" (
    "id" uuid not null default gen_random_uuid(),
    "transaction_id" uuid,
    "product_id" uuid,
    "quantity" numeric(10,3) default 1,
    "unit_price" numeric(10,2) default 0,
    "total_price" numeric(10,2) default 0,
    "discount_amount" numeric(10,2) default 0,
    "vat_percentage" numeric(5,2) default 27,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."pos_transaction_items" enable row level security;


  create table "public"."pos_transactions" (
    "id" uuid not null default gen_random_uuid(),
    "transaction_number" text,
    "cashier_id" uuid,
    "location_id" uuid,
    "subtotal" numeric(10,2) default 0,
    "tax_amount" numeric(10,2) default 0,
    "total_amount" numeric(10,2) default 0,
    "payment_method" text,
    "status" text default 'completed'::text,
    "cashmatic_transaction_id" text,
    "receipt_number" text,
    "amount_paid" numeric(10,2) default 0,
    "change_amount" numeric(10,2) default 0,
    "notes" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."pos_transactions" enable row level security;

alter table "public"."partners" enable row level security;

alter table "public"."transactions" enable row level security;

CREATE UNIQUE INDEX cashmatic_logs_pkey ON public.cashmatic_logs USING btree (id);

CREATE INDEX idx_cashmatic_logs_created_at ON public.cashmatic_logs USING btree (created_at DESC);

CREATE INDEX idx_cashmatic_logs_event_type ON public.cashmatic_logs USING btree (event_type);

CREATE INDEX idx_pos_items_product ON public.pos_transaction_items USING btree (product_id);

CREATE INDEX idx_pos_items_tx ON public.pos_transaction_items USING btree (transaction_id);

CREATE INDEX idx_pos_tx_cashier ON public.pos_transactions USING btree (cashier_id);

CREATE INDEX idx_pos_tx_created ON public.pos_transactions USING btree (created_at DESC);

CREATE INDEX idx_pos_tx_payment ON public.pos_transactions USING btree (payment_method);

CREATE INDEX idx_pos_tx_status ON public.pos_transactions USING btree (status);

CREATE INDEX idx_store_inv_product ON public.store_inventory USING btree (product_id);

CREATE UNIQUE INDEX pos_transaction_items_pkey ON public.pos_transaction_items USING btree (id);

CREATE UNIQUE INDEX pos_transactions_pkey ON public.pos_transactions USING btree (id);

alter table "public"."cashmatic_logs" add constraint "cashmatic_logs_pkey" PRIMARY KEY using index "cashmatic_logs_pkey";

alter table "public"."pos_transaction_items" add constraint "pos_transaction_items_pkey" PRIMARY KEY using index "pos_transaction_items_pkey";

alter table "public"."pos_transactions" add constraint "pos_transactions_pkey" PRIMARY KEY using index "pos_transactions_pkey";

alter table "public"."pos_transaction_items" add constraint "pos_transaction_items_product_id_fkey" FOREIGN KEY (product_id) REFERENCES public.products(id) not valid;

alter table "public"."pos_transaction_items" validate constraint "pos_transaction_items_product_id_fkey";

alter table "public"."pos_transaction_items" add constraint "pos_transaction_items_transaction_id_fkey" FOREIGN KEY (transaction_id) REFERENCES public.pos_transactions(id) ON DELETE CASCADE not valid;

alter table "public"."pos_transaction_items" validate constraint "pos_transaction_items_transaction_id_fkey";

alter table "public"."pos_transactions" add constraint "pos_transactions_cashier_id_fkey" FOREIGN KEY (cashier_id) REFERENCES auth.users(id) not valid;

alter table "public"."pos_transactions" validate constraint "pos_transactions_cashier_id_fkey";

alter table "public"."pos_transactions" add constraint "pos_transactions_payment_method_check" CHECK ((payment_method = ANY (ARRAY['cash'::text, 'card'::text, 'cashmatic_cash'::text, 'transfer'::text, 'other'::text]))) not valid;

alter table "public"."pos_transactions" validate constraint "pos_transactions_payment_method_check";

alter table "public"."pos_transactions" add constraint "pos_transactions_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'completed'::text, 'cancelled'::text, 'refunded'::text]))) not valid;

alter table "public"."pos_transactions" validate constraint "pos_transactions_status_check";

alter table "public"."payments" add constraint "payments_payment_method_check" CHECK (((payment_method)::text = ANY ((ARRAY['cash'::character varying, 'card'::character varying, 'transfer'::character varying, 'other'::character varying])::text[]))) not valid;

alter table "public"."payments" validate constraint "payments_payment_method_check";

alter table "public"."payments" add constraint "payments_status_check" CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'completed'::character varying, 'failed'::character varying, 'refunded'::character varying])::text[]))) not valid;

alter table "public"."payments" validate constraint "payments_status_check";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.auto_generate_transaction_number()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF NEW.transaction_number IS NULL OR NEW.transaction_number = '' THEN
    NEW.transaction_number := 'TX-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' ||
      LPAD(NEXTVAL('public.pos_tx_number_seq')::text, 5, '0');
  END IF;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.decrement_stock(p_product_id uuid, p_quantity numeric)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  UPDATE public.store_inventory
  SET current_stock = GREATEST(0, current_stock - p_quantity),
      updated_at    = now()
  WHERE product_id = p_product_id;
  -- Ha nincs még rekord, ne dobjon hibát
  IF NOT FOUND THEN
    RAISE NOTICE 'Nincs készletrekord ehhez a termékhez: %', p_product_id;
  END IF;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.increment_stock(p_product_id uuid, p_quantity numeric)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  UPDATE public.store_inventory
  SET current_stock = current_stock + p_quantity,
      updated_at    = now()
  WHERE product_id = p_product_id;
  IF NOT FOUND THEN
    RAISE NOTICE 'Nincs készletrekord ehhez a termékhez: %', p_product_id;
  END IF;
END;
$function$
;

create or replace view "public"."v_pos_daily_summary" as  SELECT date((created_at AT TIME ZONE 'Europe/Budapest'::text)) AS day,
    count(*) AS transaction_count,
    sum(total_amount) AS total_revenue,
    sum(tax_amount) AS total_vat,
    sum(
        CASE
            WHEN (payment_method = 'card'::text) THEN total_amount
            ELSE (0)::numeric
        END) AS card_revenue,
    sum(
        CASE
            WHEN (payment_method = ANY (ARRAY['cash'::text, 'cashmatic_cash'::text])) THEN total_amount
            ELSE (0)::numeric
        END) AS cash_revenue,
    avg(total_amount) AS avg_transaction
   FROM public.pos_transactions
  WHERE (status = 'completed'::text)
  GROUP BY (date((created_at AT TIME ZONE 'Europe/Budapest'::text)))
  ORDER BY (date((created_at AT TIME ZONE 'Europe/Budapest'::text))) DESC;


CREATE OR REPLACE FUNCTION public.update_updated_at_column()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$function$
;

grant delete on table "public"."cashmatic_logs" to "anon";

grant insert on table "public"."cashmatic_logs" to "anon";

grant references on table "public"."cashmatic_logs" to "anon";

grant select on table "public"."cashmatic_logs" to "anon";

grant trigger on table "public"."cashmatic_logs" to "anon";

grant truncate on table "public"."cashmatic_logs" to "anon";

grant update on table "public"."cashmatic_logs" to "anon";

grant delete on table "public"."cashmatic_logs" to "authenticated";

grant insert on table "public"."cashmatic_logs" to "authenticated";

grant references on table "public"."cashmatic_logs" to "authenticated";

grant select on table "public"."cashmatic_logs" to "authenticated";

grant trigger on table "public"."cashmatic_logs" to "authenticated";

grant truncate on table "public"."cashmatic_logs" to "authenticated";

grant update on table "public"."cashmatic_logs" to "authenticated";

grant delete on table "public"."cashmatic_logs" to "service_role";

grant insert on table "public"."cashmatic_logs" to "service_role";

grant references on table "public"."cashmatic_logs" to "service_role";

grant select on table "public"."cashmatic_logs" to "service_role";

grant trigger on table "public"."cashmatic_logs" to "service_role";

grant truncate on table "public"."cashmatic_logs" to "service_role";

grant update on table "public"."cashmatic_logs" to "service_role";

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


  create policy "cashmatic_logs_authenticated"
  on "public"."cashmatic_logs"
  as permissive
  for all
  to public
using ((auth.role() = 'authenticated'::text))
with check ((auth.role() = 'authenticated'::text));



  create policy "Allow All"
  on "public"."partners"
  as permissive
  for all
  to public
using (true)
with check (true);



  create policy "Allow all"
  on "public"."partners"
  as permissive
  for all
  to public
using (true)
with check (true);



  create policy "pos_transaction_items_all_authenticated"
  on "public"."pos_transaction_items"
  as permissive
  for all
  to public
using ((auth.role() = 'authenticated'::text))
with check ((auth.role() = 'authenticated'::text));



  create policy "pos_transactions_all_authenticated"
  on "public"."pos_transactions"
  as permissive
  for all
  to public
using ((auth.role() = 'authenticated'::text))
with check ((auth.role() = 'authenticated'::text));



  create policy "Allow All"
  on "public"."production_batches"
  as permissive
  for all
  to public
using (true)
with check (true);



  create policy "Allow all"
  on "public"."production_batches"
  as permissive
  for all
  to public
using (true)
with check (true);



  create policy "Enable delete access for all users"
  on "public"."production_batches"
  as permissive
  for delete
  to public
using (true);



  create policy "Enable insert access for all users"
  on "public"."production_batches"
  as permissive
  for insert
  to public
with check (true);



  create policy "Enable read access for all users"
  on "public"."production_batches"
  as permissive
  for select
  to public
using (true);



  create policy "Enable update access for all users"
  on "public"."production_batches"
  as permissive
  for update
  to public
using (true)
with check (true);



  create policy "store_inventory_read_all"
  on "public"."store_inventory"
  as permissive
  for select
  to public
using (true);



  create policy "store_inventory_write_authenticated"
  on "public"."store_inventory"
  as permissive
  for all
  to public
using ((auth.role() = 'authenticated'::text))
with check ((auth.role() = 'authenticated'::text));



  create policy "Allow All"
  on "public"."transactions"
  as permissive
  for all
  to public
using (true)
with check (true);



  create policy "Allow all"
  on "public"."transactions"
  as permissive
  for all
  to public
using (true)
with check (true);


CREATE TRIGGER trg_auto_tx_number BEFORE INSERT ON public.pos_transactions FOR EACH ROW EXECUTE FUNCTION public.auto_generate_transaction_number();

CREATE TRIGGER trg_pos_tx_updated_at BEFORE UPDATE ON public.pos_transactions FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();



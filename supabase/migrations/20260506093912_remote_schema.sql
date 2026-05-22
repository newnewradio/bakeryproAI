drop trigger if exists "update_cash_movements_updated_at" on "public"."cash_movements";

drop trigger if exists "on_pos_return_item_insert" on "public"."pos_return_items";

drop trigger if exists "trigger_return_inventory_update" on "public"."pos_return_items";

drop trigger if exists "update_pos_return_items_updated_at" on "public"."pos_return_items";

drop trigger if exists "generate_return_number_trigger" on "public"."pos_returns";

drop trigger if exists "update_pos_returns_updated_at" on "public"."pos_returns";

drop trigger if exists "generate_session_number_trigger" on "public"."pos_sessions";

drop trigger if exists "update_pos_sessions_updated_at" on "public"."pos_sessions";

drop trigger if exists "enforce_product_exists" on "public"."pos_transaction_items";

drop trigger if exists "update_pos_transaction_items_updated_at" on "public"."pos_transaction_items";

drop trigger if exists "update_store_inventory_on_transaction" on "public"."pos_transaction_items";

drop trigger if exists "generate_transaction_number_trigger" on "public"."pos_transactions";

drop trigger if exists "update_pos_transactions_updated_at" on "public"."pos_transactions";

drop trigger if exists "update_recipes_updated_at" on "public"."recipes";

drop policy "admin_cash_movements" on "public"."cash_movements";

drop policy "salesperson_cash_movements" on "public"."cash_movements";

drop policy "admin_pos_return_items" on "public"."pos_return_items";

drop policy "salesperson_pos_return_items" on "public"."pos_return_items";

drop policy "admin_pos_returns" on "public"."pos_returns";

drop policy "salesperson_pos_returns" on "public"."pos_returns";

drop policy "Adminok kezelhetik az összes POS munkamenetet" on "public"."pos_sessions";

drop policy "Eladók kezelhetik a saját POS munkameneteiket" on "public"."pos_sessions";

drop policy "Mindenki olvashatja a POS munkameneteket" on "public"."pos_sessions";

drop policy "admin_pos_sessions" on "public"."pos_sessions";

drop policy "salesperson_pos_sessions" on "public"."pos_sessions";

drop policy "admin_pos_transaction_items" on "public"."pos_transaction_items";

drop policy "salesperson_pos_transaction_items" on "public"."pos_transaction_items";

drop policy "Adminok kezelhetik az összes POS tranzakciót" on "public"."pos_transactions";

drop policy "Eladók kezelhetik a saját POS tranzakcióikat" on "public"."pos_transactions";

drop policy "Mindenki olvashatja a POS tranzakciókat" on "public"."pos_transactions";

drop policy "admin_pos_transactions" on "public"."pos_transactions";

drop policy "salesperson_pos_transactions" on "public"."pos_transactions";

drop policy "Admins can manage all production steps" on "public"."production_steps";

drop policy "Bakers can manage production steps" on "public"."production_steps";

drop policy "Salespersons can view production steps" on "public"."production_steps";

drop policy "Users can insert production steps" on "public"."production_steps";

drop policy "Users can read production steps" on "public"."production_steps";

drop policy "Users can update production steps" on "public"."production_steps";

drop policy "Adminok kezelhetik az összes recept lépést" on "public"."recipe_steps";

drop policy "Mindenki olvashatja a recept lépéseket" on "public"."recipe_steps";

drop policy "Pékek és adminok kezelhetik a recept lépéseket" on "public"."recipe_steps";

drop policy "Users can insert recipe steps" on "public"."recipe_steps";

drop policy "Users can read recipe steps" on "public"."recipe_steps";

drop policy "Users can update recipe steps" on "public"."recipe_steps";

drop policy "Mindenki olvashatja a recepteket" on "public"."recipes";

drop policy "Pékek és adminok kezelhetik a recepteket" on "public"."recipes";

revoke delete on table "public"."cash_movements" from "anon";

revoke insert on table "public"."cash_movements" from "anon";

revoke references on table "public"."cash_movements" from "anon";

revoke select on table "public"."cash_movements" from "anon";

revoke trigger on table "public"."cash_movements" from "anon";

revoke truncate on table "public"."cash_movements" from "anon";

revoke update on table "public"."cash_movements" from "anon";

revoke delete on table "public"."cash_movements" from "authenticated";

revoke insert on table "public"."cash_movements" from "authenticated";

revoke references on table "public"."cash_movements" from "authenticated";

revoke select on table "public"."cash_movements" from "authenticated";

revoke trigger on table "public"."cash_movements" from "authenticated";

revoke truncate on table "public"."cash_movements" from "authenticated";

revoke update on table "public"."cash_movements" from "authenticated";

revoke delete on table "public"."cash_movements" from "service_role";

revoke insert on table "public"."cash_movements" from "service_role";

revoke references on table "public"."cash_movements" from "service_role";

revoke select on table "public"."cash_movements" from "service_role";

revoke trigger on table "public"."cash_movements" from "service_role";

revoke truncate on table "public"."cash_movements" from "service_role";

revoke update on table "public"."cash_movements" from "service_role";

revoke delete on table "public"."pos_return_items" from "anon";

revoke insert on table "public"."pos_return_items" from "anon";

revoke references on table "public"."pos_return_items" from "anon";

revoke select on table "public"."pos_return_items" from "anon";

revoke trigger on table "public"."pos_return_items" from "anon";

revoke truncate on table "public"."pos_return_items" from "anon";

revoke update on table "public"."pos_return_items" from "anon";

revoke delete on table "public"."pos_return_items" from "authenticated";

revoke insert on table "public"."pos_return_items" from "authenticated";

revoke references on table "public"."pos_return_items" from "authenticated";

revoke select on table "public"."pos_return_items" from "authenticated";

revoke trigger on table "public"."pos_return_items" from "authenticated";

revoke truncate on table "public"."pos_return_items" from "authenticated";

revoke update on table "public"."pos_return_items" from "authenticated";

revoke delete on table "public"."pos_return_items" from "service_role";

revoke insert on table "public"."pos_return_items" from "service_role";

revoke references on table "public"."pos_return_items" from "service_role";

revoke select on table "public"."pos_return_items" from "service_role";

revoke trigger on table "public"."pos_return_items" from "service_role";

revoke truncate on table "public"."pos_return_items" from "service_role";

revoke update on table "public"."pos_return_items" from "service_role";

revoke delete on table "public"."pos_returns" from "anon";

revoke insert on table "public"."pos_returns" from "anon";

revoke references on table "public"."pos_returns" from "anon";

revoke select on table "public"."pos_returns" from "anon";

revoke trigger on table "public"."pos_returns" from "anon";

revoke truncate on table "public"."pos_returns" from "anon";

revoke update on table "public"."pos_returns" from "anon";

revoke delete on table "public"."pos_returns" from "authenticated";

revoke insert on table "public"."pos_returns" from "authenticated";

revoke references on table "public"."pos_returns" from "authenticated";

revoke select on table "public"."pos_returns" from "authenticated";

revoke trigger on table "public"."pos_returns" from "authenticated";

revoke truncate on table "public"."pos_returns" from "authenticated";

revoke update on table "public"."pos_returns" from "authenticated";

revoke delete on table "public"."pos_returns" from "service_role";

revoke insert on table "public"."pos_returns" from "service_role";

revoke references on table "public"."pos_returns" from "service_role";

revoke select on table "public"."pos_returns" from "service_role";

revoke trigger on table "public"."pos_returns" from "service_role";

revoke truncate on table "public"."pos_returns" from "service_role";

revoke update on table "public"."pos_returns" from "service_role";

revoke delete on table "public"."pos_sessions" from "anon";

revoke insert on table "public"."pos_sessions" from "anon";

revoke references on table "public"."pos_sessions" from "anon";

revoke select on table "public"."pos_sessions" from "anon";

revoke trigger on table "public"."pos_sessions" from "anon";

revoke truncate on table "public"."pos_sessions" from "anon";

revoke update on table "public"."pos_sessions" from "anon";

revoke delete on table "public"."pos_sessions" from "authenticated";

revoke insert on table "public"."pos_sessions" from "authenticated";

revoke references on table "public"."pos_sessions" from "authenticated";

revoke select on table "public"."pos_sessions" from "authenticated";

revoke trigger on table "public"."pos_sessions" from "authenticated";

revoke truncate on table "public"."pos_sessions" from "authenticated";

revoke update on table "public"."pos_sessions" from "authenticated";

revoke delete on table "public"."pos_sessions" from "service_role";

revoke insert on table "public"."pos_sessions" from "service_role";

revoke references on table "public"."pos_sessions" from "service_role";

revoke select on table "public"."pos_sessions" from "service_role";

revoke trigger on table "public"."pos_sessions" from "service_role";

revoke truncate on table "public"."pos_sessions" from "service_role";

revoke update on table "public"."pos_sessions" from "service_role";

revoke delete on table "public"."pos_transaction_items" from "anon";

revoke insert on table "public"."pos_transaction_items" from "anon";

revoke references on table "public"."pos_transaction_items" from "anon";

revoke select on table "public"."pos_transaction_items" from "anon";

revoke trigger on table "public"."pos_transaction_items" from "anon";

revoke truncate on table "public"."pos_transaction_items" from "anon";

revoke update on table "public"."pos_transaction_items" from "anon";

revoke delete on table "public"."pos_transaction_items" from "authenticated";

revoke insert on table "public"."pos_transaction_items" from "authenticated";

revoke references on table "public"."pos_transaction_items" from "authenticated";

revoke select on table "public"."pos_transaction_items" from "authenticated";

revoke trigger on table "public"."pos_transaction_items" from "authenticated";

revoke truncate on table "public"."pos_transaction_items" from "authenticated";

revoke update on table "public"."pos_transaction_items" from "authenticated";

revoke delete on table "public"."pos_transaction_items" from "service_role";

revoke insert on table "public"."pos_transaction_items" from "service_role";

revoke references on table "public"."pos_transaction_items" from "service_role";

revoke select on table "public"."pos_transaction_items" from "service_role";

revoke trigger on table "public"."pos_transaction_items" from "service_role";

revoke truncate on table "public"."pos_transaction_items" from "service_role";

revoke update on table "public"."pos_transaction_items" from "service_role";

revoke delete on table "public"."pos_transactions" from "anon";

revoke insert on table "public"."pos_transactions" from "anon";

revoke references on table "public"."pos_transactions" from "anon";

revoke select on table "public"."pos_transactions" from "anon";

revoke trigger on table "public"."pos_transactions" from "anon";

revoke truncate on table "public"."pos_transactions" from "anon";

revoke update on table "public"."pos_transactions" from "anon";

revoke delete on table "public"."pos_transactions" from "authenticated";

revoke insert on table "public"."pos_transactions" from "authenticated";

revoke references on table "public"."pos_transactions" from "authenticated";

revoke select on table "public"."pos_transactions" from "authenticated";

revoke trigger on table "public"."pos_transactions" from "authenticated";

revoke truncate on table "public"."pos_transactions" from "authenticated";

revoke update on table "public"."pos_transactions" from "authenticated";

revoke delete on table "public"."pos_transactions" from "service_role";

revoke insert on table "public"."pos_transactions" from "service_role";

revoke references on table "public"."pos_transactions" from "service_role";

revoke select on table "public"."pos_transactions" from "service_role";

revoke trigger on table "public"."pos_transactions" from "service_role";

revoke truncate on table "public"."pos_transactions" from "service_role";

revoke update on table "public"."pos_transactions" from "service_role";

revoke delete on table "public"."production_steps" from "anon";

revoke insert on table "public"."production_steps" from "anon";

revoke references on table "public"."production_steps" from "anon";

revoke select on table "public"."production_steps" from "anon";

revoke trigger on table "public"."production_steps" from "anon";

revoke truncate on table "public"."production_steps" from "anon";

revoke update on table "public"."production_steps" from "anon";

revoke delete on table "public"."production_steps" from "authenticated";

revoke insert on table "public"."production_steps" from "authenticated";

revoke references on table "public"."production_steps" from "authenticated";

revoke select on table "public"."production_steps" from "authenticated";

revoke trigger on table "public"."production_steps" from "authenticated";

revoke truncate on table "public"."production_steps" from "authenticated";

revoke update on table "public"."production_steps" from "authenticated";

revoke delete on table "public"."production_steps" from "service_role";

revoke insert on table "public"."production_steps" from "service_role";

revoke references on table "public"."production_steps" from "service_role";

revoke select on table "public"."production_steps" from "service_role";

revoke trigger on table "public"."production_steps" from "service_role";

revoke truncate on table "public"."production_steps" from "service_role";

revoke update on table "public"."production_steps" from "service_role";

revoke delete on table "public"."recipes" from "anon";

revoke insert on table "public"."recipes" from "anon";

revoke references on table "public"."recipes" from "anon";

revoke select on table "public"."recipes" from "anon";

revoke trigger on table "public"."recipes" from "anon";

revoke truncate on table "public"."recipes" from "anon";

revoke update on table "public"."recipes" from "anon";

revoke delete on table "public"."recipes" from "authenticated";

revoke insert on table "public"."recipes" from "authenticated";

revoke references on table "public"."recipes" from "authenticated";

revoke select on table "public"."recipes" from "authenticated";

revoke trigger on table "public"."recipes" from "authenticated";

revoke truncate on table "public"."recipes" from "authenticated";

revoke update on table "public"."recipes" from "authenticated";

revoke delete on table "public"."recipes" from "service_role";

revoke insert on table "public"."recipes" from "service_role";

revoke references on table "public"."recipes" from "service_role";

revoke select on table "public"."recipes" from "service_role";

revoke trigger on table "public"."recipes" from "service_role";

revoke truncate on table "public"."recipes" from "service_role";

revoke update on table "public"."recipes" from "service_role";

alter table "public"."cash_movements" drop constraint "cash_movements_cashier_id_fkey";

alter table "public"."cash_movements" drop constraint "cash_movements_location_id_fkey";

alter table "public"."cash_movements" drop constraint "cash_movements_session_id_fkey";

alter table "public"."cash_movements" drop constraint "cash_movements_type_check";

alter table "public"."pos_return_items" drop constraint "pos_return_items_product_id_fkey";

alter table "public"."pos_return_items" drop constraint "pos_return_items_quantity_check";

alter table "public"."pos_return_items" drop constraint "pos_return_items_return_id_fkey";

alter table "public"."pos_returns" drop constraint "pos_returns_cashier_id_fkey";

alter table "public"."pos_returns" drop constraint "pos_returns_location_id_fkey";

alter table "public"."pos_returns" drop constraint "pos_returns_payment_method_check";

alter table "public"."pos_returns" drop constraint "pos_returns_session_id_fkey";

alter table "public"."pos_returns" drop constraint "pos_returns_status_check";

alter table "public"."pos_sessions" drop constraint "pos_sessions_cashier_id_fkey";

alter table "public"."pos_sessions" drop constraint "pos_sessions_location_id_fkey";

alter table "public"."pos_sessions" drop constraint "pos_sessions_status_check";

alter table "public"."pos_transaction_items" drop constraint "pos_transaction_items_product_id_fkey";

alter table "public"."pos_transaction_items" drop constraint "pos_transaction_items_quantity_check";

alter table "public"."pos_transaction_items" drop constraint "pos_transaction_items_total_price_check";

alter table "public"."pos_transaction_items" drop constraint "pos_transaction_items_transaction_id_fkey";

alter table "public"."pos_transaction_items" drop constraint "pos_transaction_items_unit_price_check";

alter table "public"."pos_transactions" drop constraint "pos_transactions_cashier_id_fkey";

alter table "public"."pos_transactions" drop constraint "pos_transactions_location_id_fkey";

alter table "public"."pos_transactions" drop constraint "pos_transactions_payment_method_check";

alter table "public"."pos_transactions" drop constraint "pos_transactions_session_id_fkey";

alter table "public"."pos_transactions" drop constraint "pos_transactions_status_check";

alter table "public"."pos_transactions" drop constraint "pos_transactions_transaction_number_key";

alter table "public"."production_steps" drop constraint "fk_production_steps_recipe_id";

alter table "public"."production_steps" drop constraint "production_steps_batch_id_fkey";

alter table "public"."production_steps" drop constraint "production_steps_created_by_fkey";

alter table "public"."production_steps" drop constraint "production_steps_recipe_id_fkey";

alter table "public"."production_steps" drop constraint "production_steps_status_check";

alter table "public"."products" drop constraint "products_base_recipe_id_fkey";

alter table "public"."recipes" drop constraint "recipes_created_by_fkey";

alter table "public"."recipes" drop constraint "recipes_difficulty_check";

alter table "public"."payments" drop constraint "payments_payment_method_check";

alter table "public"."payments" drop constraint "payments_status_check";

drop function if exists "public"."insert_production_step"(p_order_id bigint, p_step_description text, p_status text);

alter table "public"."cash_movements" drop constraint "cash_movements_pkey";

alter table "public"."pos_return_items" drop constraint "pos_return_items_pkey";

alter table "public"."pos_returns" drop constraint "pos_returns_pkey";

alter table "public"."pos_sessions" drop constraint "pos_sessions_pkey";

alter table "public"."pos_transaction_items" drop constraint "pos_transaction_items_pkey";

alter table "public"."pos_transactions" drop constraint "pos_transactions_pkey";

alter table "public"."production_steps" drop constraint "production_steps_pkey";

alter table "public"."recipes" drop constraint "recipes_pkey";

drop index if exists "public"."cash_movements_pkey";

drop index if exists "public"."idx_cash_movements_created_at";

drop index if exists "public"."idx_cash_movements_session_id";

drop index if exists "public"."idx_cash_movements_type";

drop index if exists "public"."idx_pos_return_items_product_id";

drop index if exists "public"."idx_pos_return_items_return_id";

drop index if exists "public"."idx_pos_returns_cashier_id";

drop index if exists "public"."idx_pos_returns_created_at";

drop index if exists "public"."idx_pos_returns_location_id";

drop index if exists "public"."idx_pos_returns_session_id";

drop index if exists "public"."idx_pos_sessions_cashier_id";

drop index if exists "public"."idx_pos_sessions_location_id";

drop index if exists "public"."idx_pos_sessions_status";

drop index if exists "public"."idx_pos_transaction_items_product_id";

drop index if exists "public"."idx_pos_transaction_items_transaction_id";

drop index if exists "public"."idx_pos_transactions_cashier_id";

drop index if exists "public"."idx_pos_transactions_created_at";

drop index if exists "public"."idx_pos_transactions_location_id";

drop index if exists "public"."idx_pos_transactions_session_id";

drop index if exists "public"."idx_production_steps_batch_id";

drop index if exists "public"."idx_production_steps_created_by";

drop index if exists "public"."idx_production_steps_order_id";

drop index if exists "public"."idx_production_steps_recipe_id";

drop index if exists "public"."idx_production_steps_recipe_step_id";

drop index if exists "public"."idx_production_steps_sequence_order";

drop index if exists "public"."idx_production_steps_status";

drop index if exists "public"."idx_recipe_steps_step_number";

drop index if exists "public"."idx_recipes_category";

drop index if exists "public"."idx_recipes_created_by";

drop index if exists "public"."pos_return_items_pkey";

drop index if exists "public"."pos_returns_pkey";

drop index if exists "public"."pos_sessions_pkey";

drop index if exists "public"."pos_transaction_items_pkey";

drop index if exists "public"."pos_transactions_pkey";

drop index if exists "public"."pos_transactions_transaction_number_key";

drop index if exists "public"."production_steps_pkey";

drop index if exists "public"."recipes_pkey";

drop table "public"."cash_movements";

drop table "public"."pos_return_items";

drop table "public"."pos_returns";

drop table "public"."pos_sessions";

drop table "public"."pos_transaction_items";

drop table "public"."pos_transactions";

drop table "public"."production_steps";

drop table "public"."recipes";


  create table "public"."production_progress" (
    "id" uuid not null default gen_random_uuid(),
    "batch_id" uuid not null,
    "recipe_step_id" uuid not null,
    "actual_temperature" double precision,
    "actual_humidity" double precision,
    "notes" text,
    "recorded_at" timestamp without time zone default now(),
    "recorded_by" uuid,
    "created_at" timestamp without time zone default now()
      );


alter table "public"."production_progress" enable row level security;

alter table "public"."recipe_steps" drop column "alert_message";

alter table "public"."recipe_steps" drop column "alert_threshold_minutes";

alter table "public"."recipe_steps" drop column "equipment";

alter table "public"."recipe_steps" drop column "image_url";

alter table "public"."recipe_steps" drop column "ingredients";

alter table "public"."recipe_steps" drop column "is_critical";

alter table "public"."recipe_steps" drop column "notes";

alter table "public"."recipe_steps" drop column "recipe_step_id";

alter table "public"."recipe_steps" add column "updated_at" timestamp without time zone default now();

alter table "public"."recipe_steps" alter column "created_at" set data type timestamp without time zone using "created_at"::timestamp without time zone;

alter table "public"."recipe_steps" alter column "description" drop not null;

alter table "public"."recipe_steps" alter column "duration_minutes" drop default;

CREATE INDEX idx_production_progress_batch_id ON public.production_progress USING btree (batch_id);

CREATE INDEX idx_production_progress_recipe_step_id ON public.production_progress USING btree (recipe_step_id);

CREATE INDEX idx_production_progress_recorded_at ON public.production_progress USING btree (recorded_at);

CREATE UNIQUE INDEX production_progress_pkey ON public.production_progress USING btree (id);

alter table "public"."production_progress" add constraint "production_progress_pkey" PRIMARY KEY using index "production_progress_pkey";

alter table "public"."production_batches" add constraint "production_batches_recipe_id_fkey" FOREIGN KEY (recipe_id) REFERENCES public.products(id) ON DELETE CASCADE not valid;

alter table "public"."production_batches" validate constraint "production_batches_recipe_id_fkey";

alter table "public"."production_progress" add constraint "production_progress_batch_id_fkey" FOREIGN KEY (batch_id) REFERENCES public.production_batches(id) ON DELETE CASCADE not valid;

alter table "public"."production_progress" validate constraint "production_progress_batch_id_fkey";

alter table "public"."production_progress" add constraint "production_progress_recipe_step_id_fkey" FOREIGN KEY (recipe_step_id) REFERENCES public.recipe_steps(id) ON DELETE CASCADE not valid;

alter table "public"."production_progress" validate constraint "production_progress_recipe_step_id_fkey";

alter table "public"."production_progress" add constraint "production_progress_recorded_by_fkey" FOREIGN KEY (recorded_by) REFERENCES auth.users(id) not valid;

alter table "public"."production_progress" validate constraint "production_progress_recorded_by_fkey";

alter table "public"."payments" add constraint "payments_payment_method_check" CHECK (((payment_method)::text = ANY ((ARRAY['cash'::character varying, 'card'::character varying, 'transfer'::character varying, 'other'::character varying])::text[]))) not valid;

alter table "public"."payments" validate constraint "payments_payment_method_check";

alter table "public"."payments" add constraint "payments_status_check" CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'completed'::character varying, 'failed'::character varying, 'refunded'::character varying])::text[]))) not valid;

alter table "public"."payments" validate constraint "payments_status_check";

grant delete on table "public"."production_progress" to "anon";

grant insert on table "public"."production_progress" to "anon";

grant references on table "public"."production_progress" to "anon";

grant select on table "public"."production_progress" to "anon";

grant trigger on table "public"."production_progress" to "anon";

grant truncate on table "public"."production_progress" to "anon";

grant update on table "public"."production_progress" to "anon";

grant delete on table "public"."production_progress" to "authenticated";

grant insert on table "public"."production_progress" to "authenticated";

grant references on table "public"."production_progress" to "authenticated";

grant select on table "public"."production_progress" to "authenticated";

grant trigger on table "public"."production_progress" to "authenticated";

grant truncate on table "public"."production_progress" to "authenticated";

grant update on table "public"."production_progress" to "authenticated";

grant delete on table "public"."production_progress" to "service_role";

grant insert on table "public"."production_progress" to "service_role";

grant references on table "public"."production_progress" to "service_role";

grant select on table "public"."production_progress" to "service_role";

grant trigger on table "public"."production_progress" to "service_role";

grant truncate on table "public"."production_progress" to "service_role";

grant update on table "public"."production_progress" to "service_role";


  create policy "Allow all to read production_progress"
  on "public"."production_progress"
  as permissive
  for select
  to public
using (true);



  create policy "Allow author to update production_progress"
  on "public"."production_progress"
  as permissive
  for update
  to public
using (((recorded_by = auth.uid()) OR (( SELECT profiles.role
   FROM public.profiles
  WHERE (profiles.id = auth.uid())) = 'admin'::text)));



  create policy "Allow baker to insert production_progress"
  on "public"."production_progress"
  as permissive
  for insert
  to public
with check ((( SELECT profiles.role
   FROM public.profiles
  WHERE (profiles.id = auth.uid())) = ANY (ARRAY['baker'::text, 'admin'::text])));



  create policy "Allow admin to insert recipe_steps"
  on "public"."recipe_steps"
  as permissive
  for insert
  to public
with check ((( SELECT profiles.role
   FROM public.profiles
  WHERE (profiles.id = auth.uid())) = 'admin'::text));



  create policy "Allow admin to update recipe_steps"
  on "public"."recipe_steps"
  as permissive
  for update
  to public
using ((( SELECT profiles.role
   FROM public.profiles
  WHERE (profiles.id = auth.uid())) = 'admin'::text));



  create policy "Allow all to read recipe_steps"
  on "public"."recipe_steps"
  as permissive
  for select
  to public
using (true);




-- Anonymous Flow — Supabase Migration
-- Run this in your Supabase SQL editor or via supabase db push

-- ─── Vessel Schedules ────────────────────────────────────────────────────────
create table if not exists vessel_schedules (
  id                  uuid primary key default gen_random_uuid(),
  vessel_name         text not null,
  voyage              text,
  shipping_line       text,
  terminal            text not null,
  status              text not null default 'scheduled',
    -- 'at_pilot_station' | 'active_at_berth' | 'scheduled' | 'departed'
  eta_etb             timestamptz,
  ata_atb             timestamptz,
  etd                 timestamptz,
  atd                 timestamptz,
  etc                 timestamptz,
  initial_berthing_lct timestamptz,
  begin_receive       timestamptz,
  pre_advice_cutoff   timestamptz,
  loading_cutoff      timestamptz,
  remarks             text,
  created_at          timestamptz default now(),
  updated_at          timestamptz default now()
);

-- Public read, service-role write only
alter table vessel_schedules enable row level security;
create policy "Public read vessel schedules"
  on vessel_schedules for select using (true);

-- ─── Announcements ───────────────────────────────────────────────────────────
create table if not exists announcements (
  id              uuid primary key default gen_random_uuid(),
  terminal        text not null,   -- 'MICT' | 'AGCT' | 'MICTSI' | 'ALL'
  title           text not null,
  body            text not null,
  image_url       text,
  category_icon   text,            -- 'truck' | 'vessel' | 'alert' | null
  published_at    timestamptz not null default now(),
  created_at      timestamptz default now()
);

alter table announcements enable row level security;
create policy "Public read announcements"
  on announcements for select using (true);

-- ─── Billing Estimates ───────────────────────────────────────────────────────
create table if not exists billing_estimates (
  id              uuid primary key default gen_random_uuid(),
  session_id      text,
  user_id         uuid references auth.users on delete set null,
  terminal        text not null,
  category        text not null default 'Import',
  qty_20          int not null default 0,
  qty_40          int not null default 0,
  qty_45          int not null default 0,
  weighing        boolean not null default false,
  out_of_gauge    boolean not null default false,
  reefer          boolean not null default false,
  dea             boolean not null default false,
  dg_class        text,
  w_cm            numeric,
  h_cm            numeric,
  l_cm            numeric,
  discharge_date  timestamptz,
  gate_out_date   timestamptz,
  plug_in_date    timestamptz,
  plug_out_date   timestamptz,
  total_amount    numeric,
  created_at      timestamptz default now()
);

create table if not exists billing_estimate_items (
  id            uuid primary key default gen_random_uuid(),
  estimate_id   uuid references billing_estimates on delete cascade,
  charge_item   text not null,
  amount        numeric not null,
  date_value    timestamptz
);

alter table billing_estimates enable row level security;
alter table billing_estimate_items enable row level security;

-- Anonymous users can insert and read their own session's estimates
create policy "Anon insert billing estimates"
  on billing_estimates for insert with check (true);
create policy "Anon read own session estimates"
  on billing_estimates for select using (true);
create policy "Anon delete own session estimates"
  on billing_estimates for delete using (true);

create policy "Read billing items"
  on billing_estimate_items for select using (true);
create policy "Insert billing items"
  on billing_estimate_items for insert with check (true);
create policy "Delete billing items"
  on billing_estimate_items for delete using (true);

-- ─── Access Requests ─────────────────────────────────────────────────────────
create table if not exists access_requests (
  id                  uuid primary key default gen_random_uuid(),
  company_name        text not null,
  city                text,
  state_province      text,
  country             text,
  zip_code            text,
  business_address    text,
  tax_id_number       text not null,
  email               text not null,
  terminal            text not null,
  user_type           text not null,
  copy_from           text,
  rep_name            text not null,
  rep_email           text not null,
  rep_position        text,
  remarks             text,
  status              text not null default 'pending',
    -- 'pending' | 'approved' | 'declined'
  submitted_at        timestamptz default now(),
  reviewed_at         timestamptz,
  reviewed_by         uuid
);

create table if not exists access_request_documents (
  id              uuid primary key default gen_random_uuid(),
  request_id      uuid references access_requests on delete cascade,
  doc_type        text not null,
  file_url        text not null,
  file_name       text,
  uploaded_at     timestamptz default now()
);

alter table access_requests enable row level security;
alter table access_request_documents enable row level security;

-- Anonymous can INSERT requests; no SELECT (admin reviews via service role)
create policy "Anon insert access requests"
  on access_requests for insert with check (true);
create policy "Anon insert access documents"
  on access_request_documents for insert with check (true);

-- ─── Seed data — sample vessel schedules ────────────────────────────────────
insert into vessel_schedules
  (vessel_name, voyage, shipping_line, terminal, status, eta_etb, etd, begin_receive, loading_cutoff, remarks)
values
  ('EVERGREEN MARINE', '101N/101S', 'OCEAN NETWORK', 'MICT', 'at_pilot_station',
   now() + interval '2 hours', now() + interval '3 days',
   now() + interval '6 hours', now() + interval '2 days', null),

  ('ALS SUMIRE', '101N/101S', 'ABC NETWORK', 'MICT', 'active_at_berth',
   now() - interval '4 hours', now() + interval '2 days',
   now() - interval '2 hours', now() + interval '1 day', null),

  ('GSL ELIZABETH', '101N/101S', 'OCEAN NETWORK', 'MICT', 'scheduled',
   now() + interval '2 days', now() + interval '5 days',
   now() + interval '2 days', now() + interval '4 days', null),

  ('ALS FAUNA', '101N/101S', 'OCEAN NETWORK', 'AGCT', 'active_at_berth',
   now() - interval '6 hours', now() + interval '1 day',
   now() - interval '4 hours', now() + interval '18 hours', 'Off Window'),

  ('IWASHIRO', '124N/124S', 'ABC NETWORK', 'MICT', 'departed',
   now() - interval '2 days', now() - interval '6 hours', null, null, null)
on conflict do nothing;

-- ─── Seed data — sample announcements ────────────────────────────────────────
insert into announcements (terminal, title, body, category_icon, published_at)
values
  ('MICT',
   'Terminal Operating Hours Update',
   'Please be advised that MICT will be operating on extended hours from Monday to Friday effective immediately. Gate operations will run from 6:00 AM to 10:00 PM. All truck appointments must be booked 24 hours in advance.',
   'truck',
   now() - interval '3 minutes'),

  ('AGCT',
   'System Maintenance Notice',
   'The ICTSI online portal will be undergoing scheduled maintenance on Saturday from 11:00 PM to 2:00 AM Sunday. During this period, online booking and tracking services will be temporarily unavailable. We apologize for any inconvenience.',
   null,
   now() - interval '8 hours'),

  ('MICTSI',
   'New Vessel Berth Allocation Policy',
   'Effective next month, MICTSI will implement a revised berth allocation policy for all vessels. Shipping lines are advised to submit berth window requests at least 72 hours prior to estimated time of arrival. Late submissions may result in delayed berthing.',
   'vessel',
   now() - interval '1 day')
on conflict do nothing;

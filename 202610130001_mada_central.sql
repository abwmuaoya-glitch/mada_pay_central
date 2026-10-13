-- Mada Pay Central: additive migration only.
-- Existing public.profiles, public.user_roles, and public.transactions are NOT recreated or altered.
-- Run after reviewing the existing schema and role mapping in your Supabase project.

create table if not exists public.mada_integrations (
  id uuid primary key default gen_random_uuid(),
  display_name text not null,
  region text not null check (region in ('ADEN','SANAA')),
  provider_type text not null check (provider_type in ('BANK','EXCHANGE','WALLET','NETWORK','OTHER')),
  status text not null default 'PENDING' check (status in ('PENDING','ACTIVE','PAUSED','REJECTED')),
  external_reference text,
  notes text,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.mada_region_members (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  region text not null check (region in ('ADEN','SANAA')),
  role text not null check (role in ('REGIONAL_OWNER','REGIONAL_ADMIN','AUDITOR','OPERATOR')),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (user_id, region)
);

create table if not exists public.mada_audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid references auth.users(id) on delete set null,
  action text not null,
  entity_type text not null,
  entity_id text,
  region text check (region in ('ADEN','SANAA') or region is null),
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists mada_integrations_region_status_idx on public.mada_integrations(region, status);
create index if not exists mada_region_members_user_region_idx on public.mada_region_members(user_id, region, active);
create index if not exists mada_audit_logs_created_at_idx on public.mada_audit_logs(created_at desc);

alter table public.mada_integrations enable row level security;
alter table public.mada_region_members enable row level security;
alter table public.mada_audit_logs enable row level security;

-- Admin access follows the existing role table pattern used by the app: user_roles(user_id, role).
-- If your existing user_roles schema differs, adjust this helper before running the migration.
create or replace function public.mada_is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.user_roles ur
    where ur.user_id = auth.uid()
      and upper(ur.role::text) in ('OWNER','ADMIN','SUPER_ADMIN')
  );
$$;

create or replace function public.mada_can_access_region(p_region text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.mada_is_admin() or exists (
    select 1 from public.mada_region_members rm
    where rm.user_id = auth.uid()
      and rm.region = p_region
      and rm.active = true
      and rm.role in ('REGIONAL_OWNER','REGIONAL_ADMIN','AUDITOR','OPERATOR')
  );
$$;

revoke all on function public.mada_is_admin() from public;
revoke all on function public.mada_can_access_region(text) from public;
grant execute on function public.mada_is_admin() to authenticated;
grant execute on function public.mada_can_access_region(text) to authenticated;

drop policy if exists "mada integrations regional read" on public.mada_integrations;
create policy "mada integrations regional read" on public.mada_integrations
for select to authenticated using (public.mada_is_admin() or public.mada_can_access_region(region));

drop policy if exists "mada integrations admin insert" on public.mada_integrations;
create policy "mada integrations admin insert" on public.mada_integrations
for insert to authenticated with check (public.mada_is_admin());

drop policy if exists "mada integrations admin update" on public.mada_integrations;
create policy "mada integrations admin update" on public.mada_integrations
for update to authenticated using (public.mada_is_admin()) with check (public.mada_is_admin());

drop policy if exists "mada region members admin manage" on public.mada_region_members;
create policy "mada region members admin manage" on public.mada_region_members
for all to authenticated using (public.mada_is_admin()) with check (public.mada_is_admin());

drop policy if exists "mada audit regional read" on public.mada_audit_logs;
create policy "mada audit regional read" on public.mada_audit_logs
for select to authenticated using (public.mada_is_admin() or public.mada_can_access_region(region));

-- Audit writes should be performed by a trusted server-side function, not directly by clients.

-- Do not store provider API secrets in mada_integrations. Put secrets in a server-side secret store.
-- Seed regional memberships only after verifying the actual user UUIDs and partnership agreement.

-- Additional catalog tables used by the unified administration UI.
create table if not exists public.mada_payment_providers (
  id uuid primary key default gen_random_uuid(),
  display_name text not null,
  region text not null check (region in ('ADEN','SANAA')),
  provider_type text not null default 'OTHER' check (provider_type in ('BANK','WALLET','EXCHANGE','NETWORK','OTHER')),
  status text not null default 'PENDING' check (status in ('PENDING','ACTIVE','PAUSED','REJECTED')),
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.mada_service_providers (
  id uuid primary key default gen_random_uuid(),
  display_name text not null,
  region text not null check (region in ('ADEN','SANAA')),
  provider_type text not null default 'OTHER',
  status text not null default 'PENDING' check (status in ('PENDING','ACTIVE','PAUSED','REJECTED')),
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.mada_services (
  id uuid primary key default gen_random_uuid(),
  service_name text not null,
  category text not null default 'GENERAL',
  status text not null default 'PENDING' check (status in ('PENDING','ACTIVE','PAUSED','REJECTED')),
  description text,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists mada_payment_providers_region_status_idx on public.mada_payment_providers(region, status);
create index if not exists mada_service_providers_region_status_idx on public.mada_service_providers(region, status);
create index if not exists mada_services_status_idx on public.mada_services(status);

alter table public.mada_payment_providers enable row level security;
alter table public.mada_service_providers enable row level security;
alter table public.mada_services enable row level security;

drop policy if exists "mada payment provider regional read" on public.mada_payment_providers;
create policy "mada payment provider regional read" on public.mada_payment_providers
for select to authenticated using (public.mada_is_admin() or public.mada_can_access_region(region));
drop policy if exists "mada payment provider admin insert" on public.mada_payment_providers;
create policy "mada payment provider admin insert" on public.mada_payment_providers
for insert to authenticated with check (public.mada_is_admin());
drop policy if exists "mada payment provider admin update" on public.mada_payment_providers;
create policy "mada payment provider admin update" on public.mada_payment_providers
for update to authenticated using (public.mada_is_admin()) with check (public.mada_is_admin());

drop policy if exists "mada service provider regional read" on public.mada_service_providers;
create policy "mada service provider regional read" on public.mada_service_providers
for select to authenticated using (public.mada_is_admin() or public.mada_can_access_region(region));
drop policy if exists "mada service provider admin insert" on public.mada_service_providers;
create policy "mada service provider admin insert" on public.mada_service_providers
for insert to authenticated with check (public.mada_is_admin());
drop policy if exists "mada service provider admin update" on public.mada_service_providers;
create policy "mada service provider admin update" on public.mada_service_providers
for update to authenticated using (public.mada_is_admin()) with check (public.mada_is_admin());

drop policy if exists "mada services authenticated read" on public.mada_services;
create policy "mada services authenticated read" on public.mada_services
for select to authenticated using (status = 'ACTIVE' or public.mada_is_admin());
drop policy if exists "mada services admin insert" on public.mada_services;
create policy "mada services admin insert" on public.mada_services
for insert to authenticated with check (public.mada_is_admin());
drop policy if exists "mada services admin update" on public.mada_services;
create policy "mada services admin update" on public.mada_services
for update to authenticated using (public.mada_is_admin()) with check (public.mada_is_admin());

-- A regional owner/admin may manage records inside their assigned region only.
create or replace function public.mada_can_manage_region(p_region text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.mada_is_admin() or exists (
    select 1 from public.mada_region_members rm
    where rm.user_id = auth.uid()
      and rm.region = p_region
      and rm.active = true
      and rm.role in ('REGIONAL_OWNER','REGIONAL_ADMIN')
  );
$$;
revoke all on function public.mada_can_manage_region(text) from public;
grant execute on function public.mada_can_manage_region(text) to authenticated;

drop policy if exists "mada region members read own" on public.mada_region_members;
create policy "mada region members read own" on public.mada_region_members
for select to authenticated using (user_id = auth.uid() or public.mada_is_admin());

drop policy if exists "mada integrations admin insert" on public.mada_integrations;
create policy "mada integrations regional insert" on public.mada_integrations
for insert to authenticated with check (public.mada_can_manage_region(region));
drop policy if exists "mada integrations admin update" on public.mada_integrations;
create policy "mada integrations regional update" on public.mada_integrations
for update to authenticated using (public.mada_can_manage_region(region)) with check (public.mada_can_manage_region(region));

drop policy if exists "mada payment provider admin insert" on public.mada_payment_providers;
create policy "mada payment provider regional insert" on public.mada_payment_providers
for insert to authenticated with check (public.mada_can_manage_region(region));
drop policy if exists "mada payment provider admin update" on public.mada_payment_providers;
create policy "mada payment provider regional update" on public.mada_payment_providers
for update to authenticated using (public.mada_can_manage_region(region)) with check (public.mada_can_manage_region(region));

drop policy if exists "mada service provider admin insert" on public.mada_service_providers;
create policy "mada service provider regional insert" on public.mada_service_providers
for insert to authenticated with check (public.mada_can_manage_region(region));
drop policy if exists "mada service provider admin update" on public.mada_service_providers;
create policy "mada service provider regional update" on public.mada_service_providers
for update to authenticated using (public.mada_can_manage_region(region)) with check (public.mada_can_manage_region(region));

-- Customer service requests are separate from the legacy registration_requests table.
create table if not exists public.mada_service_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  service_key text not null,
  details text not null default '',
  status text not null default 'PENDING' check (status in ('PENDING','PROCESSING','APPROVED','REJECTED','COMPLETED')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists mada_service_requests_created_idx on public.mada_service_requests(created_at desc);
create index if not exists mada_service_requests_user_idx on public.mada_service_requests(user_id, created_at desc);
alter table public.mada_service_requests enable row level security;
drop policy if exists "mada service requests customer create own" on public.mada_service_requests;
create policy "mada service requests customer create own" on public.mada_service_requests
for insert to authenticated with check (user_id = auth.uid());
drop policy if exists "mada service requests customer read own" on public.mada_service_requests;
create policy "mada service requests customer read own" on public.mada_service_requests
for select to authenticated using (user_id = auth.uid() or public.mada_is_admin());
drop policy if exists "mada service requests admin update" on public.mada_service_requests;
create policy "mada service requests admin update" on public.mada_service_requests
for update to authenticated using (public.mada_is_admin()) with check (public.mada_is_admin());

-- Narrow security-definer RPC: administrators can approve/block a device without granting broad profile updates.
create or replace function public.mada_admin_set_device(
  p_user_id uuid,
  p_device_id text,
  p_device_status text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null or not public.mada_is_admin() then
    raise exception 'not authorized';
  end if;
  if p_device_status not in ('ACTIVE','BLOCKED','PENDING') then
    raise exception 'invalid device status';
  end if;
  if p_device_status = 'ACTIVE' and coalesce(trim(p_device_id), '') = '' then
    raise exception 'device id required';
  end if;
  update public.profiles
     set device_id = nullif(trim(p_device_id), ''),
         device_status = p_device_status
   where id = p_user_id;
  if not found then
    raise exception 'profile not found';
  end if;
end;
$$;
revoke all on function public.mada_admin_set_device(uuid, text, text) from public;
grant execute on function public.mada_admin_set_device(uuid, text, text) to authenticated;

create extension if not exists "pgcrypto";

create table if not exists public.client_addresses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  recipient text not null,
  street text not null,
  number text not null,
  complement text,
  neighborhood text not null,
  city text not null,
  state text not null,
  zip_code text not null,
  latitude double precision,
  longitude double precision,
  is_default boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint client_addresses_state_length check (char_length(trim(state)) = 2),
  constraint client_addresses_zip_code_format check (zip_code ~ '^[0-9]{5}-?[0-9]{3}$')
);

create index if not exists client_addresses_user_id_idx
  on public.client_addresses(user_id);

create unique index if not exists client_addresses_one_default_per_user_idx
  on public.client_addresses(user_id)
  where is_default = true;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists client_addresses_set_updated_at on public.client_addresses;
create trigger client_addresses_set_updated_at
before update on public.client_addresses
for each row
execute function public.set_updated_at();

alter table public.client_addresses enable row level security;

drop policy if exists "Users can read their own addresses"
  on public.client_addresses;
create policy "Users can read their own addresses"
  on public.client_addresses
  for select
  using (auth.uid() = user_id);

drop policy if exists "Users can insert their own addresses"
  on public.client_addresses;
create policy "Users can insert their own addresses"
  on public.client_addresses
  for insert
  with check (auth.uid() = user_id);

drop policy if exists "Users can update their own addresses"
  on public.client_addresses;
create policy "Users can update their own addresses"
  on public.client_addresses
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Users can delete their own addresses"
  on public.client_addresses;
create policy "Users can delete their own addresses"
  on public.client_addresses
  for delete
  using (auth.uid() = user_id);

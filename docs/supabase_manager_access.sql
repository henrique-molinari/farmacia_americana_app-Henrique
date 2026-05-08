-- Rode este SQL no Supabase SQL Editor depois de criar as tabelas iniciais.
-- Ele libera leitura administrativa para atendente, farmaceutico, gerente e admin.

create or replace function public.current_user_role()
returns text
language sql
security definer
set search_path = public
as $$
  select role
  from public.profiles
  where id = auth.uid()
  limit 1
$$;

do $$
begin
  alter publication supabase_realtime add table public.orders;
exception
  when duplicate_object then null;
end;
$$;

do $$
begin
  alter publication supabase_realtime add table public.profiles;
exception
  when duplicate_object then null;
end;
$$;

alter table public.orders replica identity full;
alter table public.profiles replica identity full;

drop policy if exists "Staff can read all profiles" on public.profiles;
create policy "Staff can read all profiles"
on public.profiles
for select
to authenticated
using (
  public.current_user_role() in ('atendente', 'farmaceutico', 'gerente', 'admin')
);

drop policy if exists "Staff can read all orders" on public.orders;
create policy "Staff can read all orders"
on public.orders
for select
to authenticated
using (
  public.current_user_role() in ('atendente', 'farmaceutico', 'gerente', 'admin')
);

drop policy if exists "Staff can read all products" on public.products;
create policy "Staff can read all products"
on public.products
for select
to authenticated
using (
  public.current_user_role() in ('atendente', 'farmaceutico', 'gerente', 'admin')
);

drop policy if exists "Staff can read all order items" on public.order_items;
create policy "Staff can read all order items"
on public.order_items
for select
to authenticated
using (
  public.current_user_role() in ('atendente', 'farmaceutico', 'gerente', 'admin')
);

drop policy if exists "Staff can update order status" on public.orders;
create policy "Staff can update order status"
on public.orders
for update
to authenticated
using (
  public.current_user_role() in ('atendente', 'farmaceutico', 'gerente', 'admin')
)
with check (
  public.current_user_role() in ('atendente', 'farmaceutico', 'gerente', 'admin')
);

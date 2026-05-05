-- Rode este SQL no Supabase SQL Editor para habilitar o chat entre cliente e atendente.
-- Ele cria as tabelas do atendimento, mantem uma conversa ativa por cliente
-- e libera as policies necessarias para cliente e equipe.

create extension if not exists pgcrypto;

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

create table if not exists public.support_conversations (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references public.profiles(id) on delete cascade,
  attendant_id uuid references public.profiles(id) on delete set null,
  status text not null default 'novo'
    check (status in ('novo', 'em_atendimento', 'finalizado')),
  is_urgent boolean not null default false,
  last_message_preview text,
  last_message_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create unique index if not exists support_conversations_one_active_per_client
on public.support_conversations (client_id)
where status in ('novo', 'em_atendimento');

create index if not exists support_conversations_status_updated_at_idx
on public.support_conversations (status, updated_at desc);

create table if not exists public.support_messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.support_conversations(id) on delete cascade,
  sender_id uuid references public.profiles(id) on delete set null,
  sender_name text,
  sender_type text not null
    check (sender_type in ('client', 'attendant', 'bot', 'system')),
  message_type text not null default 'text'
    check (message_type in ('text', 'attachment')),
  body text,
  attachment_name text,
  attachment_details text,
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists support_messages_conversation_created_at_idx
on public.support_messages (conversation_id, created_at);

create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

drop trigger if exists trg_support_conversations_updated_at on public.support_conversations;
create trigger trg_support_conversations_updated_at
before update on public.support_conversations
for each row
execute function public.touch_updated_at();

create or replace function public.sync_support_conversation_after_message()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.support_conversations
     set last_message_preview = coalesce(
           nullif(new.body, ''),
           nullif(new.attachment_name, ''),
           'Nova mensagem'
         ),
         last_message_at = new.created_at,
         updated_at = timezone('utc', now()),
         status = case
           when status = 'finalizado' then 'em_atendimento'
           else status
         end,
         is_urgent = case
           when new.sender_type = 'system' and coalesce(new.body, '') ilike '%urgencia%'
             then true
           else is_urgent
         end
   where id = new.conversation_id;

  return new;
end;
$$;

drop trigger if exists trg_support_messages_sync_conversation on public.support_messages;
create trigger trg_support_messages_sync_conversation
after insert on public.support_messages
for each row
execute function public.sync_support_conversation_after_message();

alter table public.support_conversations enable row level security;
alter table public.support_messages enable row level security;

drop policy if exists "Client can read own support conversations" on public.support_conversations;
create policy "Client can read own support conversations"
on public.support_conversations
for select
to authenticated
using (client_id = auth.uid());

drop policy if exists "Client can create own support conversations" on public.support_conversations;
create policy "Client can create own support conversations"
on public.support_conversations
for insert
to authenticated
with check (client_id = auth.uid());

drop policy if exists "Client can update own support conversations" on public.support_conversations;
create policy "Client can update own support conversations"
on public.support_conversations
for update
to authenticated
using (client_id = auth.uid())
with check (client_id = auth.uid());

drop policy if exists "Staff can read support conversations" on public.support_conversations;
create policy "Staff can read support conversations"
on public.support_conversations
for select
to authenticated
using (public.current_user_role() in ('atendente', 'farmaceutico', 'gerente', 'admin'));

drop policy if exists "Staff can update support conversations" on public.support_conversations;
create policy "Staff can update support conversations"
on public.support_conversations
for update
to authenticated
using (public.current_user_role() in ('atendente', 'farmaceutico', 'gerente', 'admin'))
with check (public.current_user_role() in ('atendente', 'farmaceutico', 'gerente', 'admin'));

drop policy if exists "Client can read own support messages" on public.support_messages;
create policy "Client can read own support messages"
on public.support_messages
for select
to authenticated
using (
  exists (
    select 1
    from public.support_conversations conversation
    where conversation.id = support_messages.conversation_id
      and conversation.client_id = auth.uid()
  )
);

drop policy if exists "Client can create own support messages" on public.support_messages;
create policy "Client can create own support messages"
on public.support_messages
for insert
to authenticated
with check (
  exists (
    select 1
    from public.support_conversations conversation
    where conversation.id = support_messages.conversation_id
      and conversation.client_id = auth.uid()
  )
);

drop policy if exists "Staff can read support messages" on public.support_messages;
create policy "Staff can read support messages"
on public.support_messages
for select
to authenticated
using (public.current_user_role() in ('atendente', 'farmaceutico', 'gerente', 'admin'));

drop policy if exists "Staff can create support messages" on public.support_messages;
create policy "Staff can create support messages"
on public.support_messages
for insert
to authenticated
with check (public.current_user_role() in ('atendente', 'farmaceutico', 'gerente', 'admin'));

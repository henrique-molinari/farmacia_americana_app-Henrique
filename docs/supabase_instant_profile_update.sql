-- Enables instant profile updates from the Flutter app.
-- This bypasses Supabase email-change confirmation for the signed-in user.
-- Run this in Supabase SQL Editor.

create or replace function public.update_my_profile_instant(
  p_full_name text,
  p_email text
)
returns table (
  id uuid,
  full_name text,
  email text,
  role text
)
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  current_user_id uuid := auth.uid();
  normalized_name text := trim(coalesce(p_full_name, ''));
  normalized_email text := lower(trim(coalesce(p_email, '')));
  profile_role text;
begin
  if current_user_id is null then
    raise exception 'Entre com sua conta para alterar seus dados.';
  end if;

  if normalized_name = '' then
    raise exception 'Informe seu nome completo.';
  end if;

  if normalized_email !~* '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$' then
    raise exception 'Informe um e-mail valido.';
  end if;

  select profiles.role
    into profile_role
  from public.profiles
  where profiles.id = current_user_id;

  profile_role := coalesce(profile_role, 'cliente');

  if profile_role = 'cliente'
    and (
      normalized_email like '%@americanaat.com'
      or normalized_email like '%@americanaadm.com'
    )
  then
    raise exception 'E-mails institucionais devem ser criados pelo cadastro correto.';
  end if;

  if exists (
    select 1
    from auth.users
    where lower(auth.users.email) = normalized_email
      and auth.users.id <> current_user_id
  ) then
    raise exception 'Este e-mail ja esta em uso por outra conta.';
  end if;

  update auth.users
  set
    email = normalized_email,
    raw_user_meta_data = coalesce(raw_user_meta_data, '{}'::jsonb)
      || jsonb_build_object('full_name', normalized_name),
    email_confirmed_at = coalesce(email_confirmed_at, now()),
    updated_at = now()
  where auth.users.id = current_user_id;

  insert into public.profiles (id, full_name, email, role)
  values (current_user_id, normalized_name, normalized_email, profile_role)
  on conflict on constraint profiles_pkey do update
  set
    full_name = excluded.full_name,
    email = excluded.email;

  return query
  select
    profiles.id,
    profiles.full_name,
    profiles.email,
    profiles.role::text
  from public.profiles
  where profiles.id = current_user_id;
end;
$$;

revoke all on function public.update_my_profile_instant(text, text) from public;
grant execute on function public.update_my_profile_instant(text, text) to authenticated;

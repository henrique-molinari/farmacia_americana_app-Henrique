-- Keeps public.profiles synchronized with Supabase Auth users.
-- Run this in Supabase SQL Editor.

create or replace function public.sync_profile_from_auth_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, email, role)
  values (
    new.id,
    coalesce(
      nullif(new.raw_user_meta_data ->> 'full_name', ''),
      split_part(coalesce(new.email, ''), '@', 1)
    ),
    coalesce(new.email, ''),
    coalesce(nullif(new.raw_user_meta_data ->> 'role', ''), 'cliente')
  )
  on conflict (id) do update
  set
    full_name = coalesce(
      nullif(new.raw_user_meta_data ->> 'full_name', ''),
      public.profiles.full_name
    ),
    email = coalesce(new.email, public.profiles.email);

  return new;
end;
$$;

drop trigger if exists sync_profile_after_auth_user_change on auth.users;

create trigger sync_profile_after_auth_user_change
after insert or update of email, raw_user_meta_data on auth.users
for each row execute function public.sync_profile_from_auth_user();

-- Fix users that already exist before the trigger was created.
update public.profiles as profile
set
  full_name = coalesce(
    nullif(auth_user.raw_user_meta_data ->> 'full_name', ''),
    profile.full_name
  ),
  email = coalesce(auth_user.email, profile.email)
from auth.users as auth_user
where profile.id = auth_user.id
  and (
    profile.email is distinct from auth_user.email
    or profile.full_name is distinct from coalesce(
      nullif(auth_user.raw_user_meta_data ->> 'full_name', ''),
      profile.full_name
    )
  );

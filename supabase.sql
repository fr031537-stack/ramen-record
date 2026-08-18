-- Supabase SQL Editorで一度だけ実行してください。
create extension if not exists pgcrypto;

create table if not exists public.shops (
  id uuid primary key default gen_random_uuid(),
  seed_id text,
  user_id uuid not null references auth.users(id) on delete cascade,
  area text not null default '',
  name text not null,
  legacy_count integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.visits (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  shop_id uuid not null references public.shops(id) on delete cascade,
  visited_on date not null,
  menu text not null default '',
  soup text not null default '',
  noodle text not null default '',
  revisit text not null default '',
  comment text not null default '',
  created_at timestamptz not null default now(),
  constraint soup_rating check (soup in ('◎','〇','△','×','')),
  constraint noodle_rating check (noodle in ('◎','〇','△','×','')),
  constraint revisit_rating check (revisit in ('◎','〇','△','×',''))
);

create table if not exists public.visit_photos (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  visit_id uuid not null references public.visits(id) on delete cascade,
  path text not null,
  created_at timestamptz not null default now()
);

alter table public.shops enable row level security;
alter table public.visits enable row level security;
alter table public.visit_photos enable row level security;

drop policy if exists "own shops select" on public.shops;
drop policy if exists "own shops insert" on public.shops;
drop policy if exists "own shops update" on public.shops;
drop policy if exists "own shops delete" on public.shops;
create policy "own shops select" on public.shops for select using ((select auth.uid()) = user_id);
create policy "own shops insert" on public.shops for insert with check ((select auth.uid()) = user_id);
create policy "own shops update" on public.shops for update using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "own shops delete" on public.shops for delete using ((select auth.uid()) = user_id);

drop policy if exists "own visits select" on public.visits;
drop policy if exists "own visits insert" on public.visits;
drop policy if exists "own visits update" on public.visits;
drop policy if exists "own visits delete" on public.visits;
create policy "own visits select" on public.visits for select using ((select auth.uid()) = user_id);
create policy "own visits insert" on public.visits for insert with check ((select auth.uid()) = user_id);
create policy "own visits update" on public.visits for update using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "own visits delete" on public.visits for delete using ((select auth.uid()) = user_id);

drop policy if exists "own photos select" on public.visit_photos;
drop policy if exists "own photos insert" on public.visit_photos;
drop policy if exists "own photos delete" on public.visit_photos;
create policy "own photos select" on public.visit_photos for select using ((select auth.uid()) = user_id);
create policy "own photos insert" on public.visit_photos for insert with check ((select auth.uid()) = user_id);
create policy "own photos delete" on public.visit_photos for delete using ((select auth.uid()) = user_id);

insert into storage.buckets (id, name, public)
values ('ramen-photos','ramen-photos',false)
on conflict (id) do update set public=false;

drop policy if exists "own ramen photos read" on storage.objects;
drop policy if exists "own ramen photos upload" on storage.objects;
drop policy if exists "own ramen photos delete" on storage.objects;
create policy "own ramen photos read" on storage.objects for select to authenticated
using (bucket_id='ramen-photos' and (storage.foldername(name))[1] = (select auth.uid()::text));
create policy "own ramen photos upload" on storage.objects for insert to authenticated
with check (bucket_id='ramen-photos' and (storage.foldername(name))[1] = (select auth.uid()::text));
create policy "own ramen photos delete" on storage.objects for delete to authenticated
using (bucket_id='ramen-photos' and (storage.foldername(name))[1] = (select auth.uid()::text));

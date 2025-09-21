-- =========================================================
-- Extensions
-- =========================================================
create extension if not exists postgis;
create extension if not exists pgcrypto; -- for gen_random_uuid()

-- =========================================================
-- Enums
-- =========================================================
do $$ begin
  create type user_role as enum ('admin','manager','agent');
exception when duplicate_object then null; end $$;

do $$ begin
  create type property_type as enum (
    'apartment','house','riad','villa','land','office','retail','warehouse','other'
  );
exception when duplicate_object then null; end $$;

do $$ begin
  create type listing_status as enum ('draft','active','pending','sold','rented','archived');
exception when duplicate_object then null; end $$;

-- =========================================================
-- Profiles (linked to Supabase auth.users)
-- =========================================================
create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role user_role not null default 'agent',
  full_name text,
  phone text,
  created_at timestamptz not null default now()
);

-- =========================================================
-- Agencies & members
-- =========================================================
create table if not exists public.agencies (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text unique,
  created_at timestamptz not null default now()
);

create table if not exists public.agency_members (
  agency_id uuid not null references public.agencies(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role user_role not null default 'agent',
  created_at timestamptz not null default now(),
  primary key (agency_id, user_id)
);

-- =========================================================
-- Branches (city offices)
-- =========================================================
create table if not exists public.agency_branches (
  id uuid primary key default gen_random_uuid(),
  agency_id uuid not null references public.agencies(id) on delete cascade,
  name text not null,
  city text not null,
  region text,
  address text,
  phone text,
  email text,
  created_at timestamptz not null default now()
);

-- =========================================================
-- Properties
-- =========================================================
create table if not exists public.properties (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  agency_id uuid not null references public.agencies(id) on delete restrict,
  branch_id uuid references public.agency_branches(id) on delete restrict,
  created_by uuid not null references auth.users(id) on delete restrict,

  title text not null,
  description text,
  property_type property_type not null,
  price_mad numeric(14,2) check (price_mad is null or price_mad >= 0),

  address text not null,
  city text not null,
  region text,
  postal_code text,
  country char(2) not null default 'MA',

  bedrooms int check (bedrooms is null or bedrooms >= 0),
  bathrooms numeric(3,1) check (bathrooms is null or bathrooms >= 0),
  area_m2 numeric(10,2) check (area_m2 is null or area_m2 >= 0),
  lot_m2 numeric(12,2) check (lot_m2 is null or lot_m2 >= 0),
  floor int,

  location geography(Point,4326),
  latitude  numeric(9,6)  check (latitude between -90 and 90),
  longitude numeric(9,6)  check (longitude between -180 and 180)
);

-- =========================================================
-- Listings
-- =========================================================
create table if not exists public.listings (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  published_at timestamptz,
  updated_at timestamptz not null default now(),

  property_id uuid not null references public.properties(id) on delete cascade,
  agency_id uuid not null references public.agencies(id) on delete restrict,
  branch_id uuid references public.agency_branches(id) on delete restrict,
  agent_id uuid not null references auth.users(id) on delete restrict,

  status listing_status not null default 'draft',
  for_sale boolean not null default true,
  for_rent boolean not null default false,
  price_mad numeric(14,2) check (price_mad is null or price_mad >= 0),

  headline text,
  description text
);

-- =========================================================
-- Media & features
-- =========================================================
create table if not exists public.listing_media (
  id uuid primary key default gen_random_uuid(),
  listing_id uuid not null references public.listings(id) on delete cascade,
  storage_path text not null,
  alt text,
  sort_order int default 0,
  is_cover boolean default false,
  created_at timestamptz not null default now()
);

create unique index if not exists ux_listing_cover
  on public.listing_media(listing_id)
  where is_cover = true;

create table if not exists public.listing_features (
  listing_id uuid not null references public.listings(id) on delete cascade,
  key text not null,
  value text,
  primary key (listing_id, key)
);

-- =========================================================
-- Leads & appointments
-- =========================================================
create table if not exists public.leads (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),

  listing_id uuid not null references public.listings(id) on delete cascade,
  agency_id uuid not null references public.agencies(id) on delete restrict,
  assigned_agent uuid references auth.users(id) on delete set null,

  full_name text not null,
  email text,
  phone text,
  message text,
  source text,
  status text not null default 'new'
);

create table if not exists public.appointments (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),

  lead_id uuid not null references public.leads(id) on delete cascade,
  listing_id uuid not null references public.listings(id) on delete cascade,
  agent_id uuid not null references auth.users(id) on delete restrict,

  scheduled_at timestamptz not null,
  notes text
);

-- =========================================================
-- Saved listings & price history
-- =========================================================
create table if not exists public.saved_listings (
  user_id uuid not null references auth.users(id) on delete cascade,
  listing_id uuid not null references public.listings(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, listing_id)
);

create table if not exists public.listing_price_history (
  id uuid primary key default gen_random_uuid(),
  listing_id uuid not null references public.listings(id) on delete cascade,
  price_mad numeric(14,2) not null check (price_mad >= 0),
  changed_at timestamptz not null default now()
);

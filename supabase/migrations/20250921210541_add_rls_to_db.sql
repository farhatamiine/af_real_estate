alter table public.profiles enable row level security;
alter table public.agencies enable row level security;
alter table public.agency_members enable row level security;
alter table public.agency_branches enable row level security;
alter table public.properties enable row level security;
alter table public.listings enable row level security;
alter table public.listing_media enable row level security;
alter table public.listing_features enable row level security;
alter table public.leads enable row level security;
alter table public.appointments enable row level security;
alter table public.saved_listings enable row level security;
alter table public.listing_price_history enable row level security;



create policy "read own profile" on public.profiles
  for select using (auth.uid() = user_id);

create policy "update own profile" on public.profiles
  for update using (auth.uid() = user_id);

create policy "read agencies" on public.agencies
  for select using (true);

create policy "read own memberships" on public.agency_members
  for select using (auth.uid() = user_id);

create policy "read branches" on public.agency_branches
  for select using (true);

create policy "read all properties" on public.properties
  for select using (true);

create policy "insert own property" on public.properties
  for insert with check (auth.uid() = created_by);

create policy "update own property" on public.properties
  for update using (auth.uid() = created_by);

create policy "delete own property" on public.properties
  for delete using (auth.uid() = created_by);

create policy "read all listings" on public.listings
  for select using (true);

create policy "insert own listing" on public.listings
  for insert with check (auth.uid() = agent_id);

create policy "update own listing" on public.listings
  for update using (auth.uid() = agent_id);

create policy "delete own listing" on public.listings
  for delete using (auth.uid() = agent_id);

create policy "read media" on public.listing_media
  for select using (true);

create policy "modify media if listing is mine" on public.listing_media
  for all using (
    exists(select 1 from public.listings l where l.id = listing_id and l.agent_id = auth.uid())
  );

create policy "read features" on public.listing_features
  for select using (true);

create policy "modify features if listing is mine" on public.listing_features
  for all using (
    exists(select 1 from public.listings l where l.id = listing_id and l.agent_id = auth.uid())
  );

create policy "read all leads" on public.leads
  for select using (true);

create policy "insert lead" on public.leads
  for insert with check (true);

create policy "read all appointments" on public.appointments
  for select using (true);

create policy "insert appointment" on public.appointments
  for insert with check (auth.uid() = agent_id);

create policy "read own saved" on public.saved_listings
  for select using (auth.uid() = user_id);

create policy "manage own saved" on public.saved_listings
  for all using (auth.uid() = user_id);

create policy "read price history" on public.listing_price_history
  for select using (true);

create policy "insert price history if agent" on public.listing_price_history
  for insert with check (
    exists(select 1 from public.listings l where l.id = listing_id and l.agent_id = auth.uid())
  );

-- =========================================================
-- SEED DATA for Real Estate App (Morocco)
-- =========================================================

-- 1. Agency
insert into public.agencies (id, name, slug)
values (gen_random_uuid(), 'Dar Immo', 'dar-immo')
on conflict (slug) do nothing;

-- 2. Branches
insert into public.agency_branches (id, agency_id, name, city, region, address, phone, email)
select gen_random_uuid(), a.id, 'Casablanca HQ', 'Casablanca', 'Grand Casablanca',
       'Maarif', '+212600000001', 'casa@darimmo.ma'
from public.agencies a
where a.slug = 'dar-immo'
on conflict do nothing;

insert into public.agency_branches (id, agency_id, name, city, region, address, phone, email)
select gen_random_uuid(), a.id, 'Marrakech Medina', 'Marrakech', 'Marrakech-Safi',
       'Medina', '+212600000002', 'marrakech@darimmo.ma'
from public.agencies a
where a.slug = 'dar-immo'
on conflict do nothing;

-- 3. Profile for logged-in user
insert into public.profiles (user_id, role, full_name, phone)
values (auth.uid(), 'admin', 'Tenant Admin', '+212600000000')
on conflict (user_id) do update
  set role = excluded.role,
      full_name = excluded.full_name,
      phone = excluded.phone;

-- 4. Membership for logged-in user
insert into public.agency_members (agency_id, user_id, role)
select a.id, auth.uid(), 'admin'
from public.agencies a
where a.slug = 'dar-immo'
on conflict (agency_id, user_id) do update
  set role = excluded.role;

-- 5. Property
insert into public.properties (
  agency_id, branch_id, created_by,
  title, description, property_type,
  price_mad, address, city, region, postal_code, country,
  bedrooms, bathrooms, area_m2, floor,
  location, latitude, longitude
)
select a.id, b.id, auth.uid(),
  'Appartement à Maarif',
  'Bel appartement lumineux, proche des commodités.',
  'apartment',
  1450000, 'Rue XYZ, Maarif', 'Casablanca', 'Grand Casablanca', '20000', 'MA',
  2, 1.0, 78.5, 3,
  geography(st_setsrid(st_makepoint(-7.632, 33.608), 4326)), 33.608, -7.632
from public.agencies a
join public.agency_branches b on b.agency_id = a.id and b.city = 'Casablanca'
where a.slug = 'dar-immo'
on conflict do nothing;

-- 6. Listing
insert into public.listings (
  property_id, agency_id, branch_id, agent_id,
  status, for_sale, for_rent,
  price_mad, headline, description
)
select p.id, p.agency_id, p.branch_id, auth.uid(),
  'active', true, false,
  p.price_mad,
  'Casablanca Maarif - 2 chambres',
  'Appartement lumineux au 3e étage, prêt à emménager.'
from public.properties p
where p.title = 'Appartement à Maarif'
on conflict do nothing;

-- 7. Media
insert into public.listing_media (listing_id, storage_path, alt, is_cover)
select l.id, 'listing-media/sample1.jpg', 'Salon lumineux', true
from public.listings l
where l.headline like 'Casablanca Maarif%'
on conflict do nothing;

-- 8. Lead
insert into public.leads (listing_id, agency_id, full_name, email, phone, message, source, status)
select l.id, l.agency_id,
  'Ahmed El Fassi', 'ahmed@example.com', '+212600000003',
  'Je suis intéressé par la visite de cet appartement.',
  'website', 'new'
from public.listings l
where l.headline like 'Casablanca Maarif%'
on conflict do nothing;

-- 9. Appointment
insert into public.appointments (lead_id, listing_id, agent_id, scheduled_at, notes)
select lead.id, lead.listing_id, auth.uid(),
  now() + interval '3 days',
  'Visite prévue avec Ahmed'
from public.leads lead
where lead.full_name = 'Ahmed El Fassi'
on conflict do nothing;

-- =========================================================
-- END OF SEED
-- =========================================================

# Nextbase + Supabase Starter (Real-Estate MVP)

Production-ready Next.js 15 + Supabase starter to build a real-estate app with role-based access (admin, manager, agent), listings, leads, geo/text search, and clean DX. Uses App Router, React 19, Tailwind v4, Radix UI, TanStack Query, and typed Server Actions.

---

## Features

- Next.js 15 (App Router, RSC, Server Actions)
- Supabase Auth, DB, Storage
- Role-based access (admin, manager, agent) via RLS
- Properties, Listings, Media, Features, Leads, Appointments
- Full-text search (tsvector) + geo search (PostGIS)
- Typed DB (`supabase gen types`) and Zod forms with React Hook Form
- SEO via `next-seo` and `next-sitemap`
- Testing: Vitest (unit) + Playwright (e2e)
- CI-ready release flow with `semantic-release`

---

## Tech stack

- Runtime: Node 20+, PNPM 9
- Framework: Next.js 15, React 19
- UI: Tailwind CSS v4, Radix UI, Headless UI, Lucide Icons, Framer Motion
- Data: Supabase JS v2, TanStack Query
- Forms/Validation: React Hook Form, Zod
- Lint/Format: ESLint, Prettier
- Tests: Vitest, @testing-library/react, Playwright

---

## Quick start

1. **Clone & install**

```bash
pnpm install
```

2. **Create `.env.local`**

```bash
# Required
NEXT_PUBLIC_SUPABASE_URL= https://xxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY= your_anon_key

# Server-only (optional but recommended where needed)
SUPABASE_SERVICE_ROLE_KEY= your_service_role_key

# Used by the types generation script
SUPABASE_PROJECT_REF= xxxxxxxxxxxxxxxxxxxx

# SEO / Sitemap (optional)
NEXT_PUBLIC_SITE_URL= http://localhost:3000
```

3. **Run dev**

```bash
pnpm dev
```

Opens on [http://localhost:3000](http://localhost:3000) using Turbopack.

---

## Supabase setup

1. Create a Supabase project.
2. In Project Settings → API, copy the URL and keys into `.env.local`.
3. (Optional) Install CLI and sign in:

```bash
pnpm dlx supabase login
```

4. Generate typed DB:

```bash
pnpm generate:types:local
```

This writes `src/lib/database.types.ts`.

> If you plan to use geo/text search and the real-estate schema, enable extensions and run your SQL migrations in the Supabase SQL editor:

- `postgis`, `pg_trgm`, `unaccent`
- Tables: `profiles`, `agencies`, `agency_members`, `properties`, `listings`, `listing_media`, `listing_features`, `leads`, `appointments`, `saved_listings`
- Triggers: `listings_tsv_trigger`
- RLS policies for agency-scoped access

---

## Scripts

Directly from `package.json`:

- `dev` → run Next dev with Turbopack
- `start` → run Next in production
- `build` → build the app
- `postbuild` → generate sitemap via `next-sitemap`
- `generate:types:local` → emit typed DB from Supabase into `src/lib/database.types.ts`
- `test` / `test:watch` → Vitest unit tests (root `src`)
- `test:e2e` → Playwright e2e tests
- `lint`, `lint:eslint`, `lint:prettier` → ESLint + Prettier
- `tsc` → type-check

---

## Project structure (suggested)

```
src/
  app/                 # App Router routes
  components/          # UI building blocks
  features/            # Feature slices (listings, leads, etc.)
  lib/
    database.types.ts  # Supabase generated types
    supabase.ts        # Supabase client helpers (browser/server)
    rls.ts             # helpers for role/agency checks (UI)
  styles/              # Tailwind v4 entry CSS
  tests/               # unit tests (vitest)
  e2e/                 # playwright specs
```

---

## Domain model (summary)

- **Profiles** augment `auth.users` with `role: admin|manager|agent`.
- **Agencies** group users.
- **Properties** hold physical data and geo.
- **Listings** hold market data (price, status, for_sale/for_rent) and search TSV.
- **Media/Features** attach to listings.
- **Leads** and **Appointments** cover CRM basics.

> For a full Mermaid class diagram and SQL, see `/docs/model.md` or your schema file if you added one.

---

## Tailwind v4

Tailwind 4 uses the new CSS entry style:

```css
@import 'tailwindcss';
```

No heavy config needed. Utilities and plugins:

- `@tailwindcss/forms`, `@tailwindcss/typography`
- `tailwindcss-animate`, `tailwind-merge`

---

## Testing

- **Unit**: Vitest + Testing Library

```bash
pnpm test
```

- **E2E**: Playwright

```bash
pnpm test:e2e
```

---

## Linting & formatting

```bash
pnpm lint        # ESLint + Prettier
pnpm lint:eslint # ESLint only
pnpm lint:prettier
```

---

## Releases (optional)

Semantic-release is configured for the `main` branch.
Use Conventional Commits (`feat:`, `fix:`, `chore:`, etc.).
CI should provide:

- `GITHUB_TOKEN` for GitHub releases
- NPM publish is disabled (`npmPublish: false`)

---

## SEO & Sitemap

- Configure default SEO with `next-seo`.
- Sitemap is generated on `postbuild` using `next-sitemap.config.cjs`.
  Set `NEXT_PUBLIC_SITE_URL` for correct absolute URLs.

---

## Notes for the Real-Estate MVP

- Create a storage bucket `listing-media` and save paths as `listing-media/{listing_id}/...`.
- Add an RPC `search_listings(...)` to combine text, filters, and radius search.
- Enforce RLS so agents/managers only see their agency’s data.
- Require at least one cover image before publishing a listing.

---

## Troubleshooting

- Types not generated: ensure `SUPABASE_PROJECT_REF` and CLI login, then run `pnpm generate:types:local`.
- 401/Forbidden: check RLS policies and that the user is a member of the agency.
- Tailwind not applying: confirm the v4 CSS entry file is imported in your root layout.

---

## License

MIT.

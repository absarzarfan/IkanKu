# IkanKu Web

Landing page, feature pages, and mock admin pages for IkanKu (Next.js App Router, TypeScript, Tailwind v4).

## Run

```bash
cd web
npm install
npm run dev      # http://localhost:3000
npm run lint
npm run build && npm start
```

Next.js 16 note: `node_modules/next/dist/docs/` holds the version-matched docs (see `AGENTS.md`).

## Routes

Public: `/`, `/produk`, `/tentang-kami`, `/hubungi-kami`, `/artikel`, `/artikel/[slug]`.
Admin (mock, front-end only): `/admin/login`, `/admin/dashboard`, `/admin/artikel/baru`, `/admin/profil`, `/admin/profil/edit`.

There is no backend. Login, contact form, articles and profile edits use client-side validation and browser
`localStorage` only; no network calls, no secrets, no env vars. Design tokens live in `app/globals.css` (`@theme`).
See `../docs/decisions-web.md` and `../docs/web-coverage.md`.

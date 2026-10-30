# UI polish log
Earlier phases (details in git history): gradient tokens (--grad-primary/cta/surface/nav), button states, type scale, contact data in web/data/contact.ts, Tim Kami single-screen cards (A-Z per role, fits 1440x900 and 1920x1080), orange only on CTA buttons, blue surfaces via .surface-brand (worst-case white contrast 4.42).

## Phase 7 redesign (feature/ui-redesign)
Direction: docs/ui-direction.md. Shared: .band-white/.band-tint/.band-blue, .curve-b (soft curve under heroes), .section-title (gradient bar), .card, .badge, .glass-card, SectionHeader, CtaBand, Reveal with stagger. Surface tint is now #F3F8FD.
**Visible changes vs before (screenshots in D:\Tools\shots\before / after):**
- Home: hero is a 2-column blue gradient band with a curved base and a framed phone; "Apa itu" has an offset image frame on a tint band; "Kenapa" steps are glass cards with white number badges; Fitur are 2x2 white cards with tinted icon tiles; testimonials on tint; closing CTA band.
- Produk: curved hero base; video card with rounded-3xl + soft shadow; Keunggulan is a 3+2 centered grid (scroll-snap row below 900px); CtaBand replaces the plain CTA.
- Artikel: featured banner with image zoom on hover (shorter, 720px); list is now white cards with category badges, pill filters, styled search.
- Tentang Kami: curved hero, Mitra and Kontak as cards, Tim Kami photos tuned (see below). Hubungi Kami: curved hero, rounded contact tiles, consistent shadows.
- Navbar: animated active/hover underline, aria-current; footer: top divider and underline-on-hover links.
**Team photos:** `zoom` and `origin` added to web/data/team.ts next to `focus`; every face is centered and large in the circle (wide shots Surya, Naufal F., Hafid, Miftahul zoomed 2.2-3x). Originals untouched.
**Skills evidence**
- ui-ux-pro-max: focus-visible rings + cursor-pointer on buttons/chips/nav (globals.css, Navbar, ArticleList); line-height 1.6 + 72ch measure (globals.css base); duration 150-300ms; no emoji icons (SVG only).
- emil-design-eng: custom ease-out cubic-bezier(.23,1,.32,1) (--ease-out); :active scale .98 (.btn-*); explicit transition properties, no `transition: all`; hover effects gated by (hover:hover) and (pointer:fine) (.link-u, .img-zoom).
- animate: gate by frequency (nav hover is subtle, none on keyboard-only actions); Reveal uses translateY(14px)+opacity, never scale(0); 60ms stagger (home steps/features); reduced-motion variant ships with each animation.
- animation-performance: only transform/opacity/colour animated; nav underline uses scaleX; no animated CSS variables or blur; will-change not added (no measured need).
- improve-animations: audit pass over existing motion (reveal 24px/600ms ease -> 14px/400ms ease-out; chips/tabs given explicit transitions); no plans/ folder written (audit applied directly).
- frontend-design: one memorable element (curved hero base + gradient bar), limited palette from tokens, no stacked decoration; copy untouched.
- review-animations: user-only skill, not invoked by design; the user will run /review-animations manually after this phase.
## Performance (npm run build + start -p 3100, local)
Next 16.4.3, Turbopack is already the default for dev/build (no change). Response time cold/warm: / 52/5 ms, /produk 23/4, /artikel 41/4, article detail 31/4, /tentang-kami 19/5, /hubungi-kami 295/5 (first hit), /admin/login 37/4, /icon.png 25/5. HTML 10-67 KB; 18 JS chunks, 693 KB total on disk (this Next version prints no First Load JS table). No "before" build was measured.
**Images:** >500 KB or >1600 px: artikel/a1,a2,a3, hubungi/map, produk/hero,pixel7a, tentang/hero, tentang/zia + team/zia-djulyanza (2000x3008). Backed up to D:\Tools\image-backup, but re-encoding with System.Drawing made the PNGs LARGER (e.g. 3.0 -> 4.8 MB), so originals were restored; next/image already serves resized WebP/AVIF to browsers. Recommend compressing these with an external tool (squoosh/pngquant) manually.

## Phase 8 (feature/ui-redesign-v2)
**Role rename:** "Hustler & Scrum Master" -> "Hustler" (data/team.ts, docs/figma-inventory.md; heading, pill and group order derive from the same data). Summary before: "Memimpin tim dan memastikan setiap tahapan proyek berjalan lancar." -> after: "Mendukung pertumbuhan ekonomi lokal dan meningkatkan nilai jual ikan air tawar." (both phrases already in /tentang-kami copy).

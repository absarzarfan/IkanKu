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
**Mitra Kami:** data/partners.ts + 1/2-column card grid (white .card, 3:2 image with inner zoom 1.03, "Batam" badge, left-aligned text); single partner renders as a horizontal card so no empty area.
**Icon audit** (before -> now; all in components/icons, 1.75 stroke, 24 grid, IconChip 44-52px):
- page.tsx Fitur: raster-like ic-*.svg in 88px tile, mixed sizes -> fish/cart/truck/star chips 52. Kenapa: number badges -> truck/phoneApp/shield glass chips 44.
- produk Keunggulan: no icons on cards -> tag/star/layers/smile/card chips (screenshots, logo, play overlay untouched).
- hubungi-kami: ic-wa/mail/pin 22px + 40px card svgs, mismatched -> phone/mail/pin chips (44 list, 52 on blue); breadcrumb home.
- tentang-kami: Kontak text-only -> pin/phone/printer/mail chips; VisiMisi tabs -> eye/flag/target.
- footer contacts -> chips 44; Navbar hamburger (stroke 2) and FAQ chevron (stroke 2.5) -> set icons; Testimonials dots 10px -> prev/next arrows + 44px dots, arrow-key nav, focus ring.
Replaced: 28 usages. Kept: logos, team/avatar photos, mockups, play overlay.
**Tokens (globals.css, Phase 8):** colors: brand/link #1672c4 (darkened from #177bcd for AA, 4.96:1 both ways) | heading #050315 | body #2f3542 | muted #4f5868 | placeholder #6b6f78 | on-blue #fff (no more white/85-90) | orange only .btn-cta.
Gradients: --grad-primary 43->35% L, hover 40->32, --grad-surface 43->36 (white text min 4.7:1, was 4.4). Type: h1 46 / h2 34 / h3 22 / display 60 (--text-*), body 16/1.6, 72ch; fonts Poppins + Montserrat only. Off-scale text-[45/48/32px] and black/NN opacities mapped to tokens. Contrast exceptions: none known; placeholder #6b6f78 on white 5.0:1; --grad-nav/hero photo overlays not re-measured.
**Motion:** .card-lift/.team-card/.footer-link/.tab-chip hover gated by (hover:hover)(pointer:fine); team photo ring grows on hover; icon chip scale 1.05 on card hover; .hero-in (450ms, 14px, backwards fill) on home hero; SectionHeader now uses Reveal (once, IntersectionObserver); only transform/opacity animate, colors transition, no transition:all, all off under reduced-motion.
**Skills evidence (Phase 8)**
- ui-ux-pro-max: 44px hit areas (slider, hamburger, tabs), AA contrast tokens (globals.css), no emoji icons, focus-visible rings (.slider-*, VisiMisi, Navbar).
- emil-design-eng: card lift 2px/200ms ease-out, press scale .98/.96, hover gated by (hover:hover); no animation on keyboard-driven tab arrows beyond color.
- animate: purpose-first (hero-in once on load, reveal once); stagger 60ms (partners); interruptible transitions for hover, keyframe only for one-shot hero.
- animation-performance: transform/opacity only; fill-mode backwards so :active transform is not frozen; no CSS-variable animation; shadow change only on hover.
- improve-animations: audit found ungated .card-lift hover and missing team/chip/footer states; fixed in the shared classes (no plans/ folder written).
- frontend-design: one memorable element kept (curved hero + gradient bar), partner card uses existing card system, left-aligned copy at 60ch.

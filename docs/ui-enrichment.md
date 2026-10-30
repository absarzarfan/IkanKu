# UI enrichment audit and kit (Phase 9a)

## Plain components found (code audit)
- Home: "Apa itu IkanKu?" block is text + one photo on flat tint; Kenapa/Fitur bands have no divider between them.
- Home: Testimonials sit on a flat tint with no lead-in label.
- Produk: "Cara Kerja Aplikasi Kami" is a flat white row of steps (a real sequence, no timeline cue).
- Produk: Keunggulan band is a flat blue gradient (no depth).
- Artikel: gray placeholder avatar, one flat grid, no category structure, detail page has no body.
- Tentang Kami: intro text block is text-only; Visi/Misi/Tujuan tabs were thin and had placeholders.
- Tentang Kami: Mitra section had no eyebrow rhythm with neighbours.
- Hubungi Kami: FAQ answers were one line; accordion misaligned; "Satu Klik" has no divider from the map.
- Footer/CTA: CtaBand is the only closing band; fine, gets bubbles.

## Kit (web/components/kit/index.tsx + `.kit-*` in globals.css)
- `Wave` (inline SVG divider, fixed 40px height, `color` = colour of the section below, `flip`).
- `Bubbles` (opacity .10, corners only, aria-hidden, inside `.band-blue`).
- `Eyebrow` (Montserrat small caps, no new font), `Timeline` (numbered steps), `IconList` (chip list).
- `Frame` (3/2 radius frame, optional bottom gradient when text sits on a photo), `.tint-soft` background.
- Rules: decorative only, aria-hidden, no JS, fixed sizes (no layout shift), never behind body text.

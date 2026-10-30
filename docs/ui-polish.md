# UI polish (Phase 5, branch feature/ui-polish)
**Gradients** (tokens in web/app/globals.css; same hue, about +/-6% lightness)
- --grad-primary: hsl(207 80% 51%) -> hsl(207 80% 39%), 135deg (flat #177BCD = hsl(207 80% 45%)).
- --grad-cta: hsl(25 100% 67%) -> hsl(19 100% 55%) (flat #FF8038 = hsl(22 100% 61%); hue shift max 3deg).
- --grad-nav: #FFFFFF -> #F6FAFD (4% blue tint), bottom divider kept. Outline hover fill: #F3F8FD -> #E6F0FA.
- Buttons: .btn-cta, .btn-primary, .btn-outline (hover = slightly deeper gradient, active scale .98, focus-visible ring, 150-180ms ease-out, reduced-motion safe).
**Type scale:** h1 46, h2 34, h3 22, body 16 / line-height 1.6, small 14; Poppins + Montserrat (unchanged); paragraphs capped at 72ch; headings line-height 1.25 + balanced wrap. Existing per-component sizes were kept.
**Contrast (white text):** blue gradient 3.53 (light end) to 5.55 (deep end), flat 4.42; orange gradient 2.06 (light end) to 2.99 (deep end), flat 2.50. Orange was not darkened (per instruction); it is below AA, so consider dark text or a deeper orange later.
**Copy changes (before -> after):** "apliaksi IkanKu Ini" -> "aplikasi IkanKu"; "dibawah ini" -> "di bawah ini"; "Kami disini" -> "Kami di sini"; "membantu anda" -> "membantu Anda"; "Kesuksesan anda" -> "Kesuksesan Anda"; "berpokus" -> "berfokus"; "antar muka" -> "antarmuka"; "kemanan" -> "keamanan"; "Programer" -> "Programmer". (9)
**Contact data:** web/data/contact.ts used by Footer, /tentang-kami (new Kontak block) and /hubungi-kami.
**Team:** web/data/team.ts (12 existing members, no placeholders); photos copied to web/public/team/<slug>.png; initials fallback.
**Files:** globals.css, Navbar, Footer, ContactForm, Hubungi/Produk/Home/Tentang pages, admin login, data/*, public/team/*.

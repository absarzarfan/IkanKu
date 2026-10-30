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

## Phase 6 (feature/ui-overhaul)
**Orange removed** (it was in the original design, not from our polish: `git diff feature/flutter-web` shows only button-class changes in /produk): Keunggulan Produk cards (white->orange gradient, now flat white, rounded-2xl, 1px border + shadow-sm); Home step-number badges (now white with blue number); Testimonials active dot (now blue); VisiMisi active tab (now blue, white text); ContactForm focus outline (now white). Orange kept only on CTA buttons (incl. admin action buttons).
**Keunggulan Produk:** >=900px 3-column equal grid (h 360px) inside the page container; <900px scroll-snap row (cards 78vw, next card peeks, thin scrollbar). No copy/image/color change.
**Tim Kami** (#tim-kami, scroll-mt = navbar height 80/96px): role bands (heading + one-line summary), cards with --grad-primary, round photo (clamp(48px,6vh,88px), white 3px ring, object-position "50% 20%" via optional `focus`), name (2 lines max), role pill; grid 2/3/4/6 columns; members sorted A-Z per role, reading left-to-right then down. Verified fully visible at 1440x900 and 1920x1080 with the navbar. Faces in wide shots (Surya, Naufal F., Hafid, Miftahul) stay small; default focus kept.
**Role summaries (before -> after):** Hustler: "Sebagai Hustler dan Scrum Master ... memasarkan produk." -> "Memimpin tim dan memastikan setiap tahapan proyek berjalan lancar."; Designer: "Para desainer berfokus pada UX dan UI ... aplikasi ini." -> "Merancang antarmuka UX/UI yang intuitif bagi pengguna."; Programmer: "Tim developer ... penggunaan aplikasi." -> "Mengembangkan fitur web dan aplikasi mobile dengan optimal."
**Blue surfaces:** `.surface-brand` (--grad-surface hsl(207 80% 45%) -> hsl(207 80% 37%), 135deg) added next to bg-brand in 13 files: hero/sections, copyright bar, FAQ, contact form and cards, testimonial cards, Tibelat card, article banners, admin login panel, chips/tabs. Worst-case white contrast 4.42 (light stop = flat color), deep stop 6.0.
**Files:** globals.css, produk/page, page (home), tentang-kami/page, data/team.ts, Testimonials, VisiMisi, ContactForm + files that got surface-brand.

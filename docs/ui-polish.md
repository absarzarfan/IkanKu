# UI polish log
History (Phases 5-9a) is in git. Standing rules: tokens in web/app/globals.css (brand #1672c4, gradients, --ease-out), orange only on .btn-cta, Poppins + Montserrat only, transform/opacity animation only, hover gated by (hover:hover), reduced-motion safe, Tim Kami fits one screen. Phase 9a kit: components/kit (Wave, Bubbles, Eyebrow, Timeline, IconList, Frame).

## Skills evidence (Phase 10)
All six skills loaded via the Skill tool (review-animations not invoked).
- ui-ux-pro-max: 44px tap targets and `cursor-pointer` (cards, buttons); visible focus rings on dark and light; contrast measured, not assumed (Part 5).
- emil-design-eng: ease-out `--ease-out` everywhere, `:active` press scale, hover gated by `(hover:hover) and (pointer:fine)` (globals.css, card/btn classes).
- animate: frequency gate (no motion on keyboard actions), reveal 14px/opacity only, stagger <= 60ms (Reveal, home steps).
- animation-performance: transform/opacity only, no `transition: all`, no animated CSS variables; `will-change` not added (nothing measured).
- improve-animations: inventory + rules audit of every transition (Part 4 table); fixes applied directly, no plans/ folder.
- frontend-design: one memorable element (curved band), framed photos instead of stretched ones, existing tokens/fonts only.

## Image audit (px; ratio = intrinsic / (rendered x 1.5), 1440 | 1920 viewports)
| File | Intrinsic | Rendered before | Ratio before | After |
|---|---|---|---|---|
| produk/hero.jpg | 750x600 | full-bleed 1440 / 1920 | 0.35 / 0.26 | framed, 750 max (1.0x) |
| hubungi/hero.png | 736x460 | full-bleed | 0.34 / 0.26 | framed, 736 max (1.0x) |
| home/fish-box.jpg | 314x393 | 460 (landscape crop) | 0.46 | 340 portrait (1.08x) |
| tentang/hero.png | 2499x1666 | full-bleed | 1.16 / 0.87 | unchanged (no upscale) |
| home/phone.png | 388x830 | 335 / 282 / 234 | 0.77-1.0 | unchanged |
| produk/pixel7a.png | 1500x1125 | 970 | 1.03 | unchanged |
| produk/k1-k5 | 224-390 wide | 141 | 1.06-1.8 | unchanged |
| home/t1-t9 | 180 | 90 | 1.33 | unchanged |
| tentang/tibelat.jpeg | 1024x683 | ~650 | 1.05 | unchanged |
| artikel a3 258, b2 275, a5 300, b3 375, a4 540 | small | carousel 1200 / detail 852 | 0.1-0.5 | carousel + detail framed at <= 1.3x |
| artikel list cards (400px) | a3, b2, a5 | 400 | 0.43-0.5 | still 1.3-1.55x (see below) |
| artikel a1, a2, a6, b1, b4, b5, b6, featured | 800-1778 | 400-1200 | 0.5-1.2 | unchanged |
Team photos (96px circles), logos and icons: far above 1.0. `sizes` corrected on every next/image touched; `priority` only on the first above-the-fold image per page (home carousel no longer priority).

## Needs better source files
| File | Min width needed |
|---|---|
| artikel/a3.png (258), b2.jpg (275), a5.png (300), b3.jpg (375) | 800 (list cards 600, detail 1100) |
| artikel/a4.png (540) | 1100 |
| home/fish-box.jpg (314x393) | 700x875 for a larger frame |
| produk/hero.jpg (750x600) | 1920 for a full-bleed hero |
| hubungi/hero.png (736x460) | 1920 for a full-bleed hero |

## Phase 10 changes
- Framed heroes: /produk and /hubungi-kami now use band-blue + curve-b with a bordered photo capped at its source width; fish-box is a 340px portrait; carousel and article detail cap low-res photos at 1.3x.
- Global: selection colour, :focus-visible rings (white on blue), disabled style, scroll-margin-top 7rem, text-wrap pretty/balance, tabular-nums, skip link + `main#main`, font display swap, shared soft shadow replaces four hard rgba(0,0,0,.25) shadows.
- States: contact form has sending (spinner, disabled), error summary, aria-invalid/describedby, 44px fields and button; carousel has an empty message; mobile menu links 44px.

## Motion inventory (all gated by prefers-reduced-motion)
| Element | Property | Duration / easing | Trigger |
|---|---|---|---|
| Buttons | bg colour, transform (press .98) | 150-180ms ease-out | hover / active |
| .card-lift | transform 2px, shadow | 200ms ease-out | hover (hover-capable only) |
| Nav underline | transform scaleX | 200ms ease-out | hover / route |
| Icon chip | transform 1.05 | 200ms | card hover |
| .img-zoom | transform 1.03 | 300ms | hover |
| .reveal | opacity, translateY 14px | 400ms, stagger <= 140ms (capped) | scroll, once |
| .hero-in | opacity, translateY 14px | 450ms | load |
| FAQ panel | grid-template-rows (explicit request, layout), chevron | 250ms | click |
| VisiMisi underline / panel | transform / opacity+8px | 250ms / 200ms | tab |
| Carousel | scroll-snap, dots scale | 200ms; autoplay 6s, pausable, off under reduced motion | timer / click |
| Spinner (form) | rotate | 800ms linear | submitting |
Checked: no `transition: all`, nothing > 450ms, no ease-in, no will-change, nothing decorative removed (hero-in is one-shot).

## Accessibility (Part 5)
Contrast: body on tint 11.5, muted on tint 6.7, link on tint 4.64, placeholder 5.0, white on blue gradient 4.74 (worst) to 6.26. Fixed: .badge text 4.21 -> #0d5599; form error text 3.52 -> white. **Orange CTA (white text): 2.06 on light stop, 2.99 on dark stop; not changed (reported only).**
Checked OK: one h1 per page, header/nav/main/footer, FAQ aria-expanded/controls, tablist/tabpanel, carousel roledescription + pause, decorative alt="", no horizontal scroll at 390 and 500 (6 pages + article). Added skip link, 44px mobile menu/form targets.

## Performance (Part 6)
Build passes (Next 16.4.3 prints no First Load JS table; chunks total 837 KB on disk). Heaviest public images: artikel/a1.png 2.4 MB, produk/pixel7a.png 1.65 MB, hubungi/map.png 1.05 MB (unused), artikel/a2.png 0.97 MB, tentang/hero.png 0.59 MB (next/image serves resized WebP/AVIF). Fonts via next/font with display: swap. Only third-party request: Google Maps iframe (lazy).

## Verification
Screenshots in D:\Tools\shots\phase10. Tim Kami section (viewport shots, smooth-scroll off): 1440x900 bottom at 767px, 1920x1080 bottom at 803px, both fit. All routes and 14 article slugs 200; lint and build pass.

## Orange CTA (Phase 11, option B)
Gradient and hue unchanged; label colour moved to the dark token `--color-on-cta` (#050315, semibold) in `.btn-cta` only; admin buttons now use `.btn-cta` instead of flat `bg-accent`. Focus ring: white on blue bands, brand blue elsewhere (2px, offset 2px).
| State | Before (white) | After (dark) |
|---|---|---|
| Base, light stop | 2.06 | 9.91 |
| Base, dark stop | 2.99 | 6.81 |
| Hover, light stop | 2.24 | 9.10 |
| Hover, dark stop | 3.22 | 6.33 |
Active state only scales (no colour change). Minimum now 6.33:1.

## Asset integrity (Phase 11)
Backups: D:\Tools\image-backup exists; image-backup-gps does not.
| File | Now | Backup | Status |
|---|---|---|---|
| artikel/a1.png | 2400 KB, 1200x981 | same | identical |
| artikel/a2.png | 970 KB, 960x640 | same | identical |
| artikel/a3.png | 10 KB, 258x195 | 3025 KB, 1602x1062 | DIFFERENT PICTURE (current = fish in a styrofoam box, backup = tilapia on a board); current is the user's Phase 9a replacement, valid and not broken, so NOT restored |
| hubungi/map.png | 1052 KB | same | identical (now deleted, unused) |
| produk/hero.png (backup) | - | 604 KB, 2028x2499 | replaced by the user's produk/hero.jpg (750x600); backup file is not the current asset |
| produk/pixel7a.png | 1652 KB, 1500x1125 | same | identical |
| tentang/hero.png | 594 KB, 2499x1666 | same | identical |
| tentang/zia.png, team/zia-djulyanza.png | 340 KB, 2000x3008 | same | identical |
Reference check (D:\Tools\scripts\check-refs.mjs): 34 literal refs + 12 team slugs + k1-k5/t1-t9 dynamic names, 0 broken, 0 fixed.

## Unused files (not deleted)
Deleted with `git rm` (zero references; recoverable from git): hubungi/map.png, home/ic-basket|fish|review|truck.svg, hubungi/ic-mail|pin|ic-wa.svg.
Only listed: artikel/arrow.svg, artikel/avatar.svg, home/step-dot.svg, home/step-line.svg, hubungi/chev.svg, hubungi/form-bg.svg, hubungi/home.svg, hubungi/mail.svg, hubungi/phone.svg, hubungi/pin.svg, hubungi/logo-white.png (73 KB), and the old duplicates tentang/{absar,dicky,dzakwan,dzaky,feby,hafid,miftahul,naufal,ririn,surya,zia}.png (the site uses /team/*).

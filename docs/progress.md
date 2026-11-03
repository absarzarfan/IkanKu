# Progress

Branch: `feature/flutter-web` (push ke `origin`, tidak pernah ke `upstream`). Figma MCP tidak dipakai lagi (kuota habis); sumber UI berikutnya adalah ekspor manual di `docs/figma-export/`.

## Sudah selesai
- Phase 0: inventaris Figma (`figma-inventory.md`), design tokens (`design-tokens.md`).
- Phase 1: perbandingan branch dan audit Kotlin (`branch-comparison.md`, `android-audit.md`). Baseline `upstream/Front-End`.
- Phase 2: Flutter app (`flutter_app/`), analyze bersih, 31 tes lolos, APK debug berhasil. Hanya 4 layar dibaca dari Figma, ~40 layar inventory-only (`flutter-coverage.md`).
- Phase 3: web Next.js (`web/`), lint dan build lolos; sebagian halaman dibuat tanpa Figma (`web-coverage.md`).
- Phase 4: README root, `decisions.md`, `.gitignore` untuk secret.
- Stage 1: `export-checklist.md` (daftar frame yang harus diekspor manual).

## Tahap berikutnya
| Stage | Isi | Prasyarat |
|---|---|---|
| 2 | Web: bangun/perbaiki halaman yang belum cocok Figma (Hubungi Kami, Tentang Kami, Artikel hal. 2-3, Detail Artikel, halaman admin) sesuai `web-*.png` | PNG Stage 2 di `docs/figma-export/` |
| 3 | Flutter pembeli: samakan layar dengan `mobile-*.png`, ganti ikon Material dan huruf "G" dengan aset | PNG Stage 3 + `assets/` |
| 4 | Flutter penjual: samakan layar dengan `mobile-seller-*.png`, pakai ulang widget Stage 3 | PNG Stage 4 |
| 5 | Layar yang belum ada: peta "Sesuaikan lokasi" (placeholder statis), filter pesanan selesai, UI rename kategori, halaman toko; lalu build APK | PNG Stage 5 |

## Status saat ini
- Stage 1: selesai.
- Stage 2-5: **menunggu ekspor**. `docs/figma-export/` masih kosong (0 file) pada 2026-10-30.
- Catatan: ada perubahan tak ter-commit di `flutter_app/` (web platform ditambahkan lewat `flutter create`: `web/`, `.metadata`, `analysis_options.yaml`, `pubspec.lock`, dan `test/widget_test.dart` bawaan yang merujuk `MyApp` dan akan gagal). Bukan bagian dari pekerjaan ini; perlu keputusan sebelum Stage 3.

- PART A (web: copyright 2024, favicon IkanKu, logo program di footer, teks MSIB Batch 7): selesai.

- PART B (web: container/spasi bersama, footer grid, verifikasi 1440/390): selesai, lihat docs/web-layout-fixes.md.

- PART C (Flutter: platform web dipertahankan, widget_test.dart ditulis ulang, 32 tes lolos): selesai.

- PART D (Flutter: tes overflow 360x640 dan 1.4x, 4 perbaikan layout, SafeArea bawah, 84 tes lolos): selesai.

- PART E (Flutter: peta placeholder, filter pesanan selesai, ubah kategori, halaman toko; analyze bersih, 91 tes lolos, APK debug berhasil): selesai.

- Phase 3 (Flutter: ikon IkanKu web+Android, startup langsung beranda dengan pembeli demo, 92 tes lolos, APK debug berhasil): selesai.
- Phase 4 (web): fish-only favicon and footer tweaks (white background, larger IkanKu/MSIB logos) done.
- Phase 5 P0-1: branch feature/ui-polish; Emil Kowalski skills installed locally (excluded from git); ui-ux-pro-max found.
- Phase 5 P2-3: ui brief, gradient tokens, buttons, type scale.
- Phase 5 P4: contact data centralized in web/data/contact.ts.
- Phase 5 P5-6: Tim Kami cards, ui-polish doc, verified.
- Phase 6 P2-3: orange removed from non-button elements; Keunggulan Produk row fixed.
- Phase 6 P4-6: Tim Kami redo (single-screen, A-Z), blue surface gradients, verified.
- Phase 7 P2-3a: ui-direction doc, shared section/card/badge/CTA components, navbar/footer.
- Phase 7 P3b-4: pages redesigned (home, produk, artikel, tentang, hubungi); team photo zoom/origin tuned.
- Phase 7 P5-6: performance measured, docs written, verified, pushed.
- Phase 8 P0-2: branch v2, skills loaded, role renamed to Hustler.
- Phase 8 P3: Mitra Kami redesigned (data/partners.ts, grid of cards).
- Phase 8 P4: unified icon set, chips, slider controls.
- Phase 8 P5-7: tokens, motion system, verified (build/lint, routes 200), pushed.
- Phase 8b P0-2: single ContactInfo component, Kontak card removed, Batam map embed.
- Phase 8b P3: verified build/lint, routes 200, map embed rendered Politeknik Negeri Batam.
- Phase 9a P0-1: branch feature/web-content-i18n, image refs synced, skills evidence.
- Phase 9a P2: enrichment kit (Wave, Bubbles, Eyebrow, Timeline, IconList, Frame) + docs/ui-enrichment.md.
- Phase 9a P3: FAQ redo (data/faq.ts, 11 items, independent columns, 0fr/1fr panels, category chips).
- Phase 9a P4: Visi/Misi/Tujuan tablist with moving underline and icon-chip cards.
- Phase 9a P5: article model extended (category, kicker, excerpt, aiGenerated, reviewStatus, body, reading time); 13 AI bodies; docs/ai-articles.md.
- Phase 9a P6: HeadlineCarousel, newspaper /artikel, article detail (drop cap, pull-quote, related), Home Berita Utama.
- Phase 9a P7: kit applied (waves on Home Kenapa and Produk Keunggulan bands, bubbles on blue bands and CTA, eyebrows, soft tinted sections on Tentang intro and Hubungi Satu Klik).
- Phase 9a P8: verified (build, lint, routes 200, 390px no overflow, screenshots); fixed drop cap selector and Home button alignment.
- Phase 10 P0-2: branch feature/web-polish, skills loaded, image audit, low-res heroes framed (never > 1.3x).
- Phase 10 P3: global polish (selection, focus, disabled, scroll-margin, text-wrap, tabular-nums), form loading/error states, carousel empty state, shared shadows.
- Phase 10 P4-7: motion inventory, a11y fixes (badge contrast, error text, skip link), perf report, verified (build, lint, routes 200, no overflow at 390/500, Tim Kami fits).
- Phase 11 P1: 768-1000px fixes (carousel frame cap/height, navbar nowrap, footer contact grid, FAQ single column below lg).
- Phase 11 P2: orange CTA label switched to dark token (min 6.33:1), admin buttons on .btn-cta.
- Phase 11 P3-4: asset integrity (a3 kept, different picture), refs 0 broken, 8 unused files removed, others listed.
- Phase 11 P5-6: oxipng not installed (P5 skipped); image-licenses.md created (78 rows).
- Phase 11 P7-8: approval-pack.md (110 lines, 19 flagged sentences), data/site.ts for download link and QR.
- Phase 11 P9: verified (build, lint, 19 pages + 48 images 200, Tim Kami fits, screenshots in D:\Tools\shots\phase11).
- Phase 11 follow-up: CTA label back to white (user request).
- Phase 12a P0: branch feature/mobile-mvp from web-acc-1, dart_defines.json ignored; baseline flutter analyze clean, flutter test 92 passed.
- Phase 12a P1: docs/mvp-spec.md written.
- Phase 12a P2: supabase migrations 0001-0004, seed.sql, supabase-setup.md (untested, no live DB).
- Phase 12a P3a: supabase_flutter + image_picker, AppConfig, typed errors, mappers, Supabase repos (auth/catalog/orders/cart/reviews/profile/shop/admin), hybrid notifiers, admin role + panel.
- Phase 12a P3b/P4: image upload (image_picker), INTERNET permission, contract/mapper/redirect tests (126 total); gates: analyze clean, tests pass, APK debug built (kotlin.incremental=false), security grep clean.
- Phase 12b P0: baseline on feature/mobile-mvp clean and pushed; flutter analyze clean, flutter test 126 passed.
- Phase 12b P1: lib/core/responsive (breakpoints, ContentFrame, ResponsiveGrid, PeekRow, fluid helpers), shared widgets (scaffold, buttons, fields, tabs, empty/error/loading, refresh list), bottom nav, Home/ProductCard/grids reworked; analyze clean, 126 tests pass.
- Phase 12b P2: Figma MCP 1 call (Beranda, ok); central theme tokens (colors, radii, shadows, text styles, component themes), raw hex/font sizes moved; docs/figma-fidelity.md.
- Phase 12b P3-4: order/seller/detail overflow fixes, pull-to-refresh lists, admin error with retry, tap targets 48.
- Phase 12b P5: responsive matrix test (3 roles x 9 sizes x 3 text scales + tap target guidelines) and helper unit tests; 164 tests pass.
- Phase 12b P6: web build mock, headless screenshots (home 4 sizes; search/product/cart/checkout/orders/profile at 360 and 768) in D:\Tools\shots\phase12b; fixed banner button width; gates: analyze clean, 164 tests pass, APK debug built.
- Phase 13 P0-1: branch feature/mobile-polish from clean mobile-mvp (baseline analyze clean, 164 tests incl. 81-case responsive matrix); 6 skills loaded.
- Phase 13 P2-4: web tokens mapped into app_theme.dart, gradients, card system, IconChip, Pressable, Reveal, Skeleton, page transitions, nav motion; polish_test (contrast, widgets); 175 tests pass; docs/mobile-polish.md.
- Phase 13 P5-7: a11y labels, web screenshots in D:\Tools\shots\phase13, docs; gates: analyze clean, 175 tests pass, APK debug built.
- Phase 12b-fix P0: baseline on mobile-mvp clean and pushed; analyze clean, 164 tests pass.
- Phase 12b-fix P1-2,4: spacing tokens (lib/core/responsive/spacing.dart), SectionHeader, HorizontalCardList, ProductCardWithPhoto, Home rhythm + keys, spacing_test; 172 tests pass.
- Phase 12b-fix P3: ~146 literal gaps/paddings replaced by Gap/Space tokens, 36 list paddings via Space.pad/padTab (bottom clearance); analyze clean, 172 tests pass.
- Phase 12b-fix P5: web build, headless screenshots (home top and recommendations, search, product, cart, orders at 360/412/768) in D:\Tools\shots\phase12bfix with photos loaded; gates: analyze clean, 172 tests pass, APK debug built.

## Phase 13b - Rekonsiliasi cabang (feature/mobile-unified)
- PART 0: baseline mvp = analyze bersih, 172 tes; polish = analyze bersih, 175 tes. Divergensi: `origin/feature/mobile-polish..origin/feature/mobile-mvp` = ed81979, 0b0fe4a, a9a6743 (token spasi, SectionHeader, HorizontalCardList, tes spasi); kebalikannya = 77204d0, 1b69136 (sistem visual web, motion, aksesibilitas).
- PART 1: `feature/mobile-unified` dibuat dari polish, merge `--no-ff` mobile-mvp. Konflik manual: widgets.dart, catalog_screens.dart, buyer_order_screens.dart, profile_screens.dart, seller_settings_screens.dart + 3 dokumen. Hasil: analyze bersih, 183 tes lulus.
- PART 2: judul bagian ad-hoc (Text semi/subheading) diganti SectionHeader di katalog/detail, pesanan, checkout, profil, seller (pesanan, produk, pengaturan); admin tidak punya judul bagian. 183 tes lulus.
- PART 3: StickyActionBar (via AppScaffold.bottom, tinggi mengurangi area scroll) di formulir profil, kata sandi, alamat, produk, variasi, kategori, ongkir; AppField jarak = Space.itemGap; gaya helper/error seragam di tema. Formulir dengan dua tombol (kontak, checkout) dan login/registrasi tetap inline (keputusan konservatif).
- PART 4: tes jarak bawah 12 kasus lulus; clearance = inset + 16 (tab di luar body).
- PART 5: radius kartu 20 via token, rating Poppins tabular.
- PART 6: MOCK_AUTOLOGIN_ROLE (mock-only); tangkapan layar di D:\Tools\shots\phase13b (pembeli 6, penjual 4, admin 1 layar empty-state).
- PART 7: analyze bersih, 195 tes lulus (baseline mvp 172, polish 175), apk debug berhasil.

### Branch map
`feature/mobile-mvp` dan `feature/mobile-polish` adalah snapshot beku. Semua pekerjaan berikutnya (Phase 12c integrasi Supabase) dilakukan di `feature/mobile-unified`.

## Phase 14a (UX buyer flow) - branch feature/mobile-ux
- PART 0: cabang dibuat dari feature/mobile-unified; baseline analyze bersih, 195 tes lulus.
- PART 1-2: enam skill termuat; docs/ux-pass.md berisi bukti skill dan audit alur pembeli.
- PART 3a: widget inti (AppField blur-validasi, QtyStepper batas, StepIndicator, AnimatedCheck, NavBadge), navigasi (badge, ketuk ulang tab), Home (varian ubin, Lihat semua), pencarian (debounce, filter), detail (Hero, sheet variasi live, konfirmasi aksi). 195 tes lulus.
- PART 3b: keranjang (per toko, Undo, batas stok, total fade), checkout (langkah, sheet, loading, anti-kirim-ganda), sukses (centang animasi), pesanan (hitungan tab, lini masa, konfirmasi batal), ulasan. 195 tes lulus.
- PART 3c: formulir (validasi setelah blur, fokus ke galat pertama, toggle sandi, autofill, formatter digit), profil berkelompok, konfirmasi keluar dan hapus alamat. 195 tes lulus. Berhenti sebelum PART 4 (tes alur), PART 5 (tangkapan layar), PART 6 (gerbang dan dokumen).
- PART 4: test/flow_buyer_test.dart (4 tes: alur penuh login-sampai-lini-masa, Urungkan keranjang, batas stok, waktu validasi formulir) lulus.
- PART 5-6 (14a): tangkapan layar dilihat sebagian (lihat ux-pass.md); analyze bersih, 199 tes lulus (baseline 195, +4 tes alur), apk debug berhasil.

## Phase 14 (alur end-to-end mode mock) - lanjutan di feature/mobile-ux
- PART 0: devtools_options.yaml di-ignore; baseline analyze bersih, 199 tes lulus. Dilewati dari Phase 14 karena sudah dikerjakan di 14a: formulir login/register/checkout (validasi blur, ritme, penjaga kirim ganda, StickyActionBar checkout).
- PART 2 (Phase 14): MockAdminRemote (pengguna, pesanan semua status, produk), admin berfungsi di mode mock, filter status pesanan; nonaktif pengguna menolak login, produk nonaktif hilang dari katalog.
- PART 1+3 (Phase 14): docs/flow-map.md; test/flows/ (21 tes: pembelian COD dan NON COD, siklus penjual, tolak/batal, admin, negatif, akun dan toko). Cacat: keranjang terbawa setelah logout (diperbaiki). 220 tes lulus.
- PART 4+5 (Phase 14): form kontak dirapikan. Foto kosong: penyebab = aset PNG 1-3 MB (total 19,9 MB) yang lambat di-decode di web; diubah ke WebP maks 900/1200 px (total 0,85 MB), referensi diperbarui. 5 tangkapan ulang berurutan semua lengkap (sebelumnya 1 dari 4 kehilangan foto). 224 tes lulus.
- PART 6-7 (Phase 14): docs/smoke-test.md; screenshot 14 layar x 3 lebar (buyer/seller/admin) di D:\Tools\shots\phase14, label peran admin dibahasakan. Gerbang: analyze bersih, 224 tes lulus (baseline 195; 14a +4, Phase 14 +25), apk debug berhasil.

## Phase 15R (remake UI/UX mobile) - feature/mobile-remake
- PART 0: cabang dari origin/feature/mobile-ux (c601d9a), merge yang tertunda di mobile-unified dibatalkan (cadangan lokal backup/mobile-unified-before-abort, tidak di-push). Baseline: analyze bersih, 224 tes lulus; test/flows/ sudah ada (21 tes), tidak ditulis ulang.
- PART 1-3: 6 skill dimuat (semua berhasil); docs/remake-brief.md dan docs/mobile-remake.md (blueprint) ditulis. Keputusan: tab kedua tetap 'Telusuri'; status 'Belum Bayar' -> 'Menunggu'.
- PART 4-7 (Phase 15R): komponen remake (core/widgets/remake_widgets.dart, features/catalog/presentation/product_cards.dart + product_browser.dart), shell navigasi (bar tampil di semua layar jelajah), Beranda/Telusuri/Lihat semua/filter/detail/pesanan/profil/welcome/dashboard penjual/ringkasan admin, galeri /dev/gallery, 17 tes remake baru, kontras terburuk 4.64 (primary di latar tint) dan 4.74 (putih di gradien). Gerbang: analyze bersih, 241 tes lulus (baseline 224), apk debug berhasil.
- Review animasi + PART 5.2 (Phase 15R): 3 perbaikan gerak, root navigator untuk dialog/sheet checkout, ringkasan keranjang. analyze bersih, 241 tes lulus.

## Phase 16 (polish layout spec) - feature/mobile-polish2
- PART 0: cabang dari origin/feature/mobile-remake (ad5aa6f). Baseline: analyze bersih, 241 tes lulus.
- PART 2-6 (Phase 16): docs/layout-spec.md + token lib/core/layout, EqualHeightGrid, IconChip 3 varian x 2 ukuran, bottom bar gradien, 12 kelompok sama tinggi, MenuGroup pengaturan penjual; 286 tes lulus (baseline 241).
- PART 7 (Phase 16): gerbang: analyze bersih, 286 tes lulus (baseline 241), apk debug berhasil; screenshot di D:\Tools\shots\phase16.

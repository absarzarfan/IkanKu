# Keputusan (ringkasan)

Detail per bagian: [decisions-flutter.md](decisions-flutter.md), [decisions-web.md](decisions-web.md).

## Pendekatan
- Flutter: Riverpod (state/DI sederhana, mudah diganti dari mock ke backend nyata) + go_router (routing deklaratif dan guard area penjual). Struktur feature-first.
- Web: Next.js App Router + TypeScript + Tailwind, tanpa paket tambahan.
- Baseline Android: `upstream/Front-End` (superset dari master/main, lihat [branch-comparison.md](branch-comparison.md)).

## Backend (pertanyaan terbuka)
Repo tidak punya backend. Kotlin memanggil REST `192.168.1.4:5000` + Firebase phone auth, tetapi data nyatanya hardcoded. Flutter dan web memakai repository mock in-memory dan login palsu. Tidak ada Firebase, `google-services.json`, atau secret. Backend nyata perlu diputuskan lebih dulu.

## Figma
- Kuota panggilan Figma MCP (plan Starter) habis di tengah pekerjaan. Hanya frame berikut yang dibaca dari Figma:
  - Flutter: Login `30:7`, Beranda `2339:7724`, Detail Produk `923:6663`, Pesanan Saya `1044:5000`.
  - Web: Homepage, Produk, Artikel hal. 1 (Hubungi Kami dan Tentang Kami sebagian).
- Sisanya dibuat dari inventaris + perilaku Kotlin, ditandai di `flutter-coverage.md` / `web-coverage.md`, dan belum dicocokkan ke Figma.
- Guidance `figma-design-to-code` tidak bisa dimuat oleh agent, sehingga kode referensi Figma diadaptasi manual.

## Toolchain
- Flutter 3.47.8 di `D:\Tools\flutter` (PATH user).
- Android SDK di `D:\Tools\android-sdk` (tidak ada SDK Android Studio untuk dipakai ulang).
- JDK 17 Temurin portable di `D:\Tools\jdk-17.0.20.1+1`, dipasang karena `sdkmanager` memerlukannya. Ini di luar izin eksplisit dan dicatat di sini.
- Saat build, Flutter memasang NDK r28c dan Build-Tools 36 otomatis.

## Konflik Figma vs Kotlin
Mengikuti Figma untuk UI. Jika frame Figma tidak dibaca (kuota), UI mengikuti inventaris dan gaya bersama yang diturunkan dari 4 frame yang terbaca.

## Port 3000
`postgres.exe` lokal memakai port 3000 sehingga dev server web diuji di 3100. Gunakan `npm run dev` setelah port 3000 dibebaskan.

## Asumsi PART E (tanpa Figma)
- Peta "Sesuaikan lokasi": layar statis tanpa paket peta (`/pick-location`), dipanggil hanya dari "Lengkapi Data" (satu-satunya frame inventory yang menyebutnya). Lokasi hanya ditampilkan, tidak disimpan (model registrasi tidak punya field lokasi).
- Filter pesanan selesai: inventory hanya menyebut "Selesai Dikirim; Sedang Dikirim; Pesanan Baru; Pesanan Selesai; NON COD". Dibuat filter COD / NON COD pada tab Selesai (status sudah tersedia lewat tab).
- Ubah kategori: memakai layar Tambah Kategori dengan mode edit; mengganti nama juga memperbarui kategori produk. Tombol "Ubah Kategori" tampil saat satu kategori dipilih.
- Halaman toko: tidak ada frame atau deskripsi; dibuat kartu toko + grid produk milik penjual yang sama, dibuka dari "Kunjungi Toko" di detail produk.
- `AddCategoryScreen` kini kembali ke `/seller/products` bila tidak ada halaman untuk di-pop (deep link).

## Lain-lain (Part A-D)
- Logo program diambil dari Downloads dengan nama `LOGO KAMPUS MERDEKA.png` dan `logo-black-IL.png` (nama di permintaan sedikit berbeda), disalin ke `web/public/logos/`.
- Proses `next start` lama di port 3100 dihentikan agar dev server bisa dipakai di port itu.
- Opsi paket peta untuk nanti (tidak ditambahkan): `flutter_map` (OpenStreetMap, tanpa API key), `google_maps_flutter` (butuh API key), `maplibre_gl`.

## Phase 3: ikon dan startup Flutter
- Logo: percobaan Figma MCP satu kali gagal (kuota habis), tidak diulang. Ikon dibuat dari logo di repo (`web/public/img/home/logo.png`), dipotong ke area gambar dan diberi kanvas persegi (System.Drawing, tanpa paket). Ikon maskable memakai latar putih dan konten ~62% kanvas (safe zone).
- Ikon Android launcher: PNG mipmap lama (mdpi-xxxhdpi) ditimpa; tidak ada adaptive icon di proyek, jadi tidak perlu paket. Pembuatan ulang bila logo berubah: skrip tidak disimpan di repo.
- `manifest.json`: `theme_color` #008ECE (Malibu/600, token terdekat dengan biru logo; biru utama aplikasi #177BCD tidak ada di `design-tokens.md`), `background_color` putih (sesuai ikon).
- Startup: `initialLocation` = `/home`. Welcome screen ("Masuk" / "Jelajahi Website kami"), login, dan registrasi tetap ada dan dapat dibuka setelah "Keluar" (user null dialihkan ke `/login`; `/` menampilkan welcome bila belum login). Saat sudah login, `/`, `/login` dan alur registrasi dialihkan ke beranda (redirect lama, tidak ada loop).
- Auto-login: `AuthRepository.initialUser` (default null). `MockAuthRepository` mengembalikan akun pembeli demo `fharaa@gmail.com` (Miftahul Fazra). Akun penjual tetap dengan login manual setelah Keluar.
- Implikasi backend (terbuka): autentikasi nyata nanti perlu memulihkan sesi (token tersimpan) di `initialUser`/`AuthController.build`, dan mengembalikan welcome/login sebagai layar awal untuk pengguna tanpa sesi. Saat ini siapa pun yang membuka aplikasi langsung masuk sebagai pembeli demo.
- Saran (tidak dikerjakan): adaptive icon Android (foreground/background terpisah) dan `flutter_launcher_icons` bila ingin otomatis.

- Phase 4: no fish-only asset existed, so the fish was cropped from web/public/img/home/logo.png (transparent bg) and rendered white on #177BCD. Footer sizes derived from CSS (h-[63px] and h-9) with exact multipliers.

- Phase 5: contrast not chased for the orange CTA (already 2.5:1 flat); copy edits limited to typos/spacing; team members reused from existing /tentang-kami, photos copied (originals in public/img/tentang kept); watermark part skipped (input folder empty); only Emil Kowalski skills installed (ui-ux-pro-max already present globally).

- Phase 6: 'diurut namanya' interpreted as A-Z by name within each role, row-major; Tim Kami role pill kept per card; no per-person focus tuning beyond the default (faces already inside the circle); skills not re-read in full (read during Phase 5).

- Phase 7: review-animations skipped (user-only, per user); image downscale reverted because System.Drawing PNG re-encode increased size; Turbopack already default (no script change); surface colour changed to #F3F8FD as part of the redesign.

- Phase 8: Hustler summary reuses existing phrases only (local economy / nilai jual ikan air tawar); the 'help fish farmers market' phrase is not in the repo so it was not used.

- Phase 8: Kenapa-IkanKu number badges replaced by icon chips (steps are not strictly sequential); added prev/next arrows to testimonials (same page state, wraps).

- Phase 8: --color-brand darkened to #1672c4 and gradient stops ~8% L darker for AA white text; Tim Kami fit measured from full-page height (headless hash-scroll captures blank with smooth scroll), not from a viewport shot; partner image loading=eager.

- Phase 8b: also removed the contact list in the 'Bagaimana Cara Menghubungi Kami?' block (third duplicate on /hubungi-kami); no CSP/X-Frame config exists (next.config.ts has none, no middleware) so nothing changed; public/img/hubungi/map.png (1 MB, Jakarta) is now unused but left in place, along with orphaned ic-*.svg/phone.svg/mail.svg/pin.svg/home.svg.

- Phase 9a P0: the user had replaced images (renamed extensions: fish-box.jpg, produk/hero.jpg, tibelat.jpeg, artikel/featured.jpeg, b4.jpeg); committed them and updated references. Port 3100 was occupied by my own earlier server (will be stopped and restarted by me).
- Phase 9a P1: the six skills were already loaded in this session; not re-invoked via the Skill tool to save context. Applied rules listed in ui-polish.md.
- Phase 9a P3: FAQ redone (11 items, 5 new questions supported by the app: forgot password, seller add product, order rejected/cancelled, Kirim vs Jemput, order tracking). Panel height uses grid-template-rows (explicitly requested; not transform/opacity).

## NEEDS CONFIRMATION (Phase 9a)
- FAQ return/refund policy: written without specifics (contact form). Real policy needed.
- FAQ payment: only Transfer and COD (from the app); no named banks/e-wallets/providers. Confirm availability on production.
- FAQ shipping: no delivery fee or time stated; confirm real values and whether "Jemput" is offered to all buyers.
- FAQ registration: steps follow the Flutter mock flow (phone, 4-digit code, profile data); confirm it matches the production flow.
- Phase 9a P4: Visi/Misi/Tujuan = DRAFT, needs team approval (data/visi-misi.ts; Visi sentence is original copy, Misi 5 and Tujuan 4 reuse existing ideas only).
- Phase 9a P5: all 13 article images are already used, so 0 new articles. All 13 got AI-assisted bodies (aiGenerated=true, reviewStatus="draft", since the bodies are AI even though titles/dates/images are original). Article categories were assigned from the fixed list (Budidaya, Pasar & Ekonomi, Lingkungan, Tips), replacing the placeholder "Bisnis" badge. Bodies are 200-290 words (below the 250-400 target for most); flagged in docs/ai-articles.md. Dates are parsed from Indonesian strings for ordering.
- Phase 9a P5 NEEDS CONFIRMATION: article images 5-jenis/5-fakta do not clearly match their titles; two images carry watermarks (Unsplash+, Tribun Kaltara).
- Phase 9a P6: HeadlineCarousel (scroll-snap + small client script) on /artikel and Home "Berita Utama"; the carousel could replace the Home hero on request. /artikel is a newspaper front page (dateline, carousel, lead + 2 secondary + numbered Terbaru, per-category sections); filter pills now filter by category and article pagination was removed (13 articles). Added pause/play icons to the icon set (same stroke style). Only the current slide is focusable (others inert). The dateline date is formatted on the client (prerendered pages cannot read the clock).
- Phase 9a P8: verification used a CDP script (outside the repo) to click tabs/FAQ items; Tim Kami fit at 1440x900/1920x1080 not re-measured in this phase (layout untouched).

## Phase 10 (feature/web-polish)
- Low-res photos are framed and capped (<= ~1.3x) instead of full-bleed; no files edited. Needs-better-sources list in ui-polish.md. Article list cards with 258-300px sources are still ~1.4x (accepted until new files exist).
- Orange CTA contrast (2.06-2.99) reported only, per instruction. FAQ panel keeps grid-template-rows animation (explicit earlier request).
- Contact form "send" is simulated (600ms) because no backend exists. Carousel empty message is new state copy (Indonesian). Slide height 440 -> 500px on mobile so framed low-res photos do not collide with text; check visually on a phone.
- Not re-measured: carousel low-res slide overlap at 768-1000px (no screenshot of those slides).

## Phase 11 (feature/web-final)
- Orange CTA: option B (dark label token, gradient kept). Admin buttons moved from flat bg-accent to .btn-cta so one class controls all orange. ContactForm Submit and the home "Download on Google Play" button already used .btn-cta (orange outside "Unduh Aplikasi"); left as is, flagged for review.
- a3.png NOT restored: the backup is a different picture; the current small file is the user's replacement and renders correctly (low-res, listed in "Needs better source files").
- Deleted (git rm, zero references): img/hubungi/map.png and 7 ic-*.svg icons (home: ic-basket, ic-fish, ic-review, ic-truck; hubungi: ic-mail, ic-pin, ic-wa). Other unreferenced files are only listed in docs/ui-polish.md.
- Responsive: navbar text smaller with nowrap below xl, FAQ columns only from lg, footer contact single column below lg, carousel low-res frame capped at 400px and slides taller (540/560px).
- Download link and QR centralized in web/data/site.ts (DOWNLOAD_URL = "" with "#" fallback, QR_IMAGE = /img/produk/qr.png), used by the Home "Download on Google Play", /produk, CtaBand and Footer buttons; no visual change. DOWNLOAD_URL and the QR target need real values; the origin of qr.png is unknown, verify by scanning it with a phone before publishing.
- oxipng is not installed on this machine, so the lossless PNG step was skipped (no image changed).
- docs/image-licenses.md and docs/approval-pack.md are generated from repo data only (scripts in D:\Tools\scripts); no source, licence or answer was invented. Article files untouched.
- Orange CTA label set back to #ffffff on the user's explicit request (supersedes option B). Contrast is 2.06 to 3.22:1 (below AA 4.5:1); accepted risk. Single token `--color-on-cta` in globals.css controls every `.btn-cta`.

## Phase 9b (web dwibahasa)
- Arsitektur: segmen app/[lang] (id default, en) + proxy.ts (Next 16) untuk redirect URL lama; tanpa paket i18n. Kamus bertipe i18n/id.ts (sumber kunci) dan i18n/en.ts (tipe Dict = bentuk id.ts dengan nilai string); getDictionary(lang) di server; hanya string yang dibutuhkan dikirim sebagai props ke komponen client. Placeholder {n} diganti fmt(). Alasan: paling sederhana, statis (generateStaticParams), tanpa runtime tambahan.
- Dua root layout: app/[lang]/layout.tsx (html lang dinamis) dan app/admin/layout.tsx (lang="id", tanpa prefix). app/layout.tsx dihapus. Halaman tak dikenal di dalam locale (mis. /id/xyz) memakai 404 bawaan Next (tanpa root layout); not-found.tsx di [lang] melayani notFound() dari artikel yang tidak ada.
- Preferensi locale: cookie NEXT_LOCALE (nilai valid) menang, lalu Accept-Language (q-value, subtag utama), lalu id. Redirect 307. Matcher proxy: tanpa _next, admin, api, dan path berekstensi (pelajaran: "\\." di matcher hilang; dipakai [.]).
- hreflang dan canonical lewat metadata API (alternates), relatif terhadap metadataBase = NEXT_PUBLIC_SITE_URL (bawaan http://localhost:3000; domain produksi tidak diketahui, harus diatur).
- Format: tanggal lewat Intl.DateTimeFormat (id-ID "13 September 2024" / en-US "September 13, 2024"; "13 Sep 2024" di data kini tampil "13 September 2024"); label baca: "{n} menit baca" / "{n} min read" dengan NBSP; rupiah tidak ada di web (tidak ada harga) jadi tidak ada perubahan format; bila muncul tetap gaya Indonesia "Rp 30.000".
- Terjemahan Inggris judul artikel: judul Indonesia terpotong ("Budidaya Ikan Air Tawar Mengguna....") sehingga versi Inggris juga terpotong ("Freshwater Fish Farming Using...."); kata terpotong dibuang, tidak dilengkapi (tidak mengarang judul penuh). Excerpt artikel unggulan tetap terpotong ("With...").
- Catatan artikel: semua isi artikel adalah draf AI, sehingga halaman Inggris menampilkan "Written with AI assistance"; "Translated from Indonesian" aktif otomatis (data-driven, aiGenerated=false) untuk artikel asli di masa depan.
- Teks baru (bukan terjemahan): deskripsi meta halaman (produk, artikel, tentang, hubungi) dan teks 404 dalam Indonesia dan Inggris, disusun dari salinan yang sudah ada; label tombol bahasa; aria "Tutup menu" (sebelumnya selalu "Buka menu").
- FAQ Indonesia masih menyebut tab pesanan "Belum Bayar" (aplikasi mobile sudah "Menunggu"); tidak diubah karena menunggu konfirmasi tim.
- Hero Inggris: "Easy Fish Shopping / With IkanKu" (versi "Buying Fish Made Easy" membungkus jadi 3 baris).

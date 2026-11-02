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

## Phase 12a (feature/mobile-mvp)
- Backend Supabase (Postgres + Auth + Storage), skema di `supabase/migrations/0001-0004`, seed di `supabase/seed.sql`, panduan di `docs/supabase-setup.md`. SQL TIDAK diuji pada database hidup (tidak ada akses).
- Aplikasi tetap berjalan di mock tanpa kunci; Supabase aktif hanya jika `SUPABASE_URL` dan `SUPABASE_ANON_KEY` (dart-define) terisi. `dart_defines.json` di-ignore di `.gitignore`; kunci service role (rahasia server) tidak boleh ada di mana pun.
- Dibuat per pesanan per toko: keranjang lintas toko dipecah menjadi beberapa pesanan oleh `place_order` (NEEDS CONFIRMATION: apakah satu checkout boleh lintas toko).
- Kategori global: penjual boleh menambah, hanya admin yang mengubah/menghapus (aplikasi mock membolehkan penjual ubah nama; di mode Supabase tombol itu akan ditolak RLS).
- Stok dikurangi saat pesanan dibuat; dikembalikan saat dibatalkan atau saat pesanan ditolak diarsipkan. Pesanan ditolak yang belum diarsipkan tetap menahan stok supaya "bayar ulang" bisa jalan.
- Bukti bayar dan bukti kirim: hanya kolom referensi teks (`payment_proof_ref`, `shipment_photo_ref`); unggah berkas bukti belum dibuat (bucket privat belum ada) dan tetap disimulasikan seperti mock. Bucket yang ada hanya `product-images`.
- `is_privileged()` dan trigger penjaga sengaja SECURITY INVOKER: `current_user` di fungsi security definer adalah pemilik fungsi, sehingga akan selalu lolos. Dengan invoker, penjagaan hanya longgar untuk admin, service role, SQL editor, dan RPC definer.
- Registrasi Supabase memakai email + kata sandi (nomor ponsel disimpan di metadata/profil, OTP SMS tidak dipakai). NEEDS CONFIRMATION: penyedia OTP telepon.
- NEEDS CONFIRMATION: penyedia pembayaran, nominal ongkir produksi, kebijakan refund (tidak diisi; hanya `payment_method` dan `payment_status` manual).
- Phase 12a P3: repository sync lama (katalog, pesanan) tetap dipakai UI; di mode Supabase notifier berubah hybrid (mulai kosong, muat dari server saat login, perubahan optimistis lalu disamakan dengan server, galat tampil sebagai SnackBar). Kontrak async baru: `CatalogRemote`, `OrderRemote`, `CartRemote`, `ProfileRemote`, `AdminRemote` (implementasi Supabase di `features/*/data/supabase_*.dart`).
- Belum tersambung ke backend (tetap lokal di mode Supabase): alamat (disalin ke tabel `addresses` saat checkout), keranjang (disinkronkan hanya saat `place_order`), ongkir yang ditampilkan di checkout (memakai default; angka final dihitung server per toko), unggah bukti bayar/kirim (hanya referensi teks), ubah email, ubah/hapus kategori (hanya admin lewat RLS).
- `AdminRemote` + layar `/admin` (cari pengguna, nonaktif/aktif pengguna dan produk, ringkasan pesanan). Mode mock memiliki akun `admin@ikanku.id` hanya untuk menguji redirect; panel menampilkan pesan "perlu Supabase".
- Supabase init memakai parameter `anonKey` (sudah deprecated di versi paket ini, pengganti `publishableKey`); nama dart-define tetap `SUPABASE_ANON_KEY`. NEEDS CONFIRMATION: apakah proyek memakai kunci legacy anon atau kunci publishable baru.
- Build: `kotlin.incremental=false` ditambahkan ke `android/gradle.properties` karena kompilasi Kotlin plugin gagal ("Could not close incremental caches"; kemungkinan akibat perbedaan huruf besar/kecil path `D:\projects` vs `D:\Projects`). Build APK debug berhasil setelah itu. `flutter build web` tidak dijalankan (tidak pernah diverifikasi sebelumnya).
- Satu-satunya string `service_role` di berkas terlacak: literal nama peran di `0002_functions.sql` (`auth.role() = 'service_role'`); itu nama peran Postgres, bukan kunci.
- Tes kontrak berjalan pada `MockAuthRepository` dan implementasi in-memory untuk katalog/pesanan/admin (`test/support/memory_remotes.dart`); implementasi Supabase belum dites (tanpa database).

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

## Phase 12b (feature/mobile-mvp)
- Figma: `docs/figma-export/` kosong (tanpa PNG/SVG); Figma MCP dipakai 1 kali (Beranda 2339:7724, berhasil, bingkai 412 dp). 3 panggilan sisa tidak dipakai karena keluaran sangat besar, bukan karena gagal. Layar lain tetap "Unverified" (lihat docs/figma-fidelity.md). flutter_svg tidak ditambahkan (tidak ada SVG di export).
- Grid memakai `ResponsiveGrid` (Wrap, kolom dari maxCrossAxisExtent) dan daftar horizontal `PeekRow` (SingleChildScrollView) agar tinggi kartu mengikuti isi; bukan SliverGridDelegateWithMaxCrossAxisExtent (butuh tinggi tetap).
- Search bar Beranda 48 dp (Figma 39) dan semua tombol min 48 dp demi pedoman target sentuh; menyimpang dari Figma, disengaja.
- Rating angka memakai Poppins (Figma Lato tidak dibundel); ikon Material tetap (tidak ada SVG ekspor).
- Test lama `layout_overflow_test.dart` diganti `responsive_matrix_test.dart` (peran x 9 ukuran x 3 skala teks, satu aplikasi per kasus, galat dikumpulkan lewat FlutterError.onError).
- Screenshot web: Flutter headless Edge merender layout tetapi foto aset tidak ter-decode pada beberapa layar (Beranda tanpa foto); seller dan admin tidak dipotret (butuh login, deep link dialihkan).
- Pull-to-refresh di Beranda, Rekomendasi, Kategori, Pesanan pembeli/penjual, Produk penjual; mode mock hanya `invalidate` (tanpa loading nyata). Admin: galat dengan tombol "Coba lagi".

## Phase 13 (feature/mobile-polish)
- Warna merek app berubah dari #177BCD ke web #1672c4. Gradien dipersempit dari 43->35% (web) menjadi 43->37% agar putih >= 4.5:1 di titik terang dan selisih <= 6%.
- Oranye tidak dipakai di app (tidak ada layar Figma yang memakainya). Lato (rating) tetap diganti Poppins; Montserrat hanya token `AppText.eyebrow`, belum dipakai karena tanpa teks baru.
- Transisi halaman lewat `PageTransitionsTheme` (builder fade + geser 200 ms) alih-alih CustomTransitionPage per rute, agar semua rute go_router konsisten tanpa mengubah router.
- Warna kontras diperdalam: danger #C8160D, hint #5F636C, teks chip status diperdalam 25%, judul header putih (bukan #EEE).
- Radius kartu 20 (web 24) untuk layar kecil. Tinggi tile menu bertambah (minimal 48 dp) akibat IconChip.
- Test `screens_test` 'Keluar dari profil' memakai scrollUntilVisible karena daftar profil kini lebih tinggi. Timeline pesanan tidak dibuat (bukan fitur yang ada).
- Reveal hanya dipasang pada baris produk dan kartu pesanan buyer (revealIndex); layar lain memakai transisi halaman, kartu, dan Pressable.
## Phase 12b-fix (spacing, feature/mobile-mvp)
- Token spasi di `lib/core/responsive/spacing.dart`: screenGutter 16/20/24, sectionGap 24 (compact) / 28, sectionTitleGap 12, itemGap 12, cardPadding 12 (compact) / 16, dotsGap 8, minBottomClearance = 64 + inset aman + 16 (layar tab) dan bottomClearance = inset + 16 (layar non-tab). Widget: SectionHeader, VGap.section/title/item, HorizontalCardList (Clip.none, tanpa padding vertikal agar jarak tepat token), ProductCardWithPhoto (offset atas = jari-jari foto; jarak judul diukur ke foto).
- Tab bawah berada di luar body Scaffold, jadi ruang bawah minimum pada layar tab bersifat tambahan (lega), bukan koreksi tumpang tindih; dipertahankan sesuai spesifikasi.
- Pengecualian yang dipertahankan: lebar logo/gambar (width fluida), Spacer di Row (cart, kategori), SizedBox(width: 48) pada slot AppBar (target sentuh), scrollPadding 20/20/20/140 pada AppField (ruang keyboard), padding optik 0 dan sisa literal non-skala (divider, ikon), tinggi minimum 48/56 tombol. Angka di luar skala dibulatkan: 6->8, 10/14->12, 18->16, 30/40->32.
- Header bagian di layar lain masih sebagian memakai `Text` + `AppText.semi`; hanya Home, Rekomendasi, dan Telusuri memakai SectionHeader. Form: jarak antar field = itemGap lewat AppField; jarak antar kelompok belum seragam.
- Server statis mengembalikan 404 untuk berkas dengan ekstensi yang tidak ada (hanya /favicon.ico yang 404, bawaan browser). Foto tampil di screenshot headless setelah menunggu >7 detik virtual (script gulir di wrapper); tanpa menunggu foto belum ter-decode.
- Cabang `feature/mobile-polish` memiliki versi Home sendiri (Phase 13); perbaikan spasi ini hanya di `feature/mobile-mvp`, merge berikutnya akan konflik di `catalog_screens.dart`.

## Phase 13b - keputusan merge
- Prinsip: struktur/ritme dari mvp (token Space, Gap/VGap, SectionHeader, HorizontalCardList, Key pengukuran); gaya visual dari polish (Pressable, AppCard.decorationFor, IconChip, gradien, Reveal, motion). Satu versi per widget (AppCard, PillButton, SectionHeader, ProductCardWithPhoto, kartu kategori, titik banner, bilah Telusuri).
- AppCard: padding default `Space.cardPadding`, margin `Space.itemGap`, tetap mendukung `revealIndex`.
- SectionHeader: SectionTitle polish (batang aksen) + aksi 48 dp; judul membungkus.
- `Space.minBottomClearance` kini = inset aman + 16 (bukan + tinggi tab): tab bawah berada DI LUAR body Scaffold (bottomNavigationBar), sehingga menambah 64 dp membuat item terakhir tidak bisa dijangkau. Tes `spacing_test` 'VGap dan minBottomClearance' disesuaikan (ekspektasi lama usang).
- `screens_test` 'Keluar dari profil': ditambah `ensureVisible` setelah `scrollUntilVisible` (scrollUntilVisible berhenti saat widget sudah dibangun di cache extent, di luar viewport, sehingga tap mengenai tab bawah). Asersi tidak berubah.

## Phase 13b - clearance bawah (PART 4)
- Semua tab (pembeli: Beranda/Telusuri/Profil; penjual: Beranda/Produk/Pengaturan) memakai `bottomNavigationBar` Scaffold, jadi tab TIDAK menimpa body. Padding bawah isi = inset aman + 16 (`Space.minBottomClearance`/`bottomClearance`). Beranda: spacer akhir diganti padding ListView.
- Tes baru `bottom_clearance_test.dart` (360x800, 412x915, 6 tab): item terakhir terlihat penuh; jarak ke tab 16..32 dp bila isi bisa di-scroll; bila isi muat tanpa scroll cukup >= 16.

## Phase 13b - radius dan font rating (PART 5)
- `AppRadius.card` = 20 (tema). Radius literal di widget dipindah ke token: auth (30->pill, 10->field), cart swipe-bg, catalog (16->card, 28->sheet, 8->chip), common, profile (10->field), seller order/product (16->card, 28->sheet), chip tab bawah (16->card). Sisa literal sengaja: bar dekoratif 3-4 dp.
- Rating: `AppText.rating` / `AppText.ratingLarge` (Poppins, `FontFeature.tabularFigures`) dipakai di kartu produk, baris produk, dan skor detail. Tidak ada referensi Lato tersisa (grep bersih); tidak ada keluarga font baru.

## Phase 13b - MOCK_AUTOLOGIN_ROLE (PART 6)
- `String.fromEnvironment('MOCK_AUTOLOGIN_ROLE')` (buyer|seller|admin) dibaca HANYA di `MockAuthRepository.initialUser`, dan diabaikan bila `AppConfig.useSupabase` true atau nilai kosong. Tidak ada di `SupabaseAuthRepository` maupun jalur Supabase lain. Nilai tak dikenal -> pembeli demo (perilaku lama). Pemakaian: `flutter build web --dart-define=MOCK_AUTOLOGIN_ROLE=seller`.
- Catatan alat: `serve.mjs` membandingkan path dengan `startsWith(root)`, jadi root harus berformat Windows (`D:\Tools\builds\...`); root bergaris miring maju membuat semua aset 404 dan tangkapan kosong.
- Pemeriksaan visual: Beranda/Telusuri/Detail/Keranjang/Pesanan/Profil (pembeli), beranda/pesanan/produk/form produk (penjual), beranda admin. Form produk: jarak antar kelompok diperbaiki (kategori & variasi memakai VGap).
- Keterbatasan: panel admin dalam mode mock hanya menampilkan "memerlukan koneksi Supabase" (daftar pengguna/produk admin tidak dapat dilihat tanpa Supabase). Pada tangkapan 360 foto detail produk belum termuat (termuat di 768); thumbnail foto pada form produk hanya sebagian termuat (batas waktu virtual-time), jadi belum terverifikasi.

## Phase 14a (UX pass pembeli)
- Badge pesanan aktif ditempatkan di tab Profil (keranjang bukan tab; badge keranjang ada di header Home dan detail). Struktur tab tidak diubah.
- Hero memakai tag `hero-<asal>-<id>` dan asal dikirim lewat `extra` rute, agar tag unik per layar (produk yang sama tampil di rail dan daftar Home).
- Grid "Rating tertinggi" diletakkan setelah daftar dan sebelum "Lihat Lebih" agar tes jarak spacing (rail -> daftar) tetap berlaku.
- Pilihan pengiriman/pembayaran menjadi bottom sheet (sesuai permintaan); kunci `ship-*`/`pay-*` dipindah ke baris opsi di sheet, baris pembuka memakai `checkout-shipping`/`checkout-payment`.
- Banner offline dan skeleton Home dilewati (lihat docs/ux-pass.md).
- Tombol "Batal" di checkout dihapus; tombol kembali di header menjalankan fungsi yang sama. Label tombol keranjang "Beli (n)".

### Selector/ekspektasi tes yang diubah (sebelum -> sesudah, alasan)
| Tes | Sebelum | Sesudah | Alasan |
|---|---|---|---|
| pencarian menyaring produk | enterText lalu pumpAndSettle | enterText lalu `pump(350 ms)` | filter kini di-debounce 300 ms; timer bukan frame sehingga pumpAndSettle tidak memajukan waktu. Asersi hasil tidak diubah |
| end-to-end COD | tap `pay-cod` langsung | tap `checkout-payment` lalu `pay-cod` | pilihan pembayaran kini bottom sheet. Asersi pesanan COD tetap |
| end-to-end COD | teks `Pesanan berhasil dilakukan !` | `Pesanan berhasil dibuat` | microcopy diperbaiki (spasi sebelum tanda seru) |
| Keluar dari profil | tap `Keluar` lalu cek `/login` | tap `Keluar`, cek dialog `Keluar dari akun?`, tap `Keluar` terakhir, cek `/login` | logout kini meminta konfirmasi. Asersi ditambah, tidak dikurangi |

## Phase 14 (alur end-to-end mode mock)
- Admin mock: `MockAdminRemote` dipasang sebagai `adminRemoteProvider` bila tidak ada klien Supabase. Pengguna berasal dari `MockAuthRepository` (akun tambahan Rina, Dedi, Budi), pesanan dari data pesanan mock, produk dari katalog mock. Mode Supabase tidak berubah; antarmuka `AdminRemote` tidak berubah.
- Produk nonaktif (mock) disimpan di `inactiveProductsProvider` dan disaring dari katalog untuk semua peran (mock tidak punya kepemilikan produk per penjual).
- Login pengguna nonaktif ditolak dengan pesan "Akun ini sedang dinonaktifkan. Silakan hubungi admin IkanKu."
- Keranjang dikosongkan saat sesi berakhir (cacat ditemukan oleh tes alur).
- Foto kosong di web: aset PNG 1-3 MB (total 19,9 MB) diubah menjadi WebP maks 900 px (banner 1200 px), total 0,85 MB. Nama berkas berubah dari `.png` ke `.webp`; referensi di lib dan test diperbarui. PNG asli tetap ada di riwayat git.
- Bagian "formulir yang tersisa" sudah dikerjakan di 14a (validasi blur, fokus ke galat, ritme, penjaga kirim ganda); hanya formulir kontak yang ditambah action keyboard dan formatter. Login/registrasi tetap inline (keputusan 13b).
- Tes alur memakai ProviderContainer baru per tes sebagai reset state mock; peran berganti lewat layar login sungguhan.
- Tidak ada bagian Phase 14 yang dilewati selain yang sudah selesai di 14a (lihat atas).

## Phase 15R (remake mobile)
- Tab kedua tetap "Telusuri" (web "Produk" = halaman fitur; "Produk" sudah dipakai tab penjual). Status "Belum Bayar" -> "Menunggu" (COD tidak "belum bayar"; sama dengan enum OrderStatus).
- Galeri foto detail produk: Product hanya punya satu gambar, jadi galeri 1 halaman tanpa indikator (tidak mengarang data). Jumlah pembelian tetap di sheet variasi (tes alur bergantung pada satu stepper), variasi inline hanya pratinjau pilihan.
- Lencana: diskon (discountPercent), stok habis (stock == 0), rating; ambang "stok menipis" tidak dibuat (akan menjadi angka karangan).
- Sheet filter: tombol "Terapkan - N produk" nonaktif bila N = 0.
- Pesanan Saya: label sel memakai FittedBox scaleDown (satu baris) agar tidak pernah terpotong pada skala 2.0; label status satu kata sehingga 2 baris tidak diperlukan.
- Font Nunito pada field input lama dipertahankan (bukan bagian layar yang dirombak).
- Selector tes yang diubah (bukan melemahkan): screens_test 'Hallo, Miftahul Fazra!' -> 'Halo, Miftahul!', 'Rekomendasi untuk anda' -> '... Anda', 'SELAMAT DATANG' -> 'Selamat datang'; flow_buyer_test: Home memakai scrollUntilVisible karena carousel turun di bawah strip nilai jual; spacing_test: urutan Beranda baru (titik -> nilai jual -> judul rekomendasi; judul "Semua ikan"; 'Lihat Lebih' -> 'Lihat semua ikan'); admin_flow_test: tab awal admin = Ringkasan, tap 'Pengguna' dulu.
- Bug yang ditemukan tes dan diperbaiki: Align tanpa heightFactor pada ContentFrame membuat bottomNavigationBar setinggi layar; PillButton beralignment memenuhi tinggi; rute jelajah tidak ada di cabang shell (edit awal salah, tertangkap tes nav).

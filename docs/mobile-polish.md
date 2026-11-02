# Mobile Polish (Phase 13, feature/mobile-polish)

Gaya, hierarki, dan gerak mengikuti tema web. Struktur layar, teks, dan fitur tidak berubah. Semua nilai ada di `flutter_app/lib/core/theme/app_theme.dart`.

## Skills evidence (semua 6 skill berhasil dimuat; review-animations tidak dipanggil)
| Skill | Aturan yang diterapkan | Lokasi |
|---|---|---|
| ui-ux-pro-max | kontras >= 4.5:1 (diuji); target sentuh >= 48 dp; tombol nonaktif + indikator saat proses | `test/polish_test.dart`, `Pressable.minSize`, `PillButton(busy)` di `core/widgets/` |
| emil-design-eng | tekan = skala 0.98 (130 ms); durasi <= 300 ms, easeOut (tanpa ease-in); tidak ada animasi dari skala 0 | `Pressable`, `AppMotion`, `Reveal` (`motion_widgets.dart`) |
| animate | gerbang frekuensi: tab bawah hanya skala/tint halus, tanpa animasi di aksi berulang; alasan tiap gerak (umpan balik, kesinambungan ruang); mode gerak dikurangi = durasi nol | `_ShellScaffold` (`app_router.dart`), `AppMotion.of` |
| animation-performance | hanya transform dan opacity (Reveal, Pressable, Skeleton); RepaintBoundary pada item animasi; tanpa animasi properti layout di daftar | `Reveal`, `Skeleton`, `FadeSlidePageTransitionsBuilder` |
| improve-animations | peta frekuensi (nav/tombol sering = halus; reveal sekali per layar); inventaris gerak; token gerak tunggal (tanpa sistem paralel) | tabel di bawah, `AppMotion` |
| frontend-design | satu titik berkesan (header gradien melengkung + banner), selebihnya tenang; sistem kartu tunggal; tanpa label eyebrow/numbering yang tidak bermakna | `GradientHeader`, `AppCard`, `SectionTitle` |

## Pemetaan token (web -> Flutter)
| Web (globals.css) | Flutter |
|---|---|
| --color-brand #1672c4 | `AppColors.primary` (sebelumnya #177BCD) |
| --grad-primary/--grad-surface (43% -> 37% terang, disempitkan dari 43 -> 35) | `AppGradients.primary/surface/nav` |
| --color-surface #f3f8fd, --color-surface-2 #e8f1fa | `background`, `surfaceTint`/`field` |
| --color-heading #050315, --color-body #2f3542, --color-muted #4f5868 | `textStrong`, `text`, `grey` |
| --color-placeholder #6b6f78 | `hint` #5F636C (diperdalam demi 4.5:1) |
| red-orange 700, malibu 700, tree-poppy 700, malachite 600 | `danger`, `info`, `warning`, `success` |
| .card (radius 24, border brand 12%, shadow 2 lapis) | `AppCard`, `AppRadius.card` 20, `AppColors.border`, `AppShadow.card` |
| .icon-chip-tint / -glass | `IconChip` (tint / glass), radius 14 |
| .section-title::after (56x4) | `SectionTitle` (40x4) |
| --ease-out | `AppMotion.curve` easeOutCubic; 150/220/300 ms |
| --color-accent oranye (hanya CTA unduh web) | TIDAK dipakai di app (tidak ada layar Figma yang memakainya) |
Font: Poppins (UI) dan Montserrat (`AppText.eyebrow`, tidak dipakai di layar karena tanpa teks baru). Radius kartu 20 (web 24) disesuaikan layar kecil.

## Kontras (diuji di `test/polish_test.dart`)
- Putih pada gradien merek: 4.74 (terburuk, titik terang) / 5.02 / 5.32 / 5.64 / 5.99; warna datar 4.95.
- Gradien bergeser maksimal 6% terang dari warna datar (43% ke 37%).
- Teks muted/background 6.71, body 11.50, hint/field 5.27, danger/putih 5.87.
- Teks status di atas tint 12%: warning 6.66, info 6.83, success 5.31, primary 6.44, danger 7.18.
- Perubahan agar lolos: `titleOnPrimary` jadi putih (sebelumnya #EEE, 4.27), danger #C8160D, hint #5F636C, teks chip status diperdalam 25% (`StatusChip.textColor`).

## Inventaris gerak
| Elemen | Properti | Durasi | Easing | Pemicu |
|---|---|---|---|---|
| Tombol, kartu, tile, kotak telusuri (`Pressable`) | transform scale 0.98 | 130 ms | easeOutCubic | tekan |
| Daftar dan kartu (`Reveal`, 8 item pertama) | opacity + translateY 14 dp | 300 ms, jeda 60 ms | easeOutCubic | sekali saat layar dibuka |
| Transisi halaman | opacity + geser 4% | 200 ms | easeOutCubic | navigasi (tema `pageTransitionsTheme`) |
| Tab bawah | scale 1.1 ikon, tint latar | 220 / 150 ms | easeOutCubic | ganti tab |
| Indikator banner | lebar + warna | 220 ms | easeOutCubic | geser banner |
| Skeleton | opacity pulse | 1200 ms | easeInOut | saat memuat; statis bila gerak dimatikan |
| Tombol busy | spinner, ukuran tetap | - | - | proses berjalan |
Semua durasi nol bila `MediaQuery.disableAnimations`. Maksimum 300 ms (transisi halaman 200 ms).
Halaman memakai `PageTransitionsBuilder` di tema (bukan CustomTransitionPage per rute) agar semua rute go_router otomatis konsisten.

## Layar yang direstyle dan bukti visual
Screenshot (web mock, headless Edge, iframe) di `D:\Tools\shots\phase13\`: Beranda 360/375/412/768; Telusuri, Detail produk, Keranjang, Checkout, Pesanan, Profil, Rekomendasi di 360 dan 768. Dilihat: Beranda, Profil, Pesanan (360). Layar lain ditangkap tetapi tidak ditinjau satu per satu. Penjual dan admin tidak dipotret (butuh login); keduanya mewarisi header, kartu, tombol, dan chip yang sama.
- Beranda: header gradien biru melengkung dengan lingkaran dekoratif, kotak telusuri dan kartu kategori/produk dalam sistem kartu web (border biru tipis, bayangan lembut), judul bagian berbatang aksen, banner dengan scrim, indikator beranimasi, tab bawah bergradien dengan pil terpilih.
- Pesanan/Profil/layar lain: header sama, kartu seragam, chip ikon pada menu profil/penjual/pengaturan, chip status berkontras tinggi, tombol utama bergradien dengan umpan balik tekan.
Dibanding web: palet #1672c4, tint #F3F8FD, gradien 43%-37%, kartu radius 20 (web 24), tanpa oranye.
Tidak dibuat: timeline pesanan dan eyebrow (tidak ada fitur/teks baru). Pengujian a11y: label Semantics di item tab, bintang, tile; dekorasi dikeluarkan dari semantics; matriks responsif 81 kasus lulus tanpa perubahan.

## Phase 13b - cabang terpadu (feature/mobile-unified)
- Gaya visual polish + ritme spasi mvp dalam satu widget per komponen. SectionHeader (batang aksen, aksi 48 dp) di semua layar; StickyActionBar pada formulir; radius kartu 20 lewat token; rating Poppins tabular; `MOCK_AUTOLOGIN_ROLE` (khusus mock) untuk pemeriksaan visual penjual/admin.

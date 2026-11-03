# Layout spec (Phase 16)
Token di `flutter_app/lib/core/layout/layout.dart` (nilai) dan `equal_height.dart` (grid sama tinggi). Kelas lebar: compact < 600, medium 600-839, expanded >= 840. Semua nilai pada skala 4 dp dan diturunkan dari nilai yang sudah ada; tidak ada warna baru, tidak ada oranye, tidak ada teks UI yang berubah.

## Nilai tetap
| Komponen | compact | medium | expanded | Catatan |
|---|---|---|---|---|
| HeroHeader isi minimum | 56 | 64 | 72 | + lengkung 32 dan kolom cari 52 mengambang |
| ValuePropCard tinggi minimum | 128 | 136 | 144 | lebar dari aturan peek; tinggi = anggota tertinggi |
| ProductFeaturedCard | lebar dari peek, rasio 0.78 | sama | sama | tinggi otomatis sama (rasio tetap) |
| ProductTile (grid) | kolom 2 | 3 | 4 | SEMUA sel satu tinggi (EqualHeightGrid): sel tertinggi |
| ProductRow | thumbnail 84 persegi | 84 | 84 | tinggi = thumbnail + padding kartu |
| StatCard tinggi minimum | 140 | 148 | 152 | |
| Sel "Pesanan Saya" tinggi minimum | 72 | 76 | 80 | ikon 24 + slot badge 20 + label |
| MenuRow tinggi minimum | 60 | 60 | 60 | divider sejajar teks: indent 12 + 40 + 12 = 64 |
| Kartu kategori tinggi minimum | 60 | 64 | 68 | |
| Aksi cepat tinggi minimum | 104 | 112 | 120 | |
| Chip ikon | 40 dan 48 saja | | | varian tint / solid / onBlue; nilai lain dibulatkan |
| Chip pilihan/filter | 40 | 40 | 40 | |
| Tombol minimum | 48 | 48 | 48 | tombol utama 50 |
| Kolom isian | 56 | 56 | 56 | |
| Bottom bar | item >= 48 x 64 | | | seluruh item area sentuh |
| SegmentedTabs | 48 | 48 | 48 | |
| StickyActionBar | tombol 48-50 + 2 x 12 | | | |
| Peek daftar horizontal | 28 | 28 | 28 | item penuh: 2 / 3 / 4 |
| Radius kartu / foto kecil | 20 / 16 | | | |
| Padding kartu | 12 | 16 | 16 | `Space.cardPadding` |

Lebar item daftar horizontal = (frame - gutter - peek - n x gap) / n; item pertama sejajar gutter; lebar tidak pernah dari teks.

## Aturan tinggi sama
Setiap kelompok dalam baris, daftar horizontal, atau grid memiliki SATU tinggi pada semua lebar dan skala teks. Teks membungkus (tidak dipotong): kelompok mengambil tinggi anggota tertinggi, token adalah batas bawah. Daftar horizontal: `HorizontalCardList` (SingleChildScrollView + IntrinsicHeight + Row stretch). Grid: `EqualHeightGrid` (RenderObject: satu tinggi untuk semua baris). Baris tunggal: IntrinsicHeight + stretch (StatRow, "Pesanan Saya").

### Tempat yang diperbaiki (12 kelompok, semuanya diuji di test/remake/equal_height_test.dart)
Beranda: strip nilai jual, kartu kategori, carousel unggulan, grid "Semua ikan". Telusuri: carousel unggulan, grid. Rekomendasi/Lihat semua: grid. Profil: StatCard, sel "Pesanan Saya". Penjual: StatCard, aksi cepat. Admin: StatCard. Tambahan: lencana ProductTile dipindah ke foto (satu baris di bawah foto: nama, harga, chip rating) agar tinggi sel hanya ditentukan nama; chip filter dan SegmentedTabs memakai tinggi tetap 40/48.

## Pilihan kartu
| Konten | Komponen |
|---|---|
| Koleksi unggulan | ProductFeaturedCard (carousel) |
| Katalog | ProductTile, grid 2 / 3 / 4 kolom |
| Daftar berinformasi | ProductRow |
| Metrik | StatCard |
| Aksi | grid chip ikon (QuickActionTile, solid) |
| Pengaturan dan navigasi | MenuGroup (profil, pengaturan penjual, ringkasan admin) |
| Nilai jual | ValuePropCard (strip) |
| Pesanan | kartu pesanan + StatusChip (+ SegmentedTabs) |
Satu tingkat kartu saja (tidak ada kartu di dalam kartu); data yang sama tidak tampil dua kali dalam jenis kartu yang sama pada satu layar (Beranda: unggulan = carousel, katalog = grid). Belum dikonversi: daftar pengguna/pesanan/produk admin masih ListTile polos (di luar cakupan polish kecil ini).

## Chip ikon dan bottom bar
- IconChip satu widget, tiga varian: tint (gradien merek rendah, ikon biru; baris menu, StatCard), solid (gradien penuh, ikon putih, sorot kiri-atas 15%; ValuePropCard, aksi cepat), onBlue (putih translusen). Ukuran 40 / 48.
- Bottom bar: item terpilih = pil gradien merek dengan ikon terisi dan label putih; label tak terpilih tetap terlihat (abu-abu token); ikon 1.0 -> 1.08 (150 ms) dan haptic ringan saat pindah tab (mati bila reduced motion). Badge di kanan atas kotak ikon, 18 dp, cincin putih 2 dp, jarak 2 dp dari ikon, di dalam pil; maks "9+".
- "Pesanan Saya": badge menempati slot tetap di kanan ikon; tidak menyentuh glyph maupun tepi sel (diuji di 320-412 dp, skala 1.0 dan 2.0).

## Skills evidence (keenam skill dimuat; review-animations tidak dipanggil)
- ui-ux-pro-max: (1) target sentuh >= 48 x 64 untuk seluruh item bottom bar (`remake_widgets.dart` AppBottomBar, tes bar_chip_test). (2) kontras terukur: putih di gradien terburuk 4.74, badge 5.87 (bar_chip_test).
- emil-design-eng: (1) skala ikon 1.0 -> 1.08 hanya untuk item terpilih, 150 ms easeOutCubic, haptic ringan (AppBottomBar). (2) tekan tetap 0.98 lewat Pressable pada seluruh item.
- animate: (1) gerbang frekuensi: pindah tab tidak menganimasikan konten, hanya warna/skala ikon. (2) reduced motion: durasi nol dan tanpa haptic (`AppMotion.of`, AppBottomBar).
- animation-performance: (1) hanya transform + opacity (AnimatedScale); pil memakai dekorasi statis, bukan animasi lebar. (2) tinggi grid dihitung sekali per layout (EqualHeightGrid), tanpa pengukuran per frame.
- improve-animations: (1) tidak ada gerak baru selain skala ikon bar. (2) inventaris tetap: Pressable, Reveal, Skeleton, AnimatedCheck, indikator banner.
- frontend-design: (1) satu hal memorable tetap hero melengkung; chip ikon solid memberi titik fokus pada nilai jual dan aksi cepat tanpa warna baru. (2) kartu mengikuti satu aturan jenis-konten -> komponen, bukan SaaS-kit seragam.

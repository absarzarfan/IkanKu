# Mobile remake (Phase 15R) - blueprint
Dasar: docs/remake-brief.md. Cabang feature/mobile-remake. Skills evidence, tabel string, dan catatan sebelum/sesudah per journey ada di bagian bawah (diisi bertahap).

## 1. Navigasi
- StatefulShellRoute per peran (go_router 18). Bottom bar tampil di SEMUA layar level-jelajah; hanya layar tugas fokus (punya aksi utama sendiri) tanpa bar.
- Rute level-jelajah dipindah ke dalam cabang shell: `/home/all` (Lihat semua), `/search/category/:name`, `/profile/orders`, `/profile/addresses`, `/profile/help`, dst. Tab Beranda: `/home` + `/home/recommendations`, `/home/category/:name`; Telusuri: `/search`; Profil: `/profile` + sub-daftar. Penjual: `/seller` (+ `/seller/orders`, `/seller/reviews`), `/seller/products`, `/seller/settings` (+ ongkir, diskon, metode bayar). Admin: shell 3 tab (Ringkasan, Pengguna, Pesanan/Produk).
- Rute lama (`/recommendations`, `/category/:name`, `/orders`, `/addresses`, `/help`, `/shop/:name`) dipertahankan sebagai redirect ke rute baru agar tautan dan tes lama tetap hidup.
- Semua `showModalBottomSheet`/`showDialog` memakai `useRootNavigator: true`: scrim menutupi bottom bar.
- Bottom bar: pil terpilih, badge di kanan atas ikon (offset, 18 dp, cincin putih 2 dp, tidak menimpa glyph), mengikuti safe area, label membungkus 2 baris, tidak terpotong pada skala teks 2.0.

### Visibilitas bottom bar
| Rute | Bar |
|---|---|
| /home, /search, /profile, /seller, /seller/products, /seller/settings, /admin* tab roots | tampil |
| Lihat semua (/home/all, /home/recommendations, /home/category/*), hasil telusuri preset | tampil |
| Sub-daftar profil (/profile/orders, /profile/addresses, /profile/help, /profile/shop/*) | tampil |
| Daftar penjual/admin (/seller/orders, /seller/reviews, daftar admin) | tampil |
| Detail produk (CTA lengket), /cart, /checkout, /payment, /order-success | tersembunyi |
| Detail pesanan, ulasan, form (profil, alamat, produk, kategori, ongkir, diskon), login/daftar | tersembunyi |
Pencocokan rute diuji di test/remake/nav_bar_test.dart.

## 2. Sistem komponen (core/widgets/remake/)
HeroHeader (gradien, dasar melengkung, gelembung, kolom cari mengambang), SectionHeader (eyebrow, judul, batang aksen, aksi), ProductFeaturedCard (foto besar, overlay gradien bawah >= 4.5:1, nama, harga, chip rating, badge), ProductTile (grid), ProductRow (daftar; thumbnail PERSEGI radius 16, tanpa foto bulat), ValuePropCard (icon chip + judul web), StatCard, StatusChip, StatusTimeline, FilterChipBar (filter aktif dapat dihapus), SegmentedTabs (pil bisa digulir + hitungan), StickyActionBar, EmptyState (icon chip + judul + petunjuk + 1 aksi), SuccessMoment, SkeletonList/SkeletonGrid, MenuGroup (baris icon chip), BottomSheetScaffold (handle, header + footer lengket, badan menggulir).
- Badge (diskon, stok, rating) dihitung hanya dari data produk yang ada. Hover (perangkat dengan kursor): tint merek ~6%, tidak pernah abu-abu (tema: hoverColor/highlightColor/splashColor merek).
- Token: warna, radius, ukuran, bayangan ada di `app_theme.dart`; tidak ada hex/ukuran mentah di layar.

## 3. Blueprint layar
- **Beranda**: HeroHeader (sapaan nama depan + tagline web, kolom cari mengambang), chip kategori ber-icon chip, banner promo (data banner yang ada), 3 ValuePropCard (judul web), "Rekomendasi" carousel ProductFeaturedCard, "Semua ikan" grid 2 kolom ProductTile, "Lihat semua" -> /home/all.
- **Telusuri**: cari tersemat + tombol filter (hitungan aktif); FilterChipBar, jumlah hasil, urutan, toggle grid/daftar (default grid). Belum cari/filter: baris kategori + carousel rekomendasi di atas grid. Kosong: EmptyState + "Atur ulang filter".
- **Lihat semua**: komponen daftar yang sama dengan Telusuri, preset dari titik masuk, bar tampil, item terakhir tidak tertutup.
- **Sheet filter** (BottomSheetScaffold, root navigator): header "Filter & urutkan" + "Atur ulang"; "Urutkan" chip 2 kolom sama lebar; "Kategori" Wrap chip tinggi tetap; "Rentang harga" dua field Min/Maks baca-saja, RangeSlider bertema dengan batas dari data + preset kuantil; "Rating minimal" 4 chip sama lebar; footer "Terapkan - N produk" dengan hitungan LANGSUNG.
- **Detail produk** (tanpa bar): galeri + indikator halaman, tombol kembali/keranjang di lingkaran translusen, kartu info menimpa foto (nama, harga besar, chip rating, badge stok, baris toko), chip variasi, deskripsi + "Selengkapnya", ringkasan ulasan, StickyActionBar (jumlah, "Masukkan Keranjang", "Beli Sekarang").
- **Keranjang**: item per toko, stepper, urungkan hapus, kartu ringkasan. **Checkout**: indikator langkah, alamat/kirim/bayar via sheet, ringkasan, total + CTA lengket. **Sukses**: SuccessMoment, aksi utama ke pesanan.
- **Pesanan**: SegmentedTabs + hitungan, kartu pesanan (StatusChip, strip thumbnail bertumpuk, total); detail: StatusTimeline + aksi ulasan.
- **Profil**: HeroHeader gradien (avatar, nama, kontak), indikator kelengkapan profil (dari field yang ada), "Pesanan Saya" 5 sel Expanded sama lebar (ikon, badge, label 2 baris), baris StatCard (total pesanan, aktif, ulasan), MenuGroup (Akun, Bantuan, Tentang), "Keluar" tombol destruktif + dialog konfirmasi.
- **Selamat datang**: value proposition web, "Masuk" utama, "Daftar" sekunder.
- **Penjual**: dashboard (StatCard pesanan per status + produk aktif, aksi cepat grid icon chip, pesanan terbaru), lalu pesanan, produk, form, pengaturan. **Admin**: ringkasan StatCard (pengguna, pesanan, produk) + tautan cepat, lalu daftar.

## 4. Gerak dan grid
150-300 ms, easeOutCubic, hanya transform + opacity; muncul saat pertama tampil (Reveal, maks 8 item, jeda 60 ms); tekan skala 0.98; reduced motion dihormati (durasi 0); HapticFeedback.selectionClick pada aksi kunci (tambah keranjang, terapkan filter, buat pesanan).
Grid: 2 kolom compact, 3 medium, 4 expanded; ContentFrame lebih lebar untuk grid pada expanded (maks 960).

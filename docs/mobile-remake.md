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

## Koreksi blueprint (implementasi)
- Rute TIDAK diganti nama: rute level-jelajah yang sama (`/recommendations`, `/category/:name`, `/shop/:name`, `/orders`, `/addresses`, `/help`, `/seller/orders`, `/seller/reviews`) dipindah ke dalam cabang StatefulShellBranch yang sesuai, sehingga tautan dan tes lama tetap hidup (tanpa redirect). `/help` penjual = `/seller/help` (cabang Pengaturan). Admin memakai AppBottomBar sendiri (4 tujuan: Ringkasan, Pengguna, Pesanan, Produk) karena satu layar bertab.
- Galeri dev: `/dev/gallery` (kDebugMode dan bukan Supabase), lib/features/dev/gallery_screen.dart.

## Skills evidence (Phase 15R; keenam skill dimuat lewat Skill tool, review-animations tidak dipanggil)
- ui-ux-pro-max: (1) kontras >= 4.5:1 diukur, bukan diasumsikan (test/remake/components_test.dart); chip filter primary 4.34 -> primaryDark 5.24 (remake_widgets.dart FilterChipBar). (2) target sentuh 48 dp dan label semantik untuk kontrol ikon (FilterChipBar, StatCard, AppBottomBar, tombol bulat detail produk). (3) skeleton/ruang tetap: SkeletonGrid, SkeletonRow (thumbnail persegi).
- emil-design-eng: (1) tekan skala 0.98, 130 ms easeOutCubic pada semua kontrol (motion_widgets.dart Pressable, dipakai SelectChip/SegmentedTabs/kartu). (2) hover hanya tint merek ~6% lewat tema, tidak pernah abu-abu (app_theme.dart hoverColor/highlightColor/splashColor). (3) tidak ada animasi pada aksi frekuensi tinggi: ganti tab bar hanya mengubah warna pil (AppBottomBar, 150 ms).
- animate: (1) gerbang frekuensi: muncul-saat-pertama hanya Reveal maks 8 item, jeda 60 ms (ProductGridRows, Welcome). (2) hanya transform + opacity (Reveal, AnimatedCheck/SuccessMoment); AnimatedSize hanya untuk "Selengkapnya" (kejadian jarang, 220 ms). (3) curve easeOutCubic dan durasi dari token AppMotion.
- animation-performance: (1) tanpa AnimatedContainer pada properti layout selain pil bar (warna) dan indikator banner. (2) daftar produk dibangun malas per baris (SliverList di ProductBrowser), bukan Wrap besar. (3) bayangan statis (AppShadow.card), tanpa blur animasi.
- improve-animations: (1) inventaris gerak lama: Pressable, Reveal, Skeleton, AnimatedCheck, indikator banner, pil bar; tidak ada gerak dekoratif baru. (2) reduced motion: semua durasi lewat AppMotion.of (nol bila disableAnimations), diuji di components_test (gerak dikurangi). (3) tidak ada rencana /plans baru (audit read-only dikerjakan langsung).
- frontend-design: (1) satu elemen memorable = hero melengkung dengan kolom cari mengambang (HeroHeader), sisanya tenang. (2) token web dipakai apa adanya (biru #1672c4, tint #F3F8FD, kartu radius 20, eyebrow + batang aksen); oranye tidak dipakai. (3) salinan dari web (tagline, 3 kartu nilai jual) di Beranda dan Welcome.

## Perubahan string (sebelum -> sesudah), 24 entri
Beranda/Telusuri: "Hallo, <nama lengkap>!" -> "Halo, <nama depan>!"; "Cari ikan" -> "Cari ikan air tawar"; "Semua Kategori" -> "Kategori ikan"; "Rekomendasi untuk anda" -> "Rekomendasi untuk Anda"; "Lihat Lebih" -> "Lihat semua ikan"; "Beli Sekarang" (banner) -> "Belanja Sekarang"; baru: tagline web "Belanja Ikan Mudah Dengan IkanKu", "Semua ikan", "Terapkan - N produk", "Selengkapnya/Lebih sedikit", "Variasi".
Pesanan: tab/status "Belum Bayar" -> "Menunggu"; Toko: "SELAMAT DATANG, NAMA!" -> "Selamat datang, Nama!"; Profil: "Kamu perlu masuk lagi untuk berbelanja." -> "Anda perlu masuk lagi untuk berbelanja."; hapus teks karangan "Tempat Budidaya Ikan Air Tawar, Restoran, Kolam Pemancingan" dari detail produk (tidak ada di data).
Kamu -> Anda (8): "koneksi internetmu" -> "koneksi internet Anda"; "ikan favoritmu" -> "ikan favorit Anda"; "alamat pilihanmu" -> "alamat pilihan Anda"; "memeriksa pesananmu" -> "memeriksa pesanan Anda"; "memproses pesananmu" -> "memproses pesanan Anda"; "Pesanan yang kamu buat" -> "Pesanan yang Anda buat"; "Tulis ulasanmu" -> "Tulis ulasan Anda"; "agar pesananmu bisa dikirim" -> "agar pesanan Anda bisa dikirim".
Nilai jual (verbatim web): "Ikan Segar Langsung ke Rumah Anda", "Mudah dan Praktis", "Jaminan Kesegaran" (Beranda dan Welcome).

## Sebelum / sesudah per journey (screenshot di D:\Tools\shots\phase15r; yang dilihat: lihat daftar di bawah)
1. Navigasi, Beranda, Telusuri, Lihat semua, filter, detail: sebelum = Rekomendasi tanpa bottom bar, daftar baris sama di mana-mana, foto bulat. Sesudah = bar tampil di semua layar jelajah (test nav_filter_test), hero + kolom cari mengambang, carousel foto besar + grid ubin, detail dengan foto penuh + kartu info menimpa foto. Sheet filter: root navigator, header/footer lengket, chip sama lebar, hitungan langsung (diuji; tidak ada screenshot sheet).
2. Keranjang, pesanan, sukses: thumbnail kini persegi (ProductImage default radius 16 di seluruh aplikasi), SegmentedTabs + hitungan, strip thumbnail bertumpuk, SuccessMoment. Checkout/payment/review/detail pesanan tidak didesain ulang selain komponen global (catatan: StatusTimeline dibuat tetapi OrderTimeline lama (dengan jam) dipertahankan).
3. Profil: hero, kelengkapan, 5 sel sama lebar (label diskalakan turun FittedBox bila tidak muat, tidak pernah terpotong di 320/360 dp skala 2.0), StatRow, MenuGroup, Keluar destruktif. Welcome: tagline + 3 nilai jual + Masuk/Daftar (tidak ada screenshot: autologin menutupi layar ini). Form profil/alamat/login/register hanya mewarisi komponen global.
4. Penjual: dashboard baru (hero, StatCard, grid aksi, pesanan terbaru), pesanan dengan SegmentedTabs. Produk/pengaturan/form: tema dan thumbnail global saja.
5. Admin: Ringkasan (StatCard + tautan cepat) + AppBottomBar; daftar memakai ListTile lama.
Screenshot dilihat (360x800): home, search, detail, seeall (build awal), profil, pesanan, dashboard penjual, produk penjual, admin; 412x915: home; 768x1024: home. Tidak dilihat / tidak diambil: cart (kosong), checkout, welcome, sheet filter, pengaturan penjual, detail/search/profil 412 dan 768 (diambil, belum dibuka), semua form.

## Review animasi (/review-animations, Phase 15R) dan PART 5.2
- Diperbaiki: transisi halaman memakai easeOutCubic juga saat keluar (sebelumnya easeInCubic); titik banner tidak lagi menganimasikan lebar (warna + AnimatedScale); dialog konfirmasi dan sheet pilihan checkout memakai root navigator (scrim menutupi bar).
- Dipertahankan dengan alasan: AnimatedSize "Selengkapnya" (tinggi teks, jarang, 220 ms), Pressable simetris 130 ms, Reveal (maks 8 baris, bisa memutar ulang bila baris dibangun ulang), Hero foto produk (tidak dimatikan saat reduced motion: catatan terbuka).
- PART 5.2 (keranjang, checkout, sukses, pesanan): sheet pilihan checkout kini BottomSheetScaffold (root navigator), kartu ringkasan keranjang (item dipilih, subtotal, catatan ongkir), area unggah bukti dengan bingkai merek. Sudah ada sebelumnya dan sesuai blueprint: item per toko, stepper, urungkan hapus, StepIndicator, total lengket + CTA, SuccessMoment, SegmentedTabs. OrderTimeline (dengan jam) tetap dipakai di detail pesanan; layar ulasan tidak diubah.
- Belum diverifikasi visual: keranjang berisi, checkout, pembayaran, detail pesanan, ulasan.

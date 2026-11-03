# Export Checklist (manual dari Figma)

File Figma: `9pmLWksHqMqsf4qR5TZ43c`. Kuota Figma MCP habis, jadi frame di bawah harus diekspor manual.

Cara ekspor: di Figma pilih frame (Ctrl+F lalu tempel node id, atau URL `...?node-id=<id dengan "-">`), panel kanan Export, format PNG, scale sesuai tabel, lalu Export. Simpan ke `docs/figma-export/` dengan nama persis seperti kolom "File target".

Aturan: mobile 2x, web 1x. Prioritas 1 = paling penting, 2 = penting, 3 = varian/verifikasi saja. Daftar disusun berdasarkan sumber: `docs/figma-inventory.md`, `docs/flutter-coverage.md`, `docs/web-coverage.md`.

## Stage 2: Halaman web yang belum cocok dengan Figma

| Prioritas | Platform | Frame di Figma | Node ID | File target | Scale | Alasan |
|---|---|---|---|---|---|---|
| 1 | Web | Hubungi Kami non animate | `875:4969` | `web-hubungi-kami.png` | 1x | partial: jawaban FAQ dan opsi form placeholder |
| 1 | Web | Tentang Kami non animate | `875:5067` | `web-tentang-kami.png` | 1x | partial: Misi/Tujuan kosong, blok Developer dilewati |
| 1 | Web | Login (admin) | `1755:1585` | `web-admin-login.png` | 1x | dibuat tanpa Figma |
| 1 | Web | Dashboard | `3649:7187` | `web-admin-dashboard-kosong.png` | 1x | dibuat tanpa Figma (state "belum ada postingan") |
| 1 | Web | Dashboard (ada postingan) | `3649:6918` | `web-admin-dashboard.png` | 1x | dibuat tanpa Figma |
| 1 | Web | Tambah Artikel 1 | `1755:1618` | `web-admin-tambah-artikel-1.png` | 1x | dibuat tanpa Figma |
| 1 | Web | Tambah Artikel 2 | `2135:3043` | `web-admin-tambah-artikel-2.png` | 1x | dibuat tanpa Figma |
| 1 | Web | Tambah Artikel 3 | `2135:3442` | `web-admin-tambah-artikel-3.png` | 1x | dibuat tanpa Figma |
| 1 | Web | Tambah Artikel 4 | `2135:2401` | `web-admin-tambah-artikel-4.png` | 1x | dibuat tanpa Figma |
| 1 | Web | Profil | `4029:7039` | `web-admin-profil.png` | 1x | dibuat tanpa Figma |
| 1 | Web | Edit Profil | `4061:2747` | `web-admin-edit-profil.png` | 1x | dibuat tanpa Figma |
| 1 | Web | Artikel non animate hal. 3 | `3789:2826` | `web-artikel-hal3.png` | 1x | not done |
| 2 | Web | Artikel non animate hal. 2 | `3382:2538` | `web-artikel-hal2.png` | 1x | partial: teks dari metadata, gambar dipetakan manual |
| 2 | Web | Detail Artikel (template utama) | `432:1486` | `web-detail-artikel-01.png` | 1x | layout diperkirakan, tanpa badan artikel |
| 2 | Web | Detail Artikel 2 | `645:537` | `web-detail-artikel-02.png` | 1x | isi artikel belum ada |
| 2 | Web | Detail Artikel 3 | `650:653` | `web-detail-artikel-03.png` | 1x | isi artikel belum ada |
| 2 | Web | Detail Artikel 4 | `650:1396` | `web-detail-artikel-04.png` | 1x | isi artikel belum ada |
| 2 | Web | Detail Artikel 5 | `650:1563` | `web-detail-artikel-05.png` | 1x | isi artikel belum ada |
| 2 | Web | Detail Artikel 6 | `650:2093` | `web-detail-artikel-06.png` | 1x | isi artikel belum ada |
| 2 | Web | Detail Artikel 7 | `678:981` | `web-detail-artikel-07.png` | 1x | isi artikel belum ada |
| 2 | Web | Detail Artikel 8 | `678:1566` | `web-detail-artikel-08.png` | 1x | isi artikel belum ada |
| 2 | Web | Detail Artikel 9 | `3326:13453` | `web-detail-artikel-09.png` | 1x | isi artikel belum ada |
| 2 | Web | Detail Artikel 10 | `3326:13673` | `web-detail-artikel-10.png` | 1x | isi artikel belum ada |
| 2 | Web | Detail Artikel 11 | `3326:13782` | `web-detail-artikel-11.png` | 1x | isi artikel belum ada |
| 2 | Web | Detail Artikel 12 | `3382:12711` | `web-detail-artikel-12.png` | 1x | isi artikel belum ada |
| 2 | Web | Detail Artikel 13 | `3382:12822` | `web-detail-artikel-13.png` | 1x | isi artikel belum ada |
| 2 | Web | Detail Artikel 14 | `3382:12958` | `web-detail-artikel-14.png` | 1x | isi artikel belum ada |
| 2 | Web | Detail Artikel 15 | `3778:2252` | `web-detail-artikel-15.png` | 1x | isi artikel belum ada |
| 2 | Web | Detail Artikel 16 | `3778:2365` | `web-detail-artikel-16.png` | 1x | isi artikel belum ada |
| 2 | Web | Detail Artikel 17 | `3778:6070` | `web-detail-artikel-17.png` | 1x | isi artikel belum ada |
| 2 | Web | Detail Artikel 18 | `3789:2457` | `web-detail-artikel-18.png` | 1x | isi artikel belum ada |
| 2 | Web | Detail Artikel 19 | `3789:2567` | `web-detail-artikel-19.png` | 1x | isi artikel belum ada |
| 3 | Web | Card Artikel 3 | `678:1284` | `web-card-artikel-3.png` | 1x | komponen kartu partial |
| 3 | Web | Card Artikel 4 | `678:1286` | `web-card-artikel-4.png` | 1x | komponen kartu partial |
| 3 | Web | Card Artikel 5 | `678:1285` | `web-card-artikel-5.png` | 1x | komponen kartu partial |
| 3 | Web | Card Artikel 6 | `678:1283` | `web-card-artikel-6.png` | 1x | komponen kartu partial |
| 3 | Web | Produk non animate (verifikasi + video) | `875:4930` | `web-produk.png` | 1x | sudah dibaca dari Figma; ekspor untuk verifikasi, video hanya poster |

## Stage 3: Layar pembeli Flutter (inventory-only, belum diverifikasi)

| Prioritas | Platform | Frame di Figma | Node ID | File target | Scale | Alasan |
|---|---|---|---|---|---|---|
| 1 | Mobile | Pillih Kategori | `378:7086` | `mobile-pilih-kategori.png` | 2x | inventory-only |
| 1 | Mobile | Daftar Keranjang | `378:9507` | `mobile-keranjang.png` | 2x | inventory-only |
| 1 | Mobile | Ringkasan Pesanan | `3434:7411` | `mobile-ringkasan-pesanan.png` | 2x | inventory-only |
| 1 | Mobile | Bayar (varian MVP, ukuran 412x1146) | `1804:11463` | `mobile-bayar.png` | 2x | inventory-only |
| 1 | Mobile | Pilihan Metode Pembayaran | `1869:5547` | `mobile-metode-pembayaran.png` | 2x | inventory-only; Figma memakai sheet, Flutter chip + dialog |
| 1 | Mobile | Pilihan Metode Pengiriman | `1804:11949` | `mobile-metode-pengiriman.png` | 2x | inventory-only; Figma memakai sheet |
| 1 | Mobile | Pembayaran | `938:4885` | `mobile-pembayaran.png` | 2x | inventory-only |
| 1 | Mobile | Pesanan sukses | `478:1178` | `mobile-pesanan-sukses.png` | 2x | inventory-only |
| 1 | Mobile | Detail Pesanan | `2128:5299` | `mobile-detail-pesanan.png` | 2x | inventory-only |
| 1 | Mobile | Detail Pengiriman | `1044:5666` | `mobile-detail-pengiriman.png` | 2x | inventory-only |
| 1 | Mobile | Pesanan Dikemas | `1044:5221` | `mobile-pesanan-dikemas.png` | 2x | tab Pesanan lain memakai kartu yang sama (inventory-only) |
| 1 | Mobile | Pesanan Dikirim | `1044:5360` | `mobile-pesanan-dikirim.png` | 2x | inventory-only |
| 1 | Mobile | Selesai | `1201:13417` | `mobile-pesanan-selesai.png` | 2x | inventory-only |
| 1 | Mobile | Ditolak | `2541:5813` | `mobile-pesanan-ditolak.png` | 2x | inventory-only |
| 1 | Mobile | Jika pesanan ditolak | `2719:8984` | `mobile-pesanan-ditolak-alasan.png` | 2x | inventory-only |
| 1 | Mobile | Memberi ulasan | `528:3796` | `mobile-memberi-ulasan.png` | 2x | inventory-only |
| 1 | Mobile | Lihat ulasan | `3120:6894` | `mobile-lihat-ulasan.png` | 2x | inventory-only |
| 1 | Mobile | Profil | `608:2519` | `mobile-profil.png` | 2x | inventory-only |
| 1 | Mobile | Profil (data) | `3328:6828` | `mobile-profil-data.png` | 2x | inventory-only |
| 1 | Mobile | Alamat | `608:4967` | `mobile-alamat.png` | 2x | inventory-only |
| 1 | Mobile | Tambah alamat | `608:5068` | `mobile-tambah-alamat.png` | 2x | inventory-only |
| 1 | Mobile | Pilih Kecamatan | `5132:6248` | `mobile-pilih-kecamatan.png` | 2x | inventory-only |
| 2 | Mobile | Start up page | `528:2181` | `mobile-startup.png` | 2x | inventory-only |
| 2 | Mobile | Sign in 1 | `155:366` | `mobile-signin-nomor.png` | 2x | inventory-only |
| 2 | Mobile | Sign in 2 | `155:402` | `mobile-signin-otp.png` | 2x | inventory-only |
| 2 | Mobile | Daftar | `1769:8280` | `mobile-daftar.png` | 2x | inventory-only |
| 2 | Mobile | Lupa kata sandi | `108:415` | `mobile-lupa-sandi.png` | 2x | inventory-only |
| 2 | Mobile | Contoh Pencarian | `496:1729` | `mobile-pencarian.png` | 2x | inventory-only |
| 2 | Mobile | Contoh Hasil Pencarian | `923:6293` | `mobile-hasil-pencarian.png` | 2x | inventory-only |
| 2 | Mobile | Rekomendari untuk anda | `2451:8597` | `mobile-rekomendasi.png` | 2x | inventory-only |
| 2 | Mobile | Frame 33821 (Variasi) | `3382:12700` | `mobile-variasi-sheet.png` | 2x | inventory-only |
| 2 | Mobile | Ganti Password | `608:4921` | `mobile-ganti-password.png` | 2x | inventory-only |
| 2 | Mobile | Ubah email | `2204:6090` | `mobile-ubah-email.png` | 2x | inventory-only |
| 2 | Mobile | Ubah nomor ponsel | `2216:5410` | `mobile-ubah-nomor.png` | 2x | inventory-only |
| 2 | Mobile | Pusat Bantuan | `3431:6761` | `mobile-pusat-bantuan.png` | 2x | inventory-only |
| 2 | Mobile | Koneksii Internet Tidak Stabil | `528:2662` | `mobile-offline.png` | 2x | inventory-only |
| 3 | Mobile | Notifikasi Ulasan | `1804:15027` | `mobile-notifikasi-ulasan.png` | 2x | inventory-only |
| 3 | Mobile | Login (verifikasi) | `30:7` | `mobile-login.png` | 2x | sudah dibaca; ekspor untuk perbandingan visual |
| 3 | Mobile | Beranda (verifikasi) | `2339:7724` | `mobile-beranda.png` | 2x | sudah dibaca; untuk perbandingan |
| 3 | Mobile | Detail Produk (verifikasi) | `923:6663` | `mobile-detail-produk.png` | 2x | sudah dibaca; untuk perbandingan |
| 3 | Mobile | Pesanan (verifikasi) | `1044:5000` | `mobile-pesanan.png` | 2x | sudah dibaca; untuk perbandingan |

## Stage 4: Layar penjual Flutter (inventory-only, belum diverifikasi)

| Prioritas | Platform | Frame di Figma | Node ID | File target | Scale | Alasan |
|---|---|---|---|---|---|---|
| 1 | Mobile | Beranda (penjual) | `1769:7716` | `mobile-seller-beranda.png` | 2x | inventory-only |
| 1 | Mobile | Daftar harian aktifitas | `1799:12083` | `mobile-seller-aktivitas.png` | 2x | inventory-only |
| 1 | Mobile | pesanan baru | `1769:8444` | `mobile-seller-pesanan-baru.png` | 2x | inventory-only |
| 1 | Mobile | PenjualDikemas | `1769:8611` | `mobile-seller-pesanan-dikemas.png` | 2x | inventory-only |
| 1 | Mobile | PenjualDikirim | `1769:8494` | `mobile-seller-pesanan-dikirim.png` | 2x | inventory-only; juga tercatat tidak ada di Kotlin |
| 1 | Mobile | PenjualSelesai | `1769:8560` | `mobile-seller-pesanan-selesai.png` | 2x | inventory-only |
| 1 | Mobile | Pembatalan | `2582:9038` | `mobile-seller-pembatalan.png` | 2x | inventory-only |
| 1 | Mobile | Diarsipkan | `2582:9658` | `mobile-seller-diarsipkan.png` | 2x | inventory-only |
| 1 | Mobile | Konfirmasi pesanan | `2330:5707` | `mobile-seller-konfirmasi-pesanan.png` | 2x | inventory-only |
| 1 | Mobile | Konfirmasi Bukti Bayar | `1121:17121` | `mobile-seller-bukti-bayar.png` | 2x | inventory-only |
| 1 | Mobile | Proses pesanan | `1121:17070` | `mobile-seller-proses-pesanan.png` | 2x | inventory-only |
| 1 | Mobile | atur pengiriman | `1769:8745` | `mobile-seller-atur-pengiriman.png` | 2x | inventory-only |
| 1 | Mobile | Bukti pengrirman | `1121:17156` | `mobile-seller-bukti-pengiriman.png` | 2x | inventory-only |
| 1 | Mobile | Ulasan per pesanan | `2582:9601` | `mobile-seller-ulasan.png` | 2x | inventory-only |
| 1 | Mobile | Daftar produk sudah ditambahkan lengkap | `1114:14023` | `mobile-seller-daftar-produk.png` | 2x | inventory-only |
| 1 | Mobile | Detail produk (penjual) | `1114:12754` | `mobile-seller-detail-produk.png` | 2x | inventory-only |
| 1 | Mobile | Tambah Produk Baru | `1769:7741` | `mobile-seller-tambah-produk.png` | 2x | inventory-only |
| 1 | Mobile | Edit produk | `1114:13537` | `mobile-seller-edit-produk.png` | 2x | inventory-only |
| 1 | Mobile | Pop up hapus produk | `1114:12791` | `mobile-seller-hapus-produk.png` | 2x | inventory-only |
| 2 | Mobile | Variasi | `3118:6992` | `mobile-seller-variasi.png` | 2x | inventory-only |
| 2 | Mobile | Atur variasi produk | `1114:12929` | `mobile-seller-atur-variasi.png` | 2x | inventory-only |
| 2 | Mobile | Tmbah Kategori | `3168:7137` | `mobile-seller-tambah-kategori.png` | 2x | inventory-only; foto kategori placeholder |
| 2 | Mobile | Diskon | `2583:10861` | `mobile-seller-diskon.png` | 2x | inventory-only |
| 2 | Mobile | Pengaturan | `2583:10986` | `mobile-seller-pengaturan.png` | 2x | inventory-only |
| 2 | Mobile | Biaya Ongkir | `2588:11577` | `mobile-seller-ongkir.png` | 2x | inventory-only |
| 2 | Mobile | Merode Pembayaran | `1804:14071` | `mobile-seller-metode-pembayaran.png` | 2x | inventory-only |
| 3 | Mobile | Detail pengiriman (penjual) | `1121:17259` | `mobile-seller-detail-pengiriman.png` | 2x | inventory-only |
| 3 | Mobile | Detail pesanan selesai | `1121:17456` | `mobile-seller-detail-pesanan-selesai.png` | 2x | inventory-only |
| 3 | Mobile | Ulasan tiap pesanan selesai | `1121:17419` | `mobile-seller-ulasan-pesanan.png` | 2x | inventory-only |

## Stage 5: Layar yang belum dibuat sama sekali

| Prioritas | Platform | Frame di Figma | Node ID | File target | Scale | Alasan |
|---|---|---|---|---|---|---|
| 1 | Mobile | Daftar / Lengkapi Data (berisi "Sesuaikan lokasi") | `1769:8280` | `mobile-peta-sesuaikan-lokasi-daftar.png` | 2x | peta "Sesuaikan lokasi" not done |
| 1 | Mobile | Tambah alamat (berisi peta) | `3499:4141` | `mobile-peta-sesuaikan-lokasi-alamat.png` | 2x | peta "Sesuaikan lokasi" not done; ekspor juga frame peta lain bila ada (Tambah alamat `4076:6951`) sebagai `mobile-peta-sesuaikan-lokasi-alamat-2.png` |
| 1 | Mobile | Filter Pesanan selesai | `1121:17361` | `mobile-seller-filter-pesanan-selesai.png` | 2x | filter pesanan selesai not done |
| 1 | Mobile | Ubah kategori | `1114:14301` | `mobile-seller-ubah-kategori.png` | 2x | UI rename kategori not done (saat ini hapus + tambah) |
| 1 | Mobile | Tambah kategori baru | `1114:14202` | `mobile-seller-tambah-kategori-baru.png` | 2x | pembanding untuk rename kategori |
| 1 | Mobile | Halaman toko / Kunjungi Toko | (tidak ada di inventaris) | `mobile-halaman-toko.png` | 2x | tidak ada frame di inventaris. Cari di Figma (kemungkinan dari kartu toko di Detail Produk `923:6663`). Jika memang tidak ada, tulis "tidak ada" di `docs/progress.md` |

## Ikon dan logo (SVG, simpan ke `flutter_app/assets/icons/` atau `web/public/`)

Ekspor sebagai SVG, scale 1x. Pilih layer ikon langsung (bukan frame), klik kanan, Copy as SVG atau panel Export, format SVG.

| Prioritas | Item | Lokasi di Figma | File target | Alasan |
|---|---|---|---|---|
| 1 | Status bar (sinyal, wifi, baterai) | Design System `Status Bar` `53:87` | `assets/icons/status-bar-*.svg` | diganti ikon Material |
| 1 | Ikon rating (bintang aktif/nonaktif) | frame `Rating` `1804:14930` (atau `6473:13689`) | `assets/icons/star-filled.svg`, `assets/icons/star-empty.svg` | diganti ikon Material |
| 1 | Ikon tab bar pembeli | instance `Tab Bar pembeli` `6443:15697` | `assets/icons/tab-*.svg` (beranda, kategori, pesanan, profil sesuai tab yang ada) | diganti ikon Material |
| 1 | Logo Google | frame Login `30:7` (tombol Google) | `assets/icons/google.svg` | diganti huruf "G" |
| 2 | Logo IkanKu | Design System `Logo` `66:70` | `assets/icons/logo.svg` | untuk verifikasi aset logo |

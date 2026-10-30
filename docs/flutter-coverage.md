# Cakupan Flutter vs Figma

PENTING (kejujuran): kuota Figma MCP habis di tengah pekerjaan. Hanya **4 frame** yang benar-benar dibaca lewat `get_design_context`:
`30:7` (Login), `2339:7724` (Beranda pembeli), `923:6663` (Detail Produk pembeli), `1044:5000` (Pesanan / Pesanan Saya).
Semua layar lain diimplementasikan dari **daftar teks di docs/figma-inventory.md + perilaku Kotlin + bahasa desain bersama** (header biru #177BCD melengkung, kartu putih radius 16, tombol pil, field #E8E8E8) yang diturunkan dari 4 frame tsb. Layar-layar itu TIDAK diverifikasi piksel terhadap Figma dan ditandai **"bukan dari Figma (kuota)"**. Tidak ada tangkapan layar Figma yang dibandingkan.

Status: **Figma-read** = layout/warna/teks dibaca dari Figma; **Inventory-only** = fungsional, UI diturunkan dari inventory + gaya bersama, belum dicocokkan ke Figma (tindak lanjut: verifikasi saat kuota tersedia); **Not done** = tidak dibuat.

| Grup layar Figma | Node id | Rute / file | Status |
|---|---|---|---|
| Login (+ Login 9, varian) | 30:7 | `/login` `auth_screens.dart` | Figma-read (kotak biru, tab, field, tombol, "Atau", Google). Tombol Google hanya pesan (tanpa backend) |
| Beranda pembeli | 2339:7724 | `/home` `catalog_screens.dart` | Figma-read (header, kategori, banner, rekomendasi, baris produk). Ikon status bar/Tab bar disederhanakan dengan Material icons |
| Detail Produk pembeli | 923:6663 | `/product/:id` | Figma-read (harga, stok, deskripsi, ulasan, kartu toko, CTA). Galeri gambar tunggal, bukan carousel |
| Pesanan Saya (tab) | 1044:5000 | `/orders` | Figma-read untuk kartu "Menunggu" + tab. Tab lain (Dikemas/Dikirim/Selesai/Ditolak) memakai kartu sama (Inventory-only) |
| Start up page | 528:2181 | `/` | Inventory-only (hanya teks "Masuk", "Jelajahi Website kami") |
| Sign in 1/2/10 (nomor, OTP) | 155:366, 155:402, 875:5578 | `/register`, `/register/otp` | Inventory-only |
| Daftar / Lengkapi Data | 1769:8280 | `/register/data` | Inventory-only; "Sesuaikan lokasi" (peta) tidak dibuat: not done (Figma quota) |
| Lupa kata sandi | 108:415 | `/forgot` | Inventory-only |
| Pilih Kategori | 378:7086 | `/category/:name` | Inventory-only |
| Rekomendasi | 2451:8597 | `/recommendations` | Inventory-only |
| Pencarian + hasil | 496:1729, 923:6293 | `/search` | Inventory-only |
| Variasi (sheet) | 3382:12700 | sheet di detail produk | Inventory-only |
| Keranjang | 378:9507, 1804:11288 | `/cart` | Inventory-only |
| Ringkasan Pesanan/Bayar, pilihan metode kirim/bayar, konfirmasi alamat | 3434:7411, 1804:11463, 1804:11936/11949, 1869:5547 | `/checkout` (dialog + chip) | Inventory-only (sheet Figma diganti chip + dialog) |
| Pembayaran / Ulang Pembayaran | 938:4885, 5068:14023 | `/payment/:id` | Inventory-only; unggah bukti disimulasikan |
| Pesanan sukses | 478:1178, 1804:14120 | `/order-success/:id` | Inventory-only |
| Detail Pesanan / Pengiriman | 2128:5299, 1044:5666, 1804:14742 | `/orders/:id` | Inventory-only |
| Pesanan ditolak / alasan | 2719:8984, 6438:9986 | `/orders/:id/rejected` | Inventory-only |
| Memberi ulasan, Lihat ulasan, notifikasi | 528:3796, 1804:14908, 3120:6894, 1804:15027 | `/orders/:id/review`, `.../review/view` | Inventory-only |
| Profil | 608:2519, 507:1479, 1804:14481 | `/profile` | Inventory-only |
| Data profil | 3328:6828 | `/profile/data` | Inventory-only |
| Ganti password | 608:4921, 2593:9321 | `/profile/password` | Inventory-only |
| Ubah email / nomor ponsel | 2204:6090.., 2216:5410.. | `/profile/email`, `/profile/phone` | Inventory-only (+OTP) |
| Alamat, Tambah alamat, Pilih Kecamatan | 608:4967, 608:5068, 3499:4141, 5132:6248 | `/addresses`, `/addresses/add`, `/pick-kecamatan` | Inventory-only; data kecamatan mock |
| Pusat Bantuan | 3431:6761, 3434:6919 | `/help` | Inventory-only; WhatsApp hanya pesan |
| Koneksi terputus | 528:2662 | `/offline` | Inventory-only; belum dipicu otomatis (tidak ada jaringan) |
| Seller: Beranda / daftar harian | 1769:7716, 1799:12083 | `/seller` | Inventory-only |
| Seller: pesanan (baru/dikemas/dikirim/selesai/ditolak/pembatalan/diarsipkan) | 1769:8444, 1769:8611, 1769:8494, 1769:8560, 2582:9038, 2582:9658, 1121:16988.. | `/seller/orders` | Inventory-only |
| Seller: proses/konfirmasi pesanan, bukti bayar | 1121:17070, 1121:17121, 2330:5707 | `/seller/orders/:id` | Inventory-only |
| Seller: bukti pengiriman / atur pengiriman | 1121:17156, 1769:8745 | `/seller/orders/:id/ship` | Inventory-only; foto disimulasikan |
| Seller: ulasan | 2582:9601, 1121:17419 | `/seller/reviews` | Inventory-only |
| Seller: produk, detail, tambah/edit, hapus | 1114:13648.., 1114:12754, 1114:13035.., 1114:13537, 1114:12791 | `/seller/products*` | Inventory-only |
| Seller: variasi | 3118:6992, 3801:6924, 1114:12929 | `/seller/products/:id/variants` | Inventory-only |
| Seller: tambah/ubah kategori | 3168:7137, 1114:14202, 1114:14301 | `/seller/categories/new` (ubah via hapus+tambah) | Inventory-only; foto kategori placeholder; rename UI: not done (Figma quota) |
| Seller: diskon | 2583:10861 | `/seller/discount` | Inventory-only |
| Seller: pengaturan, ongkir, metode pembayaran | 2583:10986, 2588:11577, 1804:14071/14023 | `/seller/settings`, `/seller/ongkir`, `/seller/payment-methods` | Inventory-only |
| Seller: filter pesanan selesai | 1121:17361 | - | Not done (Figma quota) |
| Kunjungi Toko (halaman toko) | - | - | Not done (tidak ada frame di inventory) |
| Section Web, LoFi, Animation, Assets | - | - | Di luar lingkup (sesuai instruksi) |

Varian yang digabung: Alamat 1..30, Sign in N, Login N, Detail Produk, Bayar, Variasi, Tambah produk, Daftar produk sudah ditambahkan (semua jadi satu layar + state).

## Pembaruan PART D (layout, tanpa Figma)
- Semua rute pembeli dan penjual di `test/route_lists.dart` dijalankan oleh `test/layout_overflow_test.dart` pada 360x640 (teks 1.0x) dan 412x917 (teks 1.4x); tidak ada overflow.
- Perbaikan: baris status pesanan di `/profile` (Expanded + FittedBox), tinggi sel grid `/category/*` mengikuti skala teks, judul bagian di `/seller/products` (Expanded), `AppScaffold` memberi SafeArea bawah pada body bila tidak ada bar bawah.
- Semua layar berstatus Inventory-only tetap **belum diverifikasi terhadap Figma**; hanya konsistensi layout yang diperiksa.

# Peta alur (mode mock)

Status ditentukan dari kode dan dijalankan lewat tes (`test/flows/*`, `test/*_test.dart`). Works = berfungsi penuh di mock; Partial = berfungsi tetapi sebagian disimulasikan; Stub = hanya tampilan; Missing = belum ada.
Lokal-saja sampai fase Supabase (disengaja): alamat, keranjang, ongkir/pengaturan toko, unggah bukti (bayar dan kirim hanya menyimpan penanda), kode OTP (`1234`).

## Pembeli
| Langkah | Rute | Status | Bukti |
|---|---|---|---|
| B1 welcome | `/` | Works | screens_test |
| B1 register (nomor -> OTP -> data) | `/register`, `/register/otp`, `/register/data` | Partial (OTP simulasi) | screens_test |
| B1 login | `/login` | Works | flows/* (setiap tes) |
| B1 logout (dengan konfirmasi, keranjang dikosongkan) | profil | Works | screens_test, flows/negative |
| B1 lupa kata sandi | `/forgot` | Stub (tidak ada email terkirim) | screens_test |
| B2 beranda | `/home` | Works | flow_buyer_test |
| B2 cari (debounce, filter, urut) | `/search` | Works | flows/buyer_purchase |
| B2 filter kategori | `/category/:name` | Works (diuji asap) | route_smoke_test |
| B2 detail produk | `/product/:id` | Works | flows |
| B2 variasi (sheet, stok, jumlah) | sheet | Works | flows/negative |
| B3 ubah keranjang (jumlah, hapus, Urungkan) | `/cart` | Works | flow_buyer_test |
| B3 alamat checkout | `/checkout` | Works (lokal) | flows |
| B3 COD | `/checkout` | Works | flows/buyer_purchase |
| B3 NON COD + bukti bayar | `/payment/:id` | Partial (bukti simulasi) | flows/buyer_purchase |
| B3 buat pesanan + sukses | `/order-success/:id` | Works (lokal) | flows |
| B4 filter status | `/orders` | Works | screens_test |
| B4 detail + lini masa | `/orders/:id` | Works | flows |
| B4 batal (hanya Menunggu) | detail | Works | flows/reject_cancel |
| B5 ulasan | `/orders/:id/review` | Works | flows/seller_lifecycle |
| B6 ubah data | `/profile/data` | Works (lokal) | screens_test |
| B6 alamat (tambah, utama, hapus) | `/addresses` | Works (lokal) | flows/account_and_shop |
| B6 ganti kata sandi | `/profile/password` | Works | flows/account_and_shop |
| B6 ubah email / ponsel | `/profile/email`, `/profile/phone` | Partial (OTP simulasi, lokal) | route_smoke_test |

## Penjual
| Langkah | Rute | Status | Bukti |
|---|---|---|---|
| S1 jadi penjual | - | Missing (hanya RPC `become_seller` di mode Supabase, tanpa UI) | kode |
| S1 pengaturan toko | `/seller/settings` | Works (lokal) | flows/account_and_shop |
| S2 tambah / ubah produk | `/seller/products/new`, `/:id/edit` | Works | screens_test, flows |
| S2 variasi | `/seller/products/:id/variants` | Works | screens_test |
| S2 aktif/nonaktif oleh penjual | - | Missing (hanya admin) | kode |
| S2 hapus produk | detail produk | Works | flows |
| S2 kategori, diskon | `/seller/categories/new`, `/seller/discount` | Works | flows/account_and_shop |
| S3 pesanan baru -> terima (= dikemas) | `/seller/orders/:id` | Works | flows/seller_lifecycle |
| S3 periksa bukti bayar (NON COD) | detail | Works | flows/seller_lifecycle |
| S3 kirim dengan bukti kirim | `/seller/orders/:id/ship` | Partial (bukti simulasi) | flows/seller_lifecycle |
| S3 selesai | detail | Works | flows/seller_lifecycle |
| S3 tolak dengan alasan | dialog | Works | flows/reject_cancel |
| S3 batal oleh penjual | - | Missing (hanya pembeli) | kode |
| S3 arsip, filter Selesai (COD/NON COD), ulasan | daftar | Works | flows, part_e_test |
| S4 ongkir | `/seller/ongkir` | Works (lokal) | route_smoke_test |
| S4 metode pembayaran | `/seller/payment-methods` | Works (memengaruhi checkout) | flows/account_and_shop |

## Admin
| Langkah | Status | Bukti |
|---|---|---|
| A1 daftar dan cari pengguna | Works (data mock) | flows/admin |
| A1 nonaktif/aktif pengguna (tidak bisa login) | Works | flows/admin |
| A1 ikhtisar pesanan + filter status | Works | flows/admin |
| A1 daftar produk, nonaktif/aktif (hilang dari katalog) | Works | flows/admin |

Hitungan: Works 35, Partial 4, Stub 1, Missing 3 (total 43).

## Defects found
1. **Keranjang terbawa setelah logout**: `CartNotifier` tidak mengosongkan state saat sesi berakhir, sehingga pengguna berikutnya melihat keranjang sebelumnya. Diperbaiki: keranjang mendengarkan `authProvider` dan dikosongkan saat null (`cart_providers.dart`). Dibuktikan `flows/negative_flow_test`.
2. **Panel admin tidak berfungsi di mock** (bukan cacat kode, tetapi celah): `adminRemoteProvider` null tanpa Supabase. Diganti `MockAdminRemote`; mode Supabase tidak berubah.
Bukan cacat (asumsi tes yang salah, tes dikoreksi): dialog tolak diisi awal "Bukti pembayaran anda tidak valid"; daftar pesanan penjual tidak menampilkan kode INV; nama pada form alamat terisi otomatis dari akun.

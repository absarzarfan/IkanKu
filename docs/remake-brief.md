# Remake brief (Phase 15R)
Sumber: web/app (home, produk, tentang-kami, hubungi-kami), web/data, web/app/globals.css, docs/ui-brief.md, docs/mvp-spec.md. Web tidak diubah.

## (a) Produk dan pengguna
IkanKu = marketplace ikan air tawar: pembeli memesan ikan segar langsung dari peternak lewat aplikasi (tanpa perantara). Pengguna: **pembeli** (jelajah, keranjang, checkout COD/transfer, lacak pesanan, ulasan), **penjual/peternak** (pesanan, produk, ongkir, metode bayar), **admin** (pengguna, pesanan, produk; artikel tetap di web).

## (b) Value proposition (disalin dari web, jangan diubah)
- Hero: "Belanja Ikan Mudah Dengan IkanKu" - sub: "Dapatkan Ikan Segar Dengan Mudah Dimana Saja".
- Keunggulan Produk (web /produk): "Transparansi Harga & Produk Yang Detail" | "Sistem Review Yang Terpercaya" | "Varietas dan Kualitas Produk Yang Terjamin" | "Pengalaman Pengguna (UX) Yang Ramah & Mudah" | "Opsi Pembayaran Yang Fleksibel".
- Kenapa IkanKu (web /): "Ikan Segar Langsung ke Rumah Anda" | "Mudah dan Praktis" | "Jaminan Kesegaran".
- Fitur Unggulan (web /): "Beragam Kategori Ikan" | "Pembelian Mudah" | "Pelacakan Pesanan" | "Ulasan Produk".

## (c) Nada bahasa
Aturan: 1 ramah dan jelas; 2 lugas, kalimat pendek, kata kerja biasa; 3 menyapa "Anda" (web), bukan "kamu"; 4 tanpa janji atau angka yang tidak ada di sumber; 5 tombol = aksi yang terjadi, nama aksi sama di seluruh alur; 6 kosong/galat = apa yang terjadi + langkah berikutnya, tanpa minta maaf berlebihan.
Contoh dari web: "Cari ikan segar tanpa ribet?" | "Cukup dengan beberapa ketukan, Anda bisa menjelajahi, memilih, dan memesan" | "Pantau status pesanan Anda" | "Mari Bergabung Bersama Kami" | "Kami di sini untuk membantu Anda" | "Temukan ikan air tawar dengan mudah".

## (d) Kosakata web -> label aplikasi
| Web | Aplikasi |
|---|---|
| Beranda | Beranda (tab 1) |
| Produk (halaman fitur) | **Telusuri** (tab 2, diputuskan tetap: "Produk" di web = halaman fitur, di aplikasi "Produk" sudah dipakai tab penjual) |
| Tentang Kami / Hubungi Kami | Tentang IkanKu / Hubungi Kami (menu Profil) |
| Pelacakan Pesanan | Pesanan Saya |
| Ulasan Produk | Ulasan |
| Unduh Aplikasi | (tidak ada di aplikasi) |
| Pembelian Mudah / keranjang, checkout | Keranjang, Checkout, Buat Pesanan |
| Pengiriman | Kirim / Jemput; Ongkir |
| Status pesanan (urutan tetap) | Menunggu, Dikemas, Dikirim, Selesai, Ditolak (+ Dibatalkan, Diarsipkan) |
| Lihat semua | Lihat semua |
| Tombol keluar | Keluar |
Status "Belum Bayar" diganti "Menunggu": pesanan COD tidak "belum bayar" dan nama ini sama dengan enum OrderStatus, tab, chip, dan linimasa.

## (e) Tampilan web -> token Flutter
Merek #1672C4 (gradien 207 80% 43% -> 37%, selisih <= 6%); latar tint #F3F8FD; kartu putih, border biru 12%, bayangan dua lapis (0 1 2 rgba(5,3,21,.04) + 0 12 28 -16 rgba(22,114,196,.28)); radius kartu 20 (foto di tile/baris 16); icon chip kotak membulat 14 (tint 16%->7%, atau kaca putih di atas biru); eyebrow Montserrat 13 w600 + batang aksen gradien 40x4; dasar hero melengkung; pembagi gelombang; gelembung dekoratif opasitas <= 0.12; oranye TIDAK dipakai; font hanya Poppins dan Montserrat (field Nunito lama dipertahankan di input, dicatat di decisions).

# Spesifikasi MVP Mobile (Flutter + Supabase)

Sumber: kode `flutter_app/lib`, `docs/android-audit.md`, `docs/flutter-coverage.md`, `docs/figma-inventory.md`. Status: **done** = UI + alur mock berjalan di Flutter; **partial** = UI ada, backend baru kontrak/skema; **missing** = belum ada.
Setelah Phase 12a seluruh layar berstatus paling tinggi **partial** untuk backend nyata (skema + repository ada, belum diuji pada database hidup).

## Layar per peran
**Pembeli** (semua done di mock, data nyata partial): Startup, Login, Daftar (nomor, OTP, data), Lupa sandi, Beranda, Kategori, Rekomendasi, Cari/hasil, Detail produk + variasi, Halaman toko, Keranjang, Checkout, Pembayaran (unggah bukti), Pesanan sukses, Pesanan Saya (Menunggu/Dikemas/Dikirim/Selesai/Ditolak), Detail pesanan, Pesanan ditolak, Beri/lihat ulasan, Profil, Data profil, Ganti sandi/email/ponsel, Alamat (+kecamatan, +lokasi placeholder), Pusat bantuan, Offline.
**Penjual** (done di mock, partial data nyata): Beranda penjual, Pesanan (baru/dikemas/dikirim/selesai/ditolak/dibatalkan/diarsipkan), Detail pesanan + bukti bayar, Kirim + bukti pengiriman, Ulasan, Produk (daftar, detail, tambah/edit, hapus, variasi), Kategori (tambah/ubah), Diskon, Pengaturan (ongkir, metode pembayaran, bank).
**Admin** (missing, baru di Phase 12a, minimal): daftar + cari pengguna, nonaktif/aktifkan pengguna, ringkasan pesanan, nonaktif/aktifkan produk. Artikel tetap di web.

## Entitas data (Dart model -> tabel)
- AppUser(id, name, email, phone, role buyer|seller|**admin**) -> `profiles` (+ avatar_url, alamat, is_active).
- Address(id, recipient, phone, street, kecamatan/kota/kode pos, isPrimary) -> `addresses`.
- SellerSettings(shopName, shippingFee, freeShippingMin, transfer/cod/delivery/pickup, banks) -> `shops` (+ `shop_banks`).
- Product(id, name, description, category, image, discountPercent, rating, sellerName) -> `products`; kategori -> `categories`.
- Variation(weight, count, price, stock) -> `product_variants`.
- CartLine(product, variation, qty) -> `cart_items`.
- Order(id, status, payment, shipping, address, shippingFee, note, rejectReason, proofUploaded, shipmentPhoto/Note, archivedFrom) -> `orders`; OrderLine -> `order_items` (snapshot nama, harga, qty).
- Review(author, rating, text, orderId) -> `reviews` (satu per item pesanan).

## Alur status pesanan
menunggu -> (penjual terima) dikemas -> (penjual kirim + bukti) dikirim -> (pembeli konfirmasi) selesai.
menunggu -> ditolak (penjual, ada alasan) -> (pembeli bayar ulang) menunggu. menunggu -> dibatalkan (pembeli).
selesai | ditolak | dibatalkan -> diarsipkan (`archived_from` menyimpan status asal). Ulasan hanya untuk pesanan selesai.

## COD / NON COD
- Transfer (NON COD): pesanan baru wajib `payment_proof` sebelum penjual boleh menerima (`needsProof`). `payment_status` manual: belum_bayar -> menunggu_verifikasi -> terverifikasi (diubah penjual).
- COD: tidak perlu bukti; `payment_status` tetap belum_bayar sampai penjual menandai lunas saat selesai.
- Tanpa payment gateway: hanya `payment_method` dan `payment_status` manual.
- Jemput: ongkir 0. Kirim: ongkir dari pengaturan toko (gratis di atas `freeShippingMin`).

## Out of scope (Phase 12a)
Payment gateway; notifikasi push; peta/lokasi nyata; chat; realtime; OTP SMS nyata (registrasi Supabase memakai email + sandi); login Google; manajemen artikel di mobile; admin membuat admin dari aplikasi; kupon/voucher; pelacakan kurir; refund otomatis; offline mode; multi-bahasa (cabang berikutnya); restyle visual.

## NEEDS CONFIRMATION
Penyedia pembayaran, nominal ongkir produksi, kebijakan refund, penyedia OTP telepon, apakah pesanan lintas toko dalam satu checkout diizinkan (spesifikasi ini memecahnya per toko).

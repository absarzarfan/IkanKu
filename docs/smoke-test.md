# Daftar uji manual (smoke test)

Cara pakai: tandai satu kotak per item. Catatan wajib diisi bila FAIL.
Mode mock: jalankan tanpa `--dart-define-from-file`. Akun demo (semua kata sandi `Admin123`): pembeli `fharaa@gmail.com`, penjual `penjual@ikanku.id`, admin `admin@ikanku.id`, pembeli tambahan `rina@ikanku.id`. Kode OTP: `1234`.
Format tiap item: `[ ] PASS  [ ] FAIL` lalu `Catatan:`.

## A. Mode mock: Pembeli
1. Buka aplikasi, layar mulai tampil dengan tombol Masuk dan Daftar.
   [ ] PASS  [ ] FAIL  Catatan:
2. Daftar akun baru: nomor -> OTP 1234 -> data diri -> langsung masuk ke Beranda.
   [ ] PASS  [ ] FAIL  Catatan:
3. Login dengan akun demo; kata sandi salah menampilkan pesan, bukan layar kosong.
   [ ] PASS  [ ] FAIL  Catatan:
4. Formulir login: galat baru muncul setelah pindah kolom atau menekan Login; fokus pindah ke kolom yang salah; ikon mata menampilkan kata sandi.
   [ ] PASS  [ ] FAIL  Catatan:
5. Beranda: foto produk tampil, "Lihat semua" membuka daftar, ketuk produk memindahkan foto (transisi) ke detail.
   [ ] PASS  [ ] FAIL  Catatan:
6. Telusuri: ketik "nila" (hasil muncul sekitar 0,3 detik), tombol hapus, filter/urut, jumlah hasil, hasil kosong punya tombol kembali.
   [ ] PASS  [ ] FAIL  Catatan:
7. Detail produk: pilih variasi di sheet, harga dan stok ikut berubah, jumlah tidak melebihi stok, "Masukkan Keranjang" memberi pesan dengan tombol Lihat keranjang.
   [ ] PASS  [ ] FAIL  Catatan:
8. Keranjang: item per toko, ubah jumlah, geser untuk hapus lalu Urungkan, total berubah, keranjang kosong punya tombol Belanja sekarang.
   [ ] PASS  [ ] FAIL  Catatan:
9. Checkout COD: pilih metode lewat sheet, Buat Pesanan, konfirmasi alamat, tombol berputar dan tidak bisa ditekan dua kali, halaman sukses tampil.
   [ ] PASS  [ ] FAIL  Catatan:
10. Checkout transfer: unggah bukti (simulasi) lalu Kirim bukti; atau Bayar nanti lalu Bayar Sekarang dari daftar pesanan.
    [ ] PASS  [ ] FAIL  Catatan:
11. Daftar pesanan: tab dengan hitungan, kartu berfoto, tarik untuk muat ulang; detail menampilkan lini masa; Batal hanya muncul untuk status Menunggu dan meminta konfirmasi.
    [ ] PASS  [ ] FAIL  Catatan:
12. Ulasan pesanan Selesai: pilih bintang, penghitung karakter, kirim tanpa bintang menampilkan pesan.
    [ ] PASS  [ ] FAIL  Catatan:
13. Profil: ubah data, tambah alamat (kolom kosong ditolak), jadikan utama, hapus alamat (konfirmasi), ganti kata sandi, Keluar (konfirmasi) mengosongkan keranjang.
    [ ] PASS  [ ] FAIL  Catatan:
14. Navigasi: ketuk ulang tab aktif menggulir ke atas; badge angka di tab Profil sama dengan pesanan aktif.
    [ ] PASS  [ ] FAIL  Catatan:

## B. Mode mock: Penjual
1. Login penjual membuka dashboard dengan hitungan pesanan per status.
   [ ] PASS  [ ] FAIL  Catatan:
2. Tambah produk (nama wajib, variasi harga dan stok), produk tampil di katalog pembeli.
   [ ] PASS  [ ] FAIL  Catatan:
3. Ubah produk, atur variasi, atur diskon, tambah kategori (kategori kembar ditolak), hapus produk.
   [ ] PASS  [ ] FAIL  Catatan:
4. Pesanan baru (dibuat pembeli) tampil di tab Menunggu; NON COD tanpa bukti tidak bisa Terima.
   [ ] PASS  [ ] FAIL  Catatan:
5. Terima -> Atur Pengiriman (unggah foto simulasi) -> Tandai Selesai; pembeli melihat tiap status baru.
   [ ] PASS  [ ] FAIL  Catatan:
6. Tolak dengan alasan; pembeli melihat alasan di Pesanan Ditolak dan bisa Bayar Ulang.
   [ ] PASS  [ ] FAIL  Catatan:
7. Filter COD / NON COD pada tab Selesai; Hapus mengarsipkan pesanan selesai/ditolak/dibatalkan.
   [ ] PASS  [ ] FAIL  Catatan:
8. Ulasan Pembeli menampilkan ulasan yang dikirim pembeli.
   [ ] PASS  [ ] FAIL  Catatan:
9. Pengaturan: ongkir dan metode pembayaran; mematikan COD menghilangkan COD di checkout pembeli.
   [ ] PASS  [ ] FAIL  Catatan:
10. Penjual tidak bisa membuka halaman pembeli (/cart) dan pembeli tidak bisa membuka /seller.
    [ ] PASS  [ ] FAIL  Catatan:

## C. Mode mock: Admin
1. Login admin membuka panel tanpa pesan "memerlukan koneksi Supabase".
   [ ] PASS  [ ] FAIL  Catatan:
2. Tab Pengguna: cari nama/email, nonaktifkan Rina Putri; coba login sebagai Rina menampilkan pesan akun dinonaktifkan.
   [ ] PASS  [ ] FAIL  Catatan:
3. Aktifkan kembali Rina; login berhasil.
   [ ] PASS  [ ] FAIL  Catatan:
4. Tab Pesanan: semua status tampil, filter status bekerja.
   [ ] PASS  [ ] FAIL  Catatan:
5. Tab Produk: nonaktifkan Ikan Nila, produk hilang dari Beranda dan Telusuri pembeli; aktifkan lagi, muncul kembali.
   [ ] PASS  [ ] FAIL  Catatan:

## D. Mode Supabase (butuh database hidup; tidak dapat diverifikasi tanpa itu)
Belum diuji otomatis; centang hanya setelah dijalankan dengan `--dart-define-from-file` dan proyek Supabase yang sudah dimigrasi.
1. Register dan login memakai akun Supabase sungguhan; sesi pulih saat aplikasi dibuka ulang.
   [ ] PASS  [ ] FAIL  Catatan:
2. Katalog dimuat dari server; produk penjual tampil setelah disimpan.
   [ ] PASS  [ ] FAIL  Catatan:
3. Checkout memanggil RPC `place_order`; harga dihitung server; pesanan tampil untuk pembeli dan penjual.
   [ ] PASS  [ ] FAIL  Catatan:
4. Perubahan status penjual tersimpan; status yang ditolak server dikembalikan (rollback) dengan pesan.
   [ ] PASS  [ ] FAIL  Catatan:
5. Admin: daftar pengguna, nonaktifkan pengguna dan produk berlaku di server (RLS).
   [ ] PASS  [ ] FAIL  Catatan:
6. Jadi penjual (`become_seller`): belum ada UI; verifikasi manual lewat RPC.
   [ ] PASS  [ ] FAIL  Catatan:
7. Alamat, keranjang, unggah foto (bukti bayar dan kirim) masih lokal/simulasi: pastikan tidak ada klaim palsu di UI.
   [ ] PASS  [ ] FAIL  Catatan:

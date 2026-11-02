# UX pass buyer flow (Phase 14a)

Cabang `feature/mobile-ux`. Lingkup: UX fitur yang sudah ada. Teks UI ada di berkas `*_strings.dart` per fitur (bahasa Inggris dibuat nanti dari teks final).

## Skills evidence
Semua enam skill berhasil dimuat (ui-ux-pro-max, emil-design-eng, animate, animation-performance, improve-animations, frontend-design). Semuanya berorientasi web; aturan diterjemahkan ke Flutter.

| Skill | Aturan yang diterapkan | Berkas |
|---|---|---|
| ui-ux-pro-max | tombol dinonaktifkan saat async (`loading-buttons`) | `core/widgets/widgets.dart` (PillButton.busy), `checkout_screens.dart` |
| ui-ux-pro-max | target sentuh >= 48 dp dan label Semantics untuk ikon | `widgets.dart` (QtyStepper, NavBadge), `cart_screen.dart` |
| ui-ux-pro-max | reservasi ruang untuk konten async / skeleton berbentuk konten | `motion_widgets.dart` (SkeletonRow, SkeletonCard) |
| emil-design-eng | tekan = scale 0.98, tanpa scale(0) (centang sukses mulai 0.7 + opacity) | `motion_widgets.dart`, `checkout_screens.dart` (AnimatedCheck) |
| emil-design-eng | aksi berfrekuensi tinggi tanpa animasi (ketuk ulang tab = scroll instan ke atas tanpa transisi halaman) | `app_router.dart` |
| emil-design-eng | keluar lebih cepat dari masuk, ease-out saja (token 150/220/300 ms, easeOutCubic) | `app_theme.dart` AppMotion |
| animate | gerbang frekuensi + tujuan: Hero hanya pada foto produk (spasial), centang hanya pada momen langka | `catalog_screens.dart`, `checkout_screens.dart` |
| animate | hanya transform dan opacity (indikator banner, bintang ulasan, centang) | `catalog_screens.dart`, `buyer_order_screens.dart` |
| animate | reduced motion ikut dibangun (`AppMotion.of` -> durasi nol) | semua widget bergerak baru |
| animation-performance | `RepaintBoundary` + AnimatedBuilder, tanpa setState per frame | `motion_widgets.dart` |
| animation-performance | tanpa animasi ukuran/layout di jalur panas (subtotal memakai fade angka, bukan tinggi) | `cart_screen.dart` |
| animation-performance | satu skeleton = satu controller bersama; hanya opacity | `motion_widgets.dart` |
| improve-animations | audit frekuensi: Reveal hanya 8 item pertama, sekali per kunjungan (sudah ada, dipertahankan) | `motion_widgets.dart` |
| improve-animations | token gerak tunggal, tidak membuat sistem paralel | `app_theme.dart` |
| improve-animations | dicatat sebagai backlog, bukan dikerjakan: animasi daftar insert/remove penuh pada keranjang selain Dismissible | bagian Skipped |
| frontend-design | hierarki: satu elemen menonjol per layar (pencarian di Home, total di keranjang) | `catalog_screens.dart`, `cart_screen.dart` |
| frontend-design | copy fungsional: kata kerja jelas, kosong/galat memberi arah | `*_strings.dart` |
| frontend-design | maksimal tiga varian kartu agar tidak monoton tetapi konsisten | `catalog_screens.dart` |

## Audit (code walk)
| Layar | Tujuan | Friksi / kekurangan |
|---|---|---|
| Welcome, Login, Register | masuk cepat | validasi saat mengetik pertama; tanpa autofill; tombol mata kata sandi belum ada; fokus tidak pindah ke field salah |
| Home | menemukan ikan | hanya dua jenis seksi (rail + daftar); "Semua Kategori" tanpa "Lihat semua"; tanpa Hero ke detail; ketuk ulang tab tidak scroll ke atas; tanpa badge pesanan aktif |
| Pencarian | cari + saring | setiap ketikan langsung memfilter; tanpa filter/urut; jumlah hasil hanya setelah submit; kosong tanpa jalan kembali |
| Detail produk | pilih variasi, beli | variasi tanpa harga/stok langsung dan tanpa jumlah; konfirmasi tambah-ke-keranjang hanya snackbar tanpa aksi; tanpa haptic |
| Keranjang | cek dan lanjut bayar | tidak dikelompokkan per toko; geser hapus tanpa Undo; stepper tanpa batas stok; total berubah mendadak; kosong tanpa tombol |
| Checkout | buat pesanan | tanpa indikator langkah; pilihan chip tersebar; kesalahan alamat hanya snackbar; tombol tanpa loading; bisa kirim ganda; ringkasan tidak bisa dilipat |
| Sukses | tahu langkah berikut | ikon statis; tanpa petunjuk langkah; copy "dilakukan !" |
| Pesanan, detail | pantau status | tab tanpa hitungan; detail tanpa lini masa; copy "Pilih Variasi" salah konteks; dialog batal hanya menampilkan id |
| Ulasan | beri bintang | bintang tanpa animasi; tanpa penghitung karakter; tombol mati tanpa penjelasan |
| Profil, Alamat | kelola akun | daftar datar; alamat utama kurang jelas; konfirmasi keluar perlu dicek |
| Semua | | monoton: satu kartu putih + kepadatan sama; skeleton berupa kotak seragam; banner offline tidak ada |

### Backlog (dampak / usaha)
1. Pindah fokus + validasi setelah blur (tinggi/rendah) 2. Checkout: langkah, sheet, loading, anti-kirim-ganda (tinggi/sedang)
3. Keranjang: per toko, Undo, batas stok (tinggi/sedang) 4. Detail: sheet variasi live + konfirmasi (tinggi/sedang)
5. Pencarian: debounce + filter/urut (sedang/sedang) 6. Navigasi: Hero, badge, scroll ke atas (sedang/rendah)
7. Home: varian seksi (sedang/sedang) 8. Lini masa pesanan, tab hitungan (sedang/rendah) 9. Ulasan, copy, a11y (sedang/rendah)

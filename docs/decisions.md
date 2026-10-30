# Keputusan (ringkasan)

Detail per bagian: [decisions-flutter.md](decisions-flutter.md), [decisions-web.md](decisions-web.md).

## Pendekatan
- Flutter: Riverpod (state/DI sederhana, mudah diganti dari mock ke backend nyata) + go_router (routing deklaratif dan guard area penjual). Struktur feature-first.
- Web: Next.js App Router + TypeScript + Tailwind, tanpa paket tambahan.
- Baseline Android: `upstream/Front-End` (superset dari master/main, lihat [branch-comparison.md](branch-comparison.md)).

## Backend (pertanyaan terbuka)
Repo tidak punya backend. Kotlin memanggil REST `192.168.1.4:5000` + Firebase phone auth, tetapi data nyatanya hardcoded. Flutter dan web memakai repository mock in-memory dan login palsu. Tidak ada Firebase, `google-services.json`, atau secret. Backend nyata perlu diputuskan lebih dulu.

## Figma
- Kuota panggilan Figma MCP (plan Starter) habis di tengah pekerjaan. Hanya frame berikut yang dibaca dari Figma:
  - Flutter: Login `30:7`, Beranda `2339:7724`, Detail Produk `923:6663`, Pesanan Saya `1044:5000`.
  - Web: Homepage, Produk, Artikel hal. 1 (Hubungi Kami dan Tentang Kami sebagian).
- Sisanya dibuat dari inventaris + perilaku Kotlin, ditandai di `flutter-coverage.md` / `web-coverage.md`, dan belum dicocokkan ke Figma.
- Guidance `figma-design-to-code` tidak bisa dimuat oleh agent, sehingga kode referensi Figma diadaptasi manual.

## Toolchain
- Flutter 3.47.8 di `D:\Tools\flutter` (PATH user).
- Android SDK di `D:\Tools\android-sdk` (tidak ada SDK Android Studio untuk dipakai ulang).
- JDK 17 Temurin portable di `D:\Tools\jdk-17.0.20.1+1`, dipasang karena `sdkmanager` memerlukannya. Ini di luar izin eksplisit dan dicatat di sini.
- Saat build, Flutter memasang NDK r28c dan Build-Tools 36 otomatis.

## Konflik Figma vs Kotlin
Mengikuti Figma untuk UI. Jika frame Figma tidak dibaca (kuota), UI mengikuti inventaris dan gaya bersama yang diturunkan dari 4 frame yang terbaca.

## Port 3000
`postgres.exe` lokal memakai port 3000 sehingga dev server web diuji di 3100. Gunakan `npm run dev` setelah port 3000 dibebaskan.

## Asumsi PART E (tanpa Figma)
- Peta "Sesuaikan lokasi": layar statis tanpa paket peta (`/pick-location`), dipanggil hanya dari "Lengkapi Data" (satu-satunya frame inventory yang menyebutnya). Lokasi hanya ditampilkan, tidak disimpan (model registrasi tidak punya field lokasi).
- Filter pesanan selesai: inventory hanya menyebut "Selesai Dikirim; Sedang Dikirim; Pesanan Baru; Pesanan Selesai; NON COD". Dibuat filter COD / NON COD pada tab Selesai (status sudah tersedia lewat tab).
- Ubah kategori: memakai layar Tambah Kategori dengan mode edit; mengganti nama juga memperbarui kategori produk. Tombol "Ubah Kategori" tampil saat satu kategori dipilih.
- Halaman toko: tidak ada frame atau deskripsi; dibuat kartu toko + grid produk milik penjual yang sama, dibuka dari "Kunjungi Toko" di detail produk.
- `AddCategoryScreen` kini kembali ke `/seller/products` bila tidak ada halaman untuk di-pop (deep link).

## Lain-lain (Part A-D)
- Logo program diambil dari Downloads dengan nama `LOGO KAMPUS MERDEKA.png` dan `logo-black-IL.png` (nama di permintaan sedikit berbeda), disalin ke `web/public/logos/`.
- Proses `next start` lama di port 3100 dihentikan agar dev server bisa dipakai di port itu.
- Opsi paket peta untuk nanti (tidak ditambahkan): `flutter_map` (OpenStreetMap, tanpa API key), `google_maps_flutter` (butuh API key), `maplibre_gl`.

## Phase 3: ikon dan startup Flutter
- Logo: percobaan Figma MCP satu kali gagal (kuota habis), tidak diulang. Ikon dibuat dari logo di repo (`web/public/img/home/logo.png`), dipotong ke area gambar dan diberi kanvas persegi (System.Drawing, tanpa paket). Ikon maskable memakai latar putih dan konten ~62% kanvas (safe zone).
- Ikon Android launcher: PNG mipmap lama (mdpi-xxxhdpi) ditimpa; tidak ada adaptive icon di proyek, jadi tidak perlu paket. Pembuatan ulang bila logo berubah: skrip tidak disimpan di repo.
- `manifest.json`: `theme_color` #008ECE (Malibu/600, token terdekat dengan biru logo; biru utama aplikasi #177BCD tidak ada di `design-tokens.md`), `background_color` putih (sesuai ikon).
- Startup: `initialLocation` = `/home`. Welcome screen ("Masuk" / "Jelajahi Website kami"), login, dan registrasi tetap ada dan dapat dibuka setelah "Keluar" (user null dialihkan ke `/login`; `/` menampilkan welcome bila belum login). Saat sudah login, `/`, `/login` dan alur registrasi dialihkan ke beranda (redirect lama, tidak ada loop).
- Auto-login: `AuthRepository.initialUser` (default null). `MockAuthRepository` mengembalikan akun pembeli demo `fharaa@gmail.com` (Miftahul Fazra). Akun penjual tetap dengan login manual setelah Keluar.
- Implikasi backend (terbuka): autentikasi nyata nanti perlu memulihkan sesi (token tersimpan) di `initialUser`/`AuthController.build`, dan mengembalikan welcome/login sebagai layar awal untuk pengguna tanpa sesi. Saat ini siapa pun yang membuka aplikasi langsung masuk sebagai pembeli demo.
- Saran (tidak dikerjakan): adaptive icon Android (foreground/background terpisah) dan `flutter_launcher_icons` bila ingin otomatis.

- Phase 4: no fish-only asset existed, so the fish was cropped from web/public/img/home/logo.png (transparent bg) and rendered white on #177BCD. Footer sizes derived from CSS (h-[63px] and h-9) with exact multipliers.

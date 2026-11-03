# Audit Aplikasi Android (baseline: `upstream/Front-End`, `abc8f13`)

Dasar: file dibaca dari `git archive upstream/Front-End` (salinan di scratchpad; repo tidak diubah). Penilaian "complete/partial/missing" per screen berdasarkan nama fungsi, wiring di `NavGraph.kt`, ViewModel, dan data yang dipakai. Isi 66 file screen tidak seluruhnya dibaca baris per baris, sehingga status bersifat penilaian level-fitur.

## 1. Kesimpulan utama

- Aplikasi adalah **prototipe UI Jetpack Compose**: hampir seluruh data hardcoded di ViewModel/model (gambar dari `res/drawable`).
- **Tidak ada backend di repo.** Klien mengarah ke REST API eksternal (Retrofit, path `api/pembeli/...`, port 5000) yang tidak ada di repo, ditambah Firebase Auth (phone OTP).
- Hanya registrasi yang menyentuh jaringan (Firebase Phone Auth + `POST api/pembeli/register`, `GET api/kecamatan`, `GET api/kodepos/{id}`). Kode login (`LoginViewModel`) ada tetapi **tidak dipanggil** dari UI.
- `AndroidManifest.xml` **tidak mendeklarasikan permission `INTERNET`** (diverifikasi): panggilan jaringan akan gagal di build nyata sampai ditambahkan.
- Tidak ada local DB: `IkankuDatabase.kt`, `IkankuApplication.kt`, `FirebaseRepository.kt`, `IRepository.kt`, `RoomRepository.kt` adalah stub kosong; Room tidak ada di dependencies.

## 2. Data source (eksplisit)

| Sumber | Status | Bukti |
|---|---|---|
| Hardcoded/mock | **Dominan** | `BerandaViewModel` (kategori, promo, rekomendasi, produk), `ProductViewModel`, `ShoppingCartViewModel` (3 item sampel), `OrderViewModel`, `OrderRejectedViewModel` (dipakai juga oleh `PesananBaru` dan `PenjualDikemas` sisi penjual) |
| REST (Retrofit) | Ada, sebagian terhubung | `api/RetrofitInstance.kt` (baseUrl `http://192.168.1.4:5000/`, interceptor Bearer token Firebase); `api/ApiServiceProvider.kt` (URL sama); `repository/RetrofitClient.kt` (baseUrl berbeda: `http://10.0.2.2:5000/api/`) untuk `GET pesanan?status=Ditolak`. Dua konfigurasi base URL tidak konsisten |
| Firebase | Hanya Auth | `PhoneAuthProvider.verifyPhoneNumber` di `DaftarScreen1.kt`; verifikasi OTP (`signInWithCredential`) **dikomentari** di `DaftarScreenOTP.kt` (tombol "Lanjut" langsung `navigate("daftar_data")`). Tidak ada Firestore/RTDB/Storage. `google-services.json` ada (project_id `ikankuauth`) |
| Local DB | Tidak ada | stub kosong |
| SharedPreferences | Helper ada | `utils/SharedPreferencesHelper.kt`; hanya `logout()` dipanggil (di `TokoSaya.kt`); `saveUser` tidak dipanggil dari alur login |

Endpoint yang didefinisikan (`network.ApiService`): `POST api/pembeli/register`, `POST api/pembeli/login`, `GET api/kecamatan`, `GET api/kodepos/{id_kecamatan}`. Di `repository.ApiService`: `GET pesanan?status=`. Tidak ada endpoint produk, keranjang, alamat, toko, ulasan.

`OrderRejectedViewModelDua` (yang memanggil REST) tidak dipakai screen mana pun yang ter-route; `RejectedOrdersScreen` memakai `OrderRejectedViewModel` hardcoded.

Temuan keamanan ringan: `RetrofitInstance` mencetak token Firebase ke Logcat; model `Pembeli`/`Toko` memuat `kata_sandi`; `google-services.json` ter-commit.

## 3. Konfigurasi dan dependency

- `compileSdk 34`, `targetSdk 34`, `minSdk 23`, `versionName 1.0`, Java/JVM 11.
- AGP 8.5.1, Kotlin 1.9.0, Compose compiler extension 1.5.2, Compose BOM 2024.04.01, plugin `com.google.gms.google-services` 4.4.2.
- Dependency utama: Compose (ui, material, material3 1.1.0, foundation 1.5.0, runtime-livedata), navigation-compose 2.7.0, lifecycle-viewmodel-compose 2.5.1, Retrofit 2.9.0 + converter-gson, OkHttp 4.9.1, Coil 2.4.0, Accompanist Pager 0.28.0 (+indicators), core-splashscreen 1.0.1, `firebase-auth` 23.1.0, `play-services-auth` 20.0.1 (tombol "Login dengan Google" hanya `navigate` ke beranda).
- Kebersihan build: dependency duplikat (retrofit, accompanist, runtime-livedata), dua versi `compose.material` (1.5.0 dan 1.4.3), versi eksplisit bercampur dengan BOM, tanpa Firebase BoM.
- Manifest: tidak ada `<uses-permission>` sama sekali (tanpa INTERNET/CAMERA/media). Satu `MainActivity` (launcher). `network_security_config` mengizinkan cleartext hanya ke `192.168.1.4`.
- Tes: hanya `ExampleUnitTest.kt` dan `ExampleInstrumentedTest.kt` (template).
- Untuk dijalankan penuh: Firebase project/`google-services.json` valid (SHA key terdaftar untuk Phone Auth), backend di IP LAN yang sama, permission INTERNET.

## 4. Arsitektur dan state

- Single-Activity, Compose penuh, tema di `ui/theme`, font Poppins (regular, bold).
- MVVM longgar: 26 file ViewModel mengekspos `StateFlow` (login/registrasi) atau `val`/`mutableStateListOf` statis (mock). Ada `LoginViewModelFactory` dan `RegisterViewModelFactory`. Tanpa DI (Hilt/Koin), tanpa repository berfungsi, tanpa use case.
- Banyak composable menerima `onBackClick = { /*TODO*/ }`; 12 TODO di `NavGraph.kt`. Route duplikat: `dikemas_penjual` didaftarkan dua kali; `ulasan_produk` dan `ulasan_produk_penjual` memakai screen sama.
- Satu NavHost, route string tanpa argumen (data tidak dikirim antar screen), tanpa pemisahan graph pembeli/penjual, tanpa guard auth.

## 5. Navigation graph (`NavGraph.kt`, startDestination = `startup_screen`)

- **Awal/Auth:** `startup_screen` -> `login_screen` / `register_screen`; registrasi: `register_screen` -> `daftar_otp` -> `daftar_data` -> `beranda_screen`; `lupa_sandi_pembeli`; `splash_screen` terdaftar tetapi bukan start (splash native via `installSplashScreen`).
- **Pembeli:** `beranda_screen`, `kategori_screen`, `daftar_rekomendasi`, `pencarian_screen`, `search_result_screen`, `detail_produk`, `keranjang_screen`, `halaman_bayar`, `transfer_screen`, `pesanan_sukses`, `pesanan_screen`, `dikemas_screen`, `dikirim_screen`, `selesai_screen`, `ditolak_screen`, `detail_pengiriman`, `detail_pesanan`, `alasan_ditolak`, `beri_ulasan`, `ulasan_saya`, `kunjungi_toko`, `profile_screen`, `data_profile`, `change_password_screen`, `ubah_email`, `ubah_emailOTP`, `ubah_nomor_ponsel`, `ubah_nomor_otp`, `alamat`, `tambah_alamat`, `pusat_bantuan`. Bottom nav pembeli: Beranda / Telusuri / Profil.
- **Penjual:** `toko_saya_screen`, `pesanan_screen_penjual`, `dikemas_penjual`, `produk_penjual_screen`, `Detail_produk_penjual`, `tambah_produk_penjual`, `tambah_kategori`, `atur_variasi`, `harga_variasi`, `atur_diskon`, `ulasan_produk(_penjual)`, `pengaturan_penjual` -> `metode_pengiriman_screen`, `metode_pembayaran_screen`, `bank_management_screen`, `biaya_ongkir`; `edit_penjual_screen`, `ganti_email_penjual`.
- **Screen ada tetapi tidak ter-route:** `NoInternetScreen`, `OrderConfirmationDeliveryScreen` (BuktiPengirimanPenjual), `OrderConfirmationPayScreen` (KonfirmasiPesananKedua), `ValidasiPembayaran`, `HelpCenterPenjualScreen`, `ReviewListOrderScreen`, `VerifyEmailPenjualScreen`, `MetodePembayaran`, `OrderScreenDua`.
- Login tidak membedakan peran: tombol Login langsung `navigate("beranda_screen")`.

## 6. Data models (`model/`)

- API-backed: `Pembeli` (id_pembeli, id_firebase, nama_lengkap, no_ponsel, email, kata_sandi, detail_alamat, id_kecamatan, id_kode_pos), `Toko` (id_toko, nama_toko, nama_penjual, jam_operasional, info_pengiriman, alamat_toko, deskripsi_toko, foto_toko, toko_libur, kata_sandi, ...), `LoginResponse` (userType, pembeli?, toko?), `Kecamatan`, `KodePos`, `OrderDua`.
- UI/mock: `Product`, `Fish`, `Category`, `Promotion`, `Recommendation`, `CartItemModel`, `Order` + `enum OrderStatus` (PENDING_CONFIRMATION, PAYMENT_REQUIRED, SHIPPED, COMPLETED, REJECTED), `Dikemas`, `Dikirim`, `BeriUlasan`, `PesananSelesai`, `OrederPesananDiterima`, `OrderAmbilPesananModel`, `Ulasan`, `RatingBreakdown`, `Profile`, `ProfilPenjual`, `ProfilAkunPenjual`, `OrderStatusItem`, `OrderStatusPenjualItem`. Gambar via `Int` resource id (bukan URL).
- Tidak ada model untuk: variasi produk (berat/isi/stok/harga), diskon, alamat, rekening bank, metode pembayaran/pengiriman, kategori penjual.

## 7. Assets

- `res/drawable`: 86 file. Ikon vector XML (nav/aksi), PNG ikan (nila, patin, angel, bluedevil, fire, guppy, mandarin), banner promo, kategori (hias, air tawar, bibit), `logo_ikanku`, ilustrasi (connection_lost, pusat bantuan, peringatan), bukti_pembayaran/bukti_map, bri, `google_logo`, `user.png`.
- Aset placeholder bernuansa pribadi: `pak_vincent.jpg`, `dzaky_indomie.jpg`, `profil_kucing.png`, `tibelat_farm.png`.
- Font Poppins (`res/font`). Ikon launcher adaptive + `ic_launcher-playstore.png`.

## 8. Status fitur

| Area | Status | Catatan |
|---|---|---|
| Startup / splash | Done (UI) | `StartupScreen`, splash native |
| Registrasi (phone, OTP, data, kecamatan/kode pos) | Partial | kirim OTP via Firebase ada; verifikasi OTP dikomentari; submit REST ada tetapi butuh backend + INTERNET |
| Login | Partial | UI + `LoginViewModel` ada, tidak dipanggil; Google login palsu |
| Lupa kata sandi | Partial | UI saja |
| Beranda, kategori, rekomendasi, pencarian, hasil | Partial | UI lengkap, data statis, pencarian tidak nyata |
| Detail produk + pilih variasi | Partial | UI besar (999 baris), data statis |
| Keranjang | Partial | tambah/kurang/hapus in-memory, 3 item sampel |
| Checkout (Bayar), transfer, pesanan sukses | Partial | UI saja, tanpa pembuatan pesanan |
| Daftar pesanan pembeli (5 status) | Partial | mock; detail pengiriman, alasan ditolak, beri ulasan ada UI |
| Profil, data profil, ganti password/email/ponsel, alamat, bantuan | Partial | UI-only, tanpa persistensi; image picker (`GetContent`) di DataProfil |
| Ulasan (lihat/beri, notifikasi terkirim) | Partial | UI mock |
| Penjual: pesanan baru/dikemas | Partial | hardcoded, memakai VM pesanan ditolak |
| Penjual: produk, tambah produk, kategori, variasi, harga variasi, diskon | Partial | form UI; tanpa upload foto nyata/simpan |
| Penjual: pengaturan (pengiriman, pembayaran, bank, ongkir), edit toko, ganti email | Partial | UI-only |
| Penjual: bukti pengiriman, konfirmasi bukti bayar, no-internet | Partial | kode ada, tidak ter-route |
| Notifikasi, peta/lokasi, real-time, offline, payment gateway | Missing | |
| Tes otomatis | Missing | hanya template |

## 9. GAP TABLE vs Figma (`figma-inventory.md`: Mobile Pembeli & Penjual, Mobile MVP sisi penjual)

Frame varian digabung per grup. "Partial" berarti UI ada tetapi statis/tanpa data atau aksi nyata. Tidak ada grup yang "complete" karena tidak ada alur end-to-end yang berfungsi.

| Figma screen group | Ada di Kotlin? | Complete/Partial/Missing | Catatan |
|---|---|---|---|
| Start up page | Ya (`StartupScreen`) | Partial | start destination; handler "Jelajahi Website" kosong |
| Login (varian isian) | Ya (`LoginScreen`) | Partial | tidak memanggil API; Google login palsu; peran tidak dipisah |
| Daftar / Lengkapi Data ("Alamat 1, 2, 17, 25, 26") | Ya (`DaftarScreenData`) | Partial | kecamatan/kode pos via REST; tanpa "Sesuaikan lokasi" (peta) |
| Sign in 1/2/10/22 (nomor ponsel + OTP) | Ya (`DaftarScreen1`, `DaftarScreenOTP`) | Partial | kirim OTP Firebase ada; verifikasi dikomentari |
| Lupa kata sandi | Ya (`LupaSandi`) | Partial | UI saja |
| Beranda pembeli | Ya (`BerandaScreen`) | Partial | mock |
| Pilih Kategori | Ya (`Kategori`) | Partial | mock |
| Rekomendasi untuk anda | Ya (`Rekomendasi`) | Partial | mock |
| Contoh Pencarian / Hasil Pencarian | Ya (`Pencarian`, `HasilPencarian`) | Partial | tanpa pencarian nyata |
| Detail Produk (pembeli) + Pilih Variasi | Ya (`DetailProduk`) | Partial | mock |
| Daftar Keranjang | Ya (`Keranjang`) | Partial | in-memory |
| Ringkasan Pesanan / Bayar / Ulang Pembayaran / Pembayaran | Ya (`Bayar`, `Transfer`) | Partial | tanpa pembuatan pesanan |
| Pilihan Metode Pembayaran, Pengiriman, "Apakah alamat sudah benar?" | Ya (dalam `Bayar`) | Partial | pop-up per varian tidak diperiksa satu per satu |
| Pesanan sukses / Ulang pesanan sukses | Ya (`PesananSukses`) | Partial | UI |
| Pesanan (menunggu/belum bayar), Dikemas, Dikirim, Selesai, Ditolak | Ya (`OrderScreen`, `Dikemas`, `Dikirim`, `Selesai`, `Ditolak`) | Partial | mock |
| Detail Pesanan / Detail Pengiriman | Ya (`DetailPesanan`, `DetailPengiriman`) | Partial | UI |
| Alasan ditolak / Jika pesanan ditolak / Bayar ulang | Ya (`AlasanDitolak`) | Partial | UI |
| Memberi ulasan / Lihat ulasan / Notifikasi ulasan | Ya (`Ulasan`, `UlasanPembeli`, `ListUlasan`) | Partial | "Ulasan Terkirim" ada di `Ulasan.kt` |
| Profil pembeli (ProfilScreen, Profil, data profil) | Ya (`ProfileScreen`, `DataProfilScreen`) | Partial | mock |
| Ganti Password | Ya (`GantiPasswordScreen`) | Partial | tidak terhubung Firebase/REST |
| Ubah email (+ OTP) | Ya (`UbahEmail`, `UbahEmailOTP`) | Partial | UI |
| Ubah/Ganti nomor ponsel (+ OTP) | Ya (`UbahNomorPonsel`, `UbahNomorPonselOTP`) | Partial | UI |
| Alamat / Atur alamat ulang / Alamat 24 | Ya (`Alamat`) | Partial | tanpa persistensi |
| Tambah alamat / Pilih Kecamatan | Ya (`TambahAlamat`) | Partial | daftar kota/kecamatan hardcoded (Batam) |
| Pusat Bantuan | Ya (`PusatBantuan`) | Partial | nomor WhatsApp berupa state, tanpa intent |
| Koneksi Internet Tidak Stabil | Ya (`NoInternet`) | Partial | tidak ter-route, tanpa deteksi koneksi |
| Tab Bar pembeli (Group 2106-2110) | Ya (`BottomNavBar`) | Partial | 3 item (Beranda, Telusuri, Profil); Figma MVP menampilkan 4 item (+ Kategori) |
| Kunjungi toko / profil toko | Ya (`KunjungiToko`) | Partial | |
| Beranda penjual / Toko Saya / Daftar harian aktivitas | Ya (`TokoSaya`) | Partial | tidak dibaca penuh; mock |
| Pesanan baru (terima/tolak), Proses pesanan | Ya (`PesananBaru`) | Partial | VM hardcoded |
| PenjualDikemas / atur pengiriman / Kirim | Ya (`PenjualDikemas`) | Partial | VM hardcoded |
| Konfirmasi pesanan / Konfirmasi Bukti Bayar | Kode ada (`KonfirmasiPesananKedua`) | Partial | tidak ter-route |
| Bukti pengiriman (upload foto) | Kode ada (`BuktiPengirimanPenjual`) | Partial | tidak ter-route; upload nyata tidak ada |
| PenjualDikirim / Sedang dikirim | Tidak ditemukan | Missing | tidak ada screen khusus penjual |
| PenjualSelesai / Pesanan selesai / Filter / Detail pesanan selesai | Tidak ditemukan | Missing | |
| Pembatalan (penjual) | Tidak ditemukan | Missing | |
| Ulasan per pesanan (penjual) | Kode ada (`ListUlasanPesanan`) | Partial | tidak ter-route |
| Produk penjual / Daftar produk dan kategori | Ya (`ProdukPenjualScreen`) | Partial | |
| Diarsipkan / Arsip produk | Tidak ditemukan | Missing | |
| Tambah produk (+ atur variasi) | Ya (`TambahProduk`) | Partial | tanpa upload foto nyata |
| Detail/Edit produk penjual (+ pop up hapus, penilaian) | Ya (`DetailProduk2`) | Partial | |
| Variasi / Harga Variasi / Atur variasi produk | Ya (`Variasi`, `HargaVariasi`) | Partial | |
| Diskon | Ya (`Diskon`) | Partial | |
| Tambah/Ubah Kategori | Ya (`TambahKategori`) | Partial | "Ubah kategori" tidak terlihat terpisah |
| Pengaturan penjual | Ya (`Pengaturan`) | Partial | |
| Biaya Ongkir | Ya (`BiayaOngkosKirim`) | Partial | |
| Metode Pembayaran / Rekening bank (penjual) | Ya (`MetodePembayaranScreen`, `BankManagementScreen`) | Partial | |
| Metode Pengiriman (penjual) | Ya (`MetodePengirimanScreen`) | Partial | |
| Edit toko / Ganti email penjual | Ya (`EditToko`, `UbahEmailPenjual`) | Partial | login penjual tidak dipisah |
| Pusat Bantuan penjual | Kode ada (`PusatBantuanPenjual`) | Partial | tidak ter-route |

Ringkasan gap: hampir semua grup Figma punya padanan UI. Kesenjangan utama: (1) integrasi data/backend (nyaris nol), (2) alur penjual Dikirim/Selesai/Pembatalan/Diarsipkan, (3) screen yang ada tetapi belum ter-route, (4) autentikasi nyata dan pemisahan peran, (5) peta/lokasi dan upload foto.

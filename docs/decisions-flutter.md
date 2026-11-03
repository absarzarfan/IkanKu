# Keputusan Flutter (flutter_app/)

## State management (3 baris)
Riverpod (Notifier/NotifierProvider): state kompilasi-aman, mudah diuji lewat `ProviderContainer`, dan repository dapat diganti lewat override provider.
go_router: redirect berbasis peran/login (fungsi murni `computeRedirect`), shell bottom-nav pembeli dan penjual.
Tanpa codegen/DI tambahan: hanya `flutter_riverpod` dan `go_router` ditambahkan.

## Arsitektur
`lib/core` (theme, router, widgets, utils) + `lib/features/<auth|catalog|cart|orders|profile|seller|common>/{data,domain,presentation}`.
Antarmuka repository: `AuthRepository`, `CatalogRepository`, `OrderRepository` dengan implementasi in-memory mock (`Mock*Repository`) di `data/`. Pengaturan penjual (ongkir, rekening) disimpan di notifier (belum punya antarmuka repository: celah yang diketahui). Tidak ada jaringan, Firebase, `google-services.json`, atau rahasia.
Font Poppins/Nunito/Montserrat di-bundle (TTF diunduh dari repo google/fonts), jadi `google_fonts` tidak dipakai. Alur pesanan: menunggu -> dikemas -> dikirim -> selesai; menunggu -> ditolak -> bayar ulang; menunggu -> dibatalkan -> diarsipkan.

## Status sumber desain (jujur)
Kuota Figma habis; hanya 4 frame dibaca (Login, Beranda, Detail Produk, Pesanan). Layar lain berbasis inventory + Kotlin + gaya bersama. Lihat `docs/flutter-coverage.md`. Skill/guidance `figma-design-to-code` tidak dapat dimuat (tidak terdaftar sebagai skill, dan tidak ada alat pembaca resource MCP); get_design_context dipanggil tanpa guidance tsb.

## Ambiguitas dan pilihan konservatif
| Ambiguitas | Pilihan |
|---|---|
| Backend belum diputuskan | Mock in-memory di balik antarmuka repository |
| Peran pembeli vs penjual (Kotlin: login tidak membedakan) | Satu form login; peran ditentukan akun mock (penjual@ikanku.id / 6281266680075). Demo password `Admin123` hanya data mock |
| Login Google | Hanya pesan "belum tersedia" (Kotlin hanya navigate ke beranda) |
| OTP | Kode mock `1234`; dipakai juga di ubah email/nomor |
| Unggah foto (bukti bayar, bukti kirim, foto produk/kategori) | Tanpa paket image_picker (tidak diminta): disimulasikan/placeholder, foto produk dipilih dari aset contoh |
| Stok tidak dikurangi saat pesanan dibuat | Dibiarkan; hanya qty keranjang dibatasi stok |
| Kecamatan/kode pos | Daftar mock Batam (dari teks Figma); Kotlin memakai API |
| Warna: Design System (Cerulean 500 #4373EE) vs frame mobile (#177BCD) | Ikuti frame mobile (Figma-read); dicatat sebagai konflik |
| Tab penjual: Figma mencantumkan Pengaturan/Produk/Beranda | 3 tab itu; pesanan lewat kartu beranda |
| Tab pembeli "Belum Bayar" = status menunggu (inventory menyebut "Menunggu") | Label "Belum Bayar" |
| Ubah kategori | Hanya tambah/hapus; rename tersedia di notifier tetapi tanpa UI |

## Konflik Figma vs Kotlin
- Kotlin: login langsung ke beranda tanpa validasi; Flutter mengikuti Figma (field + validasi) dan memakai mock auth.
- Kotlin: `OrderStatus` 5 nilai; Figma punya tab Belum Bayar/Dikemas/Dikirim/Selesai/Ditolak plus sisi penjual Pembatalan/Diarsipkan: Flutter memakai 7 status.
- Font: Figma frame memakai Poppins + Nunito + Lato + Roboto; token memuat Montserrat. Lato/Roboto tidak di-bundle (fallback sistem).

## Keputusan backend (terbuka)
Perlu keputusan: REST milik tim vs Firebase (Kotlin: Retrofit ke 192.168.1.4:5000 + Firebase Phone Auth). Titik penggantian: override `authRepositoryProvider`, `catalogRepositoryProvider`, `orderRepositoryProvider`; antarmuka saat ini sinkron untuk katalog/pesanan dan perlu dijadikan async saat backend nyata.

## Aset yang tidak diekspor
Ikon status bar, ikon rating/chevron SVG, ikon tab bar, logo Google (SVG diunduh lalu dibuang karena tidak ada paket SVG; diganti huruf G), gambar produk selain 12 PNG pada Beranda/Detail (gambar nila/salmon/gurita memakai aset yang paling mungkin cocok, belum diverifikasi visual), gambar kategori penjual, avatar. Semua diganti ikon Material/placeholder. Aset PNG ~19 MB belum dioptimalkan.

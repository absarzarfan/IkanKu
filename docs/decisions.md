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

# IkanKu

Marketplace ikan. Repo ini berisi tiga bagian:

| Folder | Isi | Status |
|---|---|---|
| `app/`, `build.gradle.kts`, ... | Aplikasi Android (Kotlin, Jetpack Compose) lama, hanya referensi | Tidak diubah |
| `flutter_app/` | Rewrite Flutter (Android, iOS-ready) | Lolos analyze, test, build APK debug |
| `web/` | Landing page + halaman fitur (Next.js) | Lolos lint dan build |
| `docs/` | Inventaris Figma, audit Android, keputusan, cakupan | |

Desain: Figma `9pmLWksHqMqsf4qR5TZ43c`. Catatan penting: tidak semua layar sudah dicocokkan ke Figma, lihat `docs/flutter-coverage.md` dan `docs/web-coverage.md`. Belum ada backend (data mock).

## Flutter
```
cd flutter_app
flutter pub get
flutter analyze
flutter test
flutter run            # perangkat/emulator Android
flutter build apk --debug
```
Butuh Flutter stable, JDK 17, Android SDK. iOS: folder `ios/` valid tetapi tidak bisa dibuild di Windows; build di Mac dengan Xcode.

## Web
```
cd web
npm install
npm run dev            # http://localhost:3000
npm run lint
npm run build
```

## Konfigurasi dan secret
Tidak ada secret yang di-commit. `google-services.json`, `.env`, keystore diabaikan lewat `.gitignore`. Aplikasi saat ini tidak memerlukan variabel lingkungan.

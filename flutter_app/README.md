# IkanKu (Flutter)

Penulisan ulang aplikasi Android IkanKu dalam Flutter (Riverpod + go_router). Data mock in-memory; tanpa backend, Firebase, atau jaringan.

## Menjalankan
```
flutter pub get
flutter run            # Android emulator/perangkat
```
Akun demo (mock): pembeli `fharaa@gmail.com`, penjual `penjual@ikanku.id`, kata sandi `Admin123`; OTP `1234`.

## Tes dan analisis
```
flutter analyze
flutter test
```

## Build
```
flutter build apk --debug      # build/app/outputs/flutter-apk/app-debug.apk
```
Toolchain: Flutter 3.47.x, JDK 17, Android SDK 35/36 (set `JAVA_HOME` dan `ANDROID_HOME`).

## iOS
Folder `ios/` dihasilkan `flutter create` dan seharusnya valid, tetapi **belum diverifikasi**: iOS tidak dapat di-build di Windows; perlu Mac dengan Xcode.

## Dokumentasi
`../docs/decisions-flutter.md` (keputusan, ambiguitas, backend terbuka) dan `../docs/flutter-coverage.md` (cakupan layar; hanya 4 frame yang dibaca langsung dari Figma karena kuota).

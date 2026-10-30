# Progress

Branch: `feature/flutter-web` (push ke `origin`, tidak pernah ke `upstream`). Figma MCP tidak dipakai lagi (kuota habis); sumber UI berikutnya adalah ekspor manual di `docs/figma-export/`.

## Sudah selesai
- Phase 0: inventaris Figma (`figma-inventory.md`), design tokens (`design-tokens.md`).
- Phase 1: perbandingan branch dan audit Kotlin (`branch-comparison.md`, `android-audit.md`). Baseline `upstream/Front-End`.
- Phase 2: Flutter app (`flutter_app/`), analyze bersih, 31 tes lolos, APK debug berhasil. Hanya 4 layar dibaca dari Figma, ~40 layar inventory-only (`flutter-coverage.md`).
- Phase 3: web Next.js (`web/`), lint dan build lolos; sebagian halaman dibuat tanpa Figma (`web-coverage.md`).
- Phase 4: README root, `decisions.md`, `.gitignore` untuk secret.
- Stage 1: `export-checklist.md` (daftar frame yang harus diekspor manual).

## Tahap berikutnya
| Stage | Isi | Prasyarat |
|---|---|---|
| 2 | Web: bangun/perbaiki halaman yang belum cocok Figma (Hubungi Kami, Tentang Kami, Artikel hal. 2-3, Detail Artikel, halaman admin) sesuai `web-*.png` | PNG Stage 2 di `docs/figma-export/` |
| 3 | Flutter pembeli: samakan layar dengan `mobile-*.png`, ganti ikon Material dan huruf "G" dengan aset | PNG Stage 3 + `assets/` |
| 4 | Flutter penjual: samakan layar dengan `mobile-seller-*.png`, pakai ulang widget Stage 3 | PNG Stage 4 |
| 5 | Layar yang belum ada: peta "Sesuaikan lokasi" (placeholder statis), filter pesanan selesai, UI rename kategori, halaman toko; lalu build APK | PNG Stage 5 |

## Status saat ini
- Stage 1: selesai.
- Stage 2-5: **menunggu ekspor**. `docs/figma-export/` masih kosong (0 file) pada 2026-10-30.
- Catatan: ada perubahan tak ter-commit di `flutter_app/` (web platform ditambahkan lewat `flutter create`: `web/`, `.metadata`, `analysis_options.yaml`, `pubspec.lock`, dan `test/widget_test.dart` bawaan yang merujuk `MyApp` dan akan gagal). Bukan bagian dari pekerjaan ini; perlu keputusan sebelum Stage 3.

- PART A (web: copyright 2024, favicon IkanKu, logo program di footer, teks MSIB Batch 7): selesai.

- PART B (web: container/spasi bersama, footer grid, verifikasi 1440/390): selesai, lihat docs/web-layout-fixes.md.

- PART C (Flutter: platform web dipertahankan, widget_test.dart ditulis ulang, 32 tes lolos): selesai.

- PART D (Flutter: tes overflow 360x640 dan 1.4x, 4 perbaikan layout, SafeArea bawah, 84 tes lolos): selesai.

- PART E (Flutter: peta placeholder, filter pesanan selesai, ubah kategori, halaman toko; analyze bersih, 91 tes lolos, APK debug berhasil): selesai.

- Phase 3 (Flutter: ikon IkanKu web+Android, startup langsung beranda dengan pembeli demo, 92 tes lolos, APK debug berhasil): selesai.
- Phase 4 (web): fish-only favicon and footer tweaks (white background, larger IkanKu/MSIB logos) done.
- Phase 5 P0-1: branch feature/ui-polish; Emil Kowalski skills installed locally (excluded from git); ui-ux-pro-max found.
- Phase 5 P2-3: ui brief, gradient tokens, buttons, type scale.
- Phase 5 P4: contact data centralized in web/data/contact.ts.
- Phase 5 P5-6: Tim Kami cards, ui-polish doc, verified.
- Phase 6 P2-3: orange removed from non-button elements; Keunggulan Produk row fixed.
- Phase 6 P4-6: Tim Kami redo (single-screen, A-Z), blue surface gradients, verified.
- Phase 7 P2-3a: ui-direction doc, shared section/card/badge/CTA components, navbar/footer.
- Phase 7 P3b-4: pages redesigned (home, produk, artikel, tentang, hubungi); team photo zoom/origin tuned.
- Phase 7 P5-6: performance measured, docs written, verified, pushed.
- Phase 8 P0-2: branch v2, skills loaded, role renamed to Hustler.
- Phase 8 P3: Mitra Kami redesigned (data/partners.ts, grid of cards).
- Phase 8 P4: unified icon set, chips, slider controls.
- Phase 8 P5-7: tokens, motion system, verified (build/lint, routes 200), pushed.
- Phase 8b P0-2: single ContactInfo component, Kontak card removed, Batam map embed.

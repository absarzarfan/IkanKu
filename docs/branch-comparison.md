# Perbandingan Branch Upstream: master vs main vs Front-End

Sumber: `git log`, `git ls-tree -r`, `git diff` terhadap ref `upstream/master`, `upstream/main`, `upstream/Front-End` (setelah `git fetch upstream`). Tidak ada file Kotlin yang diubah.

## 1. Ringkasan

| Aspek | upstream/master | upstream/main | upstream/Front-End |
|---|---|---|---|
| HEAD | `a5b7466` | `a5b7466` | `abc8f13` |
| Jumlah commit | 35 | 35 | 37 |
| Commit terakhir | 2024-12-09 "sesuikan ui login" (Dzakwan993) | sama dengan master | 2024-12-20 "Perbaikan pada FE, tidak ada BE di repo ini" (Jesse Pinkman) |
| File `.kt` | 181 | (identik dengan master) | 181 |
| Berisi Android Kotlin (Jetpack Compose) | Ya | Ya | Ya |
| Berisi backend | Tidak ada | Tidak ada | Tidak ada (sesuai pesan commit) |

Hasil verifikasi:
- `master` dan `main` menunjuk commit yang sama (`a5b7466`): identik 100%.
- `Front-End` = `master` + 2 commit (`098759e` 2024-12-19 "Test Push ke branch Front-End", `abc8f13` 2024-12-20). Jadi `Front-End` adalah superset linear dari `master`; tidak ada commit di master yang hilang dari Front-End.

## 2. Riwayat commit

Rentang: 2024-10-30 (commit awal "Initial commit") sampai 2024-12-20.

| Author | master/main | Front-End |
|---|---|---|
| Dzakwan993 | 18 | 18 |
| Jesse Pinkman | 8 | 10 |
| absarzarfan | 6 | 6 |
| dzaky | 3 | 3 |

Commit terakhir di master/main (terbaru ke lama): `a5b7466` sesuikan ui login; `0b6a45b` solve conflict; `b9002bd` fitur login admin dan daftar; `fc44433` "Semoga 1 minggu BE jadi"; `b8ae8c5` Mengkonsistenkan Front End. Pesan commit lama menyebut "aku cinta backend" (2024-11-25), namun tidak ada kode server di tree (lihat bagian 3).

## 3. Perbedaan file-tree

Tree master vs main: tidak ada beda. Tree Front-End vs master (`git diff --name-status`): 72 file berubah.

- Ditambah: `.idea/.name`, `app/src/main/ic_launcher-playstore.png`, `app/src/main/res/drawable/user.png`, `app/src/main/res/values/ic_launcher_background.xml`, `ic_launcher_foreground.webp` per density (mipmap).
- Dihapus: `.idea/other.xml`.
- Diubah (Kotlin): `MainActivity.kt`, `NavGraph.kt`, 3 ViewModel (`DitolakViewModel`, `ProfileViewModel`, `ShoppingCartViewModel`), 10 komponen UI, dan 30 screen (Login, Splash, StartupPages, Profile, TambahAlamat, Transfer, DetailKategori, DetailPengiriman, DataProfil, dll.).
- Diubah (resource/build): `app/build.gradle.kts` (+6 baris), `colors.xml`, `themes.xml`, ikon launcher (`ic_launcher*.xml`, `.webp`).
- Total ~1249 insersi, ~1463 penghapusan: penyempurnaan UI/branding (ikon, tema, layout), bukan fitur baru.

Struktur direktori yang sama di ketiga branch: satu modul `app/` (`com.example.ikanku`) dengan paket `api`, `database`, `model`, `navigation`, `repository`, `ui/{components,screens,theme}`, `utils`, `viewmodel`, `res/`; file Gradle (Kotlin DSL + `libs.versions.toml`). Tidak ditemukan folder backend, Flutter, atau web di branch mana pun.

## 4. Fitur per branch

Ketiganya memuat himpunan screen yang sama (~65 file di `ui/screens`: alur pembeli, penjual, registrasi/login). Front-End hanya menambah poles UI di atas himpunan itu. Detail fitur ada di `android-audit.md`.

## 5. Keputusan baseline

**Baseline Android: `upstream/Front-End` (HEAD `abc8f13`).**

Alasan:
1. Superset linear dari master/main: semua commit master ada di dalamnya, ditambah 2 commit terbaru.
2. Memuat perbaikan UI terbaru (ikon launcher, tema/warna, perubahan di 30 screen) yang paling selaras dengan tujuan mengacu desain Figma.
3. Jumlah file `.kt` sama (181), jadi tidak ada fitur yang hilang dibanding master.
4. Catatan: Front-End secara eksplisit tidak memuat backend. Hal ini juga berlaku untuk master/main, sehingga tidak ada kerugian memilih Front-End.

Risiko: Front-End bukan branch default (default upstream/origin = master). Perlu keputusan apakah baseline diambil sebagai titik awal branch kerja baru.

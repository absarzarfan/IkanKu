# Web Coverage: Figma frame -> route

Status: full = dibaca dari Figma dan diimplementasikan; partial = ada tapi tidak lengkap/diperkirakan; not done.
Catatan: Figma MCP kehabisan kuota setelah 5 frame; semua "partial (tanpa Figma)" dibuat tanpa membaca frame.

| Frame Figma | Node ID | Route / file | Status |
|---|---|---|---|
| Homepage non animate | 2335:7624 (juga 4844:14860) | `/` `app/page.tsx` | full (responsif = ekstrapolasi) |
| Produk non animate | 875:4930 | `/produk` | full (video = poster saja) |
| Hubungi Kami non animate | 875:4969 | `/hubungi-kami` | partial: jawaban FAQ & opsi layanan placeholder; form lokal |
| Tentang Kami non animate | 875:5067 | `/tentang-kami` | partial: Misi/Tujuan tanpa konten; blok Developer dilewati |
| Artikel non animate hal.1 | 3261:2654 (3326:2742, 4844:14772) | `/artikel` | full untuk hal.1 |
| Artikel non animate hal.2 | 3382:2538 | `/artikel` (hal.2) | partial: teks dari metadata, gambar dipetakan manual |
| Artikel non animate hal.3 | 3789:2826 | - | not done: kuota Figma |
| Detail Artikel (19 varian) | 432:1486, 645:537, 650:653, 650:1396, 650:1563, 650:2093, 678:981, 678:1566, 3326:13453, 3326:13673, 3326:13782, 3382:12711, 3382:12822, 3382:12958, 3778:2252, 3778:2365, 3778:6070, 3789:2457, 3789:2567; MVP 4844:14621 | `/artikel/[slug]` | partial (tanpa Figma): layout diperkirakan, tanpa badan artikel |
| Card Artikel 3-6 | 678:1283-1286 | komponen kartu di `ArticleList` | partial |
| Login | 1755:1585 | `/admin/login` | partial (tanpa Figma), auth tiruan |
| Profil | 4029:7039 | `/admin/profil` | partial (tanpa Figma) |
| Dashboard (admin) | 3649:6918, 3649:7187 | `/admin/dashboard` | partial (tanpa Figma) |
| Tambah Artikel 1 | 1755:1618 | `/admin/artikel/baru` | partial (tanpa Figma) |
| Tambah Artikel 2, 3, 4 | 2135:3043, 2135:3442, 2135:2401 | `/admin/artikel/baru` (satu editor, state dilebur) | partial (tanpa Figma) |
| Edit Profil (admin) | 4061:2747 | `/admin/profil/edit` | partial (tanpa Figma) |
| Animation section | 798:5443 | `Reveal` (fade-in saat scroll), hover kartu | partial: tidak dibaca; hanya animasi sederhana |
| Mobile / tablet | - | semua halaman | ekstrapolasi, tidak ada di Figma |

## Pembaruan PART A/B
- Footer: tahun 2024, tiga logo program (MSIB, Infinite Learning, Kampus Merdeka). Tentang Kami: kalimat MSIB Batch 7. Favicon: `web/app/icon.png`.
- Layout seragam di semua route (lihat `web-layout-fixes.md`). Status "partial (tanpa Figma)" pada tabel di atas tetap berlaku: tidak diverifikasi terhadap Figma.

# Figma Fidelity (mobile, Flutter) - Phase 12b

Baseline frame width: **412 dp** (frame Beranda 2339:7724, 412x~1000). Layout is fluid from 280 dp; content max width 560 dp.
Sumber: `docs/figma-export/` KOSONG (tidak ada PNG/SVG, folder `assets/` tanpa berkas). Figma MCP: **1 panggilan** (`get_design_context` Beranda, berhasil, tanpa kegagalan); 3 panggilan sisa tidak dipakai (keluaran sangat besar, batas konteks). Semua selain Beranda: dari bacaan Phase 12a + inventory.

## Sumber token (lib/core/theme/app_theme.dart)
| Token | Nilai | Sumber |
|---|---|---|
| primary #177BCD, background #F6F6F6, field #E8E8E8, text #171A1F, grey #9095A0, greyLight #BCC1CA | - | Figma MCP (Beranda: kotak, search, dot) |
| navy #1A2151, star #FFB91B, success #299722 | - | docs/design-tokens.md (Design System) |
| danger #FF3848, dangerSoft #FFF2F1, onPrimarySoft, titleOnPrimary, hint, googleLabel | - | Figma 12a (Login/Detail), diasumsikan |
| shadow card 0/4/2 25%, header 0/4/4 25% | - | Figma MCP (drop-shadow Container 36, kotak) |
| radius card 16, sheet/banner 28, chip 7, field 10, pill 30, header 16 | - | Figma MCP (corner large/extra-large, tombol 7); field 10 dan pill 30 dari 12a |
| Poppins 15/12/20/30, kaki tab 15, search 14 | - | Figma MCP (Beranda) |
| Rating angka Lato 11 | diganti Poppins 11 | Lato tidak dibundel (keputusan: tidak menambah font) |
| ukuran tombol min 48, search bar 48 (Figma 39) | - | asumsi aksesibilitas; BEDA dari Figma 39 |

## Per layar (Matched / Partial / Unverified / No Figma frame)
| Layar | Status | Catatan |
|---|---|---|
| Home (/home) | Partial | Cocok: header 20/Poppins, kategori 3 kartu, banner rasio 1.55 (316x205), judul kiri + tombol kanan bawah, kartu rekomendasi foto 96 menimpa tepi, baris produk, label tab 15. Beda: search bar 48 (Figma 39), tab bar tanpa ikon SVG Figma (Material icons), ikon bintang Material, rating Poppins (bukan Lato), tab bar tinggi min 64 (Figma 100), kartu produk 'intip' lebar fluid (Figma 176 tetap) |
| Login | Partial | Dibaca Figma di 12a (tidak dibandingkan ulang); logo fluid, tab garis 80% lebar; Google 'G' teks, bukan logo SVG |
| Product detail | Partial | Dibaca Figma di 12a; foto AspectRatio 1.6 (Figma 240 tinggi); galeri tunggal |
| Orders (Pesanan Saya) | Partial | Dibaca Figma di 12a; kartu Menunggu + tab; tab lain sama |
| Welcome, register (3 layar), forgot, category, recommendations, search, cart, checkout, payment, order success, order detail, rejected, review (2), profile (+data, password, email, phone), addresses (+add, kecamatan), help, offline | Unverified | Tanpa ekspor/MCP; hanya responsif. Search/Category/Recommendations memakai komponen Home yang cocok |
| Seller: home/orders, order detail, ship proof, reviews, products (+form, variants), categories, discount, settings, ongkir, payment methods | Unverified | Tanpa ekspor; hanya responsif |
| Shop page, pick location | Unverified | Tidak ada frame di inventory |
| Admin (/admin) | No Figma frame | Dibuat dengan token dan komponen yang sama |

Ringkasan: Matched 0, Partial 4, Unverified ~40, No frame 1.
Tindak lanjut manual: ekspor PNG 2x frame di `docs/export-checklist.md` (prioritas 1 mobile) dan SVG ikon (bintang, tab, Google, chevron) ke `docs/figma-export/assets/`; lalu verifikasi per layar.

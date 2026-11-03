# Keputusan Web (web/)

## Stack dan paket
- `create-next-app` (Next 16.4.3, React 19.3, Tailwind 4, TypeScript, ESLint, App Router, tanpa `src/`, alias `@/*`).
- Paket tambahan: **tidak ada**. Font Poppins + Montserrat lewat `next/font/google` (bawaan Next). Animasi hanya CSS + IntersectionObserver (`components/Reveal.tsx`), tanpa library.
- Token (warna brand `#177bcd`, aksen `#ff8038`, abu `#eee`, teks `#050315`, palet skala dari `docs/design-tokens.md`, ukuran h1-h4) didefinisikan di `@theme` pada `app/globals.css`. Warna brand/aksen diambil dari frame web (bukan dari halaman Design System); skala 50-950 di docs tidak dipakai langsung oleh frame web.

## Batasan penting: kuota Figma MCP habis
Setelah membaca Homepage, Produk, Hubungi Kami, Tentang Kami, dan Artikel (halaman 1) lewat `get_design_context`, plus metadata Artikel halaman 2, semua panggilan Figma MCP ditolak ("tool call limit on the Starter plan"). Akibatnya:
- Detail Artikel (19 varian), Login, Profil, Dashboard, Tambah Artikel 1-4, Edit Profil, dan Artikel halaman 3 **tidak dibaca dari Figma**. Halaman tersebut dibuat dari teks yang tercatat di `docs/figma-inventory.md` dan gaya visual halaman lain: ini perkiraan, bukan pixel-faithful, dan harus ditinjau ulang setelah kuota tersedia.
- Skill `figma-design-to-code` tidak terdaftar sebagai Skill dan tidak ada tool pembaca resource MCP; panduan itu tidak dimuat. Konversi kode referensi dilakukan manual (Tailwind, `next/image`, komponen bersama).
- Tidak ada perbandingan visual dengan screenshot Figma yang ketat; hanya pengecekan kasar terhadap screenshot desain yang dikembalikan saat design context.

## Ambiguitas dan opsi konservatif
- **Responsif**: Figma hanya 1440 desktop. Layout tablet (~768) dan mobile (~375) adalah ekstrapolasi saya (nav menjadi menu hamburger, grid menumpuk, posisi absolut diganti flex/grid). Tidak ada referensi Figma.
- Layout Figma memakai posisi absolut; diterjemahkan ke flex/grid dengan container maks 1440px, sehingga jarak piksel tidak identik.
- Homepage: dipakai frame `Homepage non animate` (2335:7624). Testimoni: 9 kartu, 3 per halaman dengan 3 titik navigasi.
- Produk: "video cara kerja" hanya gambar Pixel 7a + ikon play (tanpa video). Keunggulan: 5 kartu (scroll horizontal).
- Hubungi Kami: jawaban FAQ **tidak ada di Figma** (hanya tombol tertutup); teks jawaban adalah placeholder buatan saya. Opsi "Layanan" di formulir juga karangan. Formulir hanya validasi lokal, tidak mengirim apa pun.
- Tentang Kami: tab Visi/Misi/Tujuan, hanya teks Visi tersedia; Misi/Tujuan menampilkan pesan "belum tersedia". Blok "Developer" (placeholder Unsplash di bawah kartu putih) tidak diimplementasikan, tim sudah lengkap di "Tim Kami". Foto tim memakai crop sederhana (`object-cover`).
- Artikel: judul kartu dipotong seperti di Figma ("...."), judul penuh tidak tersedia; semua kartu berkategori Bisnis seperti di frame, jadi filter Kesehatan/Budidaya menghasilkan hasil kosong. Halaman 3 dari 3 tidak dapat dibaca, sehingga daftar hanya 12 artikel / 2 halaman (Figma menunjukkan "Page x of 3"). Gambar kartu halaman 2 dipetakan ke teks berdasarkan kecocokan visual (Ikan Lele=ikan lele, Perbedaan Air Payau=koi bertuliskan judul, Inovasi=keramba, dan lainnya berdasarkan tebakan: **Mana yang Lebih Bergizi** = pasar ikan, **Purwakarta** = keramba/perahu, **Pokdakan** = foto kelompok).
- Detail Artikel: satu route dinamis `/artikel/[slug]` dengan `generateStaticParams` untuk 13 artikel. Isi badan artikel tidak diambil (hanya judul, tanggal, kategori, gambar, kutipan featured, 4 subjudul artikel utama dari inventory). 19 varian Figma tidak dipetakan satu-satu.

## Admin: auth tiruan
- Semua halaman di bawah `/admin/...`. **Tidak ada autentikasi nyata**: login hanya memeriksa format email dan panjang password >= 6, lalu menyimpan flag di `localStorage`; guard di `AdminShell` hanya redirect sisi klien dan bukan kontrol keamanan. Tidak ada panggilan jaringan, tidak ada secret.
- Postingan (draf/terbit) dan profil disimpan di `localStorage`. **Pertanyaan terbuka untuk backend**: mekanisme auth (sesi/JWT), model artikel, kepemilikan/peran admin, upload gambar artikel, dan API Detail/List artikel.
- Tambah Artikel 1-4 (state berbeda pada Figma) dilebur menjadi satu editor dengan penghitung karakter judul (80), karakter/kata, dan "tersimpan sebagai DRAF".

## Lingkungan
- Port 3000 di mesin ini sudah dipakai proses `postgres.exe` (bukan milik proyek ini, tidak dihentikan), sehingga `npm run dev` sempat melapor server sudah ada dan koneksi ke :3000 direset. Verifikasi dilakukan di `http://localhost:3100` (`next dev -p 3100`).
- Chrome headless punya lebar jendela minimum ~500px; screenshot 375px diambil lewat iframe 375px.

## Aset
Diekspor dari Figma ke `web/public/img/` (home, produk, hubungi, tentang, artikel). Tidak diekspor / kurang: foto Figma halaman 3 artikel, aset Detail Artikel, Login/Profil/Dashboard/Tambah Artikel/Edit Profil (kuota). Video cara kerja (hanya poster). Foto avatar admin tidak ada. Blok Developer (placeholder Unsplash) sengaja tidak dipakai.

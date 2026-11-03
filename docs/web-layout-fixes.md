# Perbaikan Layout Web (PART B)

Hanya konsistensi layout; tidak ada perubahan warna, font, bayangan, animasi, ikon, atau copy (selain PART A).

- `web/app/globals.css`: tambah `.container-page` (max-width 1440, padding 24 / 40 / 80px di mobile / md / lg) dan `.section-y` (padding vertikal 48 / 64 / 80px).
- Header (`Navbar`), `AdminShell`, dan footer memakai `.container-page`, jadi tepi kiri-kanan sama di semua route (sebelumnya padding 79 / 82 / 140 / 186 / 192 / 221px berbeda-beda).
- Footer: satu grid `brand+kontak | Download Aplikasi | link`, kolom rata atas, jadi satu kolom di mobile. Kontak (email/telepon/alamat) satu kolom di bawah `sm` agar email tidak terpecah.
- `/` (`app/page.tsx`): semua section memakai `.container-page` + `.section-y`; blok Testimoni ikut.
- `/produk`: hero, "Cara Kerja", daftar "Keunggulan Produk" (carousel tetap scroll horizontal), dan CTA memakai container dan spasi yang sama.
- `/artikel` + `ArticleList`: hero dan daftar artikel di container yang sama; `/artikel/[slug]` tidak diubah (sudah max-w sendiri).
- `/hubungi-kami` + `Faq` + `ContactForm`: FAQ dibungkus container (kartu tetap), tiga section lain memakai `.container-page` + `.section-y`.
- `/tentang-kami` + `VisiMisi`: section memakai container; kartu "Tim Kami" tanpa max-width sendiri; daftar anggota 2 kolom di `lg` (sebelumnya 3 kolom, nama tertimpa teks), nama `min-w-0 break-words`; "Mitra Kami" tanpa padding khusus 140px.
- Halaman admin: konten ada di `AdminShell` (container sama); `login` tetap kartu terpusat `max-w-[420px]`.

Verifikasi: Edge headless (screenshot di luar repo) di 1440px untuk `/`, `/produk`, `/tentang-kami`; di 390px (viewport iframe asli, karena Edge headless tidak mau lebih sempit dari ~500px) untuk `/tentang-kami`, `/artikel`. Dashboard terkunci login tiruan (tampil "Memuat…" lalu redirect) sehingga hanya ditinjau lewat kode. 768px tidak difoto. Animasi scroll-reveal tidak terpicu di screenshot sehingga beberapa blok tampak kosong di foto (bukan bug layout).

Gate: `npm run lint` bersih, `npm run build` berhasil, semua route 200 di port 3100.
- Phase 4: web favicon is now a white fish on blue rounded square (web/app/icon.png); footer main section is white, IkanKu logo 63->84px (+33%), MSIB 36->54px (+50%), program logos in one centered wrapping flex row.

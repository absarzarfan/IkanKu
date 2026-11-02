# Setup Supabase untuk IkanKu (Phase 12a)

> **Peringatan:** semua SQL di `supabase/` ditulis tanpa akses ke database hidup dan **belum diuji**. Jalankan di proyek pengembangan, bukan produksi, dan periksa setiap error. Gunakan daftar uji RLS di bawah sebelum mempercayai skema ini.

## 1. Buat proyek
1. Buka https://supabase.com/dashboard, buat proyek baru (region terdekat, mis. Singapore).
2. Di **Authentication > Providers > Email**, aktifkan Email. Untuk pengembangan, matikan "Confirm email" agar registrasi langsung masuk (nyalakan kembali untuk produksi).
3. Di **Authentication > URL Configuration**, atur Site URL sesuai kebutuhan reset password (NEEDS CONFIRMATION: deep link aplikasi belum ditentukan).

## 2. Jalankan migrasi (urut)
Buka **SQL Editor**, jalankan isi file satu per satu:
1. `supabase/migrations/0001_schema.sql`
2. `supabase/migrations/0002_functions.sql`
3. `supabase/migrations/0003_rls.sql`
4. `supabase/migrations/0004_storage.sql` (bucket `product-images` + policy; jika ditolak, lihat langkah 5)

## 3. Buat pengguna demo
Di **Authentication > Users > Add user** buat (centang Auto Confirm User), dengan kata sandi kuat milik Anda sendiri (jangan dicommit):
- satu pembeli, satu calon penjual, satu calon admin.
Profil terbentuk otomatis dengan role `buyer` lewat trigger.

## 4. Promosikan penjual dan admin (manual, bukan dari aplikasi)
Ganti email sesuai akun demo Anda. Dijalankan di SQL Editor (berjalan sebagai `postgres`, sehingga lolos penjaga role):
```sql
-- penjual demo
update public.profiles set role = 'seller' where id = (select id from auth.users where email = 'PENJUAL_EMAIL');
-- admin (satu-satunya cara membuat admin)
update public.profiles set role = 'admin'  where id = (select id from auth.users where email = 'ADMIN_EMAIL');
```
Lalu jalankan `supabase/seed.sql` (kategori + produk contoh untuk penjual pertama; toko dibuat bila belum ada). Penjual nyata lewat aplikasi memakai RPC `become_seller(nama_toko)`.

## 5. Bucket storage (jika langkah 2.4 gagal)
**Storage > New bucket**: nama `product-images`, Public ON, batas 2 MB, mime `image/jpeg, image/png, image/webp`. Lalu **Policies**: tambahkan 4 policy seperti di `0004_storage.sql` (select publik; insert/update/delete untuk `authenticated` dengan `public.is_seller()` dan `(storage.foldername(name))[1] = auth.uid()::text`). Aplikasi mengunggah ke `<user_id>/<nama_berkas>`.

## 6. Konfigurasi aplikasi
1. Di **Project Settings > API** salin **Project URL** dan **anon public key** (kunci publik saja).
2. Berkas `flutter_app/dart_defines.json` (tidak masuk git) harus berisi tepat dua kunci:
   ```json
   { "SUPABASE_URL": "https://xxxx.supabase.co", "SUPABASE_ANON_KEY": "<anon public key>" }
   ```
   Contoh kosong: `flutter_app/dart_defines.example.json`.
3. **Jangan pernah** menaruh kunci service role (rahasia server) di aplikasi, repo, atau dokumen. Kunci itu melewati RLS.
4. Jalankan: `cd flutter_app && flutter run --dart-define-from-file=dart_defines.json`. Tanpa berkas/kunci, aplikasi memakai data mock seperti sebelumnya.

## 7. Daftar uji RLS (SQL Editor)
Simulasikan pengguna: ganti `<UID>` dengan id pengguna dari `auth.users`. Blok ini membuat sesi berperan `authenticated`:
```sql
begin;
select set_config('request.jwt.claims', '{"sub":"<UID>","role":"authenticated"}', true);
set local role authenticated;
-- ... jalankan uji di sini ...
rollback;
```
Uji dan hasil yang diharapkan:
1. **Pembeli A tidak membaca pesanan pembeli B:** `select count(*) from public.orders where buyer_id <> '<UID_A>';` harus 0.
2. **Tidak bisa menjadi admin:** `update public.profiles set role = 'admin' where id = '<UID_A>';` harus error `Perubahan role/status/email tidak diizinkan`.
3. **Tidak bisa reaktivasi diri / ubah is_active:** `update public.profiles set is_active = false where id = '<UID_A>';` harus error.
4. **Tidak bisa insert pesanan langsung:** `insert into public.orders (...)` harus ditolak RLS (`new row violates row-level security policy`).
5. **Tidak bisa memesan di bawah harga:** tidak ada parameter harga di `place_order`; kolom `unit_price` pesanan sama dengan harga variasi setelah diskon. Coba ubah harga lewat cart: `update public.cart_items set ...` tidak punya kolom harga. Verifikasi: setelah `select public.place_order('cod','kirim','<ADDR_ID>')`, jalankan `select unit_price from order_items` dan bandingkan dengan `product_variants.price`.
6. **Stok:** pesan qty melebihi stok; harus error `Stok ... tidak cukup` dan tidak ada baris order baru.
7. **Pembeli tidak mengubah status langsung:** `update public.orders set status = 'selesai';` mempengaruhi 0 baris (tidak ada policy update).
8. **Transisi tidak valid:** `select public.update_order_status('<ORDER_ID>', 'selesai');` pada pesanan `menunggu` oleh pembeli harus error `Transisi status ... tidak diizinkan`.
9. **Penjual hanya produk tokonya:** sebagai penjual X, `update public.products set name = 'x' where shop_id <> (select id from public.shops where owner_id = '<UID_X>');` mempengaruhi 0 baris.
10. **Pembeli tidak melihat produk nonaktif:** admin jalankan `select public.admin_set_product_active('<PID>', false);`, lalu sebagai pembeli `select count(*) from public.products where id = '<PID>';` harus 0; penjual tidak bisa mengaktifkannya kembali (error).
11. **Ulasan:** `insert into public.reviews (order_item_id, reviewer_id, rating) ...` pada item pesanan yang belum `selesai` harus ditolak; kedua kali pada item yang sama harus gagal (unique).
12. **Storage:** pembeli (bukan penjual) mengunggah ke `product-images` harus ditolak; penjual ke folder pengguna lain harus ditolak.
13. **Anon:** `set local role anon; select count(*) from public.products;` harus error permission denied.

Catat hasilnya; laporkan setiap uji yang gagal sebelum fase berikutnya.

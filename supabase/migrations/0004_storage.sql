-- Bucket product-images: baca publik; unggah/hapus hanya penjual login di folder miliknya (path diawali auth.uid()).
-- Batas: 2 MB per berkas; mime image/jpeg, image/png, image/webp. BELUM diuji pada database hidup.
-- Jika SQL editor menolak mengubah storage.objects, buat bucket dan policy lewat Dashboard (lihat docs/supabase-setup.md).

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('product-images', 'product-images', true, 2097152, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do update
  set public = excluded.public,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

create policy "product-images public read" on storage.objects for select
  using (bucket_id = 'product-images');

create policy "product-images seller insert" on storage.objects for insert to authenticated
  with check (bucket_id = 'product-images' and public.is_seller()
              and (storage.foldername(name))[1] = auth.uid()::text);

create policy "product-images seller update" on storage.objects for update to authenticated
  using (bucket_id = 'product-images' and public.is_seller() and (storage.foldername(name))[1] = auth.uid()::text)
  with check (bucket_id = 'product-images' and public.is_seller() and (storage.foldername(name))[1] = auth.uid()::text);

create policy "product-images seller delete" on storage.objects for delete to authenticated
  using (bucket_id = 'product-images' and public.is_seller() and (storage.foldername(name))[1] = auth.uid()::text);

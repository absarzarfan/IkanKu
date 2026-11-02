-- Row Level Security di SEMUA tabel. Tabel tanpa policy untuk suatu operasi = operasi itu ditolak.
-- BELUM diuji pada database hidup.

revoke all on all tables in schema public from anon;
revoke all on all sequences in schema public from anon;

alter table public.profiles         enable row level security;
alter table public.addresses        enable row level security;
alter table public.shops            enable row level security;
alter table public.shop_banks       enable row level security;
alter table public.categories       enable row level security;
alter table public.products         enable row level security;
alter table public.product_variants enable row level security;
alter table public.cart_items       enable row level security;
alter table public.orders           enable row level security;
alter table public.order_items      enable row level security;
alter table public.reviews          enable row level security;

-- profiles: baca sendiri atau admin; ubah sendiri (trigger menjaga role/is_active/email); admin boleh ubah.
-- Tidak ada policy insert/delete: baris dibuat trigger auth.users.
create policy profiles_select on public.profiles for select to authenticated
  using (id = auth.uid() or public.is_admin());
create policy profiles_update_own on public.profiles for update to authenticated
  using (id = auth.uid()) with check (id = auth.uid());
create policy profiles_update_admin on public.profiles for update to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- addresses: milik sendiri.
create policy addresses_own on public.addresses for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- shops: toko aktif terbaca semua pengguna login; pemilik/admin melihat toko sendiri.
-- Insert hanya lewat become_seller().
create policy shops_select on public.shops for select to authenticated
  using (is_active or owner_id = auth.uid() or public.is_admin());
create policy shops_update_owner on public.shops for update to authenticated
  using (owner_id = auth.uid() and public.is_seller()) with check (owner_id = auth.uid());
create policy shops_update_admin on public.shops for update to authenticated
  using (public.is_admin()) with check (public.is_admin());

create policy shop_banks_select on public.shop_banks for select to authenticated
  using (exists (select 1 from public.shops s where s.id = shop_id
                 and (s.is_active or s.owner_id = auth.uid() or public.is_admin())));
create policy shop_banks_write on public.shop_banks for all to authenticated
  using (public.is_seller() and exists (select 1 from public.shops s where s.id = shop_id and s.owner_id = auth.uid()))
  with check (public.is_seller() and exists (select 1 from public.shops s where s.id = shop_id and s.owner_id = auth.uid()));

-- categories: semua pengguna login membaca; penjual menambah; hanya admin mengubah/menghapus.
create policy categories_select on public.categories for select to authenticated using (true);
create policy categories_insert on public.categories for insert to authenticated
  with check (public.is_seller() or public.is_admin());
create policy categories_update on public.categories for update to authenticated
  using (public.is_admin()) with check (public.is_admin());
create policy categories_delete on public.categories for delete to authenticated
  using (public.is_admin());

-- products: pembeli hanya produk aktif dari toko aktif; penjual kelola produk tokonya; admin baca semua.
create policy products_select on public.products for select to authenticated using (
  (is_active and exists (select 1 from public.shops s where s.id = shop_id and s.is_active))
  or exists (select 1 from public.shops s where s.id = shop_id and s.owner_id = auth.uid())
  or public.is_admin());
create policy products_insert on public.products for insert to authenticated with check (
  public.is_seller() and exists (select 1 from public.shops s where s.id = shop_id and s.owner_id = auth.uid()));
create policy products_update_owner on public.products for update to authenticated
  using (public.is_seller() and exists (select 1 from public.shops s where s.id = shop_id and s.owner_id = auth.uid()))
  with check (public.is_seller() and exists (select 1 from public.shops s where s.id = shop_id and s.owner_id = auth.uid()));
create policy products_update_admin on public.products for update to authenticated
  using (public.is_admin()) with check (public.is_admin());
create policy products_delete on public.products for delete to authenticated
  using (public.is_seller() and exists (select 1 from public.shops s where s.id = shop_id and s.owner_id = auth.uid()));

-- product_variants: terlihat sejauh produknya terlihat (subquery tunduk pada RLS products).
create policy variants_select on public.product_variants for select to authenticated
  using (exists (select 1 from public.products p where p.id = product_id));
create policy variants_write on public.product_variants for all to authenticated
  using (public.is_seller() and exists (
    select 1 from public.products p join public.shops s on s.id = p.shop_id
    where p.id = product_id and s.owner_id = auth.uid()))
  with check (public.is_seller() and exists (
    select 1 from public.products p join public.shops s on s.id = p.shop_id
    where p.id = product_id and s.owner_id = auth.uid()));

-- cart_items: milik sendiri; varian harus terlihat.
create policy cart_own on public.cart_items for all to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid() and exists (select 1 from public.product_variants v where v.id = variant_id));

-- orders: pembeli, pemilik toko, atau admin membaca. TIDAK ada insert/update/delete langsung:
-- buat lewat place_order(), ubah lewat update_order_status()/set_payment_proof()/set_payment_status().
create policy orders_select on public.orders for select to authenticated using (
  buyer_id = auth.uid()
  or (public.is_seller() and exists (select 1 from public.shops s where s.id = shop_id and s.owner_id = auth.uid()))
  or public.is_admin());

create policy order_items_select on public.order_items for select to authenticated
  using (exists (select 1 from public.orders o where o.id = order_id));

-- reviews: terbaca semua pengguna login (ulasan produk). Insert hanya untuk item pesanan selesai milik pemberi ulasan.
create policy reviews_select on public.reviews for select to authenticated using (true);
create policy reviews_insert on public.reviews for insert to authenticated with check (
  reviewer_id = auth.uid()
  and exists (
    select 1 from public.order_items oi join public.orders o on o.id = oi.order_id
    where oi.id = order_item_id and o.buyer_id = auth.uid()
      and (o.status = 'selesai' or (o.status = 'diarsipkan' and o.archived_from = 'selesai'))));
create policy reviews_update_own on public.reviews for update to authenticated
  using (reviewer_id = auth.uid()) with check (reviewer_id = auth.uid());
create policy reviews_delete on public.reviews for delete to authenticated
  using (reviewer_id = auth.uid() or public.is_admin());

-- Untuk pengguna login: akses tabel mengikuti policy di atas.
grant select, insert, update, delete on all tables in schema public to authenticated;
grant select on public.product_stats to authenticated;

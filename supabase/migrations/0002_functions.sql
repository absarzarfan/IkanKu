-- Fungsi bantu, trigger keamanan, dan RPC. BELUM diuji pada database hidup.

create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select exists (select 1 from public.profiles where id = auth.uid() and role = 'admin' and is_active);
$$;

create or replace function public.is_seller() returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select exists (select 1 from public.profiles where id = auth.uid() and role = 'seller' and is_active);
$$;

-- Pemanggil istimewa: admin aplikasi, service role, atau SQL editor/migrasi (postgres).
-- SECURITY INVOKER (sengaja): current_user harus peran pemanggil, bukan pemilik fungsi.
-- Di dalam fungsi security definer (mis. become_seller) current_user = postgres, sehingga lolos.
create or replace function public.is_privileged() returns boolean
language sql stable set search_path = public, pg_temp as $$
  select public.is_admin()
      or coalesce(auth.role(), '') = 'service_role'
      or current_user in ('postgres', 'supabase_admin');
$$;

-- Pengguna baru SELALU pembeli; metadata role diabaikan.
create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  insert into public.profiles (id, role, full_name, email, phone)
  values (new.id, 'buyer',
          coalesce(new.raw_user_meta_data ->> 'full_name', ''),
          coalesce(new.email, ''),
          coalesce(new.raw_user_meta_data ->> 'phone', ''));
  return new;
end $$;

create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

create or replace function public.sync_profile_email() returns trigger
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  update public.profiles set email = coalesce(new.email, '') where id = new.id;
  return new;
end $$;

create trigger on_auth_user_email_changed after update of email on auth.users
  for each row when (old.email is distinct from new.email) execute function public.sync_profile_email();

-- Pemilik tidak boleh mengubah role, is_active, email, id.
create or replace function public.guard_profile() returns trigger
language plpgsql set search_path = public, pg_temp as $$
begin
  if public.is_privileged() then return new; end if;
  if new.id is distinct from old.id
     or new.role is distinct from old.role
     or new.is_active is distinct from old.is_active
     or new.email is distinct from old.email then
    raise exception 'Perubahan role/status/email tidak diizinkan' using errcode = '42501';
  end if;
  return new;
end $$;

create trigger profiles_guard before update on public.profiles
  for each row execute function public.guard_profile();

create or replace function public.guard_shop() returns trigger
language plpgsql set search_path = public, pg_temp as $$
begin
  if public.is_privileged() then return new; end if;
  if new.owner_id is distinct from old.owner_id or new.is_active is distinct from old.is_active then
    raise exception 'Perubahan pemilik/status toko tidak diizinkan' using errcode = '42501';
  end if;
  return new;
end $$;

create trigger shops_guard before update on public.shops
  for each row execute function public.guard_shop();

create or replace function public.guard_product() returns trigger
language plpgsql set search_path = public, pg_temp as $$
begin
  if public.is_privileged() then return new; end if;
  if tg_op = 'INSERT' then
    new.disabled_by_admin := false;
    return new;
  end if;
  if new.disabled_by_admin is distinct from old.disabled_by_admin
     or new.shop_id is distinct from old.shop_id
     or (new.is_active and old.disabled_by_admin) then
    raise exception 'Produk dinonaktifkan admin atau perubahan tidak diizinkan' using errcode = '42501';
  end if;
  return new;
end $$;

create trigger products_guard before insert or update on public.products
  for each row execute function public.guard_product();

-- Seller upgrade: satu-satunya jalur pembeli menjadi penjual.
create or replace function public.become_seller(p_shop_name text) returns uuid
language plpgsql security definer set search_path = public, pg_temp as $$
declare
  uid uuid := auth.uid();
  p public.profiles;
  sid uuid;
begin
  if uid is null then raise exception 'Belum login' using errcode = '42501'; end if;
  if coalesce(trim(p_shop_name), '') = '' then raise exception 'Nama toko wajib diisi' using errcode = '22023'; end if;
  select * into p from public.profiles where id = uid for update;
  if not found or not p.is_active then raise exception 'Akun tidak aktif' using errcode = '42501'; end if;
  if p.role = 'admin' then raise exception 'Admin tidak dapat menjadi penjual' using errcode = '42501'; end if;
  update public.profiles set role = 'seller' where id = uid;
  insert into public.shops (owner_id, name) values (uid, trim(p_shop_name))
    on conflict (owner_id) do update set name = excluded.name
    returning id into sid;
  return sid;
end $$;

-- Harga setelah diskon (sama dengan Product.discounted di Dart).
create or replace function public.discounted_price(p_price integer, p_discount integer) returns integer
language sql immutable set search_path = public, pg_temp as $$
  select round(p_price * (100 - p_discount) / 100.0)::integer;
$$;

-- Satu RPC membuat pesanan: harga dari tabel, stok dicek, keranjang dikosongkan, satu transaksi.
-- Keranjang lintas toko dipecah menjadi satu pesanan per toko. Mengembalikan id pesanan.
create or replace function public.place_order(
  p_payment_method  public.payment_method,
  p_shipping_method public.shipping_method,
  p_address_id      uuid,
  p_note            text default '',
  p_cart_item_ids   uuid[] default null
) returns setof uuid
language plpgsql security definer set search_path = public, pg_temp as $$
declare
  uid uuid := auth.uid();
  prof public.profiles;
  addr public.addresses;
  shop public.shops;
  r record;
  oid uuid;
  subtotal integer;
  fee integer;
begin
  if uid is null then raise exception 'Belum login' using errcode = '42501'; end if;
  select * into prof from public.profiles where id = uid;
  if not found or not prof.is_active then raise exception 'Akun tidak aktif' using errcode = '42501'; end if;
  select * into addr from public.addresses where id = p_address_id and user_id = uid;
  if not found then raise exception 'Alamat tidak valid' using errcode = '22023'; end if;

  if not exists (select 1 from public.cart_items where user_id = uid and (p_cart_item_ids is null or id = any (p_cart_item_ids))) then
    raise exception 'Keranjang kosong' using errcode = '22023';
  end if;

  -- Kunci variasi (urut id) lalu validasi stok dan status.
  for r in
    select c.qty, v.stock, p.name, p.is_active as p_active, s.is_active as s_active
    from public.cart_items c
    join public.product_variants v on v.id = c.variant_id
    join public.products p on p.id = v.product_id
    join public.shops s on s.id = p.shop_id
    where c.user_id = uid and (p_cart_item_ids is null or c.id = any (p_cart_item_ids))
    order by v.id
    for update of v
  loop
    if not r.p_active or not r.s_active then raise exception 'Produk % tidak tersedia', r.name using errcode = '22023'; end if;
    if r.stock < r.qty then raise exception 'Stok % tidak cukup', r.name using errcode = '22023'; end if;
  end loop;

  for shop in
    select s.* from public.shops s
    where s.id in (
      select p.shop_id from public.cart_items c
      join public.product_variants v on v.id = c.variant_id
      join public.products p on p.id = v.product_id
      where c.user_id = uid and (p_cart_item_ids is null or c.id = any (p_cart_item_ids)))
    order by s.id
  loop
    if shop.owner_id = uid then raise exception 'Tidak dapat membeli produk sendiri' using errcode = '22023'; end if;
    if p_payment_method = 'transfer' and not shop.transfer_enabled then raise exception 'Toko % tidak menerima transfer', shop.name using errcode = '22023'; end if;
    if p_payment_method = 'cod' and not shop.cod_enabled then raise exception 'Toko % tidak menerima COD', shop.name using errcode = '22023'; end if;
    if p_shipping_method = 'kirim' and not shop.delivery_enabled then raise exception 'Toko % tidak melayani pengiriman', shop.name using errcode = '22023'; end if;
    if p_shipping_method = 'jemput' and not shop.pickup_enabled then raise exception 'Toko % tidak melayani jemput', shop.name using errcode = '22023'; end if;

    select coalesce(sum(public.discounted_price(v.price, p.discount_percent) * c.qty), 0) into subtotal
    from public.cart_items c
    join public.product_variants v on v.id = c.variant_id
    join public.products p on p.id = v.product_id
    where c.user_id = uid and p.shop_id = shop.id and (p_cart_item_ids is null or c.id = any (p_cart_item_ids));

    fee := case
      when p_shipping_method = 'jemput' then 0
      when shop.free_shipping_min > 0 and subtotal >= shop.free_shipping_min then 0
      else shop.shipping_fee end;

    insert into public.orders (buyer_id, shop_id, buyer_name, payment_method, shipping_method, shipping_fee,
                               ship_recipient, ship_phone, ship_street, ship_kecamatan, ship_city, ship_postal_code, note)
    values (uid, shop.id, prof.full_name, p_payment_method, p_shipping_method, fee,
            addr.recipient, addr.phone, addr.street, addr.kecamatan, addr.city, addr.postal_code, coalesce(p_note, ''))
    returning id into oid;

    insert into public.order_items (order_id, product_id, variant_id, product_name, variant_label, unit_price, quantity)
    select oid, p.id, v.id, p.name, 'Berat ' || v.weight || ', Isi ' || v.count || ' ekor',
           public.discounted_price(v.price, p.discount_percent), c.qty
    from public.cart_items c
    join public.product_variants v on v.id = c.variant_id
    join public.products p on p.id = v.product_id
    where c.user_id = uid and p.shop_id = shop.id and (p_cart_item_ids is null or c.id = any (p_cart_item_ids));

    update public.product_variants v set stock = v.stock - c.qty
    from public.cart_items c, public.products p
    where c.variant_id = v.id and c.user_id = uid and p.id = v.product_id and p.shop_id = shop.id
      and (p_cart_item_ids is null or c.id = any (p_cart_item_ids));

    return next oid;
  end loop;

  delete from public.cart_items where user_id = uid and (p_cart_item_ids is null or id = any (p_cart_item_ids));
end $$;

-- Mengembalikan stok item pesanan (batal / arsip dari ditolak). Hanya dipanggil dari RPC lain.
create or replace function public.restock_order(p_order_id uuid) returns void
language sql security definer set search_path = public, pg_temp as $$
  update public.product_variants v set stock = v.stock + i.quantity
  from public.order_items i where i.order_id = p_order_id and i.variant_id = v.id;
$$;

-- Perubahan status: hanya transisi valid oleh peran yang tepat.
create or replace function public.update_order_status(
  p_order_id uuid, p_new public.order_status,
  p_reason text default null, p_photo_ref text default null, p_note text default null
) returns public.orders
language plpgsql security definer set search_path = public, pg_temp as $$
declare
  uid uuid := auth.uid();
  o public.orders;
  is_buyer boolean;
  is_shop_owner boolean;
begin
  if uid is null then raise exception 'Belum login' using errcode = '42501'; end if;
  select * into o from public.orders where id = p_order_id for update;
  if not found then raise exception 'Pesanan tidak ditemukan' using errcode = '22023'; end if;
  is_buyer := o.buyer_id = uid;
  is_shop_owner := exists (select 1 from public.shops where id = o.shop_id and owner_id = uid) and public.is_seller();
  if not (is_buyer or is_shop_owner) then raise exception 'Bukan pesanan Anda' using errcode = '42501'; end if;

  if o.status = 'menunggu' and p_new = 'dikemas' and is_shop_owner then
    if o.payment_method = 'transfer' and o.payment_proof_ref is null then
      raise exception 'Bukti pembayaran belum diunggah' using errcode = '22023';
    end if;
    update public.orders set status = 'dikemas',
      payment_status = case when payment_method = 'transfer' then 'terverifikasi' else payment_status end
      where id = o.id;
  elsif o.status = 'menunggu' and p_new = 'ditolak' and is_shop_owner then
    update public.orders set status = 'ditolak',
      reject_reason = coalesce(nullif(trim(p_reason), ''), 'Pesanan ditolak penjual') where id = o.id;
  elsif o.status = 'menunggu' and p_new = 'dibatalkan' and is_buyer then
    update public.orders set status = 'dibatalkan' where id = o.id;
    perform public.restock_order(o.id);
  elsif o.status = 'dikemas' and p_new = 'dikirim' and is_shop_owner then
    if coalesce(p_photo_ref, '') = '' then raise exception 'Bukti pengiriman wajib' using errcode = '22023'; end if;
    update public.orders set status = 'dikirim', shipment_photo_ref = p_photo_ref,
      shipment_note = coalesce(p_note, '') where id = o.id;
  elsif o.status = 'dikirim' and p_new = 'selesai' and is_buyer then
    update public.orders set status = 'selesai' where id = o.id;
  elsif o.status = 'ditolak' and p_new = 'menunggu' and is_buyer then
    if o.payment_method = 'transfer' and o.payment_proof_ref is null then
      raise exception 'Bukti pembayaran belum diunggah' using errcode = '22023';
    end if;
    update public.orders set status = 'menunggu', reject_reason = null where id = o.id;
  elsif p_new = 'diarsipkan' and o.status in ('selesai', 'ditolak', 'dibatalkan') then
    update public.orders set status = 'diarsipkan', archived_from = o.status where id = o.id;
    if o.status = 'ditolak' then perform public.restock_order(o.id); end if;
  else
    raise exception 'Transisi status % -> % tidak diizinkan', o.status, p_new using errcode = '22023';
  end if;

  select * into o from public.orders where id = p_order_id;
  return o;
end $$;

-- Pembeli menyimpan referensi bukti bayar; status pembayaran menjadi menunggu_verifikasi.
create or replace function public.set_payment_proof(p_order_id uuid, p_ref text) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if coalesce(p_ref, '') = '' then raise exception 'Referensi bukti kosong' using errcode = '22023'; end if;
  update public.orders set payment_proof_ref = p_ref, payment_status = 'menunggu_verifikasi'
   where id = p_order_id and buyer_id = auth.uid() and status in ('menunggu', 'ditolak') and payment_method = 'transfer';
  if not found then raise exception 'Tidak dapat mengunggah bukti' using errcode = '42501'; end if;
end $$;

-- Penjual menandai status pembayaran manual (mis. COD lunas).
create or replace function public.set_payment_status(p_order_id uuid, p_status public.payment_status) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  update public.orders o set payment_status = p_status
   where o.id = p_order_id and public.is_seller()
     and exists (select 1 from public.shops s where s.id = o.shop_id and s.owner_id = auth.uid());
  if not found then raise exception 'Tidak diizinkan' using errcode = '42501'; end if;
end $$;

-- Ulasan: product_id dan nama pemberi ulasan diisi server, bukan klien.
create or replace function public.fill_review_product() returns trigger
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  select product_id into new.product_id from public.order_items where id = new.order_item_id;
  select full_name into new.reviewer_name from public.profiles where id = new.reviewer_id;
  new.reviewer_name := coalesce(new.reviewer_name, '');
  return new;
end $$;

create trigger reviews_fill before insert on public.reviews
  for each row execute function public.fill_review_product();

create or replace function public.admin_set_user_active(p_user_id uuid, p_active boolean) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if not public.is_admin() then raise exception 'Hanya admin' using errcode = '42501'; end if;
  if p_user_id = auth.uid() then raise exception 'Tidak dapat menonaktifkan diri sendiri' using errcode = '22023'; end if;
  update public.profiles set is_active = p_active where id = p_user_id;
  update public.shops set is_active = p_active where owner_id = p_user_id;
end $$;

create or replace function public.admin_set_product_active(p_product_id uuid, p_active boolean) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if not public.is_admin() then raise exception 'Hanya admin' using errcode = '42501'; end if;
  update public.products set is_active = p_active, disabled_by_admin = not p_active where id = p_product_id;
end $$;

-- Hak eksekusi: hanya pengguna login; anon dan publik tidak boleh memanggil.
revoke all on function
  public.become_seller(text),
  public.place_order(public.payment_method, public.shipping_method, uuid, text, uuid[]),
  public.update_order_status(uuid, public.order_status, text, text, text),
  public.set_payment_proof(uuid, text),
  public.set_payment_status(uuid, public.payment_status),
  public.admin_set_user_active(uuid, boolean),
  public.admin_set_product_active(uuid, boolean),
  public.restock_order(uuid),
  public.is_admin(), public.is_seller(), public.is_privileged()
  from public, anon, authenticated;

grant execute on function
  public.become_seller(text),
  public.place_order(public.payment_method, public.shipping_method, uuid, text, uuid[]),
  public.update_order_status(uuid, public.order_status, text, text, text),
  public.set_payment_proof(uuid, text),
  public.set_payment_status(uuid, public.payment_status),
  public.admin_set_user_active(uuid, boolean),
  public.admin_set_product_active(uuid, boolean),
  public.is_admin(), public.is_seller(), public.is_privileged()
  to authenticated;

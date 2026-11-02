-- Data contoh UNTUK PENGEMBANGAN saja. Tanpa data pribadi dan tanpa insert ke auth.users.
-- Jalankan setelah migrasi 0001-0004 dan setelah satu pengguna didaftarkan lalu dipromosikan jadi penjual
-- (lihat docs/supabase-setup.md). Aman dijalankan ulang. BELUM diuji pada database hidup.

insert into public.categories (name) values ('Air Tawar'), ('Laut'), ('Hias'), ('Bibit')
on conflict (name) do nothing;

do $$
declare
  seller_id uuid;
  shop uuid;
  prod uuid;
  rec record;
begin
  select id into seller_id from public.profiles where role = 'seller' order by created_at limit 1;
  if seller_id is null then
    raise notice 'Belum ada penjual: kategori dibuat, produk contoh dilewati.';
    return;
  end if;

  insert into public.shops (owner_id, name) values (seller_id, 'Toko Contoh IkanKu')
  on conflict (owner_id) do nothing;
  select id into shop from public.shops where owner_id = seller_id;

  for rec in
    select * from (values
      ('Ikan Nila',   'Air Tawar', 'Ikan nila segar, cocok untuk bakar, sup, atau pepes.', 31000),
      ('Ikan Discus', 'Hias',      'Ikan hias discus.',                                      100000),
      ('Ikan Cupang', 'Hias',      'Ikan cupang dengan ekor dan sirip cantik.',              40000),
      ('Ikan Salmon', 'Laut',      'Salmon segar, kaya omega-3.',                            90000),
      ('Gurita',      'Laut',      'Gurita segar hasil tangkapan harian.',                   75000),
      ('Bibit Nila',  'Bibit',     'Bibit nila ukuran 3-5 cm.',                              5000)
    ) as t(name, category, description, base)
  loop
    if exists (select 1 from public.products where shop_id = shop and name = rec.name) then continue; end if;
    insert into public.products (shop_id, category_id, name, description)
    values (shop, (select id from public.categories where name = rec.category), rec.name, rec.description)
    returning id into prod;
    insert into public.product_variants (product_id, weight, count, price, stock) values
      (prod, '500 gr', 2, round(rec.base * 0.55), 40),
      (prod, '1 Kg',   2, rec.base,               60),
      (prod, '1 Kg',   4, round(rec.base * 1.8),  20);
  end loop;
end $$;

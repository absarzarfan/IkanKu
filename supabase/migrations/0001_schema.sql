-- IkanKu: skema dasar. Jalankan berurutan 0001 -> 0004. BELUM diuji pada database hidup.

create extension if not exists pgcrypto;

create type public.user_role      as enum ('buyer', 'seller', 'admin');
create type public.order_status   as enum ('menunggu', 'dikemas', 'dikirim', 'selesai', 'ditolak', 'dibatalkan', 'diarsipkan');
create type public.payment_method as enum ('transfer', 'cod');
create type public.payment_status as enum ('belum_bayar', 'menunggu_verifikasi', 'terverifikasi');
create type public.shipping_method as enum ('kirim', 'jemput');

create or replace function public.set_updated_at() returns trigger
language plpgsql set search_path = public, pg_temp as $$
begin
  new.updated_at := now();
  return new;
end $$;

create table public.profiles (
  id          uuid primary key references auth.users (id) on delete cascade,
  role        public.user_role not null default 'buyer',
  full_name   text not null default '',
  email       text not null default '',
  phone       text not null default '',
  avatar_url  text,
  is_active   boolean not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create table public.addresses (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references public.profiles (id) on delete cascade,
  recipient   text not null,
  phone       text not null,
  street      text not null,
  kecamatan   text not null,
  city        text not null,
  postal_code text not null,
  is_primary  boolean not null default false,
  created_at  timestamptz not null default now()
);
create index addresses_user_idx on public.addresses (user_id);

create table public.shops (
  id                 uuid primary key default gen_random_uuid(),
  owner_id           uuid not null unique references public.profiles (id) on delete cascade,
  name               text not null,
  shipping_fee       integer not null default 0 check (shipping_fee >= 0),
  free_shipping_min  integer not null default 0 check (free_shipping_min >= 0),
  transfer_enabled   boolean not null default true,
  cod_enabled        boolean not null default true,
  delivery_enabled   boolean not null default true,
  pickup_enabled     boolean not null default true,
  is_active          boolean not null default true,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);

create table public.shop_banks (
  id       uuid primary key default gen_random_uuid(),
  shop_id  uuid not null references public.shops (id) on delete cascade,
  bank     text not null,
  number   text not null,
  holder   text not null
);
create index shop_banks_shop_idx on public.shop_banks (shop_id);

create table public.categories (
  id          uuid primary key default gen_random_uuid(),
  name        text not null unique,
  created_at  timestamptz not null default now()
);

create table public.products (
  id                 uuid primary key default gen_random_uuid(),
  shop_id            uuid not null references public.shops (id) on delete cascade,
  category_id        uuid references public.categories (id) on delete set null,
  name               text not null,
  description        text not null default '',
  image_url          text,
  discount_percent   integer not null default 0 check (discount_percent between 0 and 90),
  is_active          boolean not null default true,
  disabled_by_admin  boolean not null default false,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);
create index products_shop_idx on public.products (shop_id);
create index products_category_idx on public.products (category_id);
create index products_name_idx on public.products (lower(name));

create table public.product_variants (
  id          uuid primary key default gen_random_uuid(),
  product_id  uuid not null references public.products (id) on delete cascade,
  weight      text not null,
  count       integer not null default 1 check (count > 0),
  price       integer not null check (price >= 0),
  stock       integer not null default 0 check (stock >= 0)
);
create index product_variants_product_idx on public.product_variants (product_id);

create table public.cart_items (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references public.profiles (id) on delete cascade,
  variant_id  uuid not null references public.product_variants (id) on delete cascade,
  qty         integer not null check (qty > 0),
  created_at  timestamptz not null default now(),
  unique (user_id, variant_id)
);

create sequence public.order_code_seq start 1100;

create table public.orders (
  id                 uuid primary key default gen_random_uuid(),
  code               text not null unique default ('INV-' || nextval('public.order_code_seq')),
  buyer_id           uuid not null references public.profiles (id),
  shop_id            uuid not null references public.shops (id),
  buyer_name         text not null,
  status             public.order_status not null default 'menunggu',
  payment_method     public.payment_method not null,
  payment_status     public.payment_status not null default 'belum_bayar',
  shipping_method    public.shipping_method not null,
  shipping_fee       integer not null default 0 check (shipping_fee >= 0),
  ship_recipient     text not null,
  ship_phone         text not null,
  ship_street        text not null,
  ship_kecamatan     text not null,
  ship_city          text not null,
  ship_postal_code   text not null,
  note               text not null default '',
  reject_reason      text,
  payment_proof_ref  text,
  shipment_photo_ref text,
  shipment_note      text not null default '',
  archived_from      public.order_status,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);
create index orders_buyer_idx on public.orders (buyer_id);
create index orders_shop_idx on public.orders (shop_id);
create index orders_status_idx on public.orders (status);

create table public.order_items (
  id            uuid primary key default gen_random_uuid(),
  order_id      uuid not null references public.orders (id) on delete cascade,
  product_id    uuid references public.products (id) on delete set null,
  variant_id    uuid references public.product_variants (id) on delete set null,
  product_name  text not null,
  variant_label text not null,
  unit_price    integer not null check (unit_price >= 0),
  quantity      integer not null check (quantity > 0)
);
create index order_items_order_idx on public.order_items (order_id);

create table public.reviews (
  id             uuid primary key default gen_random_uuid(),
  order_item_id  uuid not null unique references public.order_items (id) on delete cascade,
  reviewer_id    uuid not null references public.profiles (id) on delete cascade,
  reviewer_name  text not null default '',
  product_id     uuid references public.products (id) on delete set null,
  rating         integer not null check (rating between 1 and 5),
  comment        text not null default '',
  created_at     timestamptz not null default now()
);
create index reviews_product_idx on public.reviews (product_id);

create trigger profiles_updated  before update on public.profiles  for each row execute function public.set_updated_at();
create trigger shops_updated     before update on public.shops     for each row execute function public.set_updated_at();
create trigger products_updated  before update on public.products  for each row execute function public.set_updated_at();
create trigger orders_updated    before update on public.orders    for each row execute function public.set_updated_at();

-- Rating rata-rata per produk; mengikuti RLS pemanggil.
create view public.product_stats with (security_invoker = true) as
  select product_id, round(avg(rating)::numeric, 1) as avg_rating, count(*)::int as review_count
  from public.reviews where product_id is not null group by product_id;

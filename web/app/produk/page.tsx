import Image from "next/image";
import type { Metadata } from "next";
import SiteShell from "@/components/SiteShell";
import Reveal from "@/components/Reveal";

export const metadata: Metadata = { title: "Produk - IkanKu" };

const adv = [
  { t: "Transparansi Harga & Produk Yang Detail", img: "k1.png" },
  { t: "Sistem Review Yang Terpercaya", img: "k2.png" },
  { t: "Varietas dan Kualitas Produk Yang Terjamin", img: "k3.png" },
  { t: "Pengalaman Pengguna (UX) Yang Ramah & Mudah", img: "k4.png" },
  { t: "Opsi Pembayaran Yang Fleksibel", img: "k5.png" },
];

export default function ProdukPage() {
  return (
    <SiteShell>
      {/* Hero */}
      <section className="relative isolate overflow-hidden">
        <Image src="/img/produk/hero.png" alt="" fill priority sizes="100vw" className="-z-10 object-cover" />
        <div className="absolute inset-0 -z-10 bg-gradient-to-b from-brand/0 from-20% to-brand" />
        <div className="mx-auto flex max-w-[1440px] flex-col items-center px-6 pb-16 pt-32 text-center lg:pt-[360px]">
          <h1 className="max-w-[800px] text-4xl font-extrabold leading-tight text-white md:text-[60px]">Dapatkan Ikan Segar Dengan Mudah Dimana Saja</h1>
          <div className="mt-16 flex flex-col items-center gap-10 sm:flex-row sm:gap-[60px] lg:mt-[100px]">
            <div className="relative h-[300px] w-[260px] overflow-hidden rounded-t-3xl shadow-[4px_0_4px_rgba(0,0,0,.25)] lg:h-[410px] lg:w-[335px]">
              <Image src="/img/home/phone.png" alt="Aplikasi IkanKu" fill sizes="335px" className="object-cover object-top" />
            </div>
            <div className="flex flex-col items-center gap-10">
              <Image src="/img/produk/qr.png" alt="Kode QR unduh aplikasi" width={200} height={200} className="rounded-lg bg-white" />
              <a href="#" className="inline-flex items-center rounded-lg bg-accent px-[42px] py-[7px] text-white transition hover:brightness-95">Unduh Aplikasi</a>
            </div>
          </div>
        </div>
      </section>

      {/* Cara kerja */}
      <section className="bg-white px-6 py-16 lg:py-[120px]">
        <h2 className="text-center text-3xl font-bold text-brand md:text-[46px]">Cara Kerja Aplikasi Kami</h2>
        <Reveal className="relative mx-auto mt-14 aspect-[970/456] w-full max-w-[970px] overflow-hidden rounded">
          <Image src="/img/produk/pixel7a.png" alt="Video cara kerja aplikasi IkanKu" fill sizes="970px" className="object-cover" />
          <div className="absolute inset-0 bg-gradient-to-b from-black/25 to-black/50" />
          <Image src="/img/produk/play.svg" alt="Putar video" width={68} height={71} className="absolute left-1/2 top-1/2 h-auto w-12 -translate-x-1/2 -translate-y-1/2 md:w-[68px]" />
        </Reveal>
      </section>

      {/* Keunggulan */}
      <section className="bg-brand py-12">
        <h2 className="text-center text-3xl font-bold text-white md:text-[46px]">Keunggulan Produk</h2>
        <ul className="mt-16 flex snap-x gap-[29px] overflow-x-auto px-6 pb-4 lg:px-0" aria-label="Keunggulan produk">
          {adv.map((a) => (
            <li key={a.t} className="relative h-[400px] w-[min(460px,85vw)] shrink-0 snap-center rounded-2xl bg-gradient-to-b from-white from-50% to-accent first:lg:ml-0">
              <div className="absolute left-[39px] top-[53px] h-[300px] w-[141px] overflow-hidden rounded-xl shadow-[6px_4px_4px_rgba(0,0,0,.25)]">
                <Image src={`/img/produk/${a.img}`} alt="" fill sizes="141px" className="object-cover" />
              </div>
              <p className="absolute left-[230px] right-4 top-[90px] flex min-h-[84px] items-center justify-center text-center font-montserrat text-xl font-bold text-black">{a.t}</p>
            </li>
          ))}
        </ul>
      </section>

      <section className="bg-white px-6 py-16 text-center">
        <p className="text-2xl md:text-[34px]">Mari Bergabung Bersama Kami</p>
        <a href="#" className="mt-8 inline-flex h-12 items-center rounded-lg bg-accent px-[42px] text-white transition hover:brightness-95">Unduh Aplikasi</a>
      </section>
    </SiteShell>
  );
}

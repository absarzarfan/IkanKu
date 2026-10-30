import Image from "next/image";
import type { Metadata } from "next";
import SiteShell from "@/components/SiteShell";
import Reveal from "@/components/Reveal";
import SectionHeader from "@/components/SectionHeader";
import CtaBand from "@/components/CtaBand";
import { Bubbles, Wave } from "@/components/kit";
import { IconChip, type IconName } from "@/components/icons";

export const metadata: Metadata = { title: "Produk - IkanKu" };

const adv: { t: string; img: string; icon: IconName }[] = [
  { t: "Transparansi Harga & Produk Yang Detail", img: "k1.png", icon: "tag" },
  { t: "Sistem Review Yang Terpercaya", img: "k2.png", icon: "star" },
  { t: "Varietas dan Kualitas Produk Yang Terjamin", img: "k3.png", icon: "layers" },
  { t: "Pengalaman Pengguna (UX) Yang Ramah & Mudah", img: "k4.png", icon: "smile" },
  { t: "Opsi Pembayaran Yang Fleksibel", img: "k5.png", icon: "card" },
];

export default function ProdukPage() {
  return (
    <SiteShell>
      {/* Hero */}
      <section className="curve-b relative isolate overflow-hidden">
        <Image src="/img/produk/hero.jpg" alt="" fill priority sizes="100vw" className="-z-10 object-cover" />
        <div className="absolute inset-0 -z-10 bg-gradient-to-b from-brand/0 from-20% to-brand" />
        <div className="container-page flex flex-col items-center pb-16 pt-32 text-center lg:pt-[360px]">
          <h1 className="max-w-[800px] text-4xl font-extrabold leading-tight text-white md:text-display">Dapatkan Ikan Segar Dengan Mudah Dimana Saja</h1>
          <div className="mt-16 flex flex-col items-center gap-10 sm:flex-row sm:gap-[60px] lg:mt-[100px]">
            <div className="relative h-[300px] w-[260px] overflow-hidden rounded-t-3xl shadow-[4px_0_4px_rgba(0,0,0,.25)] lg:h-[410px] lg:w-[335px]">
              <Image src="/img/home/phone.png" alt="Aplikasi IkanKu" fill sizes="335px" className="object-cover object-top" />
            </div>
            <div className="flex flex-col items-center gap-10">
              <Image src="/img/produk/qr.png" alt="Kode QR unduh aplikasi" width={200} height={200} className="rounded-lg bg-white" />
              <a href="#" className="inline-flex items-center btn-cta rounded-lg px-[42px] py-[7px] text-white">Unduh Aplikasi</a>
            </div>
          </div>
        </div>
      </section>

      {/* Cara kerja */}
      <section className="band-white section-y"><div className="container-page">
        <SectionHeader eyebrow="Panduan" title="Cara Kerja Aplikasi Kami" />
        <Reveal className="relative mx-auto mt-14 aspect-[970/456] w-full max-w-[970px] overflow-hidden rounded-3xl shadow-[0_24px_48px_-24px_rgba(23,123,205,.5)]">
          <Image src="/img/produk/pixel7a.png" alt="Video cara kerja aplikasi IkanKu" fill sizes="970px" className="object-cover" />
          <div className="absolute inset-0 bg-gradient-to-b from-black/25 to-black/50" />
          <Image src="/img/produk/play.svg" alt="Putar video" width={68} height={71} className="absolute left-1/2 top-1/2 h-auto w-12 -translate-x-1/2 -translate-y-1/2 md:w-[68px]" />
        </Reveal>
        </div>
      </section>

      {/* Keunggulan */}
      <section className="band-blue section-y">
        <Bubbles />
        <SectionHeader tone="dark" eyebrow="Produk" title="Keunggulan Produk" />
        <ul className="container-page scrollbar-thin mt-16 flex snap-x snap-mandatory gap-6 overflow-x-auto scroll-pl-6 pb-4 min-[900px]:grid min-[900px]:grid-cols-6 min-[900px]:overflow-visible" aria-label="Keunggulan produk">
          {adv.map((a, i) => (
            <li key={a.t} className={`${i === 3 ? "min-[900px]:col-start-2 " : ""}min-[900px]:col-span-2 card-lift flex h-[360px] w-[min(380px,78vw)] shrink-0 snap-start items-center gap-4 rounded-2xl border border-black/10 bg-white p-5 shadow-sm min-[900px]:w-auto min-[900px]:min-w-0 min-[900px]:gap-5`}>
              <div className="relative aspect-[141/300] w-[38%] max-w-[141px] shrink-0 overflow-hidden rounded-xl shadow-[6px_4px_4px_rgba(0,0,0,.25)]">
                <Image src={`/img/produk/${a.img}`} alt="" fill sizes="141px" className="object-cover" />
              </div>
              <div className="flex min-w-0 flex-1 flex-col items-center gap-4">
                <IconChip name={a.icon} />
                <p className="text-balance break-words text-center font-montserrat text-lg font-bold text-ink lg:text-xl">{a.t}</p>
              </div>
            </li>
          ))}
        </ul>
      <div aria-hidden="true" className="absolute inset-x-0 bottom-0"><Wave color="var(--color-surface)" /></div>
      </section>

      <CtaBand />
    </SiteShell>
  );
}

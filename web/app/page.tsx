import Image from "next/image";
import Link from "next/link";
import SiteShell from "@/components/SiteShell";
import Reveal from "@/components/Reveal";
import Testimonials from "@/components/Testimonials";
import SectionHeader from "@/components/SectionHeader";
import CtaBand from "@/components/CtaBand";
import { Bubbles, Wave } from "@/components/kit";
import HeadlineCarousel from "@/components/HeadlineCarousel";
import { Eyebrow } from "@/components/kit";
import { articleUi } from "@/data/article-ui";
import { latestArticles } from "@/lib/articles";
import { IconChip, type IconName } from "@/components/icons";

const steps: { t: string; d: string; icon: IconName }[] = [
  { t: "Ikan Segar Langsung ke Rumah Anda", icon: "truck", d: "Dapatkan ikan segar langsung dari peternakan lokal yang diantar langsung ke rumah Anda. Tanpa perantara, hanya ikan berkualitas tinggi untuk kebutuhan harian Anda." },
  { t: "Mudah dan Praktis", icon: "phoneApp", d: "Cukup dengan beberapa ketukan, Anda bisa menjelajahi, memilih, dan memesan ikan air tawar favorit kapan saja dan di mana saja. Belanja cepat dan mudah, langsung dari genggaman tangan Anda." },
  { t: "Jaminan Kesegaran", icon: "shield", d: "Kami menjamin bahwa ikan yang Anda pesan dipilih dengan cermat dan diproses agar tetap segar hingga sampai ke tangan Anda." },
];

const features: { icon: IconName; t: string; d: string }[] = [
  { icon: "fish", t: "Beragam Kategori Ikan", d: "Temukan berbagai jenis ikan air tawar dengan mudah, mulai dari ikan konsumsi hingga ikan hias, semuanya tersedia dengan deskripsi lengkap." },
  { icon: "cart", t: "Pembelian Mudah", d: "Nikmati proses belanja yang simpel dengan fitur keranjang, checkout, dan opsi pengiriman yang terintegrasi untuk pengalaman yang nyaman." },
  { icon: "truck", t: "Pelacakan Pesanan", d: "Pantau status pesanan Anda, mulai dari belum dibayar, dikemas, hingga dikirim dan selesai." },
  { icon: "star", t: "Ulasan Produk", d: "Berikan rating dan ulasan produk untuk membantu pembeli lain dan meningkatkan kualitas layanan penjual." },
];

export default function Home() {
  return (
    <SiteShell>
      {/* Hero */}
      <section className="band-blue curve-b overflow-hidden">
        <div className="container-page grid items-center gap-10 pt-12 md:grid-cols-[1.1fr_0.9fr] lg:pt-0">
          <div>
            <h1 className="hero-in text-4xl font-bold leading-[1.15] md:text-h1 lg:text-display">Belanja Ikan Mudah<br />Dengan IkanKu</h1>
            <a href="#" style={{ "--d": "80ms" } as React.CSSProperties} className="hero-in btn-cta mt-8 inline-flex h-12 items-center rounded-lg px-[42px] text-base text-white">Download on Google Play</a>
          </div>
          <div className="relative mx-auto h-[320px] w-[260px] shrink-0 md:ml-auto md:mr-0 lg:mt-10 lg:h-[420px] lg:w-[335px]">
            <div aria-hidden className="absolute -right-6 top-6 h-[85%] w-[85%] rounded-[40px] border border-white/25 bg-white/10" />
            <div className="relative h-full w-full overflow-hidden rounded-t-3xl shadow-[0_18px_40px_-18px_rgba(5,3,21,.55)]">
              <Image src="/img/home/phone.png" alt="Tampilan aplikasi IkanKu" fill sizes="335px" className="object-cover object-top" priority />
            </div>
          </div>
        </div>
      </section>

      {/* Berita Utama (carousel could replace the hero on request, see docs/decisions.md) */}
      <section className="band-white section-y">
        <div className="container-page">
          <Eyebrow>{articleUi.pageTitle}</Eyebrow>
          <h2 className="mb-8 text-3xl font-bold text-brand md:text-h2">{articleUi.headlines}</h2>
          <HeadlineCarousel items={latestArticles(5)} />
          <p className="mt-6 text-center"><Link href="/artikel" className="btn-outline inline-flex min-h-11 items-center rounded-lg border border-black px-5 py-2 text-sm">{articleUi.allArticles}</Link></p>
        </div>
      </section>

      {/* Apa itu */}
      <section className="band-tint section-y">
        <div className="container-page flex flex-col items-center gap-12 md:flex-row lg:gap-[88px]">
          <Reveal className="relative w-full max-w-[460px] shrink-0">
            <div aria-hidden className="absolute -bottom-4 -left-4 h-full w-full rounded-3xl bg-brand/15" />
            <div className="relative aspect-[419/300] overflow-hidden rounded-3xl shadow-[0_18px_40px_-20px_rgba(23,123,205,.5)]">
              <Image src="/img/home/fish-box.jpg" alt="Ikan segar dalam boks" fill sizes="460px" className="object-cover" />
            </div>
          </Reveal>
          <Reveal delay={80}>
            <h2 className="text-3xl font-bold text-brand md:text-h1 md:leading-[1.15]">Apa itu IkanKu?</h2>
            <div className="mt-4 h-1 w-14 rounded bg-[image:var(--grad-primary)]" />
            <p className="mt-8 max-w-[540px] text-lg text-body">Cari ikan segar tanpa ribet? IkanKu solusinya! Temukan ikan air tawar berkualitas langsung dari petani dengan harga terbaik, hanya lewat aplikasi. Pesan sekarang, dan nikmati kemudahan mendapatkan ikan segar di depan pintu Anda!</p>
          </Reveal>
        </div>
      </section>

      {/* Kenapa */}
      <section className="band-blue py-14 lg:py-20">
        <Bubbles />
        <div className="container-page">
          <SectionHeader tone="dark" title="Kenapa IkanKu?" />
          <div className="mt-14 flex flex-col items-center gap-10 md:flex-row md:items-start lg:gap-[96px]">
            <div className="relative h-[420px] w-[282px] shrink-0 overflow-hidden rounded-3xl shadow-[0_18px_40px_-18px_rgba(5,3,21,.55)] lg:h-[560px]">
              <Image src="/img/home/phone.png" alt="Aplikasi IkanKu" fill sizes="282px" className="object-cover" />
            </div>
            <ol className="flex flex-1 flex-col gap-5">
              {steps.map((s, i) => (
                <Reveal key={s.t} delay={i * 60}>
                  <li className="glass-card relative p-6 pl-[88px]">
                    <IconChip name={s.icon} tone="glass" size={44} className="absolute left-6 top-6" />
                    <h3 className="text-h3 font-semibold">{s.t}</h3>
                    <p className="mt-3 max-w-[581px] text-white">{s.d}</p>
                  </li>
                </Reveal>
              ))}
            </ol>
          </div>
        </div>
      <div aria-hidden="true" className="absolute inset-x-0 bottom-0"><Wave color="#fff" /></div>
      </section>

      {/* Fitur */}
      <section className="band-white section-y">
        <div className="container-page">
          <SectionHeader eyebrow="Aplikasi" title="Fitur Unggulan" intro="Temukan kemudahan belanja ikan air tawar dengan fitur lengkap dan pengalaman belanja yang cepat serta aman." />
          <div className="mt-12 grid gap-6 md:grid-cols-2">
            {features.map((f, i) => (
              <Reveal key={f.t} delay={(i % 2) * 60} className="h-full">
                <div className="card card-lift flex h-full min-h-[220px] flex-col items-start gap-5 p-7 sm:flex-row sm:items-center">
                  <IconChip name={f.icon} size={52} />
                  <div>
                    <h3 className="text-h3 font-semibold text-ink">{f.t}</h3>
                    <p className="mt-3 max-w-[340px] text-body">{f.d}</p>
                  </div>
                </div>
              </Reveal>
            ))}
          </div>
        </div>
      </section>

      <div className="band-tint"><Testimonials /></div>

      <CtaBand />
    </SiteShell>
  );
}

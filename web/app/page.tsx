import Image from "next/image";
import SiteShell from "@/components/SiteShell";
import Reveal from "@/components/Reveal";
import Testimonials from "@/components/Testimonials";

const steps = [
  { t: "Ikan Segar Langsung ke Rumah Anda", d: "Dapatkan ikan segar langsung dari peternakan lokal yang diantar langsung ke rumah Anda. Tanpa perantara, hanya ikan berkualitas tinggi untuk kebutuhan harian Anda." },
  { t: "Mudah dan Praktis", d: "Cukup dengan beberapa ketukan, Anda bisa menjelajahi, memilih, dan memesan ikan air tawar favorit kapan saja dan di mana saja. Belanja cepat dan mudah, langsung dari genggaman tangan Anda." },
  { t: "Jaminan Kesegaran", d: "Kami menjamin bahwa ikan yang Anda pesan dipilih dengan cermat dan diproses agar tetap segar hingga sampai ke tangan Anda." },
];

const features = [
  { icon: "ic-fish.svg", t: "Beragam Kategori Ikan", d: "Temukan berbagai jenis ikan air tawar dengan mudah, mulai dari ikan konsumsi hingga ikan hias, semuanya tersedia dengan deskripsi lengkap." },
  { icon: "ic-basket.svg", t: "Pembelian Mudah", d: "Nikmati proses belanja yang simpel dengan fitur keranjang, checkout, dan opsi pengiriman yang terintegrasi untuk pengalaman yang nyaman." },
  { icon: "ic-truck.svg", t: "Pelacakan Pesanan", d: "Pantau status pesanan Anda, mulai dari belum dibayar, dikemas, hingga dikirim dan selesai." },
  { icon: "ic-review.svg", t: "Ulasan Produk", d: "Berikan rating dan ulasan produk untuk membantu pembeli lain dan meningkatkan kualitas layanan penjual." },
];

export default function Home() {
  return (
    <SiteShell>
      {/* Hero */}
      <section className="bg-brand">
        <div className="mx-auto flex max-w-[1440px] flex-col items-center gap-8 px-6 pt-12 md:flex-row md:justify-between lg:px-[186px] lg:pt-0">
          <div className="text-white">
            <h1 className="text-3xl leading-[1.5] md:text-[46px] md:leading-[79px]">Belanja Ikan Mudah<br />Dengan IkanKu</h1>
            <a href="#" className="mt-6 inline-flex h-10 items-center rounded-lg bg-accent px-[42px] text-base transition hover:brightness-95">Download on Google Play</a>
          </div>
          <div className="relative h-[300px] w-[260px] shrink-0 overflow-hidden rounded-t-3xl shadow-[4px_0_4px_rgba(0,0,0,.25)] lg:mt-6 lg:h-[380px] lg:w-[325px]">
            <Image src="/img/home/phone.png" alt="Tampilan aplikasi IkanKu" fill sizes="325px" className="object-cover object-top" priority />
          </div>
        </div>
      </section>

      {/* Apa itu */}
      <section className="mx-auto flex max-w-[1440px] flex-col items-center gap-10 px-6 py-16 md:flex-row lg:gap-[68px] lg:px-[186px] lg:py-[60px]">
        <Reveal className="relative h-[240px] w-full max-w-[419px] shrink-0 overflow-hidden rounded-3xl">
          <Image src="/img/home/fish-box.png" alt="Ikan segar dalam boks" fill sizes="419px" className="object-cover" />
        </Reveal>
        <Reveal>
          <h2 className="text-3xl text-brand md:text-[46px]">Apa itu IkanKu?</h2>
          <p className="mt-8 max-w-[526px] text-justify text-lg">Cari ikan segar tanpa ribet? IkanKu solusinya! Temukan ikan air tawar berkualitas langsung dari petani dengan harga terbaik, hanya lewat aplikasi. Pesan sekarang, dan nikmati kemudahan mendapatkan ikan segar di depan pintu Anda!</p>
        </Reveal>
      </section>

      {/* Kenapa */}
      <section className="bg-brand py-12 text-white lg:py-10">
        <div className="mx-auto max-w-[1440px] px-6 lg:px-[221px]">
          <h2 className="text-center text-3xl font-bold md:text-[46px]">Kenapa IkanKu?</h2>
          <div className="mt-12 flex flex-col items-center gap-10 md:flex-row md:items-start lg:gap-[135px]">
            <div className="relative h-[420px] w-[282px] shrink-0 overflow-hidden rounded-3xl shadow-[4px_4px_4px_rgba(0,0,0,.25)] lg:h-[604px]">
              <Image src="/img/home/phone.png" alt="Aplikasi IkanKu" fill sizes="282px" className="object-cover" />
            </div>
            <ol className="flex flex-col gap-10 lg:gap-[56px]">
              {steps.map((s, i) => (
                <li key={s.t} className="relative pl-14">
                  <span className="absolute left-0 top-0 flex h-[30px] w-[30px] items-center justify-center rounded-full bg-accent text-[22px] font-bold leading-none">{i + 1}</span>
                  <h3 className="text-[22px] font-bold">{s.t}</h3>
                  <p className="mt-3 max-w-[581px] text-justify">{s.d}</p>
                </li>
              ))}
            </ol>
          </div>
        </div>
      </section>

      {/* Fitur */}
      <section className="mx-auto max-w-[1440px] px-6 py-16 lg:px-[192px]">
        <h2 className="text-center text-3xl font-bold text-brand md:text-[46px]">Fitur Unggulan</h2>
        <p className="mx-auto mt-8 max-w-[582px] text-center">Temukan kemudahan belanja ikan air tawar dengan fitur lengkap dan pengalaman belanja yang cepat serta aman.</p>
        <div className="mt-12 grid gap-[14px] md:grid-cols-2">
          {features.map((f) => (
            <Reveal key={f.t} className="flex min-h-[240px] flex-col items-start gap-4 sm:flex-row sm:items-center sm:gap-6 rounded-2xl bg-white p-6 lg:pl-9 lg:pr-6">
              <Image src={`/img/home/${f.icon}`} alt="" width={100} height={100} className="shrink-0" />
              <div>
                <h3 className="text-[22px] font-bold text-muted">{f.t}</h3>
                <p className="mt-4 max-w-[315px]">{f.d}</p>
              </div>
            </Reveal>
          ))}
        </div>
      </section>

      <Testimonials />

      {/* CTA */}
      <section className="bg-surface-2">
        <div className="mx-auto flex max-w-[1440px] flex-col items-center justify-between gap-4 px-6 py-8 text-center sm:flex-row sm:text-left lg:px-[79px]">
          <p className="text-2xl lg:text-4xl">Mari Bergabung Bersama Kami</p>
          <a href="#" className="inline-flex h-12 items-center rounded-lg bg-accent px-[42px] text-white transition hover:brightness-95 lg:mr-[156px]">Unduh Aplikasi</a>
        </div>
      </section>
    </SiteShell>
  );
}

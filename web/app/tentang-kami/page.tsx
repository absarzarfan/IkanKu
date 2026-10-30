import Image from "next/image";
import type { Metadata } from "next";
import SiteShell from "@/components/SiteShell";
import Reveal from "@/components/Reveal";
import VisiMisi from "@/components/VisiMisi";

export const metadata: Metadata = { title: "Tentang Kami - IkanKu" };

const teams = [
  {
    role: "Hustler & Scrum Master",
    desc: "Sebagai Hustler dan Scrum Master di proyek IkanKu, mereka memimpin tim dengan efektif, memastikan setiap tahapan berjalan lancar, serta menghadirkan solusi inovatif untuk marketplace ikan tawar. Fokus utama mereka adalah mendukung ekonomi lokal dan memudahkan petani ikan dalam memasarkan produk.",
    people: [
      { n: "Surya Fahriandi", i: "surya.png" },
      { n: "Mohamad Feby", i: "feby.png" },
      { n: "Naufal Fadhilah", i: "naufal.png" },
    ],
  },
  {
    role: "Designer",
    desc: "Para desainer berbakat yang berpokus pada User Experience (UX) dan User Interface (UI). Dengan pemahaman mendalam tentang kebutuhan pengguna, mereka merancang antar muka yang intuitif dan estetis untuk memberikan pengalaman terbaik dalam menggunakan aplikasi ini.",
    people: [
      { n: "Dicky Aryadi", i: "dicky.png" },
      { n: "Hafid Daris F", i: "hafid.png" },
      { n: "Ririn Fitri Wulandari", i: "ririn.png" },
      { n: "Miftahul Fazra", i: "miftahul.png" },
    ],
  },
  {
    role: "Programer",
    desc: "Tim developer atau programer yang memiliki keahlian dalam bidang pengembangan web dan aplikasi mobile. Mereka memastikan bahwa setiap fitur bekerja dengan optimal, memprioritaskan kecepatan, kemanan, dan kemudahan penggunaan aplikasi.",
    people: [
      { n: "Muhammad Dzakwan Naufal", i: "dzakwan.png" },
      { n: "Andi", i: "andi.png" },
      { n: "Muhammad Dzaky Naufal", i: "dzaky.png" },
      { n: "Zia Djulyanza", i: "zia.png" },
      { n: "Absar R Zarfan", i: "absar.png" },
    ],
  },
];

export default function TentangKamiPage() {
  return (
    <SiteShell>
      <section className="relative isolate h-[320px] overflow-hidden md:h-[700px]">
        <Image src="/img/tentang/hero.png" alt="" fill priority sizes="100vw" className="-z-10 object-cover" />
        <div className="absolute inset-0 -z-10 bg-gradient-to-b from-transparent from-40% to-brand" />
      </section>

      <section className="container-page section-y text-center">
        <h1 className="text-3xl font-bold leading-[52px] text-brand md:text-[45px]">Marketplace Ikan Tawar Inovatif<br />Visi Misi dan Tujuan Kami</h1>
        <p className="mx-auto mt-8 max-w-[670px]">Dengan fokus kepada kebutuhan pengguna, kami berkomitmen menghadirkan solusi inovatif yang meningkatkan nilai jual ikan air tawar, mendukung pertumbuhan ekonomi lokal dan kualitas di setiap transaksi. Kesuksesan anda dalam mendapatkan produk ikan segar adalah pencapaian tertinggi kami.</p>
        <p className="mx-auto mt-4 max-w-[670px]">Tim IkanKu dipertemukan melalui program Magang dan Studi Independen Bersertifikat (MSIB) Batch 7 di Infinite Learning.</p>
      </section>

      <VisiMisi />

      <section className="bg-brand section-y">
        <div className="container-page"><div className="rounded-3xl bg-white px-6 py-12 md:px-12">
          <h2 className="mb-10 text-center text-3xl font-bold text-brand md:text-[46px]">Tim Kami</h2>
          <div className="space-y-14">
            {teams.map((t) => (
              <Reveal key={t.role}>
                <h3 className="mb-6 text-2xl md:text-[32px] md:leading-[40px]">{t.role}</h3>
                <div className="grid gap-8 md:grid-cols-2 md:gap-0">
                  <ul className="grid grid-cols-2 gap-x-6 gap-y-6 pr-4 sm:grid-cols-3 md:grid-cols-2">
                    {t.people.map((p) => (
                      <li key={p.n} className="flex flex-col gap-2 lg:flex-row lg:gap-4">
                        <Image src={`/img/tentang/${p.i}`} alt={p.n} width={117} height={127} className="h-[127px] w-[117px] shrink-0 rounded object-cover" />
                        <span className="min-w-0 break-words text-base font-medium text-black/80">{p.n}</span>
                      </li>
                    ))}
                  </ul>
                  <p className="border-t border-black pt-6 md:border-l md:border-t-0 md:pl-10 md:pt-0">{t.desc}</p>
                </div>
              </Reveal>
            ))}
          </div>
        </div></div>
      </section>

      <section className="container-page section-y flex flex-col items-center gap-10 md:flex-row md:justify-between">
        <h2 className="text-5xl font-bold leading-[1.2] text-brand md:w-[240px] md:text-[72px] md:tracking-[-2px]">Mitra Kami</h2>
        <Reveal className="w-full max-w-[630px] rounded-2xl bg-brand p-7 text-white">
          <div className="flex flex-col items-center gap-4 sm:flex-row">
            <Image src="/img/tentang/tibelat.png" alt="Tibelat Farm" width={191} height={150} className="h-[150px] w-[191px] rounded object-cover" />
            <p className="flex-1 text-center text-xl font-bold">Tibelat Farm - Batam</p>
          </div>
          <p className="mt-6 text-justify text-sm">Tibelat Farm adalah salah satu mitra kami yang berlokasi di Batam. Sebagai usaha budidaya ikan tawar terkemuka, Tibelat Farm berkomitmen untuk menyediakan ikan berkualitas tinggi dengan praktik budidaya yang ramah lingkungan. Dengan fasilitas modern dan tim yang berpengalaman, Tibelat Farm memastikan bahwa setiap ikan yang dihasilkan memenuhi standar mutu terbaik. Kami bangga bermitra dengan Tibelat Farm dalam mendukung sektor perikanan yang berkelanjutan.</p>
        </Reveal>
      </section>
    </SiteShell>
  );
}

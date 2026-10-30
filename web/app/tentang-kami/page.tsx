import Image from "next/image";
import type { Metadata } from "next";
import SiteShell from "@/components/SiteShell";
import Reveal from "@/components/Reveal";
import VisiMisi from "@/components/VisiMisi";
import { existsSync } from "node:fs";
import { join } from "node:path";
import { contact } from "@/data/contact";
import { membersOf, roles } from "@/data/team";

export const metadata: Metadata = { title: "Tentang Kami - IkanKu" };

const photoExists = (src: string) => existsSync(join(process.cwd(), "public", src));
const initials = (n: string) => n.split(" ").filter(Boolean).slice(0, 2).map((w) => w[0]).join("").toUpperCase();

export default function TentangKamiPage() {
  return (
    <SiteShell>
      <section className="relative isolate h-[320px] overflow-hidden md:h-[700px]">
        <Image src="/img/tentang/hero.png" alt="" fill priority sizes="100vw" className="-z-10 object-cover" />
        <div className="absolute inset-0 -z-10 bg-gradient-to-b from-transparent from-40% to-brand" />
      </section>

      <section className="container-page section-y text-center">
        <h1 className="text-3xl font-bold leading-[52px] text-brand md:text-[45px]">Marketplace Ikan Tawar Inovatif<br />Visi Misi dan Tujuan Kami</h1>
        <p className="mx-auto mt-8 max-w-[670px]">Dengan fokus kepada kebutuhan pengguna, kami berkomitmen menghadirkan solusi inovatif yang meningkatkan nilai jual ikan air tawar, mendukung pertumbuhan ekonomi lokal dan kualitas di setiap transaksi. Kesuksesan Anda dalam mendapatkan produk ikan segar adalah pencapaian tertinggi kami.</p>
        <p className="mx-auto mt-4 max-w-[670px]">Tim IkanKu dipertemukan melalui program Magang dan Studi Independen Bersertifikat (MSIB) Batch 7 di Infinite Learning.</p>
      </section>

      <VisiMisi />

      <section id="tim-kami" className="scroll-mt-20 bg-brand surface-brand py-3 lg:scroll-mt-24">
        <div className="container-page"><div className="rounded-3xl bg-white px-4 py-3 md:px-8">
          <h2 className="mb-2 text-center text-3xl font-bold text-brand md:text-[34px]">Tim Kami</h2>
          <div className="space-y-[clamp(6px,1vh,16px)]">
            {roles.map((r) => (
              <div key={r.role}>
                <div className="mb-1.5 flex flex-wrap items-baseline gap-x-3">
                  <h3 className="text-lg font-semibold">{r.role}</h3>
                  <p className="text-sm text-black/60">{r.desc}</p>
                </div>
                <ul className="grid grid-cols-2 gap-3 sm:grid-cols-3 md:grid-cols-4 xl:grid-cols-6">
                  {membersOf(r.role).map((p) => (
                    <li key={p.name} className="card-lift flex flex-col items-center rounded-2xl px-3 py-2.5 text-center text-white" style={{ backgroundImage: "var(--grad-primary)" }}>
                      <div className="relative shrink-0 overflow-hidden rounded-full ring-[3px] ring-white" style={{ width: "clamp(48px, 6vh, 88px)", height: "clamp(48px, 6vh, 88px)" }}>
                        {photoExists(p.photo) ? (
                          <Image src={p.photo} alt={p.name} fill sizes="96px" className="object-cover" style={{ objectPosition: p.focus ?? "50% 20%" }} />
                        ) : (
                          <span aria-hidden className="flex h-full w-full items-center justify-center bg-white text-xl font-semibold text-brand">{initials(p.name)}</span>
                        )}
                      </div>
                      <p className="mt-2 line-clamp-2 min-h-[2.5rem] text-sm font-semibold leading-5">{p.name}</p>
                      <span className="mt-1 rounded-full bg-white/15 px-2.5 py-0.5 text-xs text-white/85">{p.role}</span>
                    </li>
                  ))}
                </ul>
              </div>
            ))}
          </div>
        </div></div>
      </section>

      <section className="container-page section-y flex flex-col items-center gap-10 md:flex-row md:justify-between">
        <h2 className="text-5xl font-bold leading-[1.2] text-brand md:w-[240px] md:text-[72px] md:tracking-[-2px]">Mitra Kami</h2>
        <Reveal className="w-full max-w-[630px] rounded-2xl bg-brand surface-brand p-7 text-white">
          <div className="flex flex-col items-center gap-4 sm:flex-row">
            <Image src="/img/tentang/tibelat.png" alt="Tibelat Farm" width={191} height={150} className="h-[150px] w-[191px] rounded object-cover" />
            <p className="flex-1 text-center text-xl font-bold">Tibelat Farm - Batam</p>
          </div>
          <p className="mt-6 text-justify text-sm">Tibelat Farm adalah salah satu mitra kami yang berlokasi di Batam. Sebagai usaha budidaya ikan tawar terkemuka, Tibelat Farm berkomitmen untuk menyediakan ikan berkualitas tinggi dengan praktik budidaya yang ramah lingkungan. Dengan fasilitas modern dan tim yang berpengalaman, Tibelat Farm memastikan bahwa setiap ikan yang dihasilkan memenuhi standar mutu terbaik. Kami bangga bermitra dengan Tibelat Farm dalam mendukung sektor perikanan yang berkelanjutan.</p>
        </Reveal>
      </section>

      <section className="container-page section-y">
        <div className="rounded-2xl bg-white p-6 md:p-10">
          <h2 className="text-3xl font-bold text-brand md:text-[34px]">Kontak</h2>
          <p className="mt-4 text-xl font-semibold">{contact.institution}</p>
          <p className="text-sm text-black/70">{contact.tagline}</p>
          <dl className="mt-6 grid gap-6 sm:grid-cols-2">
            <div><dt className="font-bold text-brand">Alamat</dt><dd className="mt-2">{contact.address}</dd></div>
            <div><dt className="font-bold text-brand">Telepon</dt><dd className="mt-2"><a href={contact.phoneHref} className="hover:text-brand">{contact.phone}</a></dd></div>
            <div><dt className="font-bold text-brand">Fax</dt><dd className="mt-2">{contact.fax}</dd></div>
            <div><dt className="font-bold text-brand">Email</dt><dd className="mt-2"><a href={contact.emailHref} className="hover:text-brand">{contact.email}</a></dd></div>
          </dl>
        </div>
      </section>
    </SiteShell>
  );
}

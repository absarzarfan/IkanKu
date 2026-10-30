import Image from "next/image";
import type { Metadata } from "next";
import SiteShell from "@/components/SiteShell";
import Reveal from "@/components/Reveal";
import VisiMisi from "@/components/VisiMisi";
import { existsSync } from "node:fs";
import { join } from "node:path";
import { contact } from "@/data/contact";
import { roles, team } from "@/data/team";

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

      <section className="bg-brand section-y">
        <div className="container-page"><div className="rounded-3xl bg-white px-6 py-12 md:px-12">
          <h2 className="mb-10 text-center text-3xl font-bold text-brand md:text-[46px]">Tim Kami</h2>
          <div className="space-y-14">
            {roles.map((r) => (
              <Reveal key={r.role}>
                <h3 className="text-2xl md:text-[32px]">{r.role}</h3>
                <p className="mt-3 text-black/80">{r.desc}</p>
                <ul className="mt-6 grid grid-cols-1 gap-6 sm:grid-cols-2 xl:grid-cols-4 lg:grid-cols-3">
                  {team.filter((p) => p.role === r.role).map((p) => (
                    <li key={p.name} className="card-lift flex h-full flex-col rounded-2xl border border-black/10 bg-white p-4 shadow-sm">
                      <div className="relative aspect-square w-full overflow-hidden rounded-xl bg-surface">
                        {photoExists(p.photo) ? (
                          <Image src={p.photo} alt={p.name} fill sizes="(min-width:1280px) 280px, (min-width:640px) 45vw, 90vw" className="object-cover" />
                        ) : (
                          <span aria-hidden className="flex h-full w-full items-center justify-center text-4xl font-semibold text-brand" style={{ backgroundImage: "var(--grad-primary)", color: "#fff" }}>{initials(p.name)}</span>
                        )}
                      </div>
                      <p className="mt-4 font-semibold text-black/90">{p.name}</p>
                      <span className="mt-2 w-fit rounded-full px-3 py-1 text-sm text-brand" style={{ background: "color-mix(in srgb, var(--color-brand) 12%, white)" }}>{p.role}</span>
                      {p.bio && <p className="mt-3 text-sm text-black/70">{p.bio}</p>}
                    </li>
                  ))}
                </ul>
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

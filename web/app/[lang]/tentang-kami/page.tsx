import Image from "next/image";
import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { pageMetadata } from "@/lib/seo";
import { getDictionary, hasLocale } from "@/i18n";
import SiteShell from "@/components/SiteShell";
import Reveal from "@/components/Reveal";
import SectionHeader from "@/components/SectionHeader";
import VisiMisi from "@/components/VisiMisi";
import { existsSync } from "node:fs";
import { join } from "node:path";
import { buildPartners } from "@/data/partners";
import { buildVisiMisi } from "@/data/visi-misi";
import { membersOf, roles } from "@/data/team";

export async function generateMetadata({ params }: PageProps<"/[lang]/tentang-kami">): Promise<Metadata> {
  const { lang } = await params;
  if (!hasLocale(lang)) return {};
  return pageMetadata(lang, "/tentang-kami", getDictionary(lang).meta.tentang);
}

const photoExists = (src: string) => existsSync(join(process.cwd(), "public", src));
const initials = (n: string) => n.split(" ").filter(Boolean).slice(0, 2).map((w) => w[0]).join("").toUpperCase();

export default async function TentangKamiPage({ params }: PageProps<"/[lang]/tentang-kami">) {
  const { lang } = await params;
  if (!hasLocale(lang)) notFound();
  const d = getDictionary(lang);
  const a = d.about;
  const partners = buildPartners(d);
  return (
    <SiteShell lang={lang}>
      <section className="curve-b relative isolate h-[320px] overflow-hidden md:h-[640px]">
        <Image src="/img/tentang/hero.png" alt="" fill priority sizes="100vw" className="-z-10 object-cover" />
        <div className="absolute inset-0 -z-10 bg-gradient-to-b from-transparent from-40% to-brand-dark/80" />
      </section>

      <section className="tint-soft"><div className="container-page section-y text-center">
        <h1 className="text-3xl font-bold leading-[1.25] text-brand md:text-h1">{a.title1}<br />{a.title2}</h1>
        <p className="mx-auto mt-8 max-w-[670px]">{a.intro1}</p>
        <p className="mx-auto mt-4 max-w-[670px]">{a.intro2}</p>
      </div></section>

      <VisiMisi tabs={buildVisiMisi(d)} ui={{ tablistLabel: d.visiMisi.tablistLabel, heading: d.visiMisi.heading }} appAlt={d.visiMisi.appAlt} />

      <section id="tim-kami" className="scroll-mt-20 bg-brand surface-brand py-3 lg:scroll-mt-24">
        <div className="container-page"><div className="rounded-3xl bg-white px-4 py-3 md:px-8">
          <h2 className="mb-2 text-center text-3xl font-bold text-brand md:text-h2">{a.teamTitle}</h2>
          <div className="space-y-[clamp(6px,1vh,16px)]">
            {roles.map((role) => (
              <div key={role}>
                <div className="mb-1.5 flex flex-wrap items-baseline gap-x-3">
                  <h3 className="text-lg font-semibold">{role}</h3>
                  <p className="text-sm text-muted">{a.roles[role]}</p>
                </div>
                <ul className="grid grid-cols-2 gap-3 sm:grid-cols-3 md:grid-cols-4 xl:grid-cols-6">
                  {membersOf(role).map((p) => (
                    <li key={p.name} className="card-lift team-card flex flex-col items-center rounded-2xl px-3 py-2.5 text-center text-white" style={{ backgroundImage: "var(--grad-primary)" }}>
                      <div className="team-photo relative shrink-0 overflow-hidden rounded-full ring-[3px] ring-white" style={{ width: "clamp(48px, 6vh, 88px)", height: "clamp(48px, 6vh, 88px)" }}>
                        {photoExists(p.photo) ? (
                          <Image src={p.photo} alt={p.name} fill sizes="96px" className="object-cover" style={{ objectPosition: p.focus ?? "50% 20%", transform: p.zoom ? `scale(${p.zoom})` : undefined, transformOrigin: p.origin ?? "50% 50%" }} />
                        ) : (
                          <span aria-hidden className="flex h-full w-full items-center justify-center bg-white text-xl font-semibold text-brand">{initials(p.name)}</span>
                        )}
                      </div>
                      <p className="mt-2 line-clamp-2 min-h-[2.5rem] text-sm font-semibold leading-5">{p.name}</p>
                      <span className="mt-1 rounded-full bg-white/15 px-2.5 py-0.5 text-xs text-white">{p.role}</span>
                    </li>
                  ))}
                </ul>
              </div>
            ))}
          </div>
        </div></div>
      </section>

      <section id="mitra-kami" className="container-page section-y scroll-mt-20">
        <SectionHeader eyebrow={a.partnersEyebrow} title={a.partnersTitle} />
        <ul className={`mt-10 grid gap-6 ${partners.length > 1 ? "md:grid-cols-2" : ""}`}>
          {partners.map((pt, n) => (
            <li key={pt.name}>
              <Reveal delay={n * 60} className="h-full"><div className={`card card-lift img-zoom flex h-full flex-col overflow-hidden ${partners.length === 1 ? "md:flex-row" : ""}`}>
                <div className={`relative aspect-[3/2] w-full shrink-0 overflow-hidden ${partners.length === 1 ? "md:aspect-auto md:min-h-[300px] md:w-[44%]" : ""}`}>
                  <Image src={pt.image} alt={pt.imageAlt} fill sizes="(min-width: 768px) 45vw, 100vw" loading="eager" className="object-cover" />
                </div>
                <div className="flex flex-col items-start gap-3 p-6 md:p-8">
                  <span className="badge">{pt.location}</span>
                  <h3 className="text-h3 font-bold text-brand">{pt.name}</h3>
                  <p className="max-w-[60ch] text-left text-body">{pt.description}</p>
                </div>
              </div></Reveal>
            </li>
          ))}
        </ul>
      </section>
    </SiteShell>
  );
}

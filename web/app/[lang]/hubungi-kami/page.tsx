import { Icon } from "@/components/icons";
import Image from "next/image";
import LocaleLink from "@/components/LocaleLink";
import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { pageMetadata } from "@/lib/seo";
import { getDictionary, hasLocale } from "@/i18n";
import SiteShell from "@/components/SiteShell";
import ContactForm from "@/components/ContactForm";
import Faq from "@/components/Faq";
import ContactInfo from "@/components/ContactInfo";
import { Eyebrow } from "@/components/kit";
import { contact } from "@/data/contact";
import { buildFaq } from "@/data/faq";

export async function generateMetadata({ params }: PageProps<"/[lang]/hubungi-kami">): Promise<Metadata> {
  const { lang } = await params;
  if (!hasLocale(lang)) return {};
  return pageMetadata(lang, "/hubungi-kami", getDictionary(lang).meta.hubungi);
}

export default async function HubungiKamiPage({ params }: PageProps<"/[lang]/hubungi-kami">) {
  const { lang } = await params;
  if (!hasLocale(lang)) notFound();
  const d = getDictionary(lang);
  const c = d.contactPage;
  const faq = buildFaq(d);
  return (
    <SiteShell lang={lang} footerContact={false}>
      <section className="band-blue curve-b overflow-hidden">
        <div className="container-page flex flex-col items-center pb-16 pt-28 text-white lg:pb-20 lg:pt-32">
          {/* Photo is 736px wide: framed and capped at its intrinsic width so it is never stretched */}
          <div className="relative aspect-[736/340] w-full max-w-[736px] overflow-hidden rounded-3xl border border-white/40 shadow-[0_24px_48px_-24px_rgba(5,3,21,.6)]">
            <Image src="/img/hubungi/hero.png" alt="" fill priority sizes="(min-width:816px) 736px, calc(100vw - 48px)" className="object-cover object-[50%_40%]" />
          </div>
          <h1 className="mt-10 text-4xl font-bold lg:text-h1">{c.h1}</h1>
          <p className="mt-4 flex items-center gap-2 text-base font-bold">
            <Icon name="home" size={20} />
            <LocaleLink lang={lang} href="/" className="underline">{c.breadcrumbHome}</LocaleLink> <span>{c.breadcrumbHere}</span>
          </p>
        </div>
      </section>

      <Faq faqs={faq.faqs} categories={faq.categories} ui={faq.ui} />

      <section className="container-page section-y grid gap-10 lg:grid-cols-2 lg:gap-[80px]">
        <div>
          <h2 className="text-3xl font-bold leading-[1.15] text-brand md:text-h1">{c.howTitle}</h2>
          <p className="mt-8 max-w-[539px]">{c.howText}</p>
        </div>
        <ContactForm labels={d.form} />
      </section>

      <section className="container-page section-y">
        <div className="card overflow-hidden">
          <iframe src={contact.map.embedUrl} title={c.mapTitle} loading="lazy" referrerPolicy="no-referrer-when-downgrade" allowFullScreen width="100%" className="block h-[280px] w-full border-0 md:h-[clamp(280px,40vh,420px)]" />
        </div>
        <div className="mt-6 flex justify-center">
          <a href={contact.map.openUrl} target="_blank" rel="noopener noreferrer" className="btn-outline inline-flex min-h-11 items-center rounded-lg border border-black px-5 py-2 text-sm">{c.openMap}</a>
        </div>
      </section>

      <section className="tint-soft"><div className="container-page section-y text-center">
        <Eyebrow>{c.eyebrow}</Eyebrow>
        <h2 className="section-title text-brand">{c.titleLine1}<br />{c.titleLine2}</h2>
        <p className="mx-auto mt-4 text-sm text-body">{d.contact.institution} - {d.contact.tagline}</p>
        <div className="mt-10 text-left"><ContactInfo lang={lang} items={["phone", "email", "fax", "address"]} variant="cards" /></div>
      </div></section>
    </SiteShell>
  );
}

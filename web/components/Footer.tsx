import { downloadHref } from "@/data/site";
import Image from "next/image";
import ContactInfo from "@/components/ContactInfo";
import LanguageSwitcher from "@/components/LanguageSwitcher";
import LocaleLink from "@/components/LocaleLink";
import { getDictionary, type Lang } from "@/i18n";

const programs = [
  { src: "/logos/msib.png", alt: "MSIB", w: 1024, h: 360, cls: "h-[54px]" },
  { src: "/logos/infinite-learning.png", alt: "Infinite Learning", w: 471, h: 125 },
  { src: "/logos/kampus-merdeka.png", alt: "Kampus Merdeka", w: 1294, h: 680 },
];

export default function Footer({ lang, showContact = true }: { lang: Lang; showContact?: boolean }) {
  const d = getDictionary(lang);
  return (
    <footer className="mt-auto">
      <div className="border-t border-brand/10 bg-white">
      <div className="container-page grid items-start gap-10 py-12 md:grid-cols-[1.2fr_1fr_auto]">
        <div>
          <Image src="/img/home/logo.png" alt={d.common.logoAlt} width={160} height={84} className="mb-6 h-[84px] w-auto" />
          <ul className="mb-10 flex flex-wrap items-center gap-x-6 gap-y-4" aria-label={d.footer.programLabel}>
            {programs.map((l) => (<li key={l.src}><Image src={l.src} alt={l.alt} width={l.w} height={l.h} className={`${l.cls ?? "h-9"} w-auto max-w-full object-contain`} /></li>))}
          </ul>
          {showContact && <ContactInfo lang={lang} items={["email", "phone", "address"]} variant="compact" />}
        </div>
        <div>
          <p className="mb-6 text-h3 font-bold text-ink">{d.footer.downloadHeading}</p>
          <a href={downloadHref} className="inline-flex h-12 items-center btn-cta rounded-lg px-[42px]">{d.common.download}</a>
        </div>
        <nav className="flex flex-col gap-6 text-h3 text-ink" aria-label={d.footer.navLabel}>
          <LocaleLink lang={lang} className="link-u w-fit" href="/tentang-kami">{d.footer.about}</LocaleLink>
          <LocaleLink lang={lang} className="link-u w-fit" href="/produk">{d.footer.product}</LocaleLink>
          <LocaleLink lang={lang} className="link-u w-fit" href="/hubungi-kami#faq">{d.footer.faq}</LocaleLink>
          <LanguageSwitcher lang={lang} variant="text" labels={{ label: d.lang.label, names: { id: d.lang.id, en: d.lang.en }, switchTo: d.lang.switchTo, text: d.lang.footerText }} />
        </nav>
      </div>
      </div>
      <div className="bg-brand surface-brand py-4 text-center text-white">{d.footer.rights}</div>
    </footer>
  );
}

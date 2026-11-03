import type { ReactNode } from "react";
import { getDictionary, type Lang } from "@/i18n";
import Navbar from "./Navbar";
import Footer from "./Footer";

export default function SiteShell({ lang, children, footerContact = true }: { lang: Lang; children: ReactNode; footerContact?: boolean }) {
  const d = getDictionary(lang);
  return (
    <>
      <a href="#main" className="skip-link">{d.common.skip}</a>
      <Navbar lang={lang} nav={d.nav} langLabels={{ label: d.lang.label, names: { id: d.lang.id, en: d.lang.en }, switchTo: d.lang.switchTo }} logoAlt={d.common.logoAlt} />
      <main id="main" tabIndex={-1} className="flex-1 outline-none">{children}</main>
      <Footer lang={lang} showContact={footerContact} />
    </>
  );
}

"use client";
import Image from "next/image";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";
import { Icon } from "@/components/icons";
import LanguageSwitcher from "@/components/LanguageSwitcher";
import { localeHref, stripLocale, type Lang } from "@/i18n/config";

type NavLabels = { home: string; product: string; articles: string; about: string; contact: string; homeAria: string; mainLabel: string; mobileLabel: string; openMenu: string; closeMenu: string };

export default function Navbar({ lang, nav, langLabels, logoAlt }: { lang: Lang; nav: NavLabels; langLabels: { label: string; names: Record<Lang, string>; switchTo: string }; logoAlt: string }) {
  const [open, setOpen] = useState(false);
  const path = stripLocale(usePathname());
  const links = [
    { href: "/", label: nav.home },
    { href: "/produk", label: nav.product },
    { href: "/artikel", label: nav.articles },
    { href: "/tentang-kami", label: nav.about },
  ];
  const active = (h: string) => (h === "/" ? path === "/" : path.startsWith(h));
  return (
    <header className="nav-grad sticky top-0 z-50 border-b border-black/10 shadow-sm">
      <div className="container-page flex h-20 items-center justify-between gap-3 lg:h-24">
        <Link href={localeHref(lang, "/")} aria-label={nav.homeAria}>
          <Image src="/img/home/logo.png" alt={logoAlt} width={160} height={84} className="h-14 w-auto lg:h-[84px]" priority />
        </Link>
        <nav className="hidden items-center gap-5 whitespace-nowrap text-base md:flex lg:gap-8 lg:text-lg xl:gap-[48px] xl:text-h3" aria-label={nav.mainLabel}>
          {links.map((l) => (
            <Link key={l.href} href={localeHref(lang, l.href)} aria-current={active(l.href) ? "page" : undefined} className={`relative py-1 transition-colors duration-150 hover:text-brand after:absolute after:inset-x-0 after:-bottom-0.5 after:h-0.5 after:origin-left after:rounded after:bg-brand after:transition-transform after:duration-200 after:ease-out motion-reduce:after:transition-none focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-brand ${active(l.href) ? "text-brand after:scale-x-100" : "text-ink after:scale-x-0 hover:after:scale-x-100"}`}>
              {l.label}
            </Link>
          ))}
        </nav>
        <div className="hidden items-center gap-3 md:flex">
          <LanguageSwitcher lang={lang} labels={langLabels} />
          <Link href={localeHref(lang, "/hubungi-kami")} className="whitespace-nowrap btn-outline rounded-lg border border-black px-4 py-2 text-sm">
            {nav.contact}
          </Link>
        </div>
        <button type="button" className="md:hidden grid size-11 cursor-pointer place-items-center rounded-lg focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand" aria-label={open ? nav.closeMenu : nav.openMenu} aria-expanded={open} onClick={() => setOpen(!open)}>
          <Icon name={open ? "close" : "menu"} size={28} />
        </button>
      </div>
      {open && (
        <nav className="flex flex-col gap-1 border-t border-black/10 bg-white px-6 py-4 text-lg md:hidden" aria-label={nav.mobileLabel}>
          {[...links, { href: "/hubungi-kami", label: nav.contact }].map((l) => (
            <Link key={l.href} href={localeHref(lang, l.href)} onClick={() => setOpen(false)} className={`flex min-h-11 items-center ${active(l.href) ? "text-brand" : ""}`}>
              {l.label}
            </Link>
          ))}
          <div className="pt-2"><LanguageSwitcher lang={lang} labels={langLabels} /></div>
        </nav>
      )}
    </header>
  );
}

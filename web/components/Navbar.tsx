"use client";
import Image from "next/image";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";

const links = [
  { href: "/", label: "Beranda" },
  { href: "/produk", label: "Produk" },
  { href: "/artikel", label: "Artikel" },
  { href: "/tentang-kami", label: "Tentang Kami" },
];

export default function Navbar() {
  const [open, setOpen] = useState(false);
  const path = usePathname();
  const active = (h: string) => (h === "/" ? path === "/" : path.startsWith(h));
  return (
    <header className="nav-grad sticky top-0 z-50 border-b border-black/10 shadow-sm">
      <div className="container-page flex h-20 items-center justify-between lg:h-24">
        <Link href="/" aria-label="IkanKu beranda">
          <Image src="/img/home/logo.png" alt="IkanKu" width={160} height={84} className="h-14 w-auto lg:h-[84px]" priority />
        </Link>
        <nav className="hidden items-center gap-10 text-[22px] md:flex lg:gap-[60px]" aria-label="Utama">
          {links.map((l) => (
            <Link key={l.href} href={l.href} className={`transition-colors hover:text-brand ${active(l.href) ? "text-brand" : "text-ink"}`}>
              {l.label}
            </Link>
          ))}
        </nav>
        <Link href="/hubungi-kami" className="hidden btn-outline rounded-lg border border-black px-4 py-2 text-sm md:block">
          Hubungi Kami
        </Link>
        <button type="button" className="md:hidden p-2" aria-label="Buka menu" aria-expanded={open} onClick={() => setOpen(!open)}>
          <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
            {open ? <path d="M6 6l12 12M18 6L6 18" /> : <path d="M4 7h16M4 12h16M4 17h16" />}
          </svg>
        </button>
      </div>
      {open && (
        <nav className="flex flex-col gap-4 border-t border-black/10 bg-white px-6 py-4 text-lg md:hidden" aria-label="Menu seluler">
          {[...links, { href: "/hubungi-kami", label: "Hubungi Kami" }].map((l) => (
            <Link key={l.href} href={l.href} onClick={() => setOpen(false)} className={active(l.href) ? "text-brand" : ""}>
              {l.label}
            </Link>
          ))}
        </nav>
      )}
    </header>
  );
}

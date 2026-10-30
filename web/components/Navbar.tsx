"use client";
import Image from "next/image";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";
import { Icon } from "@/components/icons";

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
            <Link key={l.href} href={l.href} aria-current={active(l.href) ? "page" : undefined} className={`relative py-1 transition-colors duration-150 hover:text-brand after:absolute after:inset-x-0 after:-bottom-0.5 after:h-0.5 after:origin-left after:rounded after:bg-brand after:transition-transform after:duration-200 after:ease-out motion-reduce:after:transition-none focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-brand ${active(l.href) ? "text-brand after:scale-x-100" : "text-ink after:scale-x-0 hover:after:scale-x-100"}`}>
              {l.label}
            </Link>
          ))}
        </nav>
        <Link href="/hubungi-kami" className="hidden btn-outline rounded-lg border border-black px-4 py-2 text-sm md:block">
          Hubungi Kami
        </Link>
        <button type="button" className="md:hidden grid size-11 cursor-pointer place-items-center rounded-lg focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand" aria-label="Buka menu" aria-expanded={open} onClick={() => setOpen(!open)}>
          <Icon name={open ? "close" : "menu"} size={28} />
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

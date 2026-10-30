import Image from "next/image";
import Link from "next/link";
import ContactInfo from "@/components/ContactInfo";

const programs = [
  { src: "/logos/msib.png", alt: "MSIB", w: 1024, h: 360, cls: "h-[54px]" },
  { src: "/logos/infinite-learning.png", alt: "Infinite Learning", w: 471, h: 125 },
  { src: "/logos/kampus-merdeka.png", alt: "Kampus Merdeka", w: 1294, h: 680 },
];

export default function Footer({ showContact = true }: { showContact?: boolean }) {
  return (
    <footer className="mt-auto">
      <div className="border-t border-brand/10 bg-white">
      <div className="container-page grid items-start gap-10 py-12 md:grid-cols-[1.2fr_1fr_auto]">
        <div>
          <Image src="/img/home/logo.png" alt="IkanKu" width={160} height={84} className="mb-6 h-[84px] w-auto" />
          <ul className="mb-10 flex flex-wrap items-center gap-x-6 gap-y-4" aria-label="Program">
            {programs.map((l) => (<li key={l.src}><Image src={l.src} alt={l.alt} width={l.w} height={l.h} className={`${l.cls ?? "h-9"} w-auto max-w-full object-contain`} /></li>))}
          </ul>
          {showContact && <ContactInfo items={["email", "phone", "address"]} variant="compact" />}
        </div>
        <div>
          <p className="mb-6 text-h3 font-bold text-ink">Download Aplikasi</p>
          <a href="#" className="inline-flex h-12 items-center btn-cta rounded-lg px-[42px] text-white">Unduh Aplikasi</a>
        </div>
        <nav className="flex flex-col gap-6 text-h3 text-ink" aria-label="Footer">
          <Link className="link-u w-fit" href="/tentang-kami">Tentang kami</Link>
          <Link className="link-u w-fit" href="/produk">Produk</Link>
          <Link className="link-u w-fit" href="/hubungi-kami#faq">FAQ</Link>
        </nav>
      </div>
      </div>
      <div className="bg-brand surface-brand py-4 text-center text-white">© 2024 All rights reserved.</div>
    </footer>
  );
}

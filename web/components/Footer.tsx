import Image from "next/image";
import Link from "next/link";
import { contact } from "@/data/contact";

const programs = [
  { src: "/logos/msib.png", alt: "MSIB", w: 1024, h: 360, cls: "h-[54px]" },
  { src: "/logos/infinite-learning.png", alt: "Infinite Learning", w: 471, h: 125 },
  { src: "/logos/kampus-merdeka.png", alt: "Kampus Merdeka", w: 1294, h: 680 },
];

export default function Footer() {
  return (
    <footer className="mt-auto">
      <div className="bg-white">
      <div className="container-page grid items-start gap-10 py-12 md:grid-cols-[1.2fr_1fr_auto]">
        <div>
          <Image src="/img/home/logo.png" alt="IkanKu" width={160} height={84} className="mb-6 h-[84px] w-auto" />
          <ul className="mb-10 flex flex-wrap items-center gap-x-6 gap-y-4" aria-label="Program">
            {programs.map((l) => (<li key={l.src}><Image src={l.src} alt={l.alt} width={l.w} height={l.h} className={`${l.cls ?? "h-9"} w-auto max-w-full object-contain`} /></li>))}
          </ul>
          <div className="grid gap-x-10 gap-y-6 text-lg text-black sm:grid-cols-2">
            <div><p>Email</p><a href={contact.emailHref} className="mt-3 block break-words hover:text-brand">{contact.email}</a></div>
            <div><p>Nomor telepon</p><a href={contact.phoneHref} className="mt-3 block hover:text-brand">{contact.phone}</a></div>
            <div className="sm:col-span-2"><p>Alamat</p><p className="mt-3">{contact.address}</p></div>
          </div>
        </div>
        <div>
          <p className="mb-6 text-[22px] font-bold text-black">Download Aplikasi</p>
          <a href="#" className="inline-flex h-12 items-center btn-cta rounded-lg px-[42px] text-white">Unduh Aplikasi</a>
        </div>
        <nav className="flex flex-col gap-6 text-[22px] text-black" aria-label="Footer">
          <Link href="/tentang-kami">Tentang kami</Link>
          <Link href="/produk">Produk</Link>
          <Link href="/hubungi-kami#faq">FAQ</Link>
        </nav>
      </div>
      </div>
      <div className="bg-brand py-4 text-center text-white">© 2024 All rights reserved.</div>
    </footer>
  );
}

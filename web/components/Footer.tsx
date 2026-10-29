import Image from "next/image";
import Link from "next/link";

export default function Footer() {
  return (
    <footer className="mt-auto bg-surface">
      <div className="mx-auto grid max-w-[1440px] gap-10 px-6 py-12 md:grid-cols-[1.2fr_1fr_auto] lg:px-[79px]">
        <div>
          <Image src="/img/home/logo.png" alt="IkanKu" width={120} height={63} className="mb-10 h-[63px] w-auto" />
          <div className="grid grid-cols-2 gap-x-10 gap-y-6 text-lg text-black">
            <div><p>Email</p><p className="mt-3 break-all">Ikanku@gmail.com</p></div>
            <div><p>Nomor telepon</p><p className="mt-3">+62 868-996-4445</p></div>
            <div className="col-span-2"><p>Alamat</p><p className="mt-3">68692 Ash Grove, Port Lindsay 77261-7123</p></div>
          </div>
        </div>
        <div>
          <p className="mb-6 text-[22px] font-bold text-black">Download Aplikasi</p>
          <a href="#" className="inline-flex h-12 items-center rounded-lg bg-accent px-[42px] text-white transition hover:brightness-95">Unduh Aplikasi</a>
        </div>
        <nav className="flex flex-col gap-6 text-[22px] text-black" aria-label="Footer">
          <Link href="/tentang-kami">Tentang kami</Link>
          <Link href="/produk">Produk</Link>
          <Link href="/hubungi-kami#faq">FAQ</Link>
        </nav>
      </div>
      <div className="bg-brand py-4 text-center text-white">© 2023 All rights reserved</div>
    </footer>
  );
}

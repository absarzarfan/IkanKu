"use client";
import { useState } from "react";
import { Icon } from "@/components/icons";

// Answers are not present in Figma (only closed question buttons); text below is placeholder copy.
const faqs = [
  { q: "Apa Itu IkanKu ?", a: "IkanKu adalah aplikasi untuk membeli ikan air tawar segar langsung dari petani dengan harga terbaik." },
  { q: "Bagiamana cara mendaftar di aplikasi ini ?", a: "Unduh aplikasi, pilih Daftar, lalu lengkapi data diri dan alamat Anda." },
  { q: "Bagaimana cara melakukan pembelian ikan tawar di aplikasi ini ?", a: "Pilih produk, tentukan variasi berat, masukkan keranjang, lalu buat pesanan dan lakukan pembayaran." },
  { q: "Apa saja metode pembayaran yang tersedia ?", a: "Tersedia pembayaran transfer dan COD sesuai pilihan penjual." },
  { q: "Apakah ada kebijakan pengembalian produk ?", a: "Silakan hubungi kami melalui formulir di halaman ini untuk pengajuan pengembalian." },
  { q: "Bagaimana cara memberikan ulasan atau rating produk?", a: "Setelah pesanan selesai, buka riwayat pesanan lalu pilih Beri Ulasan." },
];

export default function Faq() {
  const [open, setOpen] = useState<number | null>(null);
  return (
    <section id="faq" className="container-page section-y"><div className="rounded-2xl bg-brand surface-brand px-6 py-12 shadow-[0_8px_8px_rgba(0,0,0,.25)] md:px-[82px] md:pb-[100px]">
      <h2 className="mb-16 text-3xl font-bold tracking-tight text-white md:text-[48px] md:leading-[1.2]">Pertanyaan Yang Sering Diajukan</h2>
      <div className="grid items-start gap-4 md:grid-cols-2 md:gap-x-[22px] md:gap-y-[18px]">
        {faqs.map((f, i) => (
          <div key={f.q} className="rounded-lg bg-white">
            <button type="button" aria-expanded={open === i} onClick={() => setOpen(open === i ? null : i)} className="flex min-h-[80px] w-full items-center justify-between gap-4 rounded-lg border border-black px-[42px] text-left text-base text-black">
              <span>{f.q}</span>
              <Icon name="chevronDown" size={24} className={`shrink-0 transition-transform duration-200 ${open === i ? "rotate-180" : ""}`} />
            </button>
            {open === i && <p className="px-[42px] pb-5 pt-3 text-sm text-black">{f.a}</p>}
          </div>
        ))}
      </div>
    </div></section>
  );
}

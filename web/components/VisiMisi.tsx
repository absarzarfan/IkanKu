"use client";
import Image from "next/image";
import { useState } from "react";

// Only the "Visi" text exists in Figma; Misi/Tujuan frames show no copy.
const tabs = [
  { k: "Visi", t: "Menjadi platform terpercaya yang menghubungkan konsumen dengan produk ikan tawar berkualitas melalui transparansi, inovasi dan pelayanan unggul, guna mendukung pertumbuhan ekonomi lokal dan keberlanjutan sektor perikanan." },
  { k: "Misi", t: "Konten Misi belum tersedia di desain." },
  { k: "Tujuan", t: "Konten Tujuan belum tersedia di desain." },
];

export default function VisiMisi() {
  const [i, setI] = useState(0);
  return (
    <section className="container-page flex flex-col items-center gap-10 pb-16 md:flex-row md:items-start md:justify-center">
      <div className="relative h-[320px] w-[234px] shrink-0 overflow-hidden rounded-t-3xl">
        <Image src="/img/home/phone.png" alt="Aplikasi IkanKu" fill sizes="234px" className="object-cover object-top" />
      </div>
      <div>
        <p className="text-4xl font-bold text-brand md:text-[45px] md:leading-[52px]">IkanKu</p>
        <div className="mt-6 flex gap-4" role="tablist">
          {tabs.map((t, n) => (
            <button key={t.k} type="button" role="tab" aria-selected={i === n} onClick={() => setI(n)} className={`rounded-lg border border-black px-8 py-1 text-sm transition ${i === n ? "border-brand bg-brand text-white" : "bg-surface text-black hover:bg-white"}`}>
              {t.k}
            </button>
          ))}
        </div>
        <p role="tabpanel" className="mt-6 max-w-[620px]">{tabs[i].t}</p>
      </div>
    </section>
  );
}

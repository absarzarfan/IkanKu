"use client";
import Image from "next/image";
import { useState } from "react";
import { Icon, type IconName } from "@/components/icons";

// Only the "Visi" text exists in Figma; Misi/Tujuan frames show no copy.
const tabs: { k: string; t: string; icon: IconName }[] = [
  { k: "Visi", icon: "eye", t: "Menjadi platform terpercaya yang menghubungkan konsumen dengan produk ikan tawar berkualitas melalui transparansi, inovasi dan pelayanan unggul, guna mendukung pertumbuhan ekonomi lokal dan keberlanjutan sektor perikanan." },
  { k: "Misi", icon: "flag", t: "Konten Misi belum tersedia di desain." },
  { k: "Tujuan", icon: "target", t: "Konten Tujuan belum tersedia di desain." },
];

export default function VisiMisi() {
  const [i, setI] = useState(0);
  return (
    <section className="container-page flex flex-col items-center gap-10 pb-16 md:flex-row md:items-start md:justify-center">
      <div className="relative h-[320px] w-[234px] shrink-0 overflow-hidden rounded-t-3xl">
        <Image src="/img/home/phone.png" alt="Aplikasi IkanKu" fill sizes="234px" className="object-cover object-top" />
      </div>
      <div>
        <p className="text-4xl font-bold text-brand md:text-h1 md:leading-[52px]">IkanKu</p>
        <div className="mt-6 flex gap-4" role="tablist">
          {tabs.map((t, n) => (
            <button key={t.k} type="button" role="tab" aria-selected={i === n} onClick={() => setI(n)} className={`tab-chip inline-flex min-h-11 cursor-pointer items-center gap-2 rounded-lg border border-black px-6 py-1 text-sm transition-colors duration-200 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand ${i === n ? "border-brand bg-brand surface-brand text-white" : "bg-surface text-black hover:bg-white"}`}>
              <Icon name={t.icon} size={18} />{t.k}
            </button>
          ))}
        </div>
        <p role="tabpanel" className="mt-6 max-w-[620px]">{tabs[i].t}</p>
      </div>
    </section>
  );
}

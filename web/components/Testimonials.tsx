"use client";
import Image from "next/image";
import { useState, type KeyboardEvent } from "react";
import { Icon } from "@/components/icons";

const items = [
  { n: "Rina", q: "Sangat mudah dan praktis! Ikan yang saya terima selalu segar, dan pelayanannya cepat.", img: "t1.png" },
  { n: "Dewi", q: "Harga ikannya jauh lebih murah daripada di pasar, dan kualitasnya luar biasa.", img: "t2.png" },
  { n: "Sari", q: "Pertama kali pesan, langsung jatuh cinta dengan kemudahan aplikasi ini. Sangat membantu!", img: "t3.png" },
  { n: "Zahra", q: "Belanja ikan jadi lebih mudah dan cepat! Kualitas ikan sangat segar, dan pengirimannya tepat waktu. Sangat puas dengan layanan IkanKu!", img: "t4.png" },
  { n: "Oktaviani", q: "Aplikasinya sangat membantu. Saya bisa menemukan berbagai jenis ikan yang sulit didapat di pasar lokal. Sungguh praktis!", img: "t5.png" },
  { n: "Siti", q: "Proses pemesanan mudah, dan fitur pelacakan pesanan sangat membantu. Saya jadi tahu kapan ikan akan tiba. Mantap!", img: "t6.png" },
  { n: "Rina", q: "Suka banget dengan fitur ulasan produk. Membantu saya memilih ikan terbaik berdasarkan pengalaman pengguna lain. Terima kasih IkanKu!", img: "t7.png" },
  { n: "Ayu", q: "Pengalaman belanja yang simpel dan menyenangkan. Tidak perlu repot pergi ke pasar lagi, semuanya cukup lewat aplikasi.", img: "t8.png" },
  { n: "Novi", q: "Ikan yang dikirim benar-benar segar, seperti baru ditangkap dari laut. Saya jadi langganan tetap di IkanKu!", img: "t9.png" },
];
const PAGES = 3;
const PER = 3;

export default function Testimonials() {
  const [page, setPage] = useState(0);
  const onKey = (e: KeyboardEvent) => {
    if (e.key === "ArrowRight") setPage((page + 1) % PAGES);
    else if (e.key === "ArrowLeft") setPage((page + PAGES - 1) % PAGES);
    else return;
    e.preventDefault();
    requestAnimationFrame(() => (e.currentTarget.querySelector('[aria-selected="true"]') as HTMLElement | null)?.focus());
  };
  const shown = items.slice(page * PER, page * PER + PER);
  return (
    <section className="container-page section-y">
      <h2 className="section-title text-brand">Testimoni</h2>
      <div className="mt-20 grid gap-x-[14px] gap-y-16 md:grid-cols-3">
        {shown.map((t, i) => (
          <figure key={`${page}-${i}`} className={`relative rounded-2xl bg-brand surface-brand px-8 pb-6 pt-14 text-center text-white ${i > 0 ? "hidden md:block" : ""}`}>
            <Image src={`/img/home/${t.img}`} alt="" width={90} height={90} className="absolute -top-10 left-1/2 h-[90px] w-[90px] -translate-x-1/2 rounded-full object-cover" />
            <blockquote className="font-montserrat text-sm font-medium">&quot;{t.q}&quot;</blockquote>
            <figcaption className="mt-8 font-montserrat text-xl font-bold">{t.n}</figcaption>
          </figure>
        ))}
      </div>
      <div className="mt-10 flex items-center justify-center gap-2">
        <button type="button" aria-label="Testimoni sebelumnya" onClick={() => setPage((page + PAGES - 1) % PAGES)} className="slider-btn"><Icon name="chevronLeft" size={22} /></button>
        <div className="flex items-center" role="tablist" aria-label="Halaman testimoni" onKeyDown={onKey}>
          {Array.from({ length: PAGES }, (_, i) => (
            <button key={i} type="button" role="tab" aria-selected={page === i} aria-label={`Testimoni ${i + 1}`} tabIndex={page === i ? 0 : -1} onClick={() => setPage(i)} className="slider-dot group">
              <span className={`block h-2.5 rounded-full transition-[width,background-color] duration-200 ${page === i ? "w-8 bg-brand" : "w-2.5 bg-dot group-hover:bg-brand/50"}`} />
            </button>
          ))}
        </div>
        <button type="button" aria-label="Testimoni berikutnya" onClick={() => setPage((page + 1) % PAGES)} className="slider-btn"><Icon name="chevronRight" size={22} /></button>
      </div>
    </section>
  );
}

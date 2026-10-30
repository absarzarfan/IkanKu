"use client";
import Image from "next/image";
import { useState } from "react";

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
  const shown = items.slice(page * PER, page * PER + PER);
  return (
    <section className="container-page section-y">
      <h2 className="text-center text-3xl text-brand md:text-[46px]">Testimoni</h2>
      <div className="mt-20 grid gap-x-[14px] gap-y-16 md:grid-cols-3">
        {shown.map((t, i) => (
          <figure key={`${page}-${i}`} className={`relative rounded-2xl bg-brand px-8 pb-6 pt-14 text-center text-white ${i > 0 ? "hidden md:block" : ""}`}>
            <Image src={`/img/home/${t.img}`} alt="" width={90} height={90} className="absolute -top-10 left-1/2 h-[90px] w-[90px] -translate-x-1/2 rounded-full object-cover" />
            <blockquote className="font-montserrat text-sm font-medium">&quot;{t.q}&quot;</blockquote>
            <figcaption className="mt-8 font-montserrat text-xl font-bold">{t.n}</figcaption>
          </figure>
        ))}
      </div>
      <div className="mt-10 flex justify-center gap-3" role="tablist" aria-label="Halaman testimoni">
        {Array.from({ length: PAGES }, (_, i) => (
          <button key={i} type="button" role="tab" aria-selected={page === i} aria-label={`Testimoni ${i + 1}`} onClick={() => setPage(i)} className={`h-[10px] w-12 rounded-lg ${page === i ? "bg-brand" : "bg-dot"}`} />
        ))}
      </div>
    </section>
  );
}

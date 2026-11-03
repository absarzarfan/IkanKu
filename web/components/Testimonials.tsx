"use client";
import Image from "next/image";
import { useState, type KeyboardEvent } from "react";
import { Icon } from "@/components/icons";
import { fmt } from "@/i18n/config";

export type TestimonialLabels = { title: string; prev: string; next: string; pages: string; item: string };

const IMAGES = ["t1.png", "t2.png", "t3.png", "t4.png", "t5.png", "t6.png", "t7.png", "t8.png", "t9.png"];
const PAGES = 3;
const PER = 3;

export default function Testimonials({ items, labels }: { items: { name: string; quote: string }[]; labels: TestimonialLabels }) {
  const [page, setPage] = useState(0);
  const onKey = (e: KeyboardEvent) => {
    if (e.key === "ArrowRight") setPage((page + 1) % PAGES);
    else if (e.key === "ArrowLeft") setPage((page + PAGES - 1) % PAGES);
    else return;
    e.preventDefault();
    requestAnimationFrame(() => (e.currentTarget.querySelector('[aria-selected="true"]') as HTMLElement | null)?.focus());
  };
  const shown = items.slice(page * PER, page * PER + PER).map((t, i) => ({ n: t.name, q: t.quote, img: IMAGES[page * PER + i] }));
  return (
    <section className="container-page section-y">
      <h2 className="section-title text-brand">{labels.title}</h2>
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
        <button type="button" aria-label={labels.prev} onClick={() => setPage((page + PAGES - 1) % PAGES)} className="slider-btn"><Icon name="chevronLeft" size={22} /></button>
        <div className="flex items-center" role="tablist" aria-label={labels.pages} onKeyDown={onKey}>
          {Array.from({ length: PAGES }, (_, i) => (
            <button key={i} type="button" role="tab" aria-selected={page === i} aria-label={fmt(labels.item, { n: i + 1 })} tabIndex={page === i ? 0 : -1} onClick={() => setPage(i)} className="slider-dot group">
              <span className={`block h-2.5 rounded-full transition-[width,background-color] duration-200 ${page === i ? "w-8 bg-brand" : "w-2.5 bg-dot group-hover:bg-brand/50"}`} />
            </button>
          ))}
        </div>
        <button type="button" aria-label={labels.next} onClick={() => setPage((page + 1) % PAGES)} className="slider-btn"><Icon name="chevronRight" size={22} /></button>
      </div>
    </section>
  );
}

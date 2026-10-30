"use client";
import Image from "next/image";
import Link from "next/link";
import { useMemo, useState } from "react";
import { articles } from "@/lib/articles";

const PER_PAGE = 6;
const chips = ["Terbaru", "Kesehatan", "Budidaya", "Bisnis"] as const;

export default function ArticleList() {
  const [q, setQ] = useState("");
  const [chip, setChip] = useState<(typeof chips)[number]>("Terbaru");
  const [page, setPage] = useState(1);

  const list = useMemo(
    () =>
      articles.filter(
        (a) =>
          (chip === "Terbaru" || a.category === chip) &&
          a.title.toLowerCase().includes(q.trim().toLowerCase()),
      ),
    [q, chip],
  );
  const pages = Math.max(1, Math.ceil(list.length / PER_PAGE));
  const cur = Math.min(page, pages);
  const shown = list.slice((cur - 1) * PER_PAGE, cur * PER_PAGE);

  return (
    <section className="container-page section-y">
      <h2 className="section-title text-brand">Artikel lainnya</h2>
      <div className="relative mx-auto mt-10 max-w-[667px]">
        <Image src="/img/artikel/search.svg" alt="" width={28} height={28} className="absolute left-5 top-4" />
        <input
          type="search"
          value={q}
          onChange={(e) => { setQ(e.target.value); setPage(1); }}
          placeholder="Search..."
          aria-label="Cari artikel"
          className="h-[60px] w-full rounded-3xl border border-brand/20 bg-white pl-[68px] pr-6 shadow-sm transition-shadow duration-200 placeholder:text-black/50 focus-visible:outline-2 focus-visible:outline-brand"
        />
      </div>
      <div className="mt-6 flex flex-wrap justify-center gap-4 md:gap-12">
        {chips.map((c) => (
          <button key={c} type="button" onClick={() => { setChip(c); setPage(1); }} aria-pressed={chip === c} className={`h-10 min-w-[100px] cursor-pointer rounded-full border border-brand/30 px-5 text-base transition-colors duration-150 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand ${chip === c ? "bg-brand surface-brand text-white" : "bg-white hover:bg-white/70"}`}>
            {c}
          </button>
        ))}
      </div>

      {shown.length === 0 ? (
        <p className="mt-16 text-center">Tidak ada artikel yang cocok.</p>
      ) : (
        <ul className="mx-auto mt-12 grid max-w-[1000px] gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {shown.map((a) => (
            <li key={a.slug}>
              <Link href={`/artikel/${a.slug}`} className="card card-lift group block h-full p-3">
                <div className="relative h-[200px] overflow-hidden rounded-2xl">
                  <Image src={a.image} alt="" fill sizes="300px" className="object-cover transition-transform duration-300 group-hover:scale-105" />
                </div>
                <h3 className="mt-4 px-2 text-xl font-semibold text-ink">{a.title}</h3>
                <span className="badge mx-2 mt-3">{a.category}</span>
                <p className="mt-3 px-2 pb-2 text-black/70">{a.date}</p>
              </Link>
            </li>
          ))}
        </ul>
      )}

      <div className="mx-auto mt-14 flex max-w-[1000px] items-center justify-between text-[22px] font-bold">
        <button type="button" disabled={cur <= 1} onClick={() => setPage(cur - 1)} className="flex items-center gap-2 text-lg disabled:opacity-30 md:text-[22px]">
          <Image src="/img/artikel/arrow.svg" alt="" width={24} height={24} /> Previous
        </button>
        <span className="whitespace-nowrap">Page {cur} of {pages}</span>
        <button type="button" disabled={cur >= pages} onClick={() => setPage(cur + 1)} className="flex items-center gap-2 text-lg disabled:opacity-30 md:text-[22px]">
          Next <Image src="/img/artikel/arrow.svg" alt="" width={24} height={24} className="rotate-180" />
        </button>
      </div>
    </section>
  );
}

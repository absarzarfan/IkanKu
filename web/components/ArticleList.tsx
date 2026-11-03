"use client";
import Image from "next/image";
import Link from "next/link";
import { useMemo, useState } from "react";
import { Kicker } from "@/components/ArticleMeta";

export type ListArticle = { slug: string; href: string; image: string; title: string; category: string; categoryLabel: string; meta: string };
export type ListLabels = { placeholder: string; searchLabel: string; filterLabel: string; all: string; noResults: string };

// One section per category (thin top rule, small-caps heading, 3-column card row); pills filter by category.
export default function ArticleList({ articles, categories, labels }: { articles: ListArticle[]; categories: { key: string; label: string }[]; labels: ListLabels }) {
  const [q, setQ] = useState("");
  const [cat, setCat] = useState<string>("*");

  const sections = useMemo(() => {
    const term = q.trim().toLowerCase();
    return categories.map((c) => ({
      c,
      items: articles.filter((a) => a.category === c.key && (cat === "*" || cat === c.key) && a.title.toLowerCase().includes(term)),
    })).filter((s) => s.items.length > 0);
  }, [q, cat, articles, categories]);

  return (
    <section className="container-page section-y">
      <div className="relative mx-auto max-w-[667px]">
        <Image src="/img/artikel/search.svg" alt="" width={28} height={28} className="pointer-events-none absolute left-5 top-4" />
        <input
          type="search"
          value={q}
          onChange={(e) => setQ(e.target.value)}
          placeholder={labels.placeholder}
          aria-label={labels.searchLabel}
          className="h-[60px] w-full rounded-3xl border border-brand/20 bg-white pl-[68px] pr-6 shadow-sm transition-shadow duration-200 placeholder:text-placeholder focus-visible:outline-2 focus-visible:outline-brand"
        />
      </div>
      <div role="group" aria-label={labels.filterLabel} className="mt-6 flex flex-wrap justify-center gap-3">
        {[{ key: "*", label: labels.all }, ...categories].map((c) => (
          <button key={c.key} type="button" onClick={() => setCat(c.key)} aria-pressed={cat === c.key} className={`inline-flex min-h-11 cursor-pointer items-center rounded-full border border-brand/30 px-5 text-base transition-colors duration-150 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand ${cat === c.key ? "bg-brand text-white" : "text-brand hover:bg-brand/10"}`}>
            {c.label}
          </button>
        ))}
      </div>

      {sections.length === 0 && <p className="mt-16 text-center">{labels.noResults}</p>}
      {sections.map(({ c, items }) => (
        <div key={c.key} className="mt-14">
          <div className="np-rule flex items-baseline justify-between pt-3">
            <h2 className="kit-eyebrow !mb-0 !text-base text-ink">{c.label}</h2>
          </div>
          <ul className="mt-6 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
            {items.map((a) => (
              <li key={a.slug}>
                <Link href={a.href} className="card card-lift img-zoom group block h-full overflow-hidden">
                  <div className="relative aspect-[3/2]">
                    <Image src={a.image} alt="" fill sizes="(min-width:1024px) 380px, (min-width:640px) 45vw, 100vw" className="object-cover" />
                  </div>
                  <div className="p-5">
                    <Kicker text={a.categoryLabel} />
                    <h3 className="np-head text-lg font-semibold text-ink">{a.title}</h3>
                    <p className="mt-3 text-sm text-muted">{a.meta}</p>
                  </div>
                </Link>
              </li>
            ))}
          </ul>
        </div>
      ))}
    </section>
  );
}

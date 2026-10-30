"use client";
import Image from "next/image";
import Link from "next/link";
import { useMemo, useState } from "react";
import { Kicker } from "@/components/ArticleMeta";
import { articleUi } from "@/data/article-ui";
import { ARTICLE_CATEGORIES, articlesByDate, readingMinutes } from "@/lib/articles";

// One section per category (thin top rule, small-caps heading, 3-column card row); pills filter by category.
export default function ArticleList() {
  const [q, setQ] = useState("");
  const [cat, setCat] = useState<string>(articleUi.filterAll);

  const sections = useMemo(() => {
    const term = q.trim().toLowerCase();
    return ARTICLE_CATEGORIES.map((c) => ({
      c,
      items: articlesByDate.filter((a) => a.category === c && (cat === articleUi.filterAll || cat === c) && a.title.toLowerCase().includes(term)),
    })).filter((s) => s.items.length > 0);
  }, [q, cat]);

  return (
    <section className="container-page section-y">
      <div className="relative mx-auto max-w-[667px]">
        <Image src="/img/artikel/search.svg" alt="" width={28} height={28} className="pointer-events-none absolute left-5 top-4" />
        <input
          type="search"
          value={q}
          onChange={(e) => setQ(e.target.value)}
          placeholder={articleUi.searchPlaceholder}
          aria-label={articleUi.searchLabel}
          className="h-[60px] w-full rounded-3xl border border-brand/20 bg-white pl-[68px] pr-6 shadow-sm transition-shadow duration-200 placeholder:text-placeholder focus-visible:outline-2 focus-visible:outline-brand"
        />
      </div>
      <div role="group" aria-label={articleUi.filterLabel} className="mt-6 flex flex-wrap justify-center gap-3">
        {[articleUi.filterAll, ...ARTICLE_CATEGORIES].map((c) => (
          <button key={c} type="button" onClick={() => setCat(c)} aria-pressed={cat === c} className={`inline-flex min-h-11 cursor-pointer items-center rounded-full border border-brand/30 px-5 text-base transition-colors duration-150 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand ${cat === c ? "bg-brand text-white" : "text-brand hover:bg-brand/10"}`}>
            {c}
          </button>
        ))}
      </div>

      {sections.length === 0 && <p className="mt-16 text-center">{articleUi.noResults}</p>}
      {sections.map(({ c, items }) => (
        <div key={c} className="mt-14">
          <div className="np-rule flex items-baseline justify-between pt-3">
            <h2 className="kit-eyebrow !mb-0 !text-base text-ink">{c}</h2>
          </div>
          <ul className="mt-6 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
            {items.map((a) => (
              <li key={a.slug}>
                <Link href={`/artikel/${a.slug}`} className="card card-lift img-zoom group block h-full overflow-hidden">
                  <div className="relative aspect-[3/2]">
                    <Image src={a.image} alt="" fill sizes="(min-width:1024px) 380px, (min-width:640px) 45vw, 100vw" className="object-cover" />
                  </div>
                  <div className="p-5">
                    <Kicker a={a} />
                    <h3 className="np-head text-lg font-semibold text-ink">{a.title}</h3>
                    <p className="mt-3 text-sm text-muted">{a.date} &middot; {readingMinutes(a)} {articleUi.minutesRead}</p>
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

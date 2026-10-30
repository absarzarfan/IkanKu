import Image from "next/image";
import Link from "next/link";
import type { Metadata } from "next";
import SiteShell from "@/components/SiteShell";
import ArticleList from "@/components/ArticleList";
import Dateline from "@/components/Dateline";
import HeadlineCarousel from "@/components/HeadlineCarousel";
import { Byline, Kicker } from "@/components/ArticleMeta";
import { articleUi } from "@/data/article-ui";
import { featured, latestArticles } from "@/lib/articles";

export const metadata: Metadata = { title: "Artikel - IkanKu" };

export default function ArtikelPage() {
  const headlines = latestArticles(5);
  const secondary = latestArticles(3).filter((a) => a.slug !== featured.slug).slice(0, 2);
  const latest = latestArticles(5);

  return (
    <SiteShell>
      <Dateline />
      <section className="container-page mt-4" aria-label={articleUi.carousel.label}>
        <HeadlineCarousel items={headlines} />
      </section>

      <section className="container-page section-y">
        <div className="np-rule flex items-baseline pt-3"><h2 className="kit-eyebrow !mb-0 !text-base text-ink">{articleUi.headlines}</h2></div>
        <div className="mt-6 grid gap-10 lg:grid-cols-[minmax(0,1fr)_320px]">
          <div>
            <Link href={`/artikel/${featured.slug}`} className="img-zoom group block">
              <div className="kit-frame relative aspect-[16/9]"><Image src={featured.image} alt="" fill sizes="(min-width:1024px) 820px, 100vw" className="object-cover" /></div>
              <div className="mt-5">
                <Kicker a={featured} />
                <h3 className="np-head text-2xl font-bold text-ink md:text-h2">{featured.title}</h3>
                <p className="mt-3 max-w-[62ch] text-body">{featured.excerpt}</p>
              </div>
            </Link>
            <div className="mt-4"><Byline a={featured} /></div>
            <ul className="np-rule mt-8 grid gap-6 pt-6 sm:grid-cols-2">
              {secondary.map((a) => (
                <li key={a.slug}>
                  <Link href={`/artikel/${a.slug}`} className="img-zoom group block">
                    <div className="kit-frame relative aspect-[3/2] !rounded-2xl"><Image src={a.image} alt="" fill sizes="(min-width:640px) 400px, 100vw" className="object-cover" /></div>
                    <div className="mt-4"><Kicker a={a} /><h3 className="np-head text-xl font-semibold text-ink">{a.title}</h3></div>
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          <aside aria-labelledby="terbaru-title" className="lg:border-l lg:border-black/15 lg:pl-8">
            <h2 id="terbaru-title" className="kit-eyebrow text-brand">{articleUi.latest}</h2>
            <ol className="divide-y divide-black/10">
              {latest.map((a, k) => (
                <li key={a.slug}>
                  <Link href={`/artikel/${a.slug}`} className="group flex items-start gap-4 py-4">
                    <span aria-hidden="true" className="w-6 shrink-0 font-montserrat text-2xl font-bold leading-none text-brand">{k + 1}</span>
                    <span className="min-w-0 flex-1">
                      <span className="np-head block text-base font-semibold text-ink link-u">{a.title}</span>
                      <span className="mt-1 block text-xs text-muted">{a.date}</span>
                    </span>
                    <span className="relative size-16 shrink-0 overflow-hidden rounded-xl"><Image src={a.image} alt="" fill sizes="64px" className="object-cover" /></span>
                  </Link>
                </li>
              ))}
            </ol>
          </aside>
        </div>
      </section>

      <ArticleList />
    </SiteShell>
  );
}

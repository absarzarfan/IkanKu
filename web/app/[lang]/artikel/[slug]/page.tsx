import Image from "next/image";
import LocaleLink from "@/components/LocaleLink";
import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { pageMetadata } from "@/lib/seo";
import { getDictionary, hasLocale, fmt } from "@/i18n";
import SiteShell from "@/components/SiteShell";
import { AiLabel, Byline, Kicker } from "@/components/ArticleMeta";
import { ARTICLE_AUTHOR, allArticles, imageWidth } from "@/lib/articles";
import { articlesFor } from "@/lib/articles";
import { articleMeta, articleNote, categoryLabel } from "@/lib/article-view";

export function generateStaticParams() {
  return allArticles.map((a) => ({ slug: a.slug }));
}

export async function generateMetadata({ params }: PageProps<"/[lang]/artikel/[slug]">): Promise<Metadata> {
  const { lang, slug } = await params;
  if (!hasLocale(lang)) return {};
  const d = getDictionary(lang);
  const a = articlesFor(lang).get(slug);
  return pageMetadata(lang, `/artikel/${slug}`, { title: a ? fmt(d.meta.articleTitle, { title: a.title }) : d.meta.artikel.title, description: a?.excerpt ?? d.meta.artikel.description });
}

export default async function ArticleDetail({ params }: PageProps<"/[lang]/artikel/[slug]">) {
  const { lang, slug } = await params;
  if (!hasLocale(lang)) notFound();
  const d = getDictionary(lang);
  const set = articlesFor(lang);
  const a = set.get(slug);
  if (!a) notFound();
  const related = set.related(a, 3);
  const sections = a.body ?? [];
  const meta = articleMeta(a, lang, d);

  return (
    <SiteShell lang={lang}>
      <article className="mx-auto max-w-[900px] px-6 py-12">
        <LocaleLink lang={lang} href="/artikel" className="link-u text-brand">&larr; {d.articles.back}</LocaleLink>
        <header className="np-rule mt-6 pt-6">
          <Kicker text={categoryLabel(a, d)} />
          <h1 className="np-head text-3xl font-bold text-ink md:text-h1">{a.title}</h1>
          {a.excerpt && <p className="mt-4 max-w-[62ch] text-lg text-body md:text-xl">{a.excerpt}</p>}
          <div className="mt-6 flex flex-wrap items-center gap-x-6 gap-y-3 border-y border-black/10 py-4 text-ink">
            <Byline author={ARTICLE_AUTHOR} meta={meta} />
            <span className="badge">{categoryLabel(a, d)}</span>
            <span className="ml-auto text-muted"><AiLabel text={articleNote(a, lang, d)} /></span>
          </div>
        </header>

        {/* Capped at 1.3x the source width so small files are not stretched across the 852px column */}
        <div className="kit-frame relative mx-auto mt-8 aspect-[16/9] w-full" style={{ maxWidth: Math.min(852, Math.round(imageWidth(a) * 1.3)) }}>
          <Image src={a.image} alt="" fill priority sizes={`(min-width:900px) ${Math.min(852, Math.round(imageWidth(a) * 1.3))}px, calc(100vw - 48px)`} className="object-cover" />
        </div>

        <div className="dropcap mx-auto mt-10 max-w-[68ch] text-lg leading-[1.8] text-body">
          {sections.map((s, k) => (
            <section key={s.heading ?? `s${k}`} className={k === 0 ? "" : "mt-10"}>
              {s.heading && <h2 className="np-head mb-3 text-h3 font-bold text-ink">{s.heading}</h2>}
              {s.paragraphs.map((p) => <p key={p} className="mt-4 first:mt-0">{p}</p>)}
              {k === 0 && a.pull && (
                <blockquote className="my-10 border-l-4 border-brand pl-6 font-montserrat text-2xl font-semibold leading-snug text-ink">{a.pull}</blockquote>
              )}
            </section>
          ))}
        </div>
      </article>

      <section className="band-tint section-y">
        <div className="container-page">
          <div className="np-rule pt-3"><h2 className="kit-eyebrow !mb-0 !text-base text-ink">{d.articles.related}</h2></div>
          <ul className="mt-6 grid gap-6 sm:grid-cols-3">
            {related.map((r) => (
              <li key={r.slug}>
                <LocaleLink lang={lang} href={`/artikel/${r.slug}`} className="card card-lift img-zoom block h-full overflow-hidden">
                  <div className="relative aspect-[3/2]"><Image src={r.image} alt="" fill sizes="(min-width:640px) 300px, 100vw" className="object-cover" /></div>
                  <div className="p-5">
                    <Kicker text={categoryLabel(r, d)} />
                    <h3 className="np-head text-lg font-semibold text-ink">{r.title}</h3>
                    <p className="mt-3 text-sm text-muted">{articleMeta(r, lang, d)}</p>
                  </div>
                </LocaleLink>
              </li>
            ))}
          </ul>
        </div>
      </section>
    </SiteShell>
  );
}

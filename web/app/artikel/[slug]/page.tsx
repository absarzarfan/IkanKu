import Image from "next/image";
import Link from "next/link";
import { notFound } from "next/navigation";
import type { Metadata } from "next";
import SiteShell from "@/components/SiteShell";
import { AiLabel, Byline, Kicker } from "@/components/ArticleMeta";
import { articleUi } from "@/data/article-ui";
import { allArticles, getArticle, relatedArticles } from "@/lib/articles";

export function generateStaticParams() {
  return allArticles.map((a) => ({ slug: a.slug }));
}

export async function generateMetadata({ params }: PageProps<"/artikel/[slug]">): Promise<Metadata> {
  const { slug } = await params;
  const a = getArticle(slug);
  return { title: a ? `${a.title} - IkanKu` : "Artikel - IkanKu" };
}

export default async function ArticleDetail({ params }: PageProps<"/artikel/[slug]">) {
  const { slug } = await params;
  const a = getArticle(slug);
  if (!a) notFound();
  const related = relatedArticles(a, 3);
  const sections = a.body ?? [];

  return (
    <SiteShell>
      <article className="mx-auto max-w-[900px] px-6 py-12">
        <Link href="/artikel" className="link-u text-brand">&larr; {articleUi.back}</Link>
        <header className="np-rule mt-6 pt-6">
          <Kicker a={a} />
          <h1 className="np-head text-3xl font-bold text-ink md:text-h1">{a.title}</h1>
          {a.excerpt && <p className="mt-4 max-w-[62ch] text-lg text-body md:text-xl">{a.excerpt}</p>}
          <div className="mt-6 flex flex-wrap items-center gap-x-6 gap-y-3 border-y border-black/10 py-4 text-ink">
            <Byline a={a} />
            <span className="badge">{a.category}</span>
            <span className="ml-auto text-muted"><AiLabel a={a} /></span>
          </div>
        </header>

        <div className="kit-frame relative mt-8 aspect-[16/9]">
          <Image src={a.image} alt="" fill priority sizes="900px" className="object-cover" />
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
          <div className="np-rule pt-3"><h2 className="kit-eyebrow !mb-0 !text-base text-ink">{articleUi.related}</h2></div>
          <ul className="mt-6 grid gap-6 sm:grid-cols-3">
            {related.map((r) => (
              <li key={r.slug}>
                <Link href={`/artikel/${r.slug}`} className="card card-lift img-zoom block h-full overflow-hidden">
                  <div className="relative aspect-[3/2]"><Image src={r.image} alt="" fill sizes="(min-width:640px) 300px, 100vw" className="object-cover" /></div>
                  <div className="p-5">
                    <Kicker a={r} />
                    <h3 className="np-head text-lg font-semibold text-ink">{r.title}</h3>
                    <p className="mt-3 text-sm text-muted">{r.date}</p>
                  </div>
                </Link>
              </li>
            ))}
          </ul>
        </div>
      </section>
    </SiteShell>
  );
}

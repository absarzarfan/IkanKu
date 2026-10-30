import Image from "next/image";
import Link from "next/link";
import { notFound } from "next/navigation";
import type { Metadata } from "next";
import SiteShell from "@/components/SiteShell";
import { allArticles, articles, featured, featuredHeadings, getArticle } from "@/lib/articles";

export function generateStaticParams() {
  return allArticles.map((a) => ({ slug: a.slug }));
}

export async function generateMetadata({ params }: PageProps<"/artikel/[slug]">): Promise<Metadata> {
  const { slug } = await params;
  const a = getArticle(slug);
  return { title: a ? `${a.title} - IkanKu` : "Artikel - IkanKu" };
}

// NOTE: the Figma detail frames could not be read (MCP rate limit), so this layout is an
// extrapolation from the article list frames. Body copy is not available (see docs/decisions-web.md).
export default async function ArticleDetail({ params }: PageProps<"/artikel/[slug]">) {
  const { slug } = await params;
  const a = getArticle(slug);
  if (!a) notFound();
  const related = articles.filter((x) => x.slug !== a.slug).slice(0, 3);
  const headings = a.slug === featured.slug ? featuredHeadings : [];

  return (
    <SiteShell>
      <article className="mx-auto max-w-[900px] px-6 py-12">
        <Link href="/artikel" className="text-brand underline">&larr; Artikel</Link>
        <h1 className="mt-6 text-3xl font-bold md:text-[34px]">{a.title}</h1>
        <div className="mt-6 flex items-center gap-4">
          <Image src="/img/artikel/avatar.svg" alt="" width={50} height={50} />
          <div className="text-lg"><p className="font-bold">IkanKu</p><p>{a.date}</p></div>
          <span className="badge ml-auto">{a.category}</span>
        </div>
        <div className="relative mt-8 h-[260px] overflow-hidden rounded-3xl md:h-[480px]">
          <Image src={a.image} alt="" fill priority sizes="900px" className="object-cover" />
        </div>
        {a.excerpt && <p className="mt-8 text-lg">{a.excerpt}</p>}
        {headings.map((h) => <h2 key={h} className="mt-8 text-[22px] font-bold">{h}</h2>)}
        <p className="mt-8 rounded-lg bg-white p-4 text-sm text-muted">Isi lengkap artikel belum tersedia: teks badan artikel pada frame Figma tidak dapat diambil.</p>
      </article>
      <section className="band-blue px-6 py-12">
        <div className="mx-auto max-w-[1000px]">
          <h2 className="mb-8 text-2xl text-white md:text-[34px]">Artikel Terkait</h2>
          <ul className="grid gap-6 sm:grid-cols-3">
            {related.map((r) => (
              <li key={r.slug} className="card card-lift p-3">
                <Link href={`/artikel/${r.slug}`}>
                  <div className="relative h-[160px] overflow-hidden rounded-2xl"><Image src={r.image} alt="" fill sizes="300px" className="object-cover" /></div>
                  <h3 className="mt-3 font-bold">{r.title}</h3>
                  <p className="mt-2 text-sm">{r.date}</p>
                </Link>
              </li>
            ))}
          </ul>
        </div>
      </section>
    </SiteShell>
  );
}

import Image from "next/image";
import Link from "next/link";
import type { Metadata } from "next";
import SiteShell from "@/components/SiteShell";
import ArticleList from "@/components/ArticleList";
import { featured } from "@/lib/articles";

export const metadata: Metadata = { title: "Artikel - IkanKu" };

export default function ArtikelPage() {
  return (
    <SiteShell>
      <section className="band-blue py-6"><div className="container-page">
        <Link href={`/artikel/${featured.slug}`} className="img-zoom relative block min-h-[420px] overflow-hidden rounded-3xl shadow-[0_24px_48px_-24px_rgba(5,3,21,.5)] md:h-[720px]">
          <Image src={featured.image} alt="" fill priority sizes="1280px" className="object-cover" />
          <div className="absolute inset-x-0 bottom-0 bg-gradient-to-b from-black/50 from-20% to-brand/50 p-6 text-white md:h-[241px] md:px-7 md:pt-[13px]">
            <div className="flex flex-col gap-4 md:flex-row md:justify-between">
              <div className="md:max-w-[885px]">
                <h1 className="text-2xl font-bold md:text-h2">{featured.title}</h1>
                <p className="mt-4 text-base md:mt-[15px] md:text-h3">{featured.excerpt}</p>
              </div>
              <div className="flex items-center gap-4 md:mt-[118px] md:border-l-2 md:border-white md:pl-5">
                <Image src="/img/artikel/avatar.svg" alt="" width={50} height={50} />
                <div className="text-lg"><p className="font-bold">IkanKu</p><p>{featured.date}</p></div>
              </div>
            </div>
          </div>
        </Link>
        </div>
      </section>
      <ArticleList />
    </SiteShell>
  );
}

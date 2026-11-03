import { downloadHref } from "@/data/site";
import Image from "next/image";
import type { Metadata } from "next";
import { notFound } from "next/navigation";
import SiteShell from "@/components/SiteShell";
import LocaleLink from "@/components/LocaleLink";
import Reveal from "@/components/Reveal";
import Testimonials from "@/components/Testimonials";
import SectionHeader from "@/components/SectionHeader";
import CtaBand from "@/components/CtaBand";
import { Bubbles, Wave } from "@/components/kit";
import HeadlineCarousel from "@/components/HeadlineCarousel";
import { Eyebrow } from "@/components/kit";
import { articlesFor } from "@/lib/articles";
import { articleCarouselItems } from "@/lib/article-view";
import { pageMetadata } from "@/lib/seo";
import { getDictionary, hasLocale } from "@/i18n";
import { IconChip, type IconName } from "@/components/icons";

const stepIcons: IconName[] = ["truck", "phoneApp", "shield"];
const featureIcons: IconName[] = ["fish", "cart", "truck", "star"];

export async function generateMetadata({ params }: PageProps<"/[lang]">): Promise<Metadata> {
  const { lang } = await params;
  if (!hasLocale(lang)) return {};
  return pageMetadata(lang, "/", getDictionary(lang).meta.home);
}

export default async function Home({ params }: PageProps<"/[lang]">) {
  const { lang } = await params;
  if (!hasLocale(lang)) notFound();
  const d = getDictionary(lang);
  const h = d.home;
  const carousel = articleCarouselItems(articlesFor(lang).latest(5), lang, d);
  return (
    <SiteShell lang={lang}>
      {/* Hero */}
      <section className="band-blue curve-b overflow-hidden">
        <div className="container-page grid items-center gap-10 pt-12 md:grid-cols-[1.1fr_0.9fr] lg:pt-0">
          <div>
            <h1 className="hero-in text-4xl font-bold leading-[1.15] md:text-h1 lg:text-display">{h.heroLine1}<br />{h.heroLine2}</h1>
            <a href={downloadHref} style={{ "--d": "80ms" } as React.CSSProperties} className="hero-in btn-cta mt-8 inline-flex h-12 items-center rounded-lg px-[42px] text-base">{d.common.downloadGooglePlay}</a>
          </div>
          <div className="relative mx-auto h-[320px] w-[260px] shrink-0 md:ml-auto md:mr-0 lg:mt-10 lg:h-[420px] lg:w-[335px]">
            <div aria-hidden className="absolute -right-6 top-6 h-[85%] w-[85%] rounded-[40px] border border-white/25 bg-white/10" />
            <div className="relative h-full w-full overflow-hidden rounded-t-3xl shadow-[0_18px_40px_-18px_rgba(5,3,21,.55)]">
              <Image src="/img/home/phone.png" alt={d.common.phoneAlt} fill sizes="335px" className="object-cover object-top" priority />
            </div>
          </div>
        </div>
      </section>

      {/* Top stories (carousel could replace the hero on request, see docs/decisions.md) */}
      <section className="band-white section-y">
        <div className="container-page">
          <Eyebrow>{d.articles.pageTitle}</Eyebrow>
          <h2 className="mb-8 text-3xl font-bold text-brand md:text-h2">{d.articles.headlines}</h2>
          <HeadlineCarousel items={carousel.items} labels={carousel.labels} priorityFirst={false} />
          <div className="mt-6 flex justify-center"><LocaleLink lang={lang} href="/artikel" className="btn-outline inline-flex min-h-11 items-center rounded-lg border border-black px-5 py-2 text-sm">{d.articles.allArticles}</LocaleLink></div>
        </div>
      </section>

      {/* What is IkanKu */}
      <section className="band-tint section-y">
        <div className="container-page flex flex-col items-center gap-12 md:flex-row lg:gap-[88px]">
          <Reveal className="relative w-full max-w-[340px] shrink-0">
            <div aria-hidden className="absolute -bottom-4 -left-4 h-full w-full rounded-3xl bg-brand/15" />
            <div className="relative aspect-[314/393] overflow-hidden rounded-3xl shadow-[0_18px_40px_-20px_rgba(23,123,205,.5)]">
              {/* Source is 314x393: capped at 340px wide (1.08x) so it stays sharp */}
              <Image src="/img/home/fish-box.jpg" alt={h.whatIsImageAlt} fill sizes="340px" className="object-cover" />
            </div>
          </Reveal>
          <Reveal delay={80}>
            <h2 className="text-3xl font-bold text-brand md:text-h1 md:leading-[1.15]">{h.whatIsTitle}</h2>
            <div className="mt-4 h-1 w-14 rounded bg-[image:var(--grad-primary)]" />
            <p className="mt-8 max-w-[540px] text-lg text-body">{h.whatIsBody}</p>
          </Reveal>
        </div>
      </section>

      {/* Why */}
      <section className="band-blue py-14 lg:py-20">
        <Bubbles />
        <div className="container-page">
          <SectionHeader tone="dark" title={h.whyTitle} />
          <div className="mt-14 flex flex-col items-center gap-10 md:flex-row md:items-start lg:gap-[96px]">
            <div className="relative h-[420px] w-[282px] shrink-0 overflow-hidden rounded-3xl shadow-[0_18px_40px_-18px_rgba(5,3,21,.55)] lg:h-[560px]">
              <Image src="/img/home/phone.png" alt={d.common.appAlt} fill sizes="282px" className="object-cover" />
            </div>
            <ol className="flex flex-1 flex-col gap-5">
              {h.steps.map((s, i) => (
                <Reveal key={s.title} delay={i * 60}>
                  <li className="glass-card relative p-6 pl-[88px]">
                    <IconChip name={stepIcons[i]} tone="glass" size={44} className="absolute left-6 top-6" />
                    <h3 className="text-h3 font-semibold">{s.title}</h3>
                    <p className="mt-3 max-w-[581px] text-white">{s.text}</p>
                  </li>
                </Reveal>
              ))}
            </ol>
          </div>
        </div>
      <div aria-hidden="true" className="absolute inset-x-0 bottom-0"><Wave color="#fff" /></div>
      </section>

      {/* Features */}
      <section className="band-white section-y">
        <div className="container-page">
          <SectionHeader eyebrow={h.featuresEyebrow} title={h.featuresTitle} intro={h.featuresIntro} />
          <div className="mt-12 grid gap-6 md:grid-cols-2">
            {h.features.map((f, i) => (
              <Reveal key={f.title} delay={(i % 2) * 60} className="h-full">
                <div className="card card-lift flex h-full min-h-[220px] flex-col items-start gap-5 p-7 sm:flex-row sm:items-center">
                  <IconChip name={featureIcons[i]} size={52} />
                  <div>
                    <h3 className="text-h3 font-semibold text-ink">{f.title}</h3>
                    <p className="mt-3 max-w-[340px] text-body">{f.text}</p>
                  </div>
                </div>
              </Reveal>
            ))}
          </div>
        </div>
      </section>

      <div className="band-tint">
        <Testimonials items={h.testimonials} labels={{ title: h.testimonialsTitle, prev: h.testimonialPrev, next: h.testimonialNext, pages: h.testimonialPages, item: h.testimonialN }} />
      </div>

      <CtaBand lang={lang} />
    </SiteShell>
  );
}

"use client";
import Image from "next/image";
import Link from "next/link";
import { useCallback, useEffect, useRef, useState, useSyncExternalStore, type KeyboardEvent } from "react";
import { Icon } from "@/components/icons";
import { Byline, Kicker } from "@/components/ArticleMeta";
import { articleUi } from "@/data/article-ui";
import type { Article } from "@/lib/articles";

const INTERVAL = 6000;
const RM = "(prefers-reduced-motion: reduce)";
const subscribeRm = (cb: () => void) => { const mq = window.matchMedia(RM); mq.addEventListener("change", cb); return () => mq.removeEventListener("change", cb); };
const getRm = () => window.matchMedia(RM).matches;

// CSS scroll-snap track + small client script. Autoplay pauses on hover/focus, has a visible pause button
// and stays off under prefers-reduced-motion. Only the current slide is focusable (others are inert).
export default function HeadlineCarousel({ items }: { items: Article[] }) {
  const trackRef = useRef<HTMLUListElement>(null);
  const [i, setI] = useState(0);
  const [userPlay, setUserPlay] = useState<boolean | null>(null);
  const [held, setHeld] = useState(false);
  const reduce = useSyncExternalStore(subscribeRm, getRm, () => true);
  const playing = userPlay ?? !reduce;
  const n = items.length;

  const goTo = useCallback((k: number) => {
    const t = trackRef.current;
    if (!t) return;
    const next = (k + n) % n;
    setI(next);
    t.scrollTo({ left: next * t.clientWidth, behavior: reduce ? "auto" : "smooth" });
  }, [n, reduce]);

  useEffect(() => {
    if (!playing || held || n < 2) return;
    const id = window.setInterval(() => goTo(i + 1), INTERVAL);
    return () => window.clearInterval(id);
  }, [playing, held, i, n, goTo]);

  const onScroll = () => {
    const t = trackRef.current;
    if (!t) return;
    const k = Math.round(t.scrollLeft / t.clientWidth);
    if (k !== i) setI(k);
  };
  const onKey = (e: KeyboardEvent) => {
    if (e.key === "ArrowRight") { e.preventDefault(); goTo(i + 1); }
    else if (e.key === "ArrowLeft") { e.preventDefault(); goTo(i - 1); }
  };

  const auto = playing && !held;
  return (
    <section
      aria-roledescription="carousel"
      aria-label={articleUi.carousel.label}
      onKeyDown={onKey}
      onMouseEnter={() => setHeld(true)}
      onMouseLeave={() => setHeld(false)}
      onFocus={() => setHeld(true)}
      onBlur={() => setHeld(false)}
      className="relative overflow-hidden rounded-3xl shadow-[0_24px_48px_-24px_rgba(5,3,21,.5)]"
    >
      <ul ref={trackRef} onScroll={onScroll} aria-live={auto ? "off" : "polite"} className="hc-track flex snap-x snap-mandatory overflow-x-auto">
        {items.map((a, k) => (
          <li key={a.slug} role="group" aria-roledescription="slide" aria-label={articleUi.carousel.slideLabel(k + 1, n)} inert={k !== i} className="relative h-[440px] w-full shrink-0 snap-center md:h-[520px]">
            <Link href={`/artikel/${a.slug}`} className="img-zoom block h-full w-full text-white focus-visible:outline-2 focus-visible:-outline-offset-4 focus-visible:outline-white">
              <Image src={a.image} alt="" fill sizes="(min-width:1280px) 1200px, 100vw" priority={k === 0} loading={k === 0 ? undefined : "lazy"} className="object-cover" />
              <div aria-hidden="true" className="absolute inset-0 bg-gradient-to-t from-[rgba(5,3,21,.92)] via-[rgba(5,3,21,.6)] via-45% to-transparent to-80%" />
              <div className="absolute inset-x-0 bottom-0 p-6 pb-16 md:p-10 md:pb-16">
                <Kicker a={a} tone="dark" />
                <h3 className="max-w-[28ch] text-2xl font-bold leading-tight text-white md:text-h2 md:leading-[1.15]">{a.title}</h3>
                {a.excerpt && <p className="mt-3 line-clamp-2 max-w-[62ch] text-base text-white">{a.excerpt}</p>}
                <div className="mt-4 text-white"><Byline a={a} tone="dark" /></div>
              </div>
            </Link>
          </li>
        ))}
      </ul>

      <div className="absolute inset-x-0 bottom-0 flex items-center justify-between gap-2 px-3 pb-2 md:px-6">
        <div className="flex items-center">
          {items.map((a, k) => (
            <button key={a.slug} type="button" aria-label={articleUi.carousel.goTo(k + 1)} aria-current={k === i} onClick={() => goTo(k)} className="slider-dot group">
              <span className={`block size-2 rounded-full bg-white transition-[transform,opacity] duration-200 ${k === i ? "scale-150 opacity-100" : "opacity-60"}`} />
            </button>
          ))}
        </div>
        <div className="flex items-center gap-1 text-white">
          <button type="button" onClick={() => setUserPlay(!playing)} aria-label={playing ? articleUi.carousel.pause : articleUi.carousel.play} className="hc-btn"><Icon name={playing ? "pause" : "play"} size={22} /></button>
          <button type="button" onClick={() => goTo(i - 1)} aria-label={articleUi.carousel.prev} className="hc-btn"><Icon name="chevronLeft" size={24} /></button>
          <button type="button" onClick={() => goTo(i + 1)} aria-label={articleUi.carousel.next} className="hc-btn"><Icon name="chevronRight" size={24} /></button>
        </div>
      </div>
    </section>
  );
}

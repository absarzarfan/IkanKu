import { downloadHref } from "@/data/site";
import Reveal from "./Reveal";
import { Bubbles } from "@/components/kit";
import { getDictionary, type Lang } from "@/i18n";

/** Closing call-to-action band. Orange is used only on the download button. */
export default function CtaBand({ lang }: { lang: Lang }) {
  const d = getDictionary(lang);
  return (
    <section className="band-tint section-y">
      <div className="container-page">
        <Reveal className="band-blue flex flex-col items-center justify-between gap-6 overflow-hidden rounded-3xl px-8 py-10 text-center sm:flex-row sm:text-left lg:px-16">
          <Bubbles />
          <p className="text-2xl font-semibold leading-tight lg:text-h2">{d.cta.heading}</p>
          <a href={downloadHref} className="btn-cta inline-flex h-12 shrink-0 items-center rounded-lg px-[42px]">{d.common.download}</a>
        </Reveal>
      </div>
    </section>
  );
}

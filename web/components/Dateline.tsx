"use client";
import { useSyncExternalStore } from "react";
import { intlLocale, type Lang } from "@/i18n/config";

// Current date is formatted on the client (the page is prerendered); the line keeps its height meanwhile.
const noop = () => () => {};

export default function Dateline({ lang, label }: { lang: Lang; label: string }) {
  const text = useSyncExternalStore(noop, () => new Intl.DateTimeFormat(intlLocale[lang], { weekday: "long", day: "numeric", month: "long", year: "numeric" }).format(new Date()), () => "");
  return (
    <div className="container-page pt-6">
      <div className="np-rule-thick flex min-h-9 flex-wrap items-center justify-between gap-x-6 gap-y-1 py-2 text-sm text-ink">
        <p className="kit-eyebrow !mb-0 text-ink"><span aria-hidden={!text}>{text || " "}</span></p>
        <h1 className="kit-eyebrow !mb-0 text-brand">{label}</h1>
      </div>
    </div>
  );
}

"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { SCROLL_KEY } from "@/components/ScrollManager";
import { LOCALE_COOKIE, localeHref, locales, stripLocale, type Lang } from "@/i18n/config";

type Labels = { label: string; names: Record<Lang, string>; switchTo: string; text?: string };

function remember(l: Lang) {
  document.cookie = `${LOCALE_COOKIE}=${l}; path=/; max-age=31536000; samesite=lax`;
  // Keep the reading position: the language switch must not move the page.
  try { sessionStorage.setItem(SCROLL_KEY, String(window.scrollY)); } catch {}
}

/** Compact "ID | EN" segmented control (navbar) or a small text switcher (footer). Keeps the current page. */
export default function LanguageSwitcher({ lang, labels, variant = "segmented" }: { lang: Lang; labels: Labels; variant?: "segmented" | "text" }) {
  const path = stripLocale(usePathname());
  const hrefFor = (l: Lang) => localeHref(l, path);
  const aria = (l: Lang) => labels.switchTo.replace("{name}", labels.names[l]);

  if (variant === "text") {
    return (
      <p className="flex flex-wrap items-center gap-x-2 text-sm text-ink">
        <span>{labels.text}</span>
        {locales.map((l, k) => (
          <span key={l} className="inline-flex items-center gap-2">
            {k > 0 && <span aria-hidden="true">|</span>}
            <Link href={hrefFor(l)} scroll={false} hrefLang={l} lang={l} aria-current={l === lang ? "true" : undefined} aria-label={aria(l)} onClick={() => remember(l)} className={`inline-flex min-h-11 items-center px-1 ${l === lang ? "font-semibold text-brand" : "link-u"}`}>
              {labels.names[l]}
            </Link>
          </span>
        ))}
      </p>
    );
  }
  return (
    <div role="group" aria-label={labels.label} className="inline-flex items-center rounded-lg border border-black/20 bg-white p-0.5 text-sm font-semibold">
      {locales.map((l) => (
        <Link
          key={l}
          href={hrefFor(l)}
          scroll={false}
          hrefLang={l}
          lang={l}
          aria-current={l === lang ? "true" : undefined}
          aria-label={aria(l)}
          onClick={() => remember(l)}
          className={`grid min-h-11 min-w-11 place-items-center rounded-md px-2 uppercase transition-colors duration-150 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand ${l === lang ? "bg-brand text-white" : "text-ink hover:text-brand"}`}
        >
          {l}
        </Link>
      ))}
    </div>
  );
}

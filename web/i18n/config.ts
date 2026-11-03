// Locale configuration shared by the proxy, the layouts and the helpers. No dependencies.
export const locales = ["id", "en"] as const;
export type Lang = (typeof locales)[number];
export const defaultLocale: Lang = "id";
export const LOCALE_COOKIE = "NEXT_LOCALE";

export const intlLocale: Record<Lang, string> = { id: "id-ID", en: "en-US" };

export const hasLocale = (v: string | undefined | null): v is Lang => !!v && (locales as readonly string[]).includes(v);

/** Prefix an internal href with the locale: "/produk" -> "/en/produk", "/" -> "/en", "/hubungi-kami#faq" -> "/en/hubungi-kami#faq". */
export function localeHref(lang: Lang, href: string) {
  if (!href.startsWith("/") || href.startsWith("//")) return href;
  if (href === "/") return `/${lang}`;
  if (href.startsWith("/#") || href.startsWith("/?")) return `/${lang}${href.slice(1)}`;
  return `/${lang}${href}`;
}

/** Remove a leading locale segment: "/en/produk" -> "/produk", "/id" -> "/". */
export function stripLocale(path: string) {
  const m = path.match(/^\/(id|en)(\/.*)?$/);
  return m ? m[2] ?? "/" : path;
}

/** Best locale from an Accept-Language header (primary subtag, q-values), or the default. */
export function fromAcceptLanguage(header: string | null | undefined): Lang {
  if (!header) return defaultLocale;
  const ranked = header
    .split(",")
    .map((part) => {
      const [tag, ...params] = part.trim().split(";");
      const q = Number(params.find((p) => p.trim().startsWith("q="))?.split("=")[1] ?? "1");
      return { primary: tag.trim().toLowerCase().split("-")[0], q: Number.isFinite(q) ? q : 0 };
    })
    .filter((x) => x.q > 0)
    .sort((a, b) => b.q - a.q);
  for (const r of ranked) if (hasLocale(r.primary)) return r.primary;
  return defaultLocale;
}

/** Replace {name} placeholders. */
export function fmt(template: string, values: Record<string, string | number>) {
  return template.replace(/\{(\w+)\}/g, (_, k: string) => String(values[k] ?? `{${k}}`));
}

import type { Metadata } from "next";
import type { Lang } from "@/i18n/config";

/** Localized title/description plus canonical and hreflang alternates (relative URLs resolve against metadataBase). */
export function pageMetadata(lang: Lang, path: string, m: { title: string; description: string }): Metadata {
  const at = (l: string) => (path === "/" ? `/${l}` : `/${l}${path}`);
  return {
    title: m.title,
    description: m.description,
    alternates: { canonical: at(lang), languages: { id: at("id"), en: at("en"), "x-default": at("id") } },
  };
}

import Link from "next/link";
import type { ComponentProps } from "react";
import { localeHref, type Lang } from "@/i18n/config";

/** next/link that prefixes internal hrefs with the locale. */
export default function LocaleLink({ lang, href, ...rest }: { lang: Lang; href: string } & Omit<ComponentProps<typeof Link>, "href">) {
  return <Link href={localeHref(lang, href)} scroll={false} {...rest} />;
}

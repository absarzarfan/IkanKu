import { cookies } from "next/headers";
import { LOCALE_COOKIE, hasLocale, defaultLocale } from "@/i18n/config";
import { getDictionary } from "@/i18n";
import LocaleLink from "@/components/LocaleLink";

export default async function NotFound() {
  const c = (await cookies()).get(LOCALE_COOKIE)?.value;
  const lang = hasLocale(c) ? c : defaultLocale;
  const d = getDictionary(lang);
  return (
    <main className="container-page flex min-h-[60vh] flex-col items-center justify-center gap-4 py-20 text-center">
      <h1 className="text-3xl font-bold text-brand md:text-h1">{d.notFound.title}</h1>
      <p className="max-w-[46ch] text-body">{d.notFound.text}</p>
      <LocaleLink lang={lang} href="/" className="btn-outline inline-flex min-h-11 items-center rounded-lg border border-black px-5 py-2 text-sm">{d.notFound.back}</LocaleLink>
    </main>
  );
}

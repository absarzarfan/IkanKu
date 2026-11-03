import { NextResponse, type NextRequest } from "next/server";
import { LOCALE_COOKIE, fromAcceptLanguage, hasLocale, locales } from "@/i18n/config";

// Old unprefixed public URLs redirect to the preferred locale: NEXT_LOCALE cookie first, then Accept-Language, default "id".
export function proxy(request: NextRequest) {
  const { pathname } = request.nextUrl;
  if (locales.some((l) => pathname === `/${l}` || pathname.startsWith(`/${l}/`))) return;

  const cookie = request.cookies.get(LOCALE_COOKIE)?.value;
  const lang = hasLocale(cookie) ? cookie : fromAcceptLanguage(request.headers.get("accept-language"));
  const url = request.nextUrl.clone();
  url.pathname = pathname === "/" ? `/${lang}` : `/${lang}${pathname}`;
  return NextResponse.redirect(url);
}

export const config = {
  // Skip Next internals, /admin, /icon.png and anything with a file extension (images, fonts, ...).
  matcher: ["/((?!_next|admin|api|.*\..*).*)"],
};

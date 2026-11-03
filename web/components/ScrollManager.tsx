"use client";
import { usePathname } from "next/navigation";
import { useEffect } from "react";

export const SCROLL_KEY = "lang-switch-scroll";

// Single owner of scroll position on navigation (all public links use scroll={false}).
// - Language switch: keep the saved position.  - URL with #hash: jump to that element.  - Otherwise: top of the page.
// Always instant (bypasses the CSS smooth scroll), so the page never glides down on its own.
export default function ScrollManager() {
  const path = usePathname();
  useEffect(() => {
    let saved: string | null = null;
    try { saved = sessionStorage.getItem(SCROLL_KEY); sessionStorage.removeItem(SCROLL_KEY); } catch {}
    const html = document.documentElement;
    const prev = html.style.scrollBehavior;
    html.style.scrollBehavior = "auto";
    const go = () => {
      if (saved !== null) window.scrollTo(0, Number(saved));
      else if (window.location.hash) document.getElementById(decodeURIComponent(window.location.hash.slice(1)))?.scrollIntoView();
      else window.scrollTo(0, 0);
    };
    go();
    const id = requestAnimationFrame(() => { go(); requestAnimationFrame(() => { go(); html.style.scrollBehavior = prev; }); });
    return () => { cancelAnimationFrame(id); html.style.scrollBehavior = prev; };
  }, [path]);
  return null;
}

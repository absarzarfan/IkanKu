import type { CarouselItem, CarouselLabels } from "@/components/HeadlineCarousel";
import type { ListArticle } from "@/components/ArticleList";
import { ARTICLE_AUTHOR, ARTICLE_CATEGORIES, SHOW_AI_LABEL, formatArticleDate, imageWidth, readingMinutes, type Article } from "@/lib/articles";
import { fmt, localeHref, type Lang } from "@/i18n/config";
import type { Dict } from "@/i18n";

// Server-side helpers that turn localized articles into plain, already-translated props for the components.

export const categoryLabel = (a: Article, d: Dict) => d.articles.categories[a.category];

/** "11 Januari 2024 · 5 menit baca" / "January 11, 2024 · 5 min read". */
export const articleMeta = (a: Article, lang: Lang, d: Dict) => `${formatArticleDate(a, lang)} · ${fmt(d.common.readingTime, { n: readingMinutes(a) })}`;

/** Article note: Indonesian pages show "Written with AI assistance" for AI articles; English pages add "Translated from Indonesian" for translated originals. */
export function articleNote(a: Article, lang: Lang, d: Dict): string | null {
  if (a.aiGenerated) return SHOW_AI_LABEL ? d.articles.aiLabel : null;
  return lang === "en" ? d.articles.translatedLabel : null;
}

export const articleHref = (lang: Lang, slug: string) => localeHref(lang, `/artikel/${slug}`);

export function articleCarouselItems(items: Article[], lang: Lang, d: Dict): { items: CarouselItem[]; labels: CarouselLabels } {
  const c = d.articles.carousel;
  return {
    items: items.map((a) => ({
      slug: a.slug,
      href: articleHref(lang, a.slug),
      image: a.image,
      width: imageWidth(a),
      title: a.title,
      excerpt: a.excerpt,
      kicker: categoryLabel(a, d),
      meta: articleMeta(a, lang, d),
    })),
    labels: { label: c.label, slideLabel: c.slideLabel, prev: c.prev, next: c.next, pause: c.pause, play: c.play, goTo: c.goTo, empty: d.articles.empty, author: ARTICLE_AUTHOR },
  };
}

export function articleListProps(items: Article[], lang: Lang, d: Dict) {
  const articles: ListArticle[] = items.map((a) => ({ slug: a.slug, href: articleHref(lang, a.slug), image: a.image, title: a.title, category: a.category, categoryLabel: categoryLabel(a, d), meta: articleMeta(a, lang, d) }));
  const categories = ARTICLE_CATEGORIES.map((key) => ({ key: key as string, label: d.articles.categories[key] }));
  const labels = { placeholder: d.articles.searchPlaceholder, searchLabel: d.articles.searchLabel, filterLabel: d.articles.filterLabel, all: d.articles.filterAll, noResults: d.articles.noResults };
  return { articles, categories, labels };
}

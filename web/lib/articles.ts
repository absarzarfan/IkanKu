// Article data. Titles/dates/images come from the Figma "Artikel" list frames (page 1 = 3261:2654, page 2 = 3382:2538).
// Titles are truncated exactly as in Figma (full titles are not available) and are NOT modified here.
// Bodies are AI-assisted drafts (see lib/article-bodies.ts, lib/article-extras.ts and docs/ai-articles.md).
import { articleBodies, type ArticleSection } from "./article-bodies";
import { articleExtras } from "./article-extras";

export const ARTICLE_CATEGORIES = ["Budidaya", "Pasar & Ekonomi", "Lingkungan", "Tips"] as const;
export type ArticleCategory = (typeof ARTICLE_CATEGORIES)[number];

export const ARTICLE_AUTHOR = "IkanKu";
/** Set to false to hide the "Ditulis dengan bantuan AI" label everywhere. */
export const SHOW_AI_LABEL = true;
export const AI_LABEL = "Ditulis dengan bantuan AI";

export type Article = {
  slug: string;
  title: string;
  date: string;
  category: ArticleCategory;
  image: string;
  excerpt?: string;
  kicker?: string;
  aiGenerated?: boolean;
  reviewStatus?: "draft" | "reviewed";
  body?: ArticleSection[];
  pull?: string;
};

const MONTHS: Record<string, number> = { januari: 0, februari: 1, maret: 2, april: 3, mei: 4, juni: 5, juli: 6, agustus: 7, sep: 8, september: 8, oktober: 9, november: 10, desember: 11 };

/** Timestamp for sorting; dates are stored as the Indonesian strings from the design. */
export function articleTime(a: Pick<Article, "date">) {
  const [d, m, y] = a.date.toLowerCase().split(" ");
  return new Date(Number(y), MONTHS[m] ?? 0, Number(d)).getTime();
}

export function articleWords(a: Article) {
  const text = [a.excerpt ?? "", ...(a.body ?? []).flatMap((s) => [s.heading ?? "", ...s.paragraphs])].join(" ");
  return text.split(/\s+/).filter(Boolean).length;
}

/** Reading time in minutes (200 wpm, minimum 1). */
export function readingMinutes(a: Article) {
  return Math.max(1, Math.ceil(articleWords(a) / 200));
}

type Meta = { category: ArticleCategory; pull?: string };
const meta: Record<string, Meta> = {
  "mendukung-ketahanan-pangan-melalui-agribisnis-perikanan-air-tawar": { category: "Pasar & Ekonomi", pull: "Ketahanan pangan tidak dibangun oleh satu langkah saja." },
  "budidaya-ikan-air-tawar-menggunakan": { category: "Budidaya" },
  "memahami-ciri-ciri-perikanan-air-tawar": { category: "Lingkungan" },
  "5-manfaat-ikan-air-tawar": { category: "Tips" },
  "5-jenis-ikan-air-tawar": { category: "Tips" },
  "5-fakta-ikan-mujair": { category: "Tips" },
  "ikan-air-tawar-terancam": { category: "Lingkungan" },
  "ikan-laut-atau-air-tawar": { category: "Tips", pull: "Bagi sebagian besar orang, mengonsumsi ikan secara bervariasi lebih bermanfaat daripada terpaku pada satu pilihan." },
  "ikan-lele-jenis-air-tawar": { category: "Budidaya" },
  "perbedaan-perikanan-air-payau": { category: "Budidaya" },
  "inovasi-teknologi-budidaya": { category: "Budidaya" },
  "purwakarta-perkuat-posisi": { category: "Pasar & Ekonomi" },
  "pokdakan-dan-poklahsar": { category: "Pasar & Ekonomi" },
};

type Base = { slug: string; title: string; date: string; image: string; excerpt?: string };

function build(b: Base): Article {
  const m = meta[b.slug];
  const body = articleBodies[b.slug];
  const extra = articleExtras[b.slug];
  const sections = body ? [...body.sections] : [];
  if (extra && sections.length > 1) sections.splice(sections.length - 1, 0, extra);
  const text = sections.flatMap((s) => s.paragraphs).join(" ");
  return {
    ...b,
    excerpt: b.excerpt ?? body?.excerpt,
    category: m.category,
    kicker: m.category,
    aiGenerated: !!body,
    reviewStatus: "draft",
    body: sections,
    pull: m.pull && text.includes(m.pull) ? m.pull : undefined,
  };
}

export const featured: Article = build({
  slug: "mendukung-ketahanan-pangan-melalui-agribisnis-perikanan-air-tawar",
  title: "Mendukung Ketahanan Pangan Melalui Agribisnis Perikanan Air Tawar",
  date: "11 Januari 2024",
  image: "/img/artikel/featured.jpeg",
  excerpt:
    "Agribisnis perikanan air tawar menjadi sektor yang semakin strategis dalam mendukung ketahanan pangan di berbagai negara. Dengan sumb...",
});

const a = (slug: string, title: string, date: string, image: string): Article => build({ slug, title, date, image });

export const articles: Article[] = [
  a("budidaya-ikan-air-tawar-menggunakan", "Budidaya Ikan Air Tawar Mengguna....", "19 Juni 2024", "/img/artikel/a1.png"),
  a("memahami-ciri-ciri-perikanan-air-tawar", "Memahami Ciri-ciri Perikanan Air Taw....", "24 Januari 2024", "/img/artikel/a2.png"),
  a("5-manfaat-ikan-air-tawar", "Ini 5 Manfaat Ikan Air Tawar untuk Kes....", "30 Desember 2023", "/img/artikel/a3.png"),
  a("5-jenis-ikan-air-tawar", "5 Jenis Ikan Air Tawar yang Sering....", "24 Juni 2024", "/img/artikel/a4.png"),
  a("5-fakta-ikan-mujair", "Inilah 5 Fakta Mengenai Ikan Mu....", "18 Agustus 2024", "/img/artikel/a5.png"),
  a("ikan-air-tawar-terancam", "Ikan air tawar di dunia terancam p....", "21 Juli 2023", "/img/artikel/a6.png"),
  a("ikan-laut-atau-air-tawar", "Mana yang Lebih Bergizi: Ikan Laut A....", "5 Agustus 2023", "/img/artikel/b1.jpg"),
  a("ikan-lele-jenis-air-tawar", "Ikan Lele Jenis Ikan Air Tawar yang Po....", "21 Juli 2023", "/img/artikel/b2.jpg"),
  a("perbedaan-perikanan-air-payau", "Perbedaan Perikanan Air Pay....", "11 Januari 2024", "/img/artikel/b3.jpg"),
  a("inovasi-teknologi-budidaya", "Inovasi Teknologi dalam Budidaya....", "21 Agustus 2024", "/img/artikel/b4.jpeg"),
  a("purwakarta-perkuat-posisi", "Purwakarta Perkuat Posisi Sebagai Pen....", "2 Mei 2024", "/img/artikel/b5.jpg"),
  a("pokdakan-dan-poklahsar", "Pokdakan dan Poklahsar Dapat B....", "13 Sep 2024", "/img/artikel/b6.jpg"),
];

export const allArticles = [featured, ...articles];

/** Newest first. */
export const articlesByDate = [...allArticles].sort((x, y) => articleTime(y) - articleTime(x));

export function getArticle(slug: string) {
  return allArticles.find((x) => x.slug === slug);
}

export function latestArticles(n: number) {
  return articlesByDate.slice(0, n);
}

/** Related articles: same category first, then the rest by date. */
export function relatedArticles(a: Article, n = 3) {
  const others = articlesByDate.filter((x) => x.slug !== a.slug);
  return [...others.filter((x) => x.category === a.category), ...others.filter((x) => x.category !== a.category)].slice(0, n);
}

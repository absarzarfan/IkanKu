import type { IconName } from "@/components/icons";
import type { Dict } from "@/i18n";

// FAQ structure (ids, categories, icons). The texts live in the dictionaries (i18n/id.ts, i18n/en.ts, key "faq").
// Items listed under NEEDS CONFIRMATION in docs/decisions.md are written without specifics on purpose.

export type FaqCategory = "Umum" | "Pembelian" | "Pembayaran" | "Pengiriman" | "Ulasan";

export type FaqItem = {
  id: string;
  category: FaqCategory;
  question: string;
  answer: string;
  steps?: string[];
  icon: IconName;
};

export type FaqUi = { title: string; intro: string; filterLabel: string; all: string };

export const faqCategoryOrder: FaqCategory[] = ["Umum", "Pembelian", "Pembayaran", "Pengiriman", "Ulasan"];

const structure: { id: string; category: FaqCategory; icon: IconName }[] = [
  { id: "apa-itu-ikanku", category: "Umum", icon: "fish" },
  { id: "cara-mendaftar", category: "Umum", icon: "phoneApp" },
  { id: "lupa-kata-sandi", category: "Umum", icon: "shield" },
  { id: "penjual-tambah-produk", category: "Umum", icon: "layers" },
  { id: "cara-pembelian", category: "Pembelian", icon: "cart" },
  { id: "pesanan-ditolak", category: "Pembelian", icon: "tag" },
  { id: "pengembalian", category: "Pembelian", icon: "shield" },
  { id: "metode-pembayaran", category: "Pembayaran", icon: "card" },
  { id: "kirim-atau-jemput", category: "Pengiriman", icon: "truck" },
  { id: "melacak-pesanan", category: "Pengiriman", icon: "pin" },
  { id: "cara-ulasan", category: "Ulasan", icon: "star" },
];

/** Localized FAQ for one language. */
export function buildFaq(d: Dict) {
  const texts = d.faq.items as Record<string, { question: string; answer: string; steps?: string[] }>;
  const faqs: FaqItem[] = structure.map((s) => ({ ...s, ...texts[s.id] }));
  const categories = faqCategoryOrder
    .filter((c) => faqs.some((f) => f.category === c))
    .map((c) => ({ key: c, label: d.faq.categories[c] }));
  const ui: FaqUi = { title: d.faq.title, intro: d.faq.intro, filterLabel: d.faq.filterLabel, all: d.faq.all };
  return { faqs, categories, ui };
}

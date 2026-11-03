import type { IconName } from "@/components/icons";
import type { Dict } from "@/i18n";

// Visi/Misi/Tujuan: structure here (keys and icons); the wording is in the dictionaries (key "visiMisi").
// DRAFT: the wording needs team approval (docs/approval-pack.md, section A). The Visi sentence is the original site copy.

export type VisiMisiItem = { icon: IconName; title: string; text: string };
export type VisiMisiTab = { key: "Visi" | "Misi" | "Tujuan"; label: string; icon: IconName; lead: string; items: VisiMisiItem[] };

const icons: Record<"visi" | "misi" | "tujuan", { tab: IconName; items: IconName[] }> = {
  visi: { tab: "eye", items: ["eye", "phoneApp", "smile"] },
  misi: { tab: "flag", items: ["tag", "home", "shield", "cart", "fish"] },
  tujuan: { tab: "target", items: ["tag", "home", "cart", "fish"] },
};
const keys = { visi: "Visi", misi: "Misi", tujuan: "Tujuan" } as const;

export function buildVisiMisi(d: Dict): VisiMisiTab[] {
  return (["visi", "misi", "tujuan"] as const).map((k) => ({
    key: keys[k],
    label: d.visiMisi[k].label,
    icon: icons[k].tab,
    lead: d.visiMisi[k].lead,
    items: d.visiMisi[k].items.map((it, i) => ({ icon: icons[k].items[i], title: it.title, text: it.text })),
  }));
}

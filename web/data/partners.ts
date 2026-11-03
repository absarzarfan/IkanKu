import type { Dict } from "@/i18n";

export type Partner = {
  name: string;
  location: string;
  image: string;
  imageAlt: string;
  description: string;
};

// Names and images are language-neutral; location and description come from the dictionary (key "about.partners").
const structure = [{ id: "tibelat" as const, name: "Tibelat Farm", image: "/img/tentang/tibelat.jpeg" }];

export function buildPartners(d: Dict): Partner[] {
  return structure.map((p) => ({ name: p.name, image: p.image, ...d.about.partners[p.id] }));
}

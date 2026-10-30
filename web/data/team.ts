export type TeamRole = "Hustler" | "Designer" | "Programmer";

export type TeamMember = {
  name: string;
  role: TeamRole;
  /** File under web/public/team, e.g. "/team/surya-fahriandi.png". Falls back to initials if missing. */
  photo: string;
  bio?: string;
  links?: { label: string; href: string }[];
  /** object-position for the circular crop; default "50% 20%". */
  focus?: string;
  /** Scale applied to the photo inside the circle (default 1). */
  zoom?: number;
  /** transform-origin for the zoom: where the face sits inside the circle (default "50% 50%"). */
  origin?: string;
  isPlaceholder?: boolean;
};

// One-line summaries, shortened from the previous role paragraphs.
export const roles: { role: TeamRole; desc: string }[] = [
  { role: "Hustler", desc: "Mendukung pertumbuhan ekonomi lokal dan meningkatkan nilai jual ikan air tawar." },
  { role: "Designer", desc: "Merancang antarmuka UX/UI yang intuitif bagi pengguna." },
  { role: "Programmer", desc: "Mengembangkan fitur web dan aplikasi mobile dengan optimal." },
];

export const slugify = (name: string) => name.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");

const m = (name: string, role: TeamRole, focus?: string, zoom?: number, origin?: string): TeamMember => ({
  name, role, photo: `/team/${slugify(name)}.png`, focus, zoom, origin,
});

// Names and roles come from the existing /tentang-kami page (no placeholders needed).
export const team: TeamMember[] = [
  m("Surya Fahriandi", "Hustler", "50% 0%", 3, "47% 40%"),
  m("Mohamad Feby", "Hustler", "50% 50%", 1.2, "47% 22%"),
  m("Naufal Fadhilah", "Hustler", "50% 50%", 2.6, "51% 50%"),
  m("Dicky Aryadi", "Designer", "50% 50%", 1.15, "47% 28%"),
  m("Hafid Daris F", "Designer", "50% 50%", 2.6, "47% 37%"),
  m("Ririn Fitri Wulandari", "Designer", "50% 50%", 1.9, "58% 40%"),
  m("Miftahul Fazra", "Designer", "50% 50%", 2.6, "46% 30%"),
  m("Muhammad Dzakwan Naufal", "Programmer", "50% 50%", 1.8, "50% 35%"),
  m("Andi", "Programmer", "50% 0%", 2.2, "48% 33%"),
  m("Muhammad Dzaky Naufal", "Programmer", "50% 50%", 1.6, "50% 24%"),
  m("Zia Djulyanza", "Programmer", "50% 40%", 2.4, "42% 50%"),
  m("Absar R Zarfan", "Programmer", "50% 50%", 1.25, "45% 30%"),
];

/** Members of one role, sorted by name (A-Z) so the grid reads left to right, then down. */
export const membersOf = (role: TeamRole) =>
  team.filter((p) => p.role === role).sort((x, y) => x.name.localeCompare(y.name, "id"));

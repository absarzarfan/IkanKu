export type TeamRole = "Hustler & Scrum Master" | "Designer" | "Programmer";

export type TeamMember = {
  name: string;
  role: TeamRole;
  /** File under web/public/team, e.g. "/team/surya-fahriandi.png". Falls back to initials if missing. */
  photo: string;
  bio?: string;
  links?: { label: string; href: string }[];
  /** object-position for the circular crop; default "50% 20%". */
  focus?: string;
  isPlaceholder?: boolean;
};

// One-line summaries, shortened from the previous role paragraphs.
export const roles: { role: TeamRole; desc: string }[] = [
  { role: "Hustler & Scrum Master", desc: "Memimpin tim dan memastikan setiap tahapan proyek berjalan lancar." },
  { role: "Designer", desc: "Merancang antarmuka UX/UI yang intuitif bagi pengguna." },
  { role: "Programmer", desc: "Mengembangkan fitur web dan aplikasi mobile dengan optimal." },
];

export const slugify = (name: string) => name.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");

const m = (name: string, role: TeamRole, focus?: string): TeamMember => ({ name, role, photo: `/team/${slugify(name)}.png`, focus });

// Names and roles come from the existing /tentang-kami page (no placeholders needed).
export const team: TeamMember[] = [
  m("Surya Fahriandi", "Hustler & Scrum Master"),
  m("Mohamad Feby", "Hustler & Scrum Master"),
  m("Naufal Fadhilah", "Hustler & Scrum Master"),
  m("Dicky Aryadi", "Designer"),
  m("Hafid Daris F", "Designer"),
  m("Ririn Fitri Wulandari", "Designer"),
  m("Miftahul Fazra", "Designer"),
  m("Muhammad Dzakwan Naufal", "Programmer"),
  m("Andi", "Programmer"),
  m("Muhammad Dzaky Naufal", "Programmer"),
  m("Zia Djulyanza", "Programmer"),
  m("Absar R Zarfan", "Programmer"),
];

/** Members of one role, sorted by name (A-Z) so the grid reads left to right, then down. */
export const membersOf = (role: TeamRole) =>
  team.filter((p) => p.role === role).sort((x, y) => x.name.localeCompare(y.name, "id"));

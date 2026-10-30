export type TeamRole = "Hustler & Scrum Master" | "Designer" | "Programmer";

export type TeamMember = {
  name: string;
  role: TeamRole;
  /** File under web/public/team, e.g. "/team/surya-fahriandi.png". Falls back to initials if missing. */
  photo: string;
  bio?: string;
  links?: { label: string; href: string }[];
  isPlaceholder?: boolean;
};

export const roles: { role: TeamRole; desc: string }[] = [
  {
    role: "Hustler & Scrum Master",
    desc: "Sebagai Hustler dan Scrum Master di proyek IkanKu, mereka memimpin tim dengan efektif, memastikan setiap tahapan berjalan lancar, serta menghadirkan solusi inovatif untuk marketplace ikan tawar. Fokus utama mereka adalah mendukung ekonomi lokal dan memudahkan petani ikan dalam memasarkan produk.",
  },
  {
    role: "Designer",
    desc: "Para desainer berfokus pada User Experience (UX) dan User Interface (UI). Dengan pemahaman mendalam tentang kebutuhan pengguna, mereka merancang antarmuka yang intuitif dan estetis untuk memberikan pengalaman terbaik dalam menggunakan aplikasi ini.",
  },
  {
    role: "Programmer",
    desc: "Tim developer atau programmer yang memiliki keahlian dalam bidang pengembangan web dan aplikasi mobile. Mereka memastikan bahwa setiap fitur bekerja dengan optimal, memprioritaskan kecepatan, keamanan, dan kemudahan penggunaan aplikasi.",
  },
];

export const slugify = (name: string) => name.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");

const m = (name: string, role: TeamRole): TeamMember => ({ name, role, photo: `/team/${slugify(name)}.png` });

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

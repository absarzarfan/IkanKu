// Mock article data. Titles/dates/images come from the Figma "Artikel" list frames
// (page 1 = 3261:2654, page 2 = 3382:2538). Titles are truncated exactly as in Figma
// (full titles are not available). Page 3 (3789:2826) could not be read (Figma MCP rate limit).
export type Article = {
  slug: string;
  title: string;
  date: string;
  category: "Bisnis" | "Kesehatan" | "Budidaya";
  image: string;
  excerpt?: string;
};

export const featured: Article = {
  slug: "mendukung-ketahanan-pangan-melalui-agribisnis-perikanan-air-tawar",
  title: "Mendukung Ketahanan Pangan Melalui Agribisnis Perikanan Air Tawar",
  date: "11 Januari 2024",
  category: "Bisnis",
  image: "/img/artikel/featured.png",
  excerpt:
    "Agribisnis perikanan air tawar menjadi sektor yang semakin strategis dalam mendukung ketahanan pangan di berbagai negara. Dengan sumb...",
};

const a = (slug: string, title: string, date: string, image: string): Article => ({
  slug,
  title,
  date,
  category: "Bisnis",
  image,
});

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
  a("inovasi-teknologi-budidaya", "Inovasi Teknologi dalam Budidaya....", "21 Agustus 2024", "/img/artikel/b4.jpg"),
  a("purwakarta-perkuat-posisi", "Purwakarta Perkuat Posisi Sebagai Pen....", "2 Mei 2024", "/img/artikel/b5.jpg"),
  a("pokdakan-dan-poklahsar", "Pokdakan dan Poklahsar Dapat B....", "13 Sep 2024", "/img/artikel/b6.jpg"),
];

export const allArticles = [featured, ...articles];

export function getArticle(slug: string) {
  return allArticles.find((x) => x.slug === slug);
}

/** Headings of the featured article's detail frame (432:1486). Body copy was not retrievable. */
export const featuredHeadings = [
  "Budidaya Ikan Sebagai Pilar Utama:",
  "Manajemen Sumber Daya Alam:",
  "Peluang Pengembangan Ekonomi Lokal:",
  "Keberlanjutan Agribisnis Perikanan:",
];

import type { IconName } from "@/components/icons";

// DRAFT (Phase 9a): Visi/Misi/Tujuan need team approval. Visi sentence is the original site copy;
// Misi/Tujuan only reuse ideas already present in the site copy (about text, hero, product benefits, app features).

export type VisiMisiItem = { icon: IconName; title: string; text: string };
export type VisiMisiTab = { key: "Visi" | "Misi" | "Tujuan"; icon: IconName; lead: string; items: VisiMisiItem[] };

export const visiMisiUi = {
  tablistLabel: "Visi, Misi, dan Tujuan IkanKu",
  heading: "IkanKu",
};

export const visiMisiTabs: VisiMisiTab[] = [
  {
    key: "Visi",
    icon: "eye",
    lead: "Menjadi platform terpercaya yang menghubungkan konsumen dengan produk ikan tawar berkualitas melalui transparansi, inovasi dan pelayanan unggul, guna mendukung pertumbuhan ekonomi lokal dan keberlanjutan sektor perikanan.",
    items: [
      { icon: "eye", title: "Transparansi", text: "Informasi produk dan pesanan yang jelas bagi pembeli." },
      { icon: "phoneApp", title: "Inovasi", text: "Aplikasi yang memudahkan jual beli ikan air tawar." },
      { icon: "smile", title: "Pelayanan unggul", text: "Pengalaman berbelanja yang nyaman dari pesan sampai terima." },
    ],
  },
  {
    key: "Misi",
    icon: "flag",
    lead: "Langkah yang kami jalankan agar ikan air tawar semakin bernilai dan mudah dijangkau.",
    items: [
      { icon: "tag", title: "Meningkatkan nilai jual", text: "Meningkatkan nilai jual ikan air tawar." },
      { icon: "home", title: "Menopang ekonomi lokal", text: "Mendukung pertumbuhan ekonomi lokal." },
      { icon: "shield", title: "Menjaga kualitas", text: "Menjaga kualitas dalam setiap transaksi." },
      { icon: "cart", title: "Akses ikan segar", text: "Memudahkan pembeli mendapatkan ikan segar." },
      { icon: "fish", title: "Menjangkau pembeli", text: "Membantu petani ikan menjangkau pembeli melalui aplikasi." },
    ],
  },
  {
    key: "Tujuan",
    icon: "target",
    lead: "Hasil yang ingin kami capai dari setiap pesanan yang berjalan lewat IkanKu.",
    items: [
      { icon: "tag", title: "Nilai jual lebih baik", text: "Ikan air tawar memiliki nilai jual yang lebih baik." },
      { icon: "home", title: "Ekonomi lokal tumbuh", text: "Ekonomi lokal tumbuh bersama para petani ikan." },
      { icon: "cart", title: "Ikan segar mudah didapat", text: "Pembeli mudah memperoleh ikan air tawar segar." },
      { icon: "fish", title: "Petani terhubung", text: "Petani ikan terhubung langsung dengan pembeli." },
    ],
  },
];

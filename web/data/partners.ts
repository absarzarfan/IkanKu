export type Partner = {
  name: string;
  location: string;
  image: string;
  imageAlt: string;
  description: string;
};

// Copy reused from the previous Mitra Kami card; add more partners here.
export const partners: Partner[] = [
  {
    name: "Tibelat Farm",
    location: "Batam",
    image: "/img/tentang/tibelat.jpeg",
    imageAlt: "Tibelat Farm",
    description:
      "Tibelat Farm adalah salah satu mitra kami yang berlokasi di Batam. Sebagai usaha budidaya ikan tawar terkemuka, Tibelat Farm berkomitmen untuk menyediakan ikan berkualitas tinggi dengan praktik budidaya yang ramah lingkungan. Dengan fasilitas modern dan tim yang berpengalaman, Tibelat Farm memastikan bahwa setiap ikan yang dihasilkan memenuhi standar mutu terbaik. Kami bangga bermitra dengan Tibelat Farm dalam mendukung sektor perikanan yang berkelanjutan.",
  },
];

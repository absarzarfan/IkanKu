// Single source of truth for contact details (footer, /tentang-kami, /hubungi-kami).
export const contact = {
  institution: "Politeknik Negeri Batam",
  tagline: "For Your Goals Beyond Horizon",
  address: "Jl. Ahmad Yani Batam Kota, Kota Batam, Kepulauan Riau, Indonesia",
  phone: "+62-778-469858 Ext.1017",
  phoneHref: "tel:+62778469858,1017",
  fax: "+62-778-463620",
  email: "info@polibatam.ac.id",
  emailHref: "mailto:info@polibatam.ac.id",
  map: {
    query: "Politeknik Negeri Batam",
    embedUrl: "https://www.google.com/maps?q=Politeknik+Negeri+Batam,+Jl.+Ahmad+Yani,+Batam+Kota&output=embed",
    openUrl: "https://www.google.com/maps/search/?api=1&query=Politeknik+Negeri+Batam",
  },
} as const;

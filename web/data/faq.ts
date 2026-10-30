import type { IconName } from "@/components/icons";

// FAQ content (Indonesian). Flows are taken from flutter_app (auth, catalog, cart, checkout, orders, seller).
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

export const faqUi = {
  title: "Pertanyaan Yang Sering Diajukan",
  intro: "Temukan jawaban seputar membeli, membayar, dan menerima ikan air tawar lewat IkanKu.",
  filterLabel: "Filter kategori pertanyaan",
  all: "Semua",
};

export const faqCategoryOrder: FaqCategory[] = ["Umum", "Pembelian", "Pembayaran", "Pengiriman", "Ulasan"];

export const faqs: FaqItem[] = [
  {
    id: "apa-itu-ikanku",
    category: "Umum",
    question: "Apa itu IkanKu?",
    icon: "fish",
    answer:
      "IkanKu adalah aplikasi untuk membeli ikan air tawar segar langsung dari petani ikan. Pembeli dapat memilih produk dan variasi berat, lalu memesan dan membayar dari satu aplikasi. Petani ikan dapat memasarkan hasil budidayanya kepada pembeli melalui aplikasi yang sama.",
  },
  {
    id: "cara-mendaftar",
    category: "Umum",
    question: "Bagaimana cara mendaftar di aplikasi ini?",
    icon: "phoneApp",
    answer: "Pendaftaran dilakukan di aplikasi IkanKu dan hanya membutuhkan beberapa menit. Siapkan nomor ponsel yang aktif, karena kode verifikasi dikirim ke nomor tersebut.",
    steps: [
      "Unduh dan buka aplikasi IkanKu, lalu pilih tab Daftar.",
      "Masukkan nomor ponsel, lalu pilih Lanjut.",
      "Masukkan kode 4 digit yang dikirim ke nomor ponsel Anda.",
      "Lengkapi data: nama lengkap, email, kata sandi (minimal 6 karakter), dan alamat.",
      "Selesaikan pendaftaran, lalu Anda bisa langsung berbelanja.",
    ],
  },
  {
    id: "lupa-kata-sandi",
    category: "Umum",
    question: "Bagaimana jika saya lupa kata sandi?",
    icon: "shield",
    answer: "Anda dapat mengatur ulang kata sandi dari halaman masuk tanpa perlu menghubungi kami. Tautan pengaturan ulang dikirim ke email yang Anda daftarkan.",
    steps: [
      "Di halaman masuk, pilih Lupa kata sandi.",
      "Masukkan alamat email yang terdaftar, lalu pilih Lanjut.",
      "Buka email Anda dan ikuti tautan untuk membuat kata sandi baru.",
    ],
  },
  {
    id: "penjual-tambah-produk",
    category: "Umum",
    question: "Bagaimana cara penjual menambahkan produk?",
    icon: "layers",
    answer: "Penjual mengelola produk dari menu Daftar Produk di akun penjual. Setiap produk dapat memiliki beberapa variasi sehingga pembeli bisa memilih ukuran yang sesuai.",
    steps: [
      "Masuk dengan akun penjual, lalu buka Daftar Produk.",
      "Pilih Tambah produk dan isi data produk beserta kategorinya.",
      "Atur variasi: berat (misalnya 1 Kg), isi (ekor), dan harga.",
      "Simpan. Produk dapat diubah atau dihapus kapan saja.",
    ],
  },
  {
    id: "cara-pembelian",
    category: "Pembelian",
    question: "Bagaimana cara melakukan pembelian ikan tawar di aplikasi ini?",
    icon: "cart",
    answer: "Pembelian dilakukan lewat keranjang, sehingga Anda bisa menggabungkan beberapa produk dalam satu pesanan. Pastikan alamat dan metode pembayaran sudah sesuai sebelum membuat pesanan.",
    steps: [
      "Pilih produk ikan yang Anda inginkan.",
      "Pilih variasi berat yang tersedia, lalu tambahkan ke keranjang.",
      "Buka keranjang, pilih produk yang ingin dibeli, lalu lanjut ke checkout.",
      "Pilih pengiriman dan metode pembayaran, lalu pilih Buat Pesanan.",
      "Selesaikan pembayaran sesuai metode yang Anda pilih.",
    ],
  },
  {
    id: "pesanan-ditolak",
    category: "Pembelian",
    question: "Apa yang terjadi jika pesanan saya ditolak atau dibatalkan?",
    icon: "tag",
    answer:
      "Penjual dapat menolak pesanan, dan status pesanan akan berubah menjadi Ditolak beserta keterangan alasannya. Pesanan yang dibatalkan tampil dengan status Dibatalkan. Anda dapat melihat statusnya kapan saja di Pesanan Saya dan memesan ulang produk yang sama jika diperlukan.",
  },
  {
    id: "pengembalian",
    category: "Pembelian",
    question: "Apakah ada kebijakan pengembalian produk?",
    icon: "shield",
    answer:
      "Pengajuan pengembalian ditangani oleh tim kami. Silakan hubungi kami melalui formulir di halaman ini dan sertakan nomor pesanan serta penjelasan singkat mengenai kendalanya. Ketentuan rinci akan kami sampaikan melalui kanal tersebut.",
  },
  {
    id: "metode-pembayaran",
    category: "Pembayaran",
    question: "Apa saja metode pembayaran yang tersedia?",
    icon: "card",
    answer:
      "Aplikasi menyediakan dua metode, yaitu Transfer dan COD (bayar di tempat). Metode yang tampil di halaman checkout mengikuti pengaturan penjual, sehingga tidak semua penjual membuka kedua metode. Untuk Transfer, rekening penjual ditampilkan setelah pesanan dibuat dan Anda mengunggah bukti pembayaran agar penjual dapat memverifikasinya.",
    steps: [
      "Di halaman checkout, pilih Transfer atau COD pada Metode Pembayaran.",
      "Jika memilih Transfer, lakukan pembayaran ke rekening penjual yang tampil setelah pesanan dibuat.",
      "Unggah bukti pembayaran di halaman pesanan, lalu tunggu verifikasi penjual.",
    ],
  },
  {
    id: "kirim-atau-jemput",
    category: "Pengiriman",
    question: "Apa perbedaan pilihan Kirim dan Jemput?",
    icon: "truck",
    answer:
      "Saat checkout Anda dapat memilih pesanan dikirim ke alamat Anda atau dijemput sendiri. Pilihan Kirim dapat dikenai ongkos kirim yang ditampilkan di ringkasan pesanan sebelum Anda membuat pesanan. Besaran ongkos kirim dan estimasi waktu tiba mengikuti keterangan di halaman checkout.",
  },
  {
    id: "melacak-pesanan",
    category: "Pengiriman",
    question: "Bagaimana cara melacak status pesanan saya?",
    icon: "pin",
    answer: "Semua pesanan Anda tersimpan di menu Pesanan Saya pada halaman Profil. Setiap pesanan menampilkan statusnya, mulai dari Menunggu, Dikemas, Dikirim, hingga Selesai.",
    steps: [
      "Buka halaman Profil, lalu pilih Pesanan Saya.",
      "Pilih tab status: Belum Bayar, Dikemas, Dikirim, Selesai, atau Ditolak.",
      "Pilih pesanan untuk melihat rincian produk, pengiriman, dan pembayaran.",
    ],
  },
  {
    id: "cara-ulasan",
    category: "Ulasan",
    question: "Bagaimana cara memberikan ulasan atau rating produk?",
    icon: "star",
    answer: "Ulasan dapat diberikan setelah pesanan berstatus Selesai. Rating menggunakan bintang, dan Anda bisa menambahkan komentar tentang produk yang diterima. Ulasan Anda tampil di halaman produk dan membantu pembeli lain.",
    steps: [
      "Buka Pesanan Saya, lalu pilih tab Selesai.",
      "Pilih pesanan yang ingin dinilai, lalu pilih Beri Ulasan.",
      "Pilih jumlah bintang dan tulis ulasan Anda.",
      "Kirim ulasan. Notifikasi Ulasan Terkirim akan muncul.",
    ],
  },
];

import type { ArticleSection } from "./article-bodies";

// Additional DRAFT sections (AI-assisted, Phase 9a), inserted before the closing section of each article body.
// Same rules as article-bodies.ts: no statistics, quotes, studies, prices or claims about IkanKu.
export const articleExtras: Record<string, ArticleSection> = {
  "mendukung-ketahanan-pangan-melalui-agribisnis-perikanan-air-tawar": {
    heading: "Peran pembeli dan konsumen",
    paragraphs: [
      "Rantai pangan tidak hanya melibatkan produsen. Pembeli yang memilih ikan dari pembudidaya setempat membantu menjaga usaha kolam tetap berjalan. Kebiasaan sederhana, seperti memilih ikan yang segar dan menanyakan asalnya, mendorong penjual dan pembudidaya menjaga mutu. Dari sisi rumah tangga, ikan juga dapat membantu menganekaragamkan lauk sehingga menu keluarga tidak bergantung pada satu jenis bahan saja.",
    ],
  },
  "budidaya-ikan-air-tawar-menggunakan": {
    heading: "Mengamati kolam setiap hari",
    paragraphs: [
      "Kebiasaan mengamati kolam di pagi dan sore hari membantu pembudidaya mengenali perubahan lebih awal. Warna air, nafsu makan ikan, dan perilaku ikan di permukaan adalah petunjuk sederhana. Jika ada yang terlihat tidak biasa, pembudidaya dapat segera memeriksa air, mengurangi pakan, atau menyesuaikan kerja alat. Catatan harian, meski singkat, memudahkan pembudidaya membandingkan kondisi kolam dari waktu ke waktu dan mengambil keputusan yang lebih tenang.",
    ],
  },
  "memahami-ciri-ciri-perikanan-air-tawar": {
    heading: "Mengapa ciri ini penting bagi pembudidaya",
    paragraphs: [
      "Pembudidaya yang memahami ciri perairan tawar dapat meniru kondisi yang disukai ikan di kolamnya. Air yang jernih, tersedia oksigen, dan tidak terlalu panas atau dingin membuat ikan lebih nyaman. Pengetahuan ini juga membantu pembudidaya memilih jenis ikan yang sesuai dengan sumber air di sekitarnya, sehingga tidak perlu memaksakan jenis yang membutuhkan kondisi berbeda dan berisiko gagal.",
    ],
  },
  "5-manfaat-ikan-air-tawar": {
    heading: "Dukungan bagi pembudidaya setempat",
    paragraphs: [
      "Manfaat ikan tidak berhenti di meja makan. Setiap pembelian ikan dari pembudidaya setempat ikut menggerakkan usaha kecil di sekitar kita. Pembudidaya mendapat kepastian pembeli, sedangkan pembeli memperoleh ikan yang lebih dekat dari tempat asalnya. Hubungan yang dekat antara penjual dan pembeli juga memudahkan pembeli menanyakan cara memilih, menyimpan, dan memasak ikan dengan benar.",
    ],
  },
  "5-jenis-ikan-air-tawar": {
    heading: "Menyesuaikan jenis dengan kebutuhan",
    paragraphs: [
      "Memilih jenis ikan sebaiknya disesuaikan dengan tujuannya. Untuk lauk harian, pembeli dapat memilih jenis yang dagingnya cocok dengan cara memasak yang disukai. Bagi pembudidaya, pilihan jenis dipengaruhi oleh ukuran kolam, sumber air, dan pasar di sekitarnya. Berbincang dengan pembudidaya atau penjual setempat sering menjadi cara terbaik untuk mengetahui jenis yang tersedia dan cocok.",
    ],
  },
  "5-fakta-ikan-mujair": {
    heading: "Tips memilih mujair di pasar",
    paragraphs: [
      "Saat membeli mujair, perhatikan tampilan tubuhnya. Ikan yang segar umumnya terlihat bersih, matanya jernih, dan insangnya berwarna cerah. Tekan perlahan bagian tubuhnya; dagingnya sebaiknya terasa kenyal. Bila membeli dalam jumlah banyak, simpan ikan di tempat dingin dan olah secepatnya agar kesegaran terjaga. Penjual biasanya bersedia membersihkan ikan sesuai permintaan pembeli.",
    ],
  },
  "ikan-air-tawar-terancam": {
    heading: "Apa yang dapat dilakukan",
    paragraphs: [
      "Upaya menjaga perairan dimulai dari hal yang dekat. Membuang sampah pada tempatnya, tidak membuang limbah ke sungai, dan menjaga tepi perairan tetap hijau membantu menjaga rumah ikan. Bagi pemancing, melepas kembali ikan yang masih kecil dapat membantu populasi tetap lestari. Masyarakat dan pelaku usaha juga dapat bekerja sama menjaga aliran air agar tetap sehat.",
    ],
  },
  "ikan-laut-atau-air-tawar": {
    heading: "Mengenali ikan yang segar",
    paragraphs: [
      "Baik ikan laut maupun ikan air tawar, tanda kesegarannya mirip. Mata tampak jernih, insang berwarna cerah, daging terasa kenyal, dan baunya tidak menyengat. Ikan yang dijajakan di atas es atau dalam boks pendingin umumnya lebih terjaga mutunya. Saat membeli, tidak ada salahnya bertanya kapan ikan tiba dan bagaimana cara penyimpanannya, karena penjual biasanya terbuka memberi penjelasan.",
    ],
  },
  "ikan-lele-jenis-air-tawar": {
    heading: "Pakan dan kebersihan kolam",
    paragraphs: [
      "Lele memakan berbagai jenis makanan, tetapi pemberian pakan tetap perlu dijaga agar tidak berlebihan. Sisa pakan yang tidak termakan dapat membuat air cepat kotor. Pembudidaya biasanya mengganti sebagian air secara berkala dan membersihkan kolam agar ikan tetap sehat. Pencatatan sederhana tentang jadwal pakan dan pergantian air membantu pembudidaya menjaga kolam tetap terkendali.",
    ],
  },
  "perbedaan-perikanan-air-payau": {
    heading: "Contoh kegiatan di masing-masing perairan",
    paragraphs: [
      "Di perairan tawar, kegiatan budidaya banyak dilakukan di kolam, keramba, atau sawah. Di perairan payau, budidaya umumnya dilakukan di tambak yang berada dekat pantai atau muara. Lokasi menentukan sarana yang dibutuhkan, misalnya pengaturan pintu air dan pemantauan kadar garam. Pembudidaya yang berpindah dari satu jenis perairan ke jenis lain perlu mempelajari kebutuhan baru ini sebelum memulai.",
    ],
  },
  "inovasi-teknologi-budidaya": {
    heading: "Belajar dari sesama pembudidaya",
    paragraphs: [
      "Banyak inovasi lahir dari pengalaman pembudidaya sendiri. Cara menata kolam, mengatur jadwal pakan, atau menyiasati keterbatasan lahan sering dibagikan lewat pertemuan kelompok. Bertukar pengalaman membantu pembudidaya baru menghindari kesalahan yang sama dan membantu pembudidaya lama menemukan cara yang lebih efisien. Teknologi akan lebih mudah diterima ketika dicoba bersama dan hasilnya dapat dilihat langsung di kolam tetangga.",
    ],
  },
  "purwakarta-perkuat-posisi": {
    heading: "Menjaga mutu dan keberlanjutan",
    paragraphs: [
      "Daerah yang ingin dikenal sebagai sentra perikanan perlu menjaga mutu hasilnya. Penanganan ikan setelah panen, kebersihan wadah, dan ketepatan pengiriman memengaruhi kepercayaan pembeli. Di sisi lain, pengelolaan air dan limbah yang baik menjaga agar kegiatan budidaya dapat terus berlangsung di tempat yang sama dalam jangka panjang tanpa merusak lingkungan sekitarnya.",
    ],
  },
  "pokdakan-dan-poklahsar": {
    heading: "Contoh kegiatan kelompok",
    paragraphs: [
      "Kegiatan kelompok dapat berupa pertemuan rutin untuk membahas masalah kolam, pembelian bersama kebutuhan budidaya, hingga pelatihan sederhana tentang pengolahan ikan. Kelompok pengolah dapat mencoba membuat produk dari ikan agar hasil panen memiliki pilihan pemasaran yang lebih beragam. Semua kegiatan ini bergantung pada kemauan anggota untuk saling berbagi dan menjaga kepercayaan.",
    ],
  },
};

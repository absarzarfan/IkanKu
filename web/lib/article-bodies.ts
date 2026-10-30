// DRAFT article bodies written with AI assistance (Phase 9a). Based only on the article title, what is visible in the
// article image and general qualitative knowledge of freshwater aquaculture. No statistics, quotes, studies, prices or
// claims about IkanKu. Needs editorial review (see docs/ai-articles.md). `pull` must be a sentence copied from the body.

export type ArticleSection = { heading?: string; paragraphs: string[] };
export type ArticleBody = { excerpt?: string; sections: ArticleSection[]; pull?: string };

export const articleBodies: Record<string, ArticleBody> = {
  "mendukung-ketahanan-pangan-melalui-agribisnis-perikanan-air-tawar": {
    sections: [
      { paragraphs: [
        "Ikan air tawar sudah lama menjadi bagian dari meja makan banyak keluarga. Di balik pasokan yang sampai ke pasar, ada rantai kegiatan yang dimulai dari kolam budidaya dan berakhir di tangan pembeli. Agribisnis perikanan air tawar menyatukan rantai itu: dari pembenihan, pembesaran, hingga pemasaran.",
        "Foto kegiatan di tepi kolam pada artikel ini menunjukkan bahwa kolam juga bisa menjadi ruang bertemu warga, bukan sekadar tempat produksi.",
      ] },
      { heading: "Budidaya Ikan Sebagai Pilar Utama:", paragraphs: [
        "Budidaya memberi pasokan ikan yang lebih terencana dibandingkan hasil tangkapan alam. Pembudidaya dapat mengatur jenis ikan, waktu tebar, dan waktu panen sesuai kebutuhan pasar. Pasokan yang lebih teratur membantu pembeli memperoleh ikan segar secara berkelanjutan.",
      ] },
      { heading: "Manajemen Sumber Daya Alam:", paragraphs: [
        "Kolam bergantung pada kualitas air dan lahan. Pengelolaan yang baik berarti menjaga air tetap bersih, memberi pakan secukupnya, dan menghindari limbah yang mencemari lingkungan sekitar. Pembudidaya yang menjaga lingkungannya juga menjaga keberlangsungan usahanya sendiri.",
      ] },
      { heading: "Peluang Pengembangan Ekonomi Lokal:", paragraphs: [
        "Usaha kolam menciptakan kegiatan pendukung di sekitarnya, misalnya penyedia pakan, perlengkapan, pengangkutan, dan pedagang. Ketika kegiatan ini berjalan di tingkat desa atau kecamatan, perputaran ekonominya ikut dirasakan masyarakat setempat.",
      ] },
      { heading: "Keberlanjutan Agribisnis Perikanan:", paragraphs: [
        "Agar usaha dapat berlangsung lama, pembudidaya perlu menyeimbangkan hasil panen dengan kelestarian lingkungan. Pengetahuan teknis, kerja sama antarpembudidaya, dan akses pasar yang jelas menjadi pendukung penting.",
        "Ketahanan pangan tidak dibangun oleh satu langkah saja. Ia tumbuh dari kebiasaan kecil yang konsisten di kolam, di pasar, dan di dapur.",
      ] },
    ],
  },

  "budidaya-ikan-air-tawar-menggunakan": {
    excerpt: "Kincir air di tengah kolam membantu menjaga kualitas air tetap baik bagi ikan yang dibudidayakan.",
    sections: [
      { paragraphs: [
        "Di banyak kolam budidaya, peralatan sederhana sering kali berperan besar. Pada foto artikel ini terlihat kincir air yang berputar di tengah kolam, memercikkan air ke udara. Alat seperti ini umum dipakai pembudidaya untuk membantu menjaga kondisi air.",
      ] },
      { heading: "Mengapa air perlu bergerak", paragraphs: [
        "Ikan mengambil oksigen yang terlarut di dalam air. Air yang diam, terutama di kolam yang padat ikan, dapat kekurangan oksigen. Pergerakan air membantu oksigen dari udara larut ke dalam kolam dan membantu sebaran oksigen lebih merata.",
      ] },
      { heading: "Peran kincir dalam kegiatan harian", paragraphs: [
        "Kincir biasanya digerakkan oleh motor dan diatur waktunya oleh pembudidaya. Pembudidaya yang berpengalaman memperhatikan tanda-tanda pada ikan, misalnya ikan yang sering naik ke permukaan, sebagai petunjuk bahwa kondisi air perlu diperbaiki.",
      ] },
      { heading: "Perawatan dasar yang tetap penting", paragraphs: [
        "Alat bantu tidak menggantikan perawatan dasar. Pakan yang berlebih akan mengendap dan memperburuk kualitas air. Karena itu pemberian pakan secukupnya, pemeriksaan air secara rutin, dan kebersihan kolam tetap menjadi kunci.",
        "Kincir juga perlu dirawat agar bekerja dengan baik, misalnya memeriksa bagian yang berputar dan sambungan listrik agar aman digunakan.",
      ] },
      { heading: "Penutup", paragraphs: [
        "Budidaya ikan air tawar adalah kombinasi antara pengamatan, perawatan, dan peralatan yang tepat. Alat sederhana yang digunakan dengan benar dapat membantu kolam tetap sehat dan hasil panen lebih terjaga.",
      ] },
    ],
  },

  "memahami-ciri-ciri-perikanan-air-tawar": {
    excerpt: "Perikanan air tawar berlangsung di sungai, danau, dan kolam. Mengenali cirinya membantu memahami bagaimana ikan hidup dan dikelola.",
    sections: [
      { paragraphs: [
        "Perikanan air tawar mencakup kegiatan menangkap dan membudidayakan ikan yang hidup di perairan dengan kadar garam sangat rendah, seperti sungai, danau, waduk, dan kolam. Foto di artikel ini memperlihatkan seekor ikan yang berenang di antara tumbuhan air yang jernih.",
      ] },
      { heading: "Habitat yang beragam", paragraphs: [
        "Perairan tawar bisa berupa aliran deras yang dingin atau kolam tenang yang hangat. Setiap jenis ikan menyesuaikan diri dengan kondisinya, sehingga tidak semua ikan cocok dipelihara di semua tempat.",
      ] },
      { heading: "Tumbuhan air sebagai bagian ekosistem", paragraphs: [
        "Tumbuhan air memberi tempat berlindung, tempat bertelur, dan sumber makanan bagi organisme kecil yang menjadi pakan alami. Keberadaannya sering menjadi tanda bahwa perairan masih dalam kondisi yang cukup baik.",
      ] },
      { heading: "Dua cara memperoleh ikan", paragraphs: [
        "Ikan air tawar dapat diperoleh dari penangkapan di perairan umum maupun dari budidaya di kolam atau keramba. Budidaya memberi kendali lebih besar atas jenis dan waktu panen, sedangkan penangkapan sangat bergantung pada kondisi alam dan kelestarian perairan.",
      ] },
      { heading: "Penutup", paragraphs: [
        "Memahami ciri perikanan air tawar membantu kita menghargai asal ikan yang dikonsumsi. Perairan yang terjaga adalah modal utama, baik bagi ikan di alam maupun bagi usaha budidaya.",
      ] },
    ],
  },

  "5-manfaat-ikan-air-tawar": {
    excerpt: "Ikan air tawar dapat menjadi bagian dari menu harian yang beragam. Berikut gambaran umum manfaat yang sering disebut.",
    sections: [
      { paragraphs: [
        "Ikan air tawar mudah dijumpai di pasar dan sering menjadi pilihan menu sehari-hari. Foto di artikel ini memperlihatkan ikan segar yang tertata dalam boks pendingin, yang menjadi cara umum menjaga ikan tetap segar hingga sampai ke pembeli.",
      ] },
      { heading: "Sumber protein hewani", paragraphs: [
        "Ikan umumnya dikenal sebagai sumber protein hewani. Protein dibutuhkan tubuh untuk membangun dan memperbaiki jaringan. Menambahkan ikan ke dalam menu dapat memperkaya pilihan lauk selain daging dan telur.",
      ] },
      { heading: "Menu yang fleksibel", paragraphs: [
        "Ikan air tawar dapat dimasak dengan banyak cara, misalnya digoreng, dibakar, dipepes, atau disajikan berkuah. Variasi ini membantu keluarga menghindari menu yang membosankan.",
      ] },
      { heading: "Mudah ditemukan", paragraphs: [
        "Karena dibudidayakan di banyak daerah, ikan air tawar relatif mudah ditemukan, baik di pasar tradisional maupun di tempat penjualan lain. Pembelian dari pembudidaya setempat juga membantu perputaran ekonomi di sekitar kita.",
      ] },
      { heading: "Memilih dan mengolah dengan baik", paragraphs: [
        "Manfaat ikan akan lebih terasa jika dipilih dan diolah dengan benar. Pilih ikan yang tampak segar, simpan dalam kondisi dingin, dan masak hingga matang. Untuk kebutuhan gizi khusus, sebaiknya berkonsultasi dengan tenaga kesehatan.",
      ] },
    ],
  },

  "5-jenis-ikan-air-tawar": {
    excerpt: "Beberapa jenis ikan air tawar sering dijumpai di pasar dan kolam budidaya. Kenali ciri umumnya agar lebih mudah memilih.",
    sections: [
      { paragraphs: [
        "Indonesia memiliki beragam ikan air tawar yang dibudidayakan dan dikonsumsi. Memahami jenisnya membantu pembeli memilih sesuai selera dan kebutuhan memasak, serta membantu pembudidaya menentukan jenis yang cocok dengan kolamnya.",
      ] },
      { heading: "Lele", paragraphs: [
        "Lele dikenal mudah dipelihara dan banyak dibudidayakan di kolam, termasuk kolam terpal. Dagingnya sering diolah dengan digoreng atau dibakar.",
      ] },
      { heading: "Nila dan mujair", paragraphs: [
        "Nila dan mujair termasuk ikan yang akrab di dapur banyak keluarga. Keduanya sering dibakar, digoreng, atau dimasak berkuah.",
      ] },
      { heading: "Ikan mas", paragraphs: [
        "Ikan mas dibudidayakan di kolam, sawah, maupun keramba, dan juga menjadi menu yang digemari di banyak daerah.",
      ] },
      { heading: "Patin dan gurami", paragraphs: [
        "Patin dan gurami juga banyak dibudidayakan dan sering dijumpai sebagai menu rumah makan maupun hidangan keluarga.",
      ] },
      { heading: "Memilih ikan yang segar", paragraphs: [
        "Apa pun jenisnya, ikan segar umumnya memiliki mata yang jernih, tubuh yang kenyal, dan bau yang tidak menyengat. Menyimpannya di tempat dingin membantu menjaga kesegaran sampai saatnya dimasak.",
      ] },
    ],
  },

  "5-fakta-ikan-mujair": {
    excerpt: "Mujair adalah ikan air tawar yang akrab di banyak dapur. Berikut gambaran umum tentang ikan ini.",
    sections: [
      { paragraphs: [
        "Mujair adalah salah satu ikan air tawar yang sudah lama dikenal masyarakat. Ia mudah ditemukan di pasar dan sering menjadi lauk sehari-hari. Artikel ini merangkum gambaran umum tentang ikan tersebut.",
      ] },
      { heading: "Mudah beradaptasi", paragraphs: [
        "Mujair dikenal cukup mudah menyesuaikan diri dengan berbagai kondisi perairan tawar. Sifat ini membuatnya banyak dipelihara di kolam dan perairan yang tersedia di sekitar permukiman.",
      ] },
      { heading: "Pemakan beragam", paragraphs: [
        "Di alam, mujair memakan berbagai jenis makanan, termasuk tumbuhan air dan organisme kecil. Dalam budidaya, pembudidaya memberikan pakan yang sesuai agar ikan tumbuh baik.",
      ] },
      { heading: "Kerabat dekat nila", paragraphs: [
        "Mujair sering disebut bersamaan dengan nila karena keduanya berkerabat dekat dan memiliki bentuk tubuh yang mirip. Pembeli kadang sulit membedakannya, dan penjual biasanya dapat membantu menjelaskan.",
      ] },
      { heading: "Mudah diolah", paragraphs: [
        "Daging mujair cocok dimasak dengan berbagai cara, seperti digoreng, dibakar, atau dibumbui kuning. Memilih ikan yang segar dan memasaknya hingga matang menjadi kunci hidangan yang lezat.",
      ] },
    ],
  },

  "ikan-air-tawar-terancam": {
    excerpt: "Sungai, danau, dan rawa menjadi rumah bagi banyak ikan. Tekanan terhadap perairan tawar dapat berdampak pada ikan yang hidup di dalamnya.",
    sections: [
      { paragraphs: [
        "Perairan tawar seperti sungai, danau, dan rawa menjadi rumah bagi beragam jenis ikan. Foto pada artikel ini menampilkan seorang pemancing yang memegang ikan di perairan terbuka, pengingat bahwa manusia dekat dengan sumber daya ini.",
        "Berbagai tekanan dapat memengaruhi kelangsungan ikan air tawar, dan banyak di antaranya berasal dari kegiatan manusia.",
      ] },
      { heading: "Perubahan dan kerusakan habitat", paragraphs: [
        "Pembangunan di tepi sungai, pengeringan rawa, atau perubahan aliran air dapat mengubah tempat ikan mencari makan dan berkembang biak. Ketika habitat berubah, tidak semua ikan mampu menyesuaikan diri.",
      ] },
      { heading: "Pencemaran", paragraphs: [
        "Limbah rumah tangga dan kegiatan lain yang masuk ke perairan dapat menurunkan kualitas air. Air yang tercemar mengganggu ikan dan organisme lain yang menjadi bagian dari rantai makanan.",
      ] },
      { heading: "Penangkapan yang tidak terkendali", paragraphs: [
        "Penangkapan yang berlebihan membuat populasi ikan sulit pulih. Karena itu aturan setempat dan kebiasaan menangkap secukupnya menjadi bagian dari menjaga perairan.",
      ] },
      { heading: "Peran budidaya dan kesadaran bersama", paragraphs: [
        "Budidaya yang dikelola dengan baik dapat mengurangi ketergantungan pada hasil tangkapan alam. Meski begitu, menjaga kebersihan perairan tetap tanggung jawab bersama, mulai dari rumah tangga hingga pelaku usaha.",
      ] },
    ],
  },

  "ikan-laut-atau-air-tawar": {
    excerpt: "Ikan laut dan ikan air tawar sama-sama dapat menjadi pilihan menu. Yang terpenting adalah jenis, kesegaran, dan cara mengolahnya.",
    sections: [
      { paragraphs: [
        "Pertanyaan tentang mana yang lebih baik, ikan laut atau ikan air tawar, sering muncul ketika orang memilih lauk. Foto pada artikel ini menampilkan beragam ikan yang dijajakan di pasar, mengingatkan bahwa pilihan di lapangan sangat banyak.",
      ] },
      { heading: "Jenis ikan lebih menentukan daripada asalnya", paragraphs: [
        "Setiap jenis ikan memiliki karakter yang berbeda, baik rasa, tekstur, maupun kandungan gizinya. Karena itu, sulit menyimpulkan bahwa satu kelompok pasti lebih baik daripada yang lain hanya dari asalnya.",
      ] },
      { heading: "Kesegaran dan penanganan", paragraphs: [
        "Ikan yang segar dan ditangani dengan baik lebih menentukan kualitas hidangan. Ikan perlu disimpan dalam kondisi dingin dan tidak dibiarkan terlalu lama di suhu ruang.",
      ] },
      { heading: "Cara memasak", paragraphs: [
        "Cara memasak memengaruhi hidangan akhirnya. Memasak dengan cara dikukus, dipanggang, atau direbus umumnya terasa lebih ringan daripada digoreng dengan banyak minyak.",
      ] },
      { heading: "Penutup", paragraphs: [
        "Bagi sebagian besar orang, mengonsumsi ikan secara bervariasi lebih bermanfaat daripada terpaku pada satu pilihan. Untuk kebutuhan gizi tertentu, tenaga kesehatan adalah rujukan yang tepat.",
      ] },
    ],
  },

  "ikan-lele-jenis-air-tawar": {
    excerpt: "Lele adalah ikan air tawar yang populer di dapur dan di kolam budidaya.",
    sections: [
      { paragraphs: [
        "Lele termasuk ikan air tawar yang sangat dikenal di Indonesia. Foto pada artikel ini memperlihatkan sekumpulan lele dengan kumis khasnya. Popularitasnya terlihat dari banyaknya warung dan rumah makan yang menjadikannya menu utama.",
      ] },
      { heading: "Ciri umum", paragraphs: [
        "Lele memiliki tubuh memanjang dengan kulit licin dan sungut di sekitar mulut. Sungut ini membantu ikan mencari makan di perairan yang keruh atau gelap.",
      ] },
      { heading: "Cocok untuk berbagai skala usaha", paragraphs: [
        "Lele dapat dipelihara di kolam tanah, kolam beton, maupun kolam terpal. Keluwesan ini membuat banyak orang memulai budidaya dari skala kecil di halaman rumah, kemudian berkembang bila usahanya berjalan baik.",
      ] },
      { heading: "Pasar yang akrab", paragraphs: [
        "Lele sudah akrab di lidah masyarakat, sehingga pembudidaya relatif mudah menemukan pembeli di sekitarnya, mulai dari rumah tangga hingga pelaku usaha kuliner.",
      ] },
      { heading: "Penanganan setelah panen", paragraphs: [
        "Seperti ikan lain, lele perlu ditangani dengan baik setelah panen agar tetap segar saat sampai ke pembeli. Wadah yang bersih, air yang cukup, dan waktu pengantaran yang singkat membantu menjaga mutunya.",
      ] },
    ],
  },

  "perbedaan-perikanan-air-payau": {
    excerpt: "Air payau dan air tawar memiliki karakter yang berbeda, dan keduanya menuntut cara pengelolaan yang berbeda pula.",
    sections: [
      { paragraphs: [
        "Dalam dunia perikanan, jenis air menentukan ikan apa yang dapat dipelihara dan bagaimana kolam dikelola. Dua jenis yang sering dibandingkan adalah air payau dan air tawar.",
      ] },
      { heading: "Perbedaan dasar", paragraphs: [
        "Air tawar memiliki kadar garam yang sangat rendah, seperti pada sungai, danau, dan sebagian besar kolam. Air payau merupakan campuran antara air tawar dan air laut, biasanya ditemukan di muara atau di sekitar pantai.",
      ] },
      { heading: "Ikan yang dipelihara", paragraphs: [
        "Tidak semua ikan dapat hidup di kedua jenis air. Setiap jenis ikan telah menyesuaikan diri dengan kadar garam tertentu. Karena itu pembudidaya memilih jenis ikan yang cocok dengan sumber air yang tersedia.",
      ] },
      { heading: "Pengelolaan kolam", paragraphs: [
        "Pada perikanan air tawar, pembudidaya memperhatikan kebersihan air dan kecukupan oksigen. Pada air payau, perubahan kadar garam akibat hujan atau pasang surut juga perlu diamati.",
      ] },
      { heading: "Penutup", paragraphs: [
        "Mengenali perbedaan kedua jenis perairan membantu pembudidaya mengambil keputusan yang tepat. Memilih ikan yang sesuai dengan lingkungannya adalah langkah pertama menuju budidaya yang berhasil.",
      ] },
    ],
  },

  "inovasi-teknologi-budidaya": {
    excerpt: "Dari kolam terpal hingga peralatan penunjang, teknologi sederhana dapat membantu budidaya ikan berjalan lebih rapi.",
    sections: [
      { paragraphs: [
        "Budidaya ikan terus berkembang seiring hadirnya cara dan peralatan baru. Foto pada artikel ini menampilkan deretan kolam berlapis terpal yang tertata rapi, dengan pepohonan dan langit terbuka di latarnya.",
      ] },
      { heading: "Kolam yang lebih mudah dikelola", paragraphs: [
        "Kolam berlapis terpal atau bahan sintetis dapat dibangun di lahan yang tidak ideal untuk kolam tanah. Permukaannya yang rata membuat kolam lebih mudah dibersihkan dan dipantau.",
      ] },
      { heading: "Penunjang kualitas air", paragraphs: [
        "Alat penambah oksigen seperti kincir atau aerator membantu menjaga kondisi air. Pembudidaya juga memakai alat sederhana untuk memeriksa kejernihan dan kondisi air secara rutin.",
      ] },
      { heading: "Pencatatan dan perencanaan", paragraphs: [
        "Teknologi tidak selalu berarti mesin. Pencatatan jadwal tebar, pemberian pakan, dan panen membantu pembudidaya merencanakan usaha dan mengenali masalah lebih awal.",
      ] },
      { heading: "Penutup", paragraphs: [
        "Inovasi paling berguna ketika sesuai dengan kebutuhan dan kemampuan pembudidaya. Teknologi yang sederhana, dirawat dengan baik, dan digunakan dengan benar sering kali memberi manfaat yang paling nyata.",
      ] },
    ],
  },

  "purwakarta-perkuat-posisi": {
    excerpt: "Sentra budidaya tumbuh dari kolam, pembudidaya, dan jalur pemasaran yang saling menunjang.",
    sections: [
      { paragraphs: [
        "Sebuah daerah dapat dikenal sebagai sentra perikanan ketika banyak pembudidaya bekerja di sana dan hasilnya mengalir ke pasar yang lebih luas. Foto pada artikel ini menampilkan kolam-kolam terpal berwarna biru dan oranye, dengan petugas yang sedang bekerja di sekitarnya.",
      ] },
      { heading: "Pembudidaya sebagai fondasi", paragraphs: [
        "Keahlian pembudidaya yang diwariskan dan dibagikan antarwarga menjadi modal penting. Pengalaman memilih benih, mengatur pakan, dan menjaga air membuat hasil panen lebih stabil.",
      ] },
      { heading: "Dukungan sarana", paragraphs: [
        "Ketersediaan sumber air, pakan, dan peralatan di sekitar lokasi memudahkan pembudidaya bekerja. Jalur pengangkutan yang baik juga membantu ikan sampai ke pembeli dalam keadaan segar.",
      ] },
      { heading: "Akses pasar", paragraphs: [
        "Hasil budidaya baru bernilai ketika sampai ke pembeli. Pembudidaya yang memiliki saluran pemasaran yang jelas dapat merencanakan produksinya dengan lebih tenang.",
      ] },
      { heading: "Penutup", paragraphs: [
        "Posisi sebuah daerah dalam dunia perikanan dibangun dari kerja bersama pembudidaya, pelaku usaha, dan masyarakat. Semakin baik kolaborasinya, semakin kuat pula manfaatnya bagi ekonomi setempat.",
      ] },
    ],
  },

  "pokdakan-dan-poklahsar": {
    excerpt: "Kelompok pembudidaya dan kelompok pengolah serta pemasar menjadi wadah kerja bersama di sektor perikanan.",
    sections: [
      { paragraphs: [
        "Dalam sektor perikanan, kerja bersama sering dilakukan lewat kelompok. Dua istilah yang kerap muncul adalah Pokdakan dan Poklahsar. Foto pada artikel ini menampilkan pasar ikan yang ramai, tempat hasil budidaya dan tangkapan bertemu dengan pembeli.",
      ] },
      { heading: "Pokdakan", paragraphs: [
        "Pokdakan adalah singkatan dari kelompok pembudidaya ikan. Anggotanya adalah warga yang memelihara ikan dan memilih bekerja sama untuk berbagi pengetahuan, peralatan, serta pengalaman.",
      ] },
      { heading: "Poklahsar", paragraphs: [
        "Poklahsar adalah singkatan dari kelompok pengolah dan pemasar hasil perikanan. Kelompok ini berfokus pada pengolahan ikan menjadi produk dan pemasarannya kepada pembeli.",
      ] },
      { heading: "Manfaat bekerja dalam kelompok", paragraphs: [
        "Bekerja dalam kelompok memudahkan anggota bertukar pengalaman, membeli kebutuhan bersama, dan menyusun jadwal produksi. Kelompok juga mempermudah anggota berhubungan dengan pihak lain yang ingin bekerja sama.",
      ] },
      { heading: "Penutup", paragraphs: [
        "Kelompok bukan sekadar wadah administrasi. Ketika anggotanya aktif dan saling percaya, kelompok dapat menjadi kekuatan yang membantu usaha perikanan skala kecil bertahan dan berkembang.",
      ] },
    ],
  },
};

/// Teks UI fitur katalog (Home, pencarian, detail produk). Satu berkas agar mudah diekstrak untuk versi bahasa Inggris.
class CatalogStrings {
  static String greeting(String name) => 'Halo, ${name.trim().split(' ').first}!';
  static const tagline = 'Belanja Ikan Mudah Dengan IkanKu';
  static const valueProps = ['Ikan Segar Langsung ke Rumah Anda', 'Mudah dan Praktis', 'Jaminan Kesegaran'];
  static const allFish = 'Semua ikan';
  static const categoriesEyebrow = 'Kategori';
  static const recoEyebrow = 'Pilihan untuk Anda';
  static const gridView = 'Tampilan grid';
  static const listView = 'Tampilan daftar';
  static const sortTooltip = 'Urutkan';
  static String applyCount(int n) => 'Terapkan - $n produk';
  static const guest = 'Tamu';
  static const searchEntry = 'Cari ikan air tawar';
  static const searchHint = 'Cari ikan air tawar';
  static const cartTooltip = 'Keranjang';
  static const categories = 'Kategori ikan';
  static const seeAll = 'Lihat semua';
  static const recommendations = 'Rekomendasi untuk Anda';
  static const topRated = 'Rating tertinggi';
  static const moreChoices = 'Pilihan lainnya';
  static const seeMore = 'Lihat semua ikan';
  static const buyBanner = 'Belanja Sekarang';
  static const noProducts = 'Belum ada produk';
  static const noProductsInCategory = 'Belum ada produk di kategori ini';
  static const productNotFound = 'Produk tidak ditemukan';
  static const productNotFoundHint = 'Produk ini mungkin sudah tidak tersedia.';
  static const backHome = 'Kembali ke beranda';

  // Pencarian
  static const clear = 'Hapus pencarian';
  static const filter = 'Filter & urutkan';
  static const filterTitle = 'Filter & urutkan';
  static const sortLabel = 'Urutkan';
  static const categoryLabel = 'Kategori';
  static const priceLabel = 'Rentang harga';
  static const ratingLabel = 'Rating minimal';
  static const apply = 'Terapkan';
  static const reset = 'Atur ulang';
  static const allCategories = 'Semua';
  static String results(int n) => '$n produk ditemukan';
  static String resultsFor(int n, String q) => '$n hasil untuk "$q"';
  static String noResults(String q) => 'Tidak ada hasil untuk "$q"';
  static const noResultsFiltered = 'Tidak ada produk yang cocok dengan filter ini';
  static const noResultsHint = 'Coba kata kunci lain atau longgarkan filter.';
  static const resetFilters = 'Atur ulang filter';
  static const browseAll = 'Lihat semua produk';

  // Detail
  static const addToCart = 'Masukkan Keranjang';
  static const buyNow = 'Beli Sekarang';
  static const description = 'Deskripsi';
  static const readMore = 'Selengkapnya';
  static const readLess = 'Lebih sedikit';
  static const variations = 'Variasi';
  static const reviewsTitle = 'Penilaian & Ulasan Produk';
  static const noReviews = 'Belum ada ulasan';
  static const showReviews = 'Tampilkan';
  static const hideReviews = 'Sembunyikan';
  static const visitShop = 'Kunjungi Toko';
  static const chooseVariation = 'Pilih variasi';
  static const quantity = 'Jumlah';
  static String stockLeft(int n) => 'Stok tersisa $n ekor';
  static String stock(int n) => 'Stok: $n ekor';
  static const soldOut = 'Stok habis';
  static const maxStock = 'Jumlah maksimal sesuai stok';
  static String reviewCount(int n) => '($n Ulasan)';
  static const addedToCart = 'Ditambahkan ke keranjang';
  static const viewCart = 'Lihat keranjang';
  static const pickVariationFirst = 'Pilih variasi dulu';
  static String total(String v) => 'Total $v';
}

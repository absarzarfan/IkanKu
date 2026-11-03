/// Teks UI checkout, pembayaran, sukses, daftar pesanan, detail, dan ulasan (pembeli).
class OrdersStrings {
  // Checkout
  static const checkoutTitle = 'Ringkasan Pemesanan';
  static const stepOrder = 'Pesanan';
  static const stepPay = 'Pembayaran';
  static const stepDone = 'Selesai';
  static const addressTitle = 'Alamat pengiriman';
  static const change = 'Ubah';
  static const addAddress = 'Tambah alamat';
  static const addressMissing = 'Pilih atau tambahkan alamat pengiriman dulu';
  static String itemsTitle(int n) => 'Ringkasan pesanan ($n item)';
  static const shippingTitle = 'Metode pengiriman';
  static const paymentTitle = 'Metode pembayaran';
  static const shipSend = 'Kirim';
  static const shipSendHint = 'Dikirim ke alamat pilihanmu';
  static const shipPickup = 'Jemput';
  static const shipPickupHint = 'Ambil sendiri, tanpa ongkir';
  static const payTransfer = 'Transfer';
  static const payTransferHint = 'Unggah bukti transfer setelah memesan';
  static const payCod = 'COD';
  static const payCodHint = 'Bayar saat pesanan diterima';
  static const noteHint = 'Catatan untuk penjual (opsional)';
  static const subtotal = 'Subtotal';
  static const shippingFee = 'Ongkir';
  static const free = 'Gratis';
  static const total = 'Total';
  static const placeOrder = 'Buat Pesanan';
  static const noItems = 'Belum ada item yang dipilih';
  static const noItemsHint = 'Pilih item di keranjang dulu, lalu lanjut ke sini.';
  static const toCart = 'Ke keranjang';
  static const confirmAddressTitle = 'Apakah alamat sudah benar?';
  static const yes = 'Ya';
  static const no = 'Tidak';

  // Pembayaran
  static const paymentScreenTitle = 'Pembayaran';
  static const transferTo = 'Transfer ke';
  static const noBank = 'Rekening belum diatur penjual';
  static const proofTitle = 'Bukti pembayaran';
  static const proofPick = 'Unggah bukti transfer (simulasi)';
  static const proofPicked = 'Bukti terpilih (simulasi)';
  static const sendProof = 'Kirim bukti';
  static const payLater = 'Bayar nanti';

  // Sukses
  static const successTitle = 'Pesanan berhasil dibuat';
  static const nextTitle = 'Langkah berikutnya';
  static const nextPayProof = 'Selesaikan pembayaran dan unggah bukti transfer agar penjual dapat memeriksa pesananmu.';
  static const nextProcessing = 'Penjual akan memproses pesananmu. Pantau statusnya di halaman Pesanan.';
  static const summaryTitle = 'Ringkasan pesanan';
  static const viewOrders = 'Lihat pesanan';
  static const shopAgain = 'Belanja lagi';
  static const paymentLabel = 'Pembayaran';

  // Daftar pesanan
  static const ordersTitle = 'Pesanan Saya';
  static const tabs = ['Menunggu', 'Dikemas', 'Dikirim', 'Selesai', 'Ditolak'];
  static String emptyTab(String tab) => 'Belum ada pesanan ${tab.toLowerCase()}';
  static const emptyHint = 'Pesanan yang kamu buat akan muncul di sini.';
  static String variation(String v) => 'Variasi: $v';
  static const payNow = 'Bayar Sekarang';
  static const cancel = 'Batal';
  static const cancelOrder = 'Batalkan pesanan';
  static const cancelTitle = 'Batalkan pesanan ini?';
  static String cancelBody(String id) => 'Pesanan $id akan dibatalkan.';
  static const cancelYes = 'Ya, batalkan';
  static const cancelNo = 'Tidak';
  static const review = 'Beri Ulasan';
  static const viewReview = 'Lihat Ulasan';
  static const viewReason = 'Lihat Alasan';
  static const notFound = 'Pesanan tidak ditemukan';

  // Detail + lini masa
  static const detailTitle = 'Detail Pesanan';
  static const shippingDetailTitle = 'Detail Pengiriman';
  static const timelineTitle = 'Status pesanan';
  static const stepCreated = 'Pesanan dibuat';
  static const stepProof = 'Bukti pembayaran dikirim';
  static const stepProofWait = 'Menunggu bukti pembayaran';
  static const stepPacked = 'Dikemas penjual';
  static const stepShipped = 'Dikirim';
  static const stepDelivered = 'Selesai';
  static const stepRejected = 'Ditolak penjual';
  static const stepCancelled = 'Dibatalkan';

  // Ulasan
  static const reviewTitle = 'Beri Ulasan';
  static const reviewAsk = 'Bagaimana pengalamanmu?';
  static const reviewHint = 'Tulis ulasanmu (opsional)';
  static const reviewNeedStars = 'Pilih jumlah bintang dulu';
  static const reviewSend = 'Kirim';
  static const reviewSent = 'Ulasan terkirim, terima kasih!';
  static const reviewMax = 300;
}

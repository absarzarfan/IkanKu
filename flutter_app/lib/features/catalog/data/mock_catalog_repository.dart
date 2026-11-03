import 'package:ikanku/features/catalog/domain/catalog.dart';

const _nilaDesc = 'Nikmati kesegaran ikan nila terbaik yang langsung didapat dari peternakan berkualitas. '
    'Ikan nila segar kami memiliki rasa gurih alami dan daging yang lembut, cocok untuk ikan bakar, sup, atau pepes.\n\n'
    'Detail Produk:\n'
    '- Berat: ±500 gram - 1 kg per ekor\n'
    '- Kondisi: Segar, belum dibekukan\n'
    '- Asal: Budidaya Tibelat Farm\n'
    '- Manfaat: Kaya akan protein, omega-3, dan rendah lemak\n'
    '- Saran Penyimpanan: Simpan di suhu 0-4°C agar tetap segar\n\n'
    'Pesan sekarang dan pastikan ikan nila segar hadir di meja makan Anda!';

const _reviews = [
  Review(author: 'Mutu', rating: 5, text: 'Solusi yg tepat kalo lagi males belanja ke pasar, pengemasannya juga aman.'),
  Review(author: 'Kak Ros', rating: 5, text: 'Produk sangat baik harga terjangkau, kualitas dan respon admin cepat.'),
];

List<Variation> _vars(String p, int base) => [
      Variation(id: '$p-1', weight: '500 gr', count: 2, price: (base * 0.55).round(), stock: 40),
      Variation(id: '$p-2', weight: '1 Kg', count: 2, price: base, stock: 60),
      Variation(id: '$p-3', weight: '1 Kg', count: 4, price: (base * 1.8).round(), stock: 20),
    ];

class MockCatalogRepository implements CatalogRepository {
  MockCatalogRepository()
      : _products = [
          Product(id: 'nila', name: 'Ikan Nila', description: _nilaDesc, category: 'Air Tawar', image: 'assets/images/cat_air_tawar.png', variations: _vars('nila', 31000), rating: 4.5, reviews: _reviews),
          Product(id: 'discus', name: 'Ikan Discus', description: 'Ikan discus berasal dari Amazon, Brazil', category: 'Hias', image: 'assets/images/fish_discus.png', variations: _vars('discus', 100000), rating: 4.5),
          Product(id: 'cupang', name: 'Ikan Cupang', description: 'Ikan lokal dg ekor dan sirip yang cantik', category: 'Hias', image: 'assets/images/fish_cupang.png', variations: _vars('cupang', 40000), rating: 4.5),
          Product(id: 'bluedevil', name: 'Ikan Blue Devil', description: 'Ikan hias berwarna biru cerah.', category: 'Hias', image: 'assets/images/fish_blue_devil.png', variations: _vars('bluedevil', 500000), rating: 4),
          Product(id: 'fire', name: 'Ikan Fire', description: 'Ikan hias berwarna merah menyala.', category: 'Hias', image: 'assets/images/fish_fire.png', variations: _vars('fire', 700000), rating: 4),
          Product(id: 'botia', name: 'Ikan Botia', description: 'Ikan hias aktif dan jinak.', category: 'Hias', image: 'assets/images/fish_botia.png', variations: _vars('botia', 800000), rating: 3.5),
          Product(id: 'salmon', name: 'Ikan Salmon', description: 'Salmon segar, kaya omega-3.', category: 'Laut', image: 'assets/images/fish_3.png', variations: _vars('salmon', 90000), rating: 4.5),
          Product(id: 'gurita', name: 'Gurita', description: 'Gurita segar hasil tangkapan harian.', category: 'Laut', image: 'assets/images/fish_4.png', variations: _vars('gurita', 75000), rating: 4.5),
          Product(id: 'bibit-nila', name: 'Bibit Nila', description: 'Bibit nila ukuran 3-5 cm.', category: 'Bibit', image: 'assets/images/cat_bibit.png', variations: _vars('bibit', 5000), rating: 4.5),
        ],
        _categories = ['Air Tawar', 'Laut', 'Hias', 'Bibit'];

  List<Product> _products;
  List<String> _categories;

  @override
  List<Product> products() => List.unmodifiable(_products);

  @override
  List<String> categories() => List.unmodifiable(_categories);

  @override
  void saveProducts(List<Product> products) => _products = List.of(products);

  @override
  void saveCategories(List<String> categories) => _categories = List.of(categories);
}

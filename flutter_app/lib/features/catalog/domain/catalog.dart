/// Variasi produk: kombinasi berat dan isi (mis. "Berat 1 Kg, Isi 2 ekor").
class Variation {
  const Variation({required this.id, required this.weight, required this.count, required this.price, required this.stock});
  final String id;
  final String weight;
  final int count;
  final int price;
  final int stock;

  String get label => 'Berat $weight, Isi $count ekor';

  Variation copyWith({String? weight, int? count, int? price, int? stock}) =>
      Variation(id: id, weight: weight ?? this.weight, count: count ?? this.count, price: price ?? this.price, stock: stock ?? this.stock);
}

class Review {
  const Review({required this.author, required this.rating, required this.text, this.orderId});
  final String author;
  final int rating;
  final String text;
  final String? orderId;
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.image,
    required this.variations,
    this.rating = 4.5,
    this.reviews = const [],
    this.discountPercent = 0,
    this.sellerName = 'Tibelat Farm',
  });

  final String id;
  final String name;
  final String description;
  final String category;
  final String image;
  final List<Variation> variations;
  final double rating;
  final List<Review> reviews;
  final int discountPercent;
  final String sellerName;

  int get stock => variations.fold(0, (s, v) => s + v.stock);

  int discounted(int price) => (price * (100 - discountPercent) / 100).round();

  /// Harga mulai dari (variasi termurah, setelah diskon).
  int get startingPrice => variations.isEmpty ? 0 : discounted(variations.map((v) => v.price).reduce((a, b) => a < b ? a : b));

  int priceOf(Variation v) => discounted(v.price);

  Product copyWith({String? name, String? description, String? category, String? image, List<Variation>? variations, int? discountPercent, List<Review>? reviews}) => Product(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        category: category ?? this.category,
        image: image ?? this.image,
        variations: variations ?? this.variations,
        rating: rating,
        reviews: reviews ?? this.reviews,
        discountPercent: discountPercent ?? this.discountPercent,
        sellerName: sellerName,
      );
}

/// Sumber data katalog. Implementasi saat ini: in-memory (mock).
/// Ganti dengan implementasi REST/Firebase tanpa mengubah UI.
abstract class CatalogRepository {
  List<Product> products();
  List<String> categories();
  void saveProducts(List<Product> products);
  void saveCategories(List<String> categories);
}

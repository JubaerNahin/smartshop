class ProductModel {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final List<String> sizes;
  final Map<String, int> stockBySize;
  final String category;
  final String brand;
  final double rating;
  final String description;
  final double discount;
  final int soldCount;

  final List<String> tags;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.sizes,
    required this.stockBySize,
    required this.category,
    required this.brand,
    required this.rating,
    required this.description,
    required this.discount,
    required this.soldCount,

    required this.tags,
  });

  factory ProductModel.fromMap(String id, Map<String, dynamic> data) {
    String parseString(dynamic v) => v?.toString() ?? '';

    double parseDouble(dynamic v) => v == null ? 0.0 : (v as num).toDouble();

    int parseInt(dynamic v) =>
        v == null
            ? 0
            : (v is num ? v.toInt() : int.tryParse(v.toString()) ?? 0);

    return ProductModel(
      id: id,
      name: parseString(data['name']),
      price: parseDouble(data['price']),
      imageUrl: parseString(data['imageUrl']),
      sizes: List<String>.from(data['sizes'] ?? []),
      stockBySize: Map<String, int>.from(
        (data['stock_by_size'] ?? {}).map(
          (k, v) => MapEntry(k.toString(), parseInt(v)),
        ),
      ),
      category: parseString(data['category']),
      brand: parseString(data['brand']),
      rating: parseDouble(data['rating']),
      description: parseString(data['description']),
      discount: parseDouble(data['discount']),
      soldCount: parseInt(data['sold_count']),
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'price': price,
    'imageUrl': imageUrl,
    'sizes': sizes,
    'stock_by_size': stockBySize,
    'category': category,
    'brand': brand,
    'rating': rating,
    'description': description,
    'discount': discount,
    'sold_count': soldCount,

    'tags': tags,
  };
}

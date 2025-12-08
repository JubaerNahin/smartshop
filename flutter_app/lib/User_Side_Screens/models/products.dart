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
    return ProductModel(
      id: id,
      name: data['name'],
      price: (data['price'] as num).toDouble(),
      imageUrl: data['imageUrl'],
      sizes: List<String>.from(data['sizes'] ?? []),
      stockBySize: Map<String, int>.from(data['stock_by_size'] ?? {}),
      category: data['category'],
      brand: data['brand'],
      rating: (data['rating'] as num).toDouble(),
      description: data['description'],
      discount:
          (data['discount'] != null)
              ? (data['discount'] as num).toDouble()
              : 0.0,
      soldCount: data['sold_count'] ?? 0,

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

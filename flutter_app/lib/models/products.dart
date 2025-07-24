class ProductModel {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final List<String> sizes;
  final int stock;
  final String category;
  final String brand;
  final double rating;
  final String description;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.sizes,
    required this.stock,
    required this.category,
    required this.brand,
    required this.rating,
    required this.description,
  });

  factory ProductModel.fromMap(String id, Map<String, dynamic> data) {
    return ProductModel(
      id: id,
      name: data['name'],
      price: (data['price'] as num).toDouble(),
      imageUrl: data['imageUrl'],
      sizes: List<String>.from(data['sizes']),
      stock: data['stock'],
      category: data['category'],
      brand: data['brand'],
      rating: (data['rating'] as num).toDouble(),
      description: data['description'],
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'price': price,
    'imageUrl': imageUrl,
    'sizes': sizes,
    'stock': stock,
    'category': category,
    'brand': brand,
    'rating': rating,
    'description': description,
  };
}

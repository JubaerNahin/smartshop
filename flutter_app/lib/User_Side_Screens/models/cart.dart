class CartItemModel {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final String imageUrl;
  final String size;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.imageUrl,
    required this.size,
  });

  factory CartItemModel.fromMap(String id, Map<String, dynamic> data) =>
      CartItemModel(
        id: id,
        productId: data['productId'],
        productName: data['productName'],
        quantity: data['quantity'],
        price: (data['price'] as num).toDouble(),
        imageUrl: data['imageUrl'],
        size: data['size'],
      );

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'productName': productName,
    'quantity': quantity,
    'price': price,
    'imageUrl': imageUrl,
    'size': size,
  };
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/controllers/cart_controller.dart';
import 'package:flutter_app/models/cart.dart';
// Update import path if needed
import 'package:flutter_app/models/products.dart';
import 'package:get/get.dart';

class ProductController extends GetxController {
  final Rx<ProductModel?> selectedProduct = Rx<ProductModel?>(null);
  final RxList<ProductModel> recommendedProducts = <ProductModel>[].obs;
  final RxList<ProductModel> products = <ProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  void fetchProducts() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('products').get();
    products.assignAll(
      snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
          .toList(),
    );
  }

  void loadProduct(ProductModel product) {
    selectedProduct.value = product;
    fetchRecommended(product.category);
  }

  void fetchRecommended(String category) async {
    // Example: fetch 2 other products from the same category
    final snapshot =
        await FirebaseFirestore.instance
            .collection('products')
            .where('category', isEqualTo: category)
            .limit(3)
            .get();

    recommendedProducts.assignAll(
      snapshot.docs
          .where((doc) => doc.id != selectedProduct.value?.id)
          .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
          .toList(),
    );
  }

  void addToCart(CartItemModel item, int quantity) {
    final product = selectedProduct.value;
    if (product != null) {
      final cartItem = CartItemModel(
        productId: product.id,
        productName: product.name,
        price: product.price * (1 - product.discount / 100),
        imageUrl: product.imageUrl,
        size: product.sizes[0],
        quantity: quantity,
        id: "",
      );
      Get.put(CartController()).addToCart(cartItem);
      Get.snackbar("Success", "${product.name} added to cart");
    }
  }

  void tryOn() {
    if (selectedProduct.value != null) {
      Get.snackbar(
        "Try-On",
        "Launching virtual try-on for ${selectedProduct.value!.name}",
      );
    }
  }

  void showReviews() {
    if (selectedProduct.value != null) {
      Get.snackbar(
        "Reviews",
        "Displaying reviews for ${selectedProduct.value!.name}",
      );
    }
  }
}

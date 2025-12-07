import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/User_Side_Screens/models/cart.dart';
import 'package:get/get.dart';

class CartController extends GetxController {
  var cartItems = <CartItemModel>[].obs;

  void addToCart(CartItemModel item) async {
    cartItems.add(item);
    await FirebaseFirestore.instance.collection('cart').add(item.toMap());

    Get.snackbar("Success", "${item.productName} added to cart");
  }

  void removeFromCart(CartItemModel item) {
    cartItems.remove(item);
  }

  void clearCart() {
    cartItems.clear();
  }

  double get totalPrice =>
      cartItems.fold(0, (sum, item) => sum + item.price * item.quantity);
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/cart.dart';
import 'package:get/get.dart';
import '../../controllers/cart_controller.dart';

class CartScreen extends StatelessWidget {
  final CartController cartController = Get.put(CartController());

  CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Cart"),
        automaticallyImplyLeading: false, // removes the back button
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Go to Dashboard',
            onPressed: () {
              Get.offNamed('/dashboard'); // Navigate to Dashboard screen
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('cart').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          }

          final cartItems =
              snapshot.data!.docs
                  .map(
                    (doc) => CartItemModel.fromMap(
                      doc.data() as Map<String, dynamic>,
                    ),
                  )
                  .toList();

          double totalPrice = cartItems.fold(
            0,
            (sum, item) => sum + item.price * item.quantity,
          );

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final product = cartItems[index];
                    return ListTile(
                      leading: Image.network(product.imageUrl, width: 60),
                      title: Text(product.productName),
                      subtitle: Text(
                        '৳${product.price.toStringAsFixed(2)} x ${product.quantity}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          cartController.removeFromCart(product);
                          FirebaseFirestore.instance
                              .collection('cart')
                              .where('productId', isEqualTo: product.productId)
                              .get()
                              .then((querySnapshot) {
                                for (var doc in querySnapshot.docs) {
                                  doc.reference.delete();
                                }
                              });
                        },
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Total: ৳${totalPrice.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to DashboardScreen with Home tab selected
                        Get.offNamed('/dashboard');
                        Get.snackbar(
                          "Success",
                          "Proceeding to Dashboard Home...",
                        );
                      },
                      child: const Text("Checkout"),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),

      //  Obx(() {
      //   if (cartController.cartItems.isEmpty) {
      //     return const Center(child: Text("Your cart is empty."));
      //   }

      //   return Column(
      //     children: [
      //       Expanded(
      //         child: ListView.builder(
      //           itemCount: cartController.cartItems.length,
      //           itemBuilder: (context, index) {
      //             final product = cartController.cartItems[index];
      //             return ListTile(
      //               leading: Image.network(product.imageUrl, width: 60),
      //               title: Text(product.productName),
      //               subtitle: Text('৳${product.price.toStringAsFixed(2)}'),
      //               trailing: IconButton(
      //                 icon: const Icon(Icons.remove_circle_outline),
      //                 onPressed: () => cartController.removeFromCart(product),
      //               ),
      //             );
      //           },
      //         ),
      //       ),
      //       Padding(
      //         padding: const EdgeInsets.all(16),
      //         child: Column(
      //           crossAxisAlignment: CrossAxisAlignment.stretch,
      //           children: [
      //             Text(
      //               "Total: ৳${cartController.totalPrice.toStringAsFixed(2)}",
      //               style: const TextStyle(
      //                 fontSize: 18,
      //                 fontWeight: FontWeight.bold,
      //               ),
      //             ),
      //             const SizedBox(height: 12),
      //             ElevatedButton(
      //               onPressed: () {
      //                 // Navigate to DashboardScreen with Home tab selected
      //                 Get.offNamed('/dashboard');
      //                 Get.snackbar(
      //                   "Success",
      //                   "Proceeding to Dashboard Home...",
      //                 );
      //               },
      //               child: const Text("Checkout"),
      //             ),
      //           ],
      //         ),
      //       ),
      //     ],
      //   );
      // }),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/User_Side_Screens/models/cart.dart';
import 'package:flutter_app/utils/app_colors.dart';
import 'package:get/get.dart';
import '../../controllers/cart_controller.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartController cartController = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: AppColors.primarycolor,
      backgroundColor: AppColors.appbar,
      appBar: AppBar(
        backgroundColor: AppColors.appbar,
        title: const Text("Your Cart", style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
        elevation: 6, // removes the back button
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            tooltip: 'Go to Dashboard',
            onPressed: () {
              Get.offNamed('/dashboard'); // Navigate to Dashboard screen
            },
          ),
        ],
      ),
      body: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        child: Container(
          color: AppColors.primarycolor,
          padding: const EdgeInsets.only(top: 16),
          child: StreamBuilder<QuerySnapshot>(
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
                          doc.id,
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
                          leading: Image.network(
                            product.imageUrl.isNotEmpty
                                ? product.imageUrl
                                : 'https://via.placeholder.com/150',
                            width: 60,
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image),
                          ),
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
                                  .doc(product.id)
                                  .delete();
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
                            Get.offNamed('/checkoutscreen');
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
        ),
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

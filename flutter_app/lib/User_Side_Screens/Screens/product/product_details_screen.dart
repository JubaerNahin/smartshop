import 'package:flutter/material.dart';
import 'package:flutter_app/User_Side_Screens/controllers/cart_controller.dart';
import 'package:flutter_app/User_Side_Screens/controllers/product_controller.dart';
import 'package:flutter_app/User_Side_Screens/models/cart.dart';
import 'package:flutter_app/widgets/my_button.dart';
import 'package:flutter_app/utils/app_colors.dart';
import 'package:get/get.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final ProductController controller = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Obx(() {
      final product = controller.selectedProduct.value;
      if (product == null) {
        return const Center(child: CircularProgressIndicator());
      }

      final double discount = product.discount ?? 0;
      final bool hasDiscount = discount > 0;
      final double price =
          hasDiscount ? product.price * (1 - discount / 100) : product.price;

      return Scaffold(
        backgroundColor: AppColors.appbar, // match appbar color
        appBar: AppBar(
          title: const Text(
            "Product Details",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.appbar,
          elevation: 6,
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.home),
              tooltip: 'Go to Dashboard',
              onPressed: () => Get.offNamed('/dashboard'),
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
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Column(
              children: [
                // Product Image
                SizedBox(
                  height: screenHeight * 0.35,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(product.imageUrl, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 12),

                // Name + Try-on
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.description,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: controller.tryOn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttoncolors,
                      ),
                      child: const Text(
                        "Try-On",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Rating + Show Reviews
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${product.rating}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: controller.showReviews,
                      child: const Text("Show Reviews"),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Recommended Products
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Recommended Products:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 160,
                  child: Obx(
                    () => ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: controller.recommendedProducts.length,
                      itemBuilder: (context, index) {
                        final item = controller.recommendedProducts[index];
                        return GestureDetector(
                          onTap: () {
                            controller.loadProduct(item);
                          },
                          child: Container(
                            width: 130,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item.imageUrl,
                                    height: 60,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 14,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${item.rating}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '৳${item.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const Spacer(),

                // Bottom Row: Price + Add to Cart
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '৳${price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        if (hasDiscount)
                          Row(
                            children: [
                              Text(
                                '৳${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${discount.toStringAsFixed(0)}% OFF',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    MyButton(
                      text: "Add to cart",
                      onTap: () {
                        final cartItem = CartItemModel(
                          productId: product.id,
                          productName: product.name,
                          price: product.price * (1 - product.discount / 100),
                          imageUrl: product.imageUrl,
                          size: product.sizes[0],
                          quantity: 1,
                          id: "",
                        );
                        Get.find<CartController>().addToCart(cartItem);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

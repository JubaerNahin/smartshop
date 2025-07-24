import 'package:flutter/material.dart';
import 'package:flutter_app/models/products.dart';
import 'package:get/get.dart';
import '../../controllers/product_controller.dart';

class ProductDetailsScreen extends StatelessWidget {
  final ProductController controller = Get.put(ProductController());

  ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Obx(() {
      final product = controller.selectedProduct.value;
      if (product == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text("Product Details"),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.home),
              tooltip: 'Go to Dashboard',
              onPressed: () => Get.offNamed('/dashboard'),
            ),
          ],
        ),
        body: Column(
          children: [
            SizedBox(
              height: screenHeight * 0.35,
              width: double.infinity,
              child: Image.network(product.imageUrl, fit: BoxFit.cover),
            ),

            // Name + Try-on
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: controller.tryOn,
                    child: const Text("Try-On"),
                  ),
                ],
              ),
            ),

            // Rating + Show Reviews
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
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
            ),

            // Recommended Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Recommended Products:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            // Recommended List
            SizedBox(
              height: 160,
              child: Obx(
                () => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.recommendedProducts.length,
                  itemBuilder: (context, index) {
                    final item = controller.recommendedProducts[index];
                    return GestureDetector(
                      onTap: () {
                        final controller = Get.find<ProductController>();
                        controller.loadProduct(product);
                        Get.to(() => ProductDetailsScreen());
                      },
                      child: Container(
                        width: 130,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(
                              item.imageUrl,
                              height: 60,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Colors.amber,
                                ),
                                Text(
                                  '${item.rating}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '৳${item.price}',
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

            // Bottom Row
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '৳${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: controller.addToCart,
                    child: const Text("Add to Cart"),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

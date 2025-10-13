import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/cart_controller.dart';
import 'package:flutter_app/models/cart.dart';
import 'package:flutter_app/widgets/my_button.dart';
import 'package:get/get.dart';
import '../../controllers/product_controller.dart';

class ProductDetailsScreen extends StatelessWidget {
  late final ProductController controller = Get.put(ProductController());

  ProductDetailsScreen({super.key});

  get price => null;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Obx(() {
      final product = controller.selectedProduct.value;
      //   final double discount = product?.discount ?? 0;
      //  final bool hasDiscount = discount >0;
      //  final double
      final double discount = product?.discount ?? 0;
      final bool hasDiscount = discount > 0;
      final double price =
          hasDiscount ? product!.price * (1 - discount / 100) : product!.price;

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
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              SizedBox(
                height: screenHeight * 0.35,
                width: double.infinity,
                child: Image.network(product.imageUrl, fit: BoxFit.cover),
              ),
              const SizedBox(height: 8),
              // Name + Try-on
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        product.description,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: controller.tryOn,
                    child: const Text("Try-On"),
                  ),
                ],
              ),

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

              // Recommended Title
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Recommended Products:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                              ' ৳${product.price.toStringAsFixed(2)}',
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
                      );
                      Get.find<CartController>().addToCart(cartItem);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

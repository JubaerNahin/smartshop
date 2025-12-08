import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/User_Side_Screens/models/products.dart';
import 'package:flutter_app/utils/app_colors.dart';
import 'package:get/get.dart';

class EmployeeViewProductScreen extends StatefulWidget {
  final ProductModel product;

  const EmployeeViewProductScreen({super.key, required this.product});

  @override
  State<EmployeeViewProductScreen> createState() =>
      _EmployeeViewProductScreenState();
}

class _EmployeeViewProductScreenState extends State<EmployeeViewProductScreen> {
  late Map<String, TextEditingController> controllers;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    controllers = {
      'name': TextEditingController(text: p.name),
      'price': TextEditingController(text: p.price.toString()),
      'imageUrl': TextEditingController(text: p.imageUrl),
      'sizes': TextEditingController(text: p.sizes.join(",")),

      'category': TextEditingController(text: p.category),
      'brand': TextEditingController(text: p.brand),
      'rating': TextEditingController(text: p.rating.toString()),
      'description': TextEditingController(text: p.description),
      'discount': TextEditingController(text: p.discount.toString()),
      'tags': TextEditingController(text: p.tags.join(",")),
      'soldCount': TextEditingController(text: p.soldCount.toString()),

      'stockBySize': TextEditingController(
        text: p.stockBySize.entries.map((e) => "${e.key}:${e.value}").join(","),
      ),
    };
  }

  @override
  void dispose() {
    for (var ctrl in controllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> updateProduct() async {
    setState(() => isLoading = true);
    try {
      // Parse stockBySize
      Map<String, int> stockBySizeMap = {};
      for (var entry in controllers['stockBySize']!.text.split(',')) {
        if (entry.contains(':')) {
          final parts = entry.split(':');
          stockBySizeMap[parts[0].trim()] = int.tryParse(parts[1].trim()) ?? 0;
        }
      }

      final updatedProduct = ProductModel(
        id: widget.product.id,
        name: controllers['name']!.text.trim(),
        price: double.parse(controllers['price']!.text.trim()),
        imageUrl: controllers['imageUrl']!.text.trim(),
        sizes:
            controllers['sizes']!.text.split(',').map((e) => e.trim()).toList(),

        category: controllers['category']!.text.trim(),
        brand: controllers['brand']!.text.trim(),
        rating: double.tryParse(controllers['rating']!.text.trim()) ?? 0.0,
        description: controllers['description']!.text.trim(),
        discount: double.tryParse(controllers['discount']!.text.trim()) ?? 0.0,
        tags:
            controllers['tags']!.text.split(',').map((e) => e.trim()).toList(),
        soldCount: int.tryParse(controllers['soldCount']!.text.trim()) ?? 0,

        stockBySize: stockBySizeMap,
      );

      await FirebaseFirestore.instance
          .collection("products")
          .doc(widget.product.id)
          .update(updatedProduct.toMap());

      Get.snackbar(
        "Success",
        "Product updated successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget inputField(
    String label,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: type,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.buttoncolors),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appbar,
        title: const Text("View / Edit Product"),
      ),
      backgroundColor: AppColors.appbar,
      body: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.primarycolor,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Product Image Preview
                controllers['imageUrl']!.text.isNotEmpty
                    ? Image.network(
                      controllers['imageUrl']!.text,
                      height: 150,
                      fit: BoxFit.cover,
                    )
                    : const SizedBox(height: 150, child: Placeholder()),
                const SizedBox(height: 12),

                inputField("Product Name", controllers['name']!),
                inputField(
                  "Price",
                  controllers['price']!,
                  type: TextInputType.number,
                ),
                inputField("Image URL", controllers['imageUrl']!),
                inputField("Sizes (comma separated)", controllers['sizes']!),

                inputField("Category", controllers['category']!),
                inputField("Brand", controllers['brand']!),
                inputField(
                  "Rating",
                  controllers['rating']!,
                  type: TextInputType.number,
                ),
                inputField("Description", controllers['description']!),
                inputField(
                  "Discount %",
                  controllers['discount']!,
                  type: TextInputType.number,
                ),
                inputField("Tags (comma separated)", controllers['tags']!),
                inputField(
                  "Stock by Size (format: S:10,M:5,L:0)",
                  controllers['stockBySize']!,
                ),
                inputField(
                  "Sold Count",
                  controllers['soldCount']!,
                  type: TextInputType.number,
                ),

                const SizedBox(height: 20),
                GestureDetector(
                  onTap: isLoading ? null : updateProduct,
                  child: Container(
                    height: 56,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.buttoncolors,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "Update Product",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

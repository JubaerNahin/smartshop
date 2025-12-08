import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_app/utils/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../User_Side_Screens/models/products.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final imageCtrl = TextEditingController();
  final sizeCtrl = TextEditingController(); // input: "M,L,XL"
  final categoryCtrl = TextEditingController();
  final brandCtrl = TextEditingController();
  final ratingCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final discountCtrl = TextEditingController();
  // Inside _AddProductScreenState
  final tagsCtrl = TextEditingController(); // input: "tshirt, red, cotton"
  final stockBySizeCtrl = TextEditingController(); // input: "S:10,M:5,L:0"
  final soldCountCtrl = TextEditingController(); // input: total sold

  bool isLoading = false;

  Future<void> addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => isLoading = true);

      final id = FirebaseFirestore.instance.collection('products').doc().id;

      // Parse stock_by_size from user input
      Map<String, int> stockBySizeMap = {};
      for (var entry in stockBySizeCtrl.text.split(',')) {
        if (entry.contains(':')) {
          final parts = entry.split(':');
          stockBySizeMap[parts[0].trim()] = int.tryParse(parts[1].trim()) ?? 0;
        }
      }

      final model = ProductModel(
        id: id,
        name: nameCtrl.text.trim(),
        price: double.parse(priceCtrl.text.trim()),
        imageUrl: imageCtrl.text.trim(),
        sizes: sizeCtrl.text.split(',').map((e) => e.trim()).toList(),
        stockBySize: stockBySizeMap,
        category: categoryCtrl.text.trim(),
        brand: brandCtrl.text.trim(),
        rating: double.parse(ratingCtrl.text.trim()),
        description: descCtrl.text.trim(),
        discount:
            discountCtrl.text.trim().isEmpty
                ? 0
                : double.parse(discountCtrl.text.trim()),
        soldCount:
            soldCountCtrl.text.trim().isEmpty
                ? 0
                : int.parse(soldCountCtrl.text.trim()),
        tags: tagsCtrl.text.split(',').map((e) => e.trim()).toList(),
      );

      await FirebaseFirestore.instance
          .collection('products')
          .doc(id)
          .set(model.toMap());

      Get.snackbar(
        "Success",
        "Product added successfully!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      clearFields();
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

  void clearFields() {
    nameCtrl.clear();
    priceCtrl.clear();
    imageCtrl.clear();
    sizeCtrl.clear();
    categoryCtrl.clear();
    brandCtrl.clear();
    ratingCtrl.clear();
    descCtrl.clear();
    discountCtrl.clear();
    tagsCtrl.clear();
    stockBySizeCtrl.clear();
    soldCountCtrl.clear();
  }

  Widget input(
    String label,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: type,
          validator: (v) => v!.isEmpty ? "Required" : null,
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
        const SizedBox(height: 14),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appbar,
      appBar: AppBar(
        title: const Text("Add Product", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.appbar,
        elevation: 6,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),

      body: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
        child: Container(
          color: AppColors.primarycolor,
          padding: const EdgeInsets.all(18),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  input("Product Name", nameCtrl),
                  input("Price", priceCtrl, type: TextInputType.number),
                  input("Image URL", imageCtrl),
                  input("Sizes (comma separated: M,L,XL)", sizeCtrl),

                  input("Category", categoryCtrl),
                  input("Brand", brandCtrl),
                  input("Rating (0-5)", ratingCtrl, type: TextInputType.number),
                  input("Description", descCtrl),
                  input(
                    "Discount % (optional)",
                    discountCtrl,
                    type: TextInputType.number,
                  ),
                  input("Tags (comma separated)", tagsCtrl),
                  input(
                    "Stock by size (format: S:10,M:5,L:0)",
                    stockBySizeCtrl,
                  ),
                  input(
                    "Sold count",
                    soldCountCtrl,
                    type: TextInputType.number,
                  ),

                  const SizedBox(height: 10),

                  GestureDetector(
                    onTap: isLoading ? null : addProduct,
                    child: Container(
                      height: 56,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.buttoncolors,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          "Add Product",
                          style: TextStyle(fontSize: 18, color: Colors.white),
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
      ),
    );
  }
}

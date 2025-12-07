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
  late TextEditingController nameCtrl;
  late TextEditingController priceCtrl;
  late TextEditingController imageCtrl;
  late TextEditingController sizeCtrl;
  late TextEditingController stockCtrl;
  late TextEditingController categoryCtrl;
  late TextEditingController brandCtrl;
  late TextEditingController ratingCtrl;
  late TextEditingController descCtrl;
  late TextEditingController discountCtrl;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    nameCtrl = TextEditingController(text: p.name);
    priceCtrl = TextEditingController(text: p.price.toString());
    imageCtrl = TextEditingController(text: p.imageUrl);
    sizeCtrl = TextEditingController(text: p.sizes.join(","));
    stockCtrl = TextEditingController(text: p.stock.toString());
    categoryCtrl = TextEditingController(text: p.category);
    brandCtrl = TextEditingController(text: p.brand);
    ratingCtrl = TextEditingController(text: p.rating.toString());
    descCtrl = TextEditingController(text: p.description);
    discountCtrl = TextEditingController(text: p.discount.toString());
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    imageCtrl.dispose();
    sizeCtrl.dispose();
    stockCtrl.dispose();
    categoryCtrl.dispose();
    brandCtrl.dispose();
    ratingCtrl.dispose();
    descCtrl.dispose();
    discountCtrl.dispose();
    super.dispose();
  }

  Future<void> updateProduct() async {
    setState(() => isLoading = true);
    try {
      final updatedProduct = ProductModel(
        id: widget.product.id,
        name: nameCtrl.text.trim(),
        price: double.parse(priceCtrl.text.trim()),
        imageUrl: imageCtrl.text.trim(),
        sizes: sizeCtrl.text.split(",").map((e) => e.trim()).toList(),
        stock: int.parse(stockCtrl.text.trim()),
        category: categoryCtrl.text.trim(),
        brand: brandCtrl.text.trim(),
        rating: double.parse(ratingCtrl.text.trim()),
        description: descCtrl.text.trim(),
        discount: double.tryParse(discountCtrl.text.trim()) ?? 0.0,
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
    // final discount = double.tryParse(discountCtrl.text) ?? 0;
    // final hasDiscount = discount > 0;
    // final discountedPrice =
    //     hasDiscount
    //         ? double.tryParse(priceCtrl.text)! * (1 - discount / 100)
    //         : double.tryParse(priceCtrl.text)!;

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
                widget.product.imageUrl.isNotEmpty
                    ? Image.network(
                      imageCtrl.text,
                      height: 150,
                      fit: BoxFit.cover,
                    )
                    : const SizedBox(height: 150, child: Placeholder()),
                const SizedBox(height: 12),

                inputField("Product Name", nameCtrl),
                inputField("Price", priceCtrl, type: TextInputType.number),
                inputField("Image URL", imageCtrl),
                inputField("Sizes (comma separated)", sizeCtrl),
                inputField("Stock", stockCtrl, type: TextInputType.number),
                inputField("Category", categoryCtrl),
                inputField("Brand", brandCtrl),
                inputField("Rating", ratingCtrl, type: TextInputType.number),
                inputField("Description", descCtrl),
                inputField(
                  "Discount %",
                  discountCtrl,
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

                // SizedBox(
                //   width: double.infinity,
                //   height: 48,
                //   child: ElevatedButton(
                //     onPressed: isLoading ? null : updateProduct,
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: AppColors.buttoncolors,
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(10),
                //       ),
                //     ),
                //     child: isLoading
                //         ? const CircularProgressIndicator(color: Colors.white)
                //         : Text(
                //             "Update Product - ৳${discountedPrice.toStringAsFixed(0)}",
                //             style: const TextStyle(
                //                 fontSize: 16, color: Colors.white),
                //           ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/utils/app_colors.dart';
import 'package:get/get.dart';

class EmployeeDiscountScreen extends StatefulWidget {
  const EmployeeDiscountScreen({super.key});

  @override
  State<EmployeeDiscountScreen> createState() => _EmployeeDiscountScreenState();
}

class _EmployeeDiscountScreenState extends State<EmployeeDiscountScreen> {
  String filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appbar,
      appBar: AppBar(
        title: const Text(
          "Discount Overview",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.appbar,
        elevation: 6,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
        child: Container(
          color: AppColors.primarycolor,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Filter buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _filterButton("All", "all"),
                  _filterButton("Active", "active"),
                  _filterButton("Expired", "expired"),
                ],
              ),
              const SizedBox(height: 16),

              // List of discounted products
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('products')
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final products =
                        snapshot.data!.docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final discount =
                              data['discount'] ?? 0; // <-- safe access
                          if (discount == 0) return false;

                          if (filterStatus == 'active') {
                            return discount > 0;
                          } else if (filterStatus == 'expired') {
                            return discount == 0;
                          }
                          return true; // all
                        }).toList();

                    if (products.isEmpty) {
                      return const Center(
                        child: Text(
                          "No discounted products found.",
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final data =
                            products[index].data() as Map<String, dynamic>;
                        final discount = data['discount'] ?? 0;
                        final name = data['name'] ?? 'Unnamed Product';

                        return Card(
                          color: AppColors.cardcolor,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(name),
                            subtitle: Text("Discount: $discount%"),
                            trailing: const Icon(Icons.arrow_forward),
                            onTap: () {
                              Get.toNamed(
                                '/employee/view_product',
                                arguments: products[index],
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterButton(String label, String value) {
    final isSelected = filterStatus == value;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          filterStatus = value;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected
                ? AppColors.appbar.withValues(alpha: 0.8)
                : AppColors.navbar,
      ),
      child: Text(label),
    );
  }
}

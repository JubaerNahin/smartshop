import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/utils/app_colors.dart';

class EmployeeAnalyticsScreen extends StatelessWidget {
  const EmployeeAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appbar,
      appBar: AppBar(
        title: const Text("Analytics"),
        backgroundColor: AppColors.appbar,
        elevation: 6,
      ),
      body: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
        child: Container(
          color: AppColors.primarycolor,
          height: double.infinity,
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Orders-based analytics
                StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('orders')
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    final orders = snapshot.data!.docs;

                    // Total Revenue
                    final totalRevenue = orders.fold<double>(0, (sum, doc) {
                      final totalNum = doc['total'] ?? 0;
                      final totalValue =
                          (totalNum is num) ? totalNum.toDouble() : 0.0;
                      return sum + totalValue;
                    });

                    // Total Orders
                    final totalOrders = orders.length;

                    // Orders by status
                    final Map<String, int> statusCount = {};
                    for (var doc in orders) {
                      final status = doc['status'] ?? 'pending';
                      statusCount[status] = (statusCount[status] ?? 0) + 1;
                    }

                    // Most Ordered Products
                    final Map<String, int> productSales = {};
                    for (var doc in orders) {
                      final items = List.from(doc['items'] ?? []);
                      for (var item in items) {
                        final name = item['name'] ?? 'Unnamed';
                        final qtyNum = item['qty'] ?? 0;
                        final qty = (qtyNum is num) ? qtyNum.toInt() : 0;
                        productSales[name] = (productSales[name] ?? 0) + qty;
                      }
                    }

                    final topProducts =
                        productSales.entries.toList()
                          ..sort((a, b) => b.value.compareTo(a.value));
                    final top5Products = topProducts.take(5).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _analyticsCard(
                          "Total Revenue",
                          "৳${totalRevenue.toStringAsFixed(2)}",
                        ),
                        _analyticsCard("Total Orders", "$totalOrders"),
                        const SizedBox(height: 12),
                        const Text(
                          "Orders by Status",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        ...statusCount.entries.map(
                          (e) => ListTile(
                            title: Text(e.key),
                            trailing: Text("${e.value}"),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Most Ordered Products",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        ...top5Products.map(
                          (e) => ListTile(
                            title: Text(e.key),
                            trailing: Text("Ordered: ${e.value}"),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Cart-based analytics: Most Interested Products
                StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collectionGroup('cart')
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    final cartItems = snapshot.data!.docs;

                    final Map<String, int> interestCount = {};
                    for (var doc in cartItems) {
                      final name = doc['productName'] ?? 'Unnamed';
                      final qtyNum = doc['quantity'] ?? 0;
                      final qty = (qtyNum is num) ? qtyNum.toInt() : 0;
                      interestCount[name] = (interestCount[name] ?? 0) + qty;
                    }

                    final topInterestedProducts =
                        interestCount.entries.toList()
                          ..sort((a, b) => b.value.compareTo(a.value));
                    final top5Interested =
                        topInterestedProducts.take(5).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Most Interested Products (From Cart)",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        ...top5Interested.map(
                          (e) => ListTile(
                            title: Text(e.key),
                            trailing: Text("In Carts: ${e.value}"),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _analyticsCard(String label, String value) {
    return Card(
      color: AppColors.cardcolor,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

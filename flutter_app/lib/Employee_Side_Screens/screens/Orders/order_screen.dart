import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/utils/app_colors.dart';
import 'package:get/get.dart';

class EmployeeOrdersScreen extends StatelessWidget {
  const EmployeeOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appbar,
      appBar: AppBar(
        title: const Text("Orders"),
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
          padding: const EdgeInsets.all(12),
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collectionGroup('orders')
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No orders found."));
              }

              final orders = snapshot.data!.docs;

              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final data = order.data() as Map<String, dynamic>;
                  final items = List.from(data['items'] ?? []);
                  final total = data['total'] ?? 0;
                  final status = data['status'] ?? 'pending';
                  final timestamp = data['orderedAt'] as Timestamp?;
                  final date =
                      timestamp != null ? timestamp.toDate() : DateTime.now();
                  final address = data['shippingAddress'] ?? '';

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text("Order #${order.id}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text("Total: ৳$total"),
                          Text("Items: ${items.length}"),
                          Text("Status: $status"),
                          Text("Date: ${date.toLocal()}".split('.')[0]),
                          Text("Address: $address"),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          await order.reference.update({'status': value});
                          Get.snackbar(
                            "Status Updated",
                            "Order status changed to $value",
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        },
                        itemBuilder:
                            (context) => [
                              const PopupMenuItem(
                                value: 'pending',
                                child: Text('Pending'),
                              ),
                              const PopupMenuItem(
                                value: 'shipped',
                                child: Text('Shipped'),
                              ),
                              const PopupMenuItem(
                                value: 'delivered',
                                child: Text('Delivered'),
                              ),
                              const PopupMenuItem(
                                value: 'cancelled',
                                child: Text('Cancelled'),
                              ),
                            ],
                        icon: const Icon(Icons.edit, color: Colors.black54),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  Future<Map<String, dynamic>> _getUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data() ?? {};
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to continue')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<Map<String, dynamic>>(
            future: _getUserData(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!userSnapshot.hasData) {
                return const Center(child: Text('Failed to load user data.'));
              }
              final userData = userSnapshot.data!;
              final address = userData['address'] ?? 'No address set';
              final paymentMethod =
                  userData['paymentMethod'] ?? 'No payment method';

              return StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('cart').snapshots(),
                builder: (context, cartSnapshot) {
                  if (cartSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!cartSnapshot.hasData ||
                      cartSnapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Your cart is empty.'));
                  }

                  final cartDocs = cartSnapshot.data!.docs;
                  final cartItems =
                      cartDocs
                          .map(
                            (doc) => {
                              'name': doc['productName'],
                              'qty': doc['quantity'],
                              'price': doc['price'],
                            },
                          )
                          .toList();

                  double subtotal = cartItems.fold(
                    0,
                    (sum, item) =>
                        sum +
                        (item['qty'] as int) *
                            (item['price'] as num).toDouble(),
                  );
                  double shipping = 5.00;
                  double total = subtotal + shipping;

                  return ListView(
                    children: [
                      // Address Section
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.location_on),
                          title: const Text('Shipping Address'),
                          subtitle: Text(address),
                          trailing: TextButton(
                            onPressed: () {
                              // TODO: Implement address change
                            },
                            child: const Text('Change'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Payment Method Section
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.payment),
                          title: const Text('Payment Method'),
                          subtitle: Text(paymentMethod),
                          trailing: TextButton(
                            onPressed: () {
                              // TODO: Implement payment method change
                            },
                            child: const Text('Change'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Cart Items Section
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Order Items',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Divider(),
                              ...cartItems.map(
                                (item) => ListTile(
                                  title: Text(
                                    item['name']?.toString() ?? 'Unnamed',
                                  ),
                                  subtitle: Text('Qty: ${item['qty']}'),
                                  trailing: Text(
                                    '৳${(item['price'] as num).toStringAsFixed(2)}',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Order Summary Section
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              _summaryRow('Subtotal', subtotal),
                              _summaryRow('Shipping', shipping),
                              const Divider(),
                              _summaryRow('Total', total, isTotal: true),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Checkout Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final uid = FirebaseAuth.instance.currentUser?.uid;
                            if (uid == null) return;

                            final orderData = {
                              'userId': uid,
                              'items': cartItems,
                              'total': total,
                              'status': 'pending',
                              'orderedAt': Timestamp.now(),
                              'shippingAddress': address,
                            };

                            await FirebaseFirestore.instance
                                .collection('Users')
                                .doc(uid)
                                .collection('orders')
                                .add(orderData);

                            // Clear cart
                            final cartRef = FirebaseFirestore.instance
                                .collection('Users')
                                .doc(uid)
                                .collection('cart');

                            final cartDocs = await cartRef.get();
                            for (var doc in cartDocs.docs) {
                              await doc.reference.delete();
                            }
                            Get.snackbar(
                              "Order Placed",
                              "Your order has been successfully placed!",
                            );
                            Get.offNamed('/dashboard');
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                          child: const Text('Place Order'),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style:
                isTotal ? const TextStyle(fontWeight: FontWeight.bold) : null,
          ),
          Text(
            '৳${value.toStringAsFixed(2)}',
            style:
                isTotal ? const TextStyle(fontWeight: FontWeight.bold) : null,
          ),
        ],
      ),
    );
  }
}

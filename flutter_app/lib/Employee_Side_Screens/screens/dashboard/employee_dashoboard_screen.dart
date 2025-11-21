import 'package:flutter/material.dart';
import 'package:flutter_app/utils/app_colors.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appbar,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.appbar,
        title: const Text("ADMIN PANEL", style: TextStyle(color: Colors.white)),
        elevation: 5,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),

      // Curved top body (same theme as user dashboard)
      body: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          color: AppColors.primarycolor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Welcome Admin 👋",
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              const Text(
                "Manage everything in SmartShop from here.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 25),

              // GRID MENU
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 0.95,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _adminCard(
                      icon: Icons.shopping_bag,
                      label: "Manage Products",
                      color: Colors.deepPurple,
                      onTap: () => Get.toNamed('/admin/products'),
                    ),
                    _adminCard(
                      icon: Icons.category,
                      label: "Manage Categories",
                      color: Colors.blue,
                      onTap: () => Get.toNamed('/admin/categories'),
                    ),
                    _adminCard(
                      icon: Icons.people,
                      label: "Manage Users",
                      color: Colors.green,
                      onTap: () => Get.toNamed('/admin/users'),
                    ),
                    _adminCard(
                      icon: Icons.receipt_long,
                      label: "Orders",
                      color: Colors.orange,
                      onTap: () => Get.toNamed('/admin/orders'),
                    ),
                    _adminCard(
                      icon: Icons.discount,
                      label: "Discounts",
                      color: Colors.redAccent,
                      onTap: () => Get.toNamed('/admin/discounts'),
                    ),
                    _adminCard(
                      icon: Icons.analytics,
                      label: "Analytics",
                      color: Colors.indigo,
                      onTap: () => Get.toNamed('/admin/analytics'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ⚡ Admin Dashboard Cards (same design approach as user side)
  Widget _adminCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400.withOpacity(0.3),
              offset: const Offset(0, 3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

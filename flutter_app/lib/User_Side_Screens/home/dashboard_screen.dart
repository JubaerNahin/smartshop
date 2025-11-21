import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/product_controller.dart';
import 'package:flutter_app/models/products.dart';
import 'package:flutter_app/User_Side_Screens/product/product_details_screen.dart';
import 'package:flutter_app/utils/app_colors.dart';
import 'package:get/get.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  bool isSearching = false;
  String searchQuery = "";

  List<ProductModel> allProducts = [];
  List<ProductModel> filteredProducts = [];

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed("/welcome");
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        Get.offNamed('/home');
        break;
      case 1:
        Get.offNamed('/cart');
        break;
      case 2:
        Get.offNamed('/chatbot');
        break;
      case 3:
        Get.offNamed('/account');
        break;
    }
  }

  void filterProducts(String query) {
    searchQuery = query;

    if (query.isEmpty) {
      filteredProducts = List.from(allProducts);
    } else {
      filteredProducts =
          allProducts.where((p) {
            return p.name.toLowerCase().contains(query.toLowerCase()) ||
                p.category.toLowerCase().contains(query.toLowerCase());
          }).toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appbar,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.appbar,
        elevation: 6,
        automaticallyImplyLeading: false,

        // 🔍 SEARCH UI HERE
        title:
            isSearching
                ? _buildSearchField()
                : const Text(
                  'S M A R T S H O P',
                  style: TextStyle(color: Colors.white),
                ),

        actions: [
          if (!isSearching)
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                setState(() => isSearching = true);
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                setState(() {
                  isSearching = false;
                  searchQuery = "";
                  filteredProducts = List.from(allProducts);
                });
              },
            ),
        ],
      ),

      body: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        child: Container(
          color: AppColors.primarycolor,
          padding: const EdgeInsets.only(top: 16),
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('products').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No products found.'));
              }

              allProducts =
                  snapshot.data!.docs.map((doc) {
                    return ProductModel.fromMap(
                      doc.id,
                      doc.data() as Map<String, dynamic>,
                    );
                  }).toList();

              if (filteredProducts.isEmpty || searchQuery.isEmpty) {
                filteredProducts = List.from(allProducts);
              }

              final discountedProducts =
                  filteredProducts.where((p) => (p.discount ?? 0) > 0).toList();

              return _buildDashboard(filteredProducts, discountedProducts);
            },
          ),
        ),
      ),

      bottomNavigationBar: _buildBottomNav(),
    );
  }

  //  The Search TextField inside AppBar
  Widget _buildSearchField() {
    return TextField(
      autofocus: true,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      decoration: const InputDecoration(
        hintText: "Search products...",
        hintStyle: TextStyle(color: Colors.white70),
        border: InputBorder.none,
      ),
      onChanged: filterProducts,
    );
  }

  Widget _buildDashboard(
    List<ProductModel> products,
    List<ProductModel> discountedProducts,
  ) {
    return searchQuery.isNotEmpty
        ? _buildSearchResults(products)
        : _buildRegularDashboard(products, discountedProducts);
  }

  //  Results when searching
  Widget _buildSearchResults(List<ProductModel> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) => _buildProductCard(products[index]),
    );
  }

  //  Normal Dashboard UI
  Widget _buildRegularDashboard(
    List<ProductModel> products,
    List<ProductModel> discountedProducts,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Discount Products',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: discountedProducts.length,
              itemBuilder:
                  (context, index) =>
                      _buildProductCard(discountedProducts[index]),
            ),
          ),

          const SizedBox(height: 20),
          const Text(
            'Featured Products',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              itemBuilder:
                  (context, index) => _buildProductCard(products[index]),
            ),
          ),

          const SizedBox(height: 16),
          const Text(
            'Popular Products',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              itemBuilder:
                  (context, index) => _buildProductCard(products[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      backgroundColor: const Color.fromARGB(255, 203, 215, 221),
      elevation: 6,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey[700],
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chatbot'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
      ],
    );
  }

  //  REUSED PRODUCT CARD
  Widget _buildProductCard(ProductModel product) {
    final discount = product.discount ?? 0;
    final hasDiscount = discount > 0;
    final discountedPrice =
        hasDiscount ? product.price * (1 - discount / 100) : product.price;

    return GestureDetector(
      onTap: () {
        final controller = Get.find<ProductController>();
        controller.loadProduct(product);
        Get.to(() => const ProductDetailsScreen());
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  product.imageUrl,
                  height: 110,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                if (hasDiscount)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "${discount.toStringAsFixed(0)}% OFF",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  Text(product.rating.toString()),
                ],
              ),
            ),

            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Row(
                children: [
                  Text(
                    '৳${discountedPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (hasDiscount)
                    Text(
                      '৳${product.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                product.name,
                style: const TextStyle(fontSize: 15),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

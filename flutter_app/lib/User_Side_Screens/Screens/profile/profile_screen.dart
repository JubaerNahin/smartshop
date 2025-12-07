import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/utils/app_colors.dart';
import 'package:flutter_app/widgets/editable_profile_field.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedIndex = 3;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController shippingaddressController =
      TextEditingController();

  String imageUrl = '';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await _firestore.collection("Users").doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      nameController.text = data['name'] ?? '';
      emailController.text = data['email'] ?? '';
      phoneController.text = data['phone'] ?? '';
      addressController.text = data['address'] ?? '';
      shippingaddressController.text = data['shippingAddress'] ?? '';
      imageUrl = data['imageUrl'] ?? '';
      setState(() {});
    }
  }

  Future<void> _updateProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('Users').doc(user.uid).update({
        'name': nameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'address': addressController.text,
        'imageUrl': imageUrl,
        'shippingAddress': shippingaddressController.text,
      });

      if (emailController.text != user.email) {
        await user.updateEmail(emailController.text);
      }
      if (passwordController.text.isNotEmpty) {
        await user.updatePassword(passwordController.text);
      }

      Get.snackbar(
        "Profile Updated",
        "Your profile has been updated successfully",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        Get.offNamed('/dashboard');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appbar,
      appBar: AppBar(
        backgroundColor: AppColors.appbar,
        title: const Text(
          'User Profile',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Get.toNamed('/signin');
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
          height: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                  child:
                      imageUrl.isEmpty
                          ? const Icon(Icons.person, size: 60)
                          : null,
                ),
                const SizedBox(height: 12),
                EditableProfileField(
                  label: 'Name',
                  value: nameController.text,
                  onChanged: (val) => nameController.text = val,
                ),
                const SizedBox(height: 12),
                EditableProfileField(
                  label: 'Email',
                  value: emailController.text,
                  onChanged: (val) => emailController.text = val,
                ),
                const SizedBox(height: 12),
                EditableProfileField(
                  label: 'Password',
                  value: passwordController.text,
                  obscure: true,
                  onChanged: (val) => passwordController.text = val,
                ),
                const SizedBox(height: 12),
                EditableProfileField(
                  label: 'Phone',
                  value: phoneController.text,
                  onChanged: (val) => phoneController.text = val,
                ),
                const SizedBox(height: 12),
                EditableProfileField(
                  label: 'Address',
                  value: addressController.text,
                  onChanged: (val) => addressController.text = val,
                ),
                const SizedBox(height: 12),
                EditableProfileField(
                  label: 'Shipping Address',
                  value: shippingaddressController.text,
                  onChanged: (val) => shippingaddressController.text = val,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _updateProfile,
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 203, 215, 221),
        elevation: 6,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey[700],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chatbot'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter_app/utils/app_colors.dart';
import 'package:flutter_app/widgets/editable_profile_field.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedIndex = 3;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final shippingController = TextEditingController();

  String localImagePath = ''; // stored locally

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
      shippingController.text = data['shippingAddress'] ?? '';
      localImagePath = data['imagePath'] ?? '';

      setState(() {});
    }
  }

  /// Pick Image + Save Locally

  Future<void> pickImage() async {
    var status = await Permission.photos.request(); // Android 13+

    if (!status.isGranted) {
      Get.snackbar(
        "Permission Required",
        "Please allow photo access to upload profile",
      );
      return;
    }

    try {
      final picker = ImagePicker();
      XFile? picked = await picker.pickImage(source: ImageSource.gallery);

      if (picked == null) return;

      final dir = await getApplicationDocumentsDirectory();
      final File saved = File(
        "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg",
      );
      await File(picked.path).copy(saved.path);

      setState(() => localImagePath = saved.path);
    } catch (e) {
      Get.snackbar("Error", "Image selection failed!");
      debugPrint(e.toString());
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
        'shippingAddress': shippingController.text,
        'imagePath': localImagePath,
      });

      if (emailController.text != user.email) {
        await user.verifyBeforeUpdateEmail(emailController.text);
      }
      if (passwordController.text.isNotEmpty) {
        await user.updatePassword(passwordController.text);
      }

      Get.snackbar(
        "Success",
        "Profile Updated",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _onItemTapped(int index) {
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
          "My Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Get.toNamed('/role');
            },
          ),
        ],
      ),

      body: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Profile Image
                GestureDetector(
                  onTap: pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 65,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage:
                            localImagePath.isNotEmpty
                                ? FileImage(
                                  File(localImagePath),
                                ) // user-picked image
                                : AssetImage('assets/images/person_image.jpg')
                                    as ImageProvider, // default asset
                        child:
                            localImagePath.isEmpty
                                ? null // remove Icon if using default asset image
                                : null,
                      ),
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.buttoncolors,
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Profile Fields Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      EditableProfileField(
                        label: "Name",
                        value: nameController.text,
                        onChanged: (v) => nameController.text = v,
                      ),
                      const SizedBox(height: 12),
                      EditableProfileField(
                        label: "Email",
                        value: emailController.text,
                        onChanged: (v) => emailController.text = v,
                      ),
                      const SizedBox(height: 12),
                      EditableProfileField(
                        label: "Password",
                        obscure: true,
                        value: passwordController.text,
                        onChanged: (v) => passwordController.text = v,
                      ),
                      const SizedBox(height: 12),
                      EditableProfileField(
                        label: "Phone",
                        value: phoneController.text,
                        onChanged: (v) => phoneController.text = v,
                      ),
                      const SizedBox(height: 12),
                      EditableProfileField(
                        label: "Address",
                        value: addressController.text,
                        onChanged: (v) => addressController.text = v,
                      ),
                      const SizedBox(height: 12),
                      EditableProfileField(
                        label: "Shipping Address",
                        value: shippingController.text,
                        onChanged: (v) => shippingController.text = v,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttoncolors,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/utils/app_colors.dart';
import 'package:flutter_app/widgets/editable_profile_field.dart';
import 'package:get/get.dart';
import '../../models/employee_users.dart';

class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({super.key});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController roleController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
  }

  Future<void> _loadEmployeeData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await _firestore.collection("employees").doc(uid).get();
    if (doc.exists) {
      final employee = EmployeeUser.fromMap(doc.id, doc.data()!);
      nameController.text = employee.name;
      emailController.text = employee.email;
      roleController.text = employee.role;
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _updateProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestore.collection('employees').doc(uid).update({
        'name': nameController.text,
        'email': emailController.text,
        'role': roleController.text,
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user != null && emailController.text != user.email) {
        await user.verifyBeforeUpdateEmail(emailController.text);
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

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appbar,
      appBar: AppBar(
        backgroundColor: AppColors.appbar,
        title: const Text(
          'Employee Profile',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                child: Container(
                  height: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 60,
                          child: Icon(Icons.person, size: 60),
                        ),
                        const SizedBox(height: 16),
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

                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _updateProfile,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 24,
                            ),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                          child: const Text('Save Changes'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}

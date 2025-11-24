import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    await Future.delayed(const Duration(seconds: 2));

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Get.offAllNamed("/role");
      return;
    }

    // CHECK EMPLOYEE COLLECTION
    final employeeDoc =
        await FirebaseFirestore.instance
            .collection("employees")
            .doc(user.uid)
            .get();

    if (employeeDoc.exists) {
      Get.offAllNamed("/employee/dashboard");
      return;
    }

    // CHECK USERS COLLECTION
    final userDoc =
        await FirebaseFirestore.instance
            .collection("Users")
            .doc(user.uid)
            .get();

    if (userDoc.exists) {
      Get.offAllNamed("/dashboard");
      return;
    }

    Get.offAllNamed("/signin");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.blue.shade50,
              ),
              child: Center(
                child: Text(
                  "SmartShop",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              "Loading...",
              style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
            ),

            const SizedBox(height: 30),

            // Loading indicator
            CircularProgressIndicator(
              strokeWidth: 3,
              color: Colors.blue.shade700,
            ),
          ],
        ),
      ),
    );
  }
}

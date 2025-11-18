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
    await Future.delayed(const Duration(seconds: 2)); // smart loading delay

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Get.offAllNamed("/signin");
      return;
    }

    final doc =
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();

    if (!doc.exists) {
      Get.offAllNamed("/login");
      return;
    }

    final role = doc["role"];

    if (role == "admin") {
      Get.offAllNamed("/admin-dashboard");
    } else {
      Get.offAllNamed("/dashboard");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
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

            // Progress Indicator
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

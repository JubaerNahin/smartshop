import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_app/utils/app_colors.dart'; // important

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _logoScale = Tween<double>(
      begin: 0.95,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _checkUserRole();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkUserRole() async {
    await Future.delayed(const Duration(seconds: 2));

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Get.offAllNamed("/role");
      return;
    }

    final employeeDoc =
        await FirebaseFirestore.instance
            .collection("employees")
            .doc(user.uid)
            .get();

    if (employeeDoc.exists) {
      Get.offAllNamed("/employee/dashboard");
      return;
    }

    final userDoc =
        await FirebaseFirestore.instance
            .collection("Users")
            .doc(user.uid)
            .get();

    if (userDoc.exists) {
      Get.offAllNamed("/main");
      return;
    }

    Get.offAllNamed("/role");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarycolor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Brand Text
            ScaleTransition(
              scale: _logoScale,
              child: Text(
                "S M A R T S H O P",
                style: GoogleFonts.openSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                  letterSpacing: 2,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Loading Indicator
            CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(AppColors.textColor),
            ),

            const SizedBox(height: 30),

            // Tagline (Subtle)
            Text(
              "Shop Smart, Live Better",
              style: GoogleFonts.openSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textColor.withValues(alpha: .7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

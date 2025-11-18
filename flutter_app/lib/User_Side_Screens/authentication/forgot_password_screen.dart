import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/utils/app_colors.dart';
import 'package:flutter_app/widgets/my_button.dart';
import 'package:flutter_app/widgets/my_textfield.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();

  // Send password reset email
  Future<void> resetPassword() async {
    if (emailController.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter your email",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      Navigator.pop(context);

      Get.snackbar(
        "Email Sent",
        "Password reset link has been sent to your email.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offNamed('/signin');
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      Get.snackbar(
        "Error",
        e.message ?? "Failed to send reset link.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarycolor,
      appBar: AppBar(
        title: const Text("Forgot Password"),
        backgroundColor: AppColors.primarycolor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.appbar,
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text(
                "Reset Your Password",
                style: GoogleFonts.openSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.appbar,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Enter your registered email and we'll send you a link to reset your password.",
                style: GoogleFonts.openSans(
                  fontSize: 15,
                  color: AppColors.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Email TextField
              MyTextfield(
                hintText: "Enter your email",
                obsecureText: false,
                controller: emailController,
              ),
              const SizedBox(height: 20),

              // Reset Button
              MyButton(text: "Send Reset Link", onTap: resetPassword),

              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Get.offNamed('/signin'),
                child: Text(
                  "Back to Sign In",
                  style: GoogleFonts.openSans(
                    color: AppColors.textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

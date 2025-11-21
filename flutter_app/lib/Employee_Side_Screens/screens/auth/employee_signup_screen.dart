import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/utils/app_colors.dart';
import 'package:flutter_app/widgets/my_button.dart';
import 'package:flutter_app/widgets/my_textfield.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class EmployeeSignUpScreen extends StatefulWidget {
  const EmployeeSignUpScreen({super.key});

  @override
  State<EmployeeSignUpScreen> createState() => _EmployeeSignUpScreenState();
}

class _EmployeeSignUpScreenState extends State<EmployeeSignUpScreen> {
  // Text editing controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  void registerEmployee() async {
    // Show loading
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    if (passwordController.text != confirmPasswordController.text) {
      Navigator.pop(context);
      displayMessage("Passwords do not match", context);
      return;
    }

    try {
      // Create Firebase Auth user
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      // Save additional info in Firestore under Employees collection
      await FirebaseFirestore.instance
          .collection("Employees")
          .doc(userCredential.user!.uid)
          .set({
            "name": nameController.text.trim(),
            "email": emailController.text.trim(),
            "createdAt": Timestamp.now(),
            "isEmployee": true, // optional flag
          });

      Navigator.pop(context);

      // Navigate to Employee Dashboard
      Get.offNamed('/employee/dashboard');
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      displayMessage(e.message ?? e.code, context);
    }
  }

  void displayMessage(String message, BuildContext context) {
    Get.snackbar(
      'Info',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarycolor,
      appBar: AppBar(
        backgroundColor: AppColors.primarycolor,
        actions: [
          TextButton(
            onPressed: () => Get.offNamed('/employee/dashboard'),
            child: Text(
              'Skip',
              style: GoogleFonts.openSans(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.appbar,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'S M A R T S H O P \n       Employee',
                      style: GoogleFonts.openSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Name
                  MyTextfield(
                    hintText: 'Name',
                    obsecureText: false,
                    controller: nameController,
                  ),
                  const SizedBox(height: 8),

                  // Email
                  MyTextfield(
                    hintText: 'E-mail',
                    obsecureText: false,
                    controller: emailController,
                  ),
                  const SizedBox(height: 8),

                  // Password
                  MyTextfield(
                    hintText: 'Password',
                    obsecureText: true,
                    controller: passwordController,
                  ),
                  const SizedBox(height: 8),

                  // Confirm Password
                  MyTextfield(
                    hintText: 'Retype Password',
                    obsecureText: true,
                    controller: confirmPasswordController,
                  ),
                  const SizedBox(height: 16),

                  // Sign Up Button
                  MyButton(text: "Sign Up", onTap: registerEmployee),
                  const SizedBox(height: 16),

                  // Already have account
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(color: AppColors.textColor),
                      ),
                      GestureDetector(
                        onTap: () => Get.toNamed('/employee/login'),
                        child: Text(
                          " Sign In",
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_app/utils/app_colors.dart';
import 'package:flutter_app/widgets/my_button.dart';
import 'package:flutter_app/widgets/my_textfield.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpScreen extends StatelessWidget {
  // Text editing controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarycolor,
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () => Get.toNamed('/dashboard'),
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'S M A R T S H O P',
                    style: GoogleFonts.openSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Name field
                MyTextfield(
                  hintText: 'Name',
                  obsecureText: false,
                  controller: nameController,
                ),
                const SizedBox(height: 8),

                // Email field
                MyTextfield(
                  hintText: 'E-mail',
                  obsecureText: false,
                  controller: emailController,
                ),
                const SizedBox(height: 8),

                // Password field
                MyTextfield(
                  hintText: 'Password',
                  obsecureText: true,
                  controller: passwordController,
                ),
                const SizedBox(height: 8),

                // Retype password field
                MyTextfield(
                  hintText: 'Retype Password',
                  obsecureText: true,
                  controller: confirmPasswordController,
                ),
                const SizedBox(height: 16),

                // Sign up button
                MyButton(
                  text: "Sign Up",
                  onTap: () {
                    // TODO: Add Firebase sign up logic and validation
                  },
                ),

                const SizedBox(height: 16),

                // Already have an account? Sign In
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(color: AppColors.textColor),
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed('/signin'),
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
    );
  }
}

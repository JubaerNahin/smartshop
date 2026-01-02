import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/User_Side_Screens/services/auth_services.dart';
import 'package:flutter_app/utils/app_colors.dart';
import 'package:flutter_app/widgets/my_button.dart';
import 'package:flutter_app/widgets/my_textfield.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Text editing controllers
  final TextEditingController nameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  void registerUser() async {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    if (passwordController.text != confirmPasswordController.text) {
      Navigator.pop(context);
      displayMassageToUser("Password don't match", context);
    } else {
      try {
        // create the user
        UserCredential? userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim(),
            );
        // save additional user info in Firestore
        await FirebaseFirestore.instance
            .collection("Users")
            .doc(userCredential.user!.uid)
            .set({
              "name": nameController.text.trim(),
              "email": emailController.text.trim(),
              "createdAt": Timestamp.now(),
            });
        Navigator.pop(context);
        Get.offNamed('/main');
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        displayMassageToUser(e.code, context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarycolor,
      appBar: AppBar(
        backgroundColor: AppColors.primarycolor,
        actions: [
          TextButton(
            onPressed: () => Get.offNamed('/dashboard'),
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
              crossAxisAlignment: CrossAxisAlignment.center,
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

                MyTextfield(
                  hintText: 'Name',
                  obsecureText: false,
                  controller: nameController,
                ),
                const SizedBox(height: 8),

                MyTextfield(
                  hintText: 'E-mail',
                  obsecureText: false,
                  controller: emailController,
                ),
                const SizedBox(height: 8),

                MyTextfield(
                  hintText: 'Password',
                  obsecureText: true,
                  controller: passwordController,
                ),
                const SizedBox(height: 8),

                MyTextfield(
                  hintText: 'Retype Password',
                  obsecureText: true,
                  controller: confirmPasswordController,
                ),
                const SizedBox(height: 16),

                MyButton(
                  text: "Sign Up",
                  onTap: () {
                    registerUser();
                  },
                ),

                const SizedBox(height: 16),

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

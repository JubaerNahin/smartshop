import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/services/auth_services.dart';
import 'package:flutter_app/utils/app_colors.dart';
import 'package:flutter_app/widgets/my_button.dart';
import 'package:flutter_app/widgets/my_textfield.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // text editing cpntroller
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  void signin() async {
    showDialog(
      context: context,
      builder: (context) => Center(child: const CircularProgressIndicator()),
    );
    //sign in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (context.mounted) Navigator.pop(context);
      Get.toNamed('/dashboard');
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      displayMassageToUser(e.code, context);
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
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'S M A R T S H O P',
                    style: GoogleFonts.openSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                //email test field
                MyTextfield(
                  hintText: 'E-mail',
                  obsecureText: false,
                  controller: emailController,
                ),

                const SizedBox(height: 8),
                // password textfield
                MyTextfield(
                  hintText: 'Password',
                  obsecureText: true,
                  controller: passwordController,
                ),

                const SizedBox(height: 8),

                //forgotpassword
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      //onTap here
                      onTap: () => Get.offNamed('/forgetpass'),
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(color: AppColors.textColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                //sign in button
                MyButton(
                  text: "Sign In",
                  onTap: () {
                    signin();
                  },
                ),
                //don't have an account?register here
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(color: AppColors.textColor),
                    ),
                    GestureDetector(
                      onTap: () => Get.offNamed('/signup'),
                      child: Text(
                        "Register here",
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

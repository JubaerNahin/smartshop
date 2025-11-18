import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_auth_controller.dart';
import '../../../utils/app_colors.dart';
import '../../../widgets/my_button.dart';
import '../../../widgets/my_textfield.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final AdminAuthController authController = Get.put(AdminAuthController());
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _login() async {
    final email = emailController.text.trim();
    final pass = passwordController.text;
    if (email.isEmpty || pass.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill email and password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      await authController.login(email, pass);
      // on success login() navigates to /admin/dashboard
    } on Exception catch (e) {
      String msg = e.toString();
      // If FirebaseAuthException, show its message
      if (e is FirebaseAuthException) msg = e.message ?? e.code;
      Get.snackbar(
        'Login failed',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void _forgotPassword() {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      Get.snackbar(
        'Info',
        'Enter your email to receive reset link',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    authController
        .sendPasswordReset(email)
        .then((_) {
          Get.snackbar(
            'Email Sent',
            'A password reset link has been sent to $email',
            snackPosition: SnackPosition.BOTTOM,
          );
        })
        .catchError((err) {
          Get.snackbar(
            'Error',
            err.toString(),
            snackPosition: SnackPosition.BOTTOM,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appbar,
      appBar: AppBar(
        title: const Text('Admin Login'),
        centerTitle: true,
        backgroundColor: AppColors.appbar,
        elevation: 4,
      ),
      body: SafeArea(
        child: Obx(() {
          final loading = authController.loading.value;
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primarycolor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'SmartShop Admin',
                      style: TextStyle(
                        color: AppColors.appbar,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    MyTextfield(
                      hintText: 'Admin email',
                      controller: emailController,
                      obsecureText: false,
                    ),
                    const SizedBox(height: 12),
                    MyTextfield(
                      hintText: 'Password',
                      controller: passwordController,
                      obsecureText: true,
                    ),
                    const SizedBox(height: 16),
                    loading
                        ? const CircularProgressIndicator()
                        : MyButton(text: 'Login', onTap: _login),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _forgotPassword,
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

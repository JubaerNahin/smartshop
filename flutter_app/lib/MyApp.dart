import 'package:flutter/material.dart';
import 'package:flutter_app/screens/home/welcome_screen.dart';
import 'package:get/get.dart';
// import 'dashboard_screen.dart';
// import 'signin_screen.dart';
// import 'signup_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SmartShop',
      debugShowCheckedModeBanner: false,
      initialRoute: '/welcome',
      getPages: [
        GetPage(name: '/welcome', page: () => const WelcomeScreen()),
        // GetPage(name: '/dashboard', page: () => const DashboardScreen()),
        // GetPage(name: '/signin', page: () => const SignInScreen()),
        // GetPage(name: '/signup', page: () => const SignUpScreen()),
      ],
    );
  }
}

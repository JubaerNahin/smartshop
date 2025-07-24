import 'package:flutter/material.dart';
import 'package:flutter_app/screens/authentication/sign_in_screen.dart';
import 'package:flutter_app/screens/authentication/sign_up_screen.dart';
import 'package:flutter_app/screens/cart/cart_screen.dart';
import 'package:flutter_app/screens/home/dashboard_screen.dart';
import 'package:flutter_app/screens/home/welcome_screen.dart';
import 'package:flutter_app/theme/themes.dart';
import 'package:get/get.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SmartShop',
      theme: AppTheme.getThemes(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/welcome',
      getPages: [
        GetPage(name: '/welcome', page: () => const WelcomeScreen()),
        GetPage(name: '/dashboard', page: () => const DashboardScreen()),
        GetPage(name: '/signin', page: () => SignInScreen()),
        GetPage(name: '/signup', page: () => SignUpScreen()),
        GetPage(name: '/cart', page: () => CartScreen()),
      ],
    );
  }
}

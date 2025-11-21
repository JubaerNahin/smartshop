import 'package:flutter/material.dart';
import 'package:flutter_app/Employee_Side_Screens/screens/auth/employee_login_screen.dart';
import 'package:flutter_app/Employee_Side_Screens/screens/dashboard/employee_dashoboard_screen.dart';
import 'package:flutter_app/User_Side_Screens/authentication/forgot_password_screen.dart';
import 'package:flutter_app/User_Side_Screens/authentication/sign_in_screen.dart';
import 'package:flutter_app/User_Side_Screens/authentication/sign_up_screen.dart';
import 'package:flutter_app/User_Side_Screens/cart/cart_screen.dart';
import 'package:flutter_app/User_Side_Screens/cart/checkout_screen.dart';
import 'package:flutter_app/User_Side_Screens/chatbot/chatbot_screen.dart';
import 'package:flutter_app/User_Side_Screens/home/dashboard_screen.dart';
import 'package:flutter_app/User_Side_Screens/home/welcome_screen.dart';
import 'package:flutter_app/User_Side_Screens/profile/profile_screen.dart';
import 'package:flutter_app/loading_screen.dart';
import 'package:flutter_app/role_schecking_screen.dart';
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
      initialRoute: '/loading',
      getPages: [
        GetPage(name: "/loading", page: () => const LoadingScreen()),
        GetPage(name: '/welcome', page: () => const WelcomeScreen()),
        GetPage(name: '/dashboard', page: () => DashboardScreen()),
        GetPage(name: '/signin', page: () => SignInScreen()),
        GetPage(name: '/signup', page: () => SignUpScreen()),
        GetPage(name: '/cart', page: () => CartScreen()),
        GetPage(name: '/checkoutscreen', page: () => CheckoutScreen()),
        GetPage(name: '/account', page: () => ProfileScreen()),
        GetPage(name: '/chatbot', page: () => ChatScreen()),
        GetPage(name: '/forgetpass', page: () => ForgotPasswordScreen()),
        GetPage(name: '/admin/login', page: () => const AdminLoginScreen()),
        GetPage(name: '/role', page: () => const RoleSelectionScreen()),
        GetPage(
          name: '/admin/dashboard',
          page: () => const AdminDashboardScreen(),
        ),
      ],
    );
  }
}

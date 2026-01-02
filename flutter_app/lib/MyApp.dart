import 'package:flutter/material.dart';
import 'package:flutter_app/Employee_Side_Screens/screens/Add_Products/add_products.dart';
import 'package:flutter_app/Employee_Side_Screens/screens/View_products/view_products_list.dart';
import 'package:flutter_app/Employee_Side_Screens/screens/auth/employee_login_screen.dart';
import 'package:flutter_app/Employee_Side_Screens/screens/auth/employee_signup_screen.dart';
import 'package:flutter_app/Employee_Side_Screens/screens/dashboard/employee_dashoboard_screen.dart';
import 'package:flutter_app/User_Side_Screens/Screens/authentication/forgot_password_screen.dart';
import 'package:flutter_app/User_Side_Screens/Screens/authentication/sign_in_screen.dart';
import 'package:flutter_app/User_Side_Screens/Screens/authentication/sign_up_screen.dart';
import 'package:flutter_app/User_Side_Screens/Screens/cart/cart_screen.dart';
import 'package:flutter_app/User_Side_Screens/Screens/cart/checkout_screen.dart';
import 'package:flutter_app/User_Side_Screens/Screens/chatbot/chatbot_screen.dart';
import 'package:flutter_app/User_Side_Screens/Screens/home/dashboard_screen.dart';
import 'package:flutter_app/User_Side_Screens/Screens/home/welcome_screen.dart';
import 'package:flutter_app/User_Side_Screens/Screens/profile/profile_screen.dart';
import 'package:flutter_app/loading_screen.dart';
import 'package:flutter_app/role_schecking_screen.dart';
import 'package:flutter_app/theme/themes.dart';
import 'package:get/get.dart';
import 'Employee_Side_Screens/screens/Analytics/analytics_screen.dart';
import 'Employee_Side_Screens/screens/Discount/employee_discount_screen.dart';
import 'Employee_Side_Screens/screens/Orders/order_screen.dart';
import 'Employee_Side_Screens/screens/Profile/profile_screen.dart';
import 'User_Side_Screens/Screens/home/main_screen.dart';

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
        GetPage(name: '/main', page: () => MainScreen()),

        GetPage(name: '/dashboard', page: () => DashboardScreen()),
        GetPage(name: '/signin', page: () => SignInScreen()),
        GetPage(name: '/signup', page: () => SignUpScreen()),
        GetPage(name: '/cart', page: () => CartScreen()),
        GetPage(name: '/checkoutscreen', page: () => CheckoutScreen()),
        GetPage(name: '/account', page: () => ProfileScreen()),
        GetPage(name: '/chatbot', page: () => ChatScreen()),
        GetPage(name: '/forgetpass', page: () => ForgotPasswordScreen()),
        GetPage(name: '/role', page: () => const RoleSelectionScreen()),
        GetPage(
          name: '/employee/login',
          page: () => const EmployeeSignInScreen(),
        ),
        GetPage(
          name: '/employee/dashboard',
          page: () => const EmployeeDashboardScreen(),
        ),
        GetPage(
          name: '/employee/signup',
          page: () => const EmployeeSignUpScreen(),
        ),
        GetPage(
          name: '/employee/add_products',
          page: () => const AddProductScreen(),
        ),
        GetPage(
          name: '/employee/view_product',
          page: () => EmployeeProductListScreen(),
        ),
        GetPage(
          name: '/employee/orders',
          page: () => const EmployeeOrdersScreen(),
        ),
        GetPage(
          name: '/employee/analytics',
          page: () => const EmployeeAnalyticsScreen(),
        ),

        GetPage(
          name: '/employee/profile',
          page: () => const EmployeeProfileScreen(),
        ),
        GetPage(
          name: '/employee/discount',
          page: () => const EmployeeDiscountScreen(),
        ),
      ],
    );
  }
}

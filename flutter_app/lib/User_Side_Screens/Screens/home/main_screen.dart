import 'package:flutter/material.dart';
import 'package:flutter_app/User_Side_Screens/Screens/cart/cart_screen.dart';
import 'package:flutter_app/User_Side_Screens/Screens/chatbot/chatbot_screen.dart';
import 'package:flutter_app/User_Side_Screens/Screens/home/dashboard_screen.dart';
import 'package:flutter_app/User_Side_Screens/Screens/profile/profile_screen.dart';
import 'package:flutter_app/utils/app_colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // List of screens corresponding to each bottom nav item
  final List<Widget> _screens = [
    const DashboardScreen(),
    const CartScreen(),
    ChatScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 203, 215, 221),
        elevation: 6,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.buttoncolors,
        unselectedItemColor: AppColors.appbar.withValues(alpha: .6),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chatbot'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}

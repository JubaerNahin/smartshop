import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/utils/app_colors.dart';

import '../../../widgets/my_button.dart';

class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({super.key});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  final RxMap<String, dynamic> employee = RxMap<String, dynamic>({});
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchEmployeeData();
  }

  void _fetchEmployeeData() async {
    try {
      final user = _auth.currentUser;
      debugPrint("Current user: $user"); // <-- check current Firebase user
      if (user != null) {
        final snapshot =
            await FirebaseFirestore.instance
                .collection('Employees')
                .where('email', isEqualTo: user.email)
                .limit(1)
                .get();

        debugPrint("Snapshot docs: ${snapshot.docs}"); // <-- see Firestore docs

        if (snapshot.docs.isNotEmpty) {
          final doc = snapshot.docs.first;
          employee.assignAll(doc.data());
          debugPrint(
            "Employee data loaded: ${employee.toString()}",
          ); // <-- final data
        } else {
          Get.snackbar('Error', 'No employee data found');
          debugPrint("No employee data found for email: ${user.email}");
        }
      } else {
        debugPrint("No user is currently logged in.");
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load employee data: $e');
      debugPrint("Error fetching employee data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Obx(() {
      if (employee.isEmpty) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      return Scaffold(
        backgroundColor: AppColors.appbar,
        appBar: AppBar(
          title: const Text(
            "Employee Profile",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.appbar,
          elevation: 6,
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
        ),
        body: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          child: Container(
            color: AppColors.primarycolor,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile placeholder
                SizedBox(
                  height: screenHeight * 0.25,
                  width: screenHeight * 0.25,
                  child: CircleAvatar(
                    backgroundColor: Colors.grey.shade300,
                    radius:
                        (screenHeight * 0.25) /
                        2, // radius is half of height/width
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/employee_image.jpg',
                        fit:
                            BoxFit
                                .cover, // ensures the image fills the circle without distortion
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Name and Email
                SizedBox(height: 32),

                _buildInfoRow("Name", employee['name'] ?? ''),
                SizedBox(height: 8),

                _buildInfoRow("Email", employee['email'] ?? ''),
                SizedBox(height: 8),

                _buildInfoRow("Role", employee['role'] ?? 'Employee'),
                SizedBox(height: 32),
                MyButton(
                  text: "Logout",
                  onTap: () async {
                    try {
                      // Sign out from Firebase
                      await FirebaseAuth.instance.signOut();

                      // Show confirmation (optional)
                      Get.snackbar(
                        "Logout",
                        "Employee logged out successfully",
                        snackPosition: SnackPosition.TOP,
                      );

                      // Redirect to login or role selection screen
                      Get.offNamed('/role'); // replace with your actual route
                    } catch (e) {
                      Get.snackbar(
                        "Error",
                        "Logout failed: $e",
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            "$title: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}

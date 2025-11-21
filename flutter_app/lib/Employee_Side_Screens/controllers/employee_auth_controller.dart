import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/Employee_Side_Screens/models/employee_users.dart';
import 'package:get/get.dart';

class EmployeeAuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var loading = false.obs;
  var currentEmployee = Rxn<EmployeeUser>();

  // Sign Up
  Future<void> signUp(String name, String email, String password) async {
    loading.value = true;
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = cred.user!.uid;

      final employee = EmployeeUser(
        id: uid,
        name: name,
        email: email,
        role: 'employee',
        createdAt: DateTime.now(),
      );

      await _firestore.collection('Employees').doc(uid).set(employee.toMap());

      currentEmployee.value = employee;
    } on FirebaseAuthException {
      rethrow;
    } finally {
      loading.value = false;
    }
  }

  // Login
  Future<void> login(String email, String password) async {
    loading.value = true;
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = cred.user!.uid;

      final doc = await _firestore.collection('Employees').doc(uid).get();
      if (!doc.exists) {
        await _auth.signOut();
        throw Exception('Employee record not found');
      }

      currentEmployee.value = EmployeeUser.fromMap(doc.id, doc.data()!);
    } finally {
      loading.value = false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    currentEmployee.value = null;
    Get.offAllNamed('/welcome');
  }

  // Password reset
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
}

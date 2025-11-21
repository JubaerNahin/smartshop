import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/Employee_Side_Screens/models/admin_users.dart';
import 'package:get/get.dart';

class AdminAuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var loading = false.obs;
  var currentAdmin = Rxn<AdminUser>();

  // Call this to sign in
  Future<void> login(String email, String password) async {
    loading.value = true;
    try {
      final UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = cred.user?.uid;
      if (uid == null) throw Exception('No user id found');

      final doc = await _firestore.collection('Users').doc(uid).get();
      if (!doc.exists) {
        // Not found in Users collection
        await _auth.signOut();
        throw Exception('User record not found');
      }

      final adminUser = AdminUser.fromMap(doc.id, doc.data()!);
      if (!adminUser.isAdmin) {
        // Not an admin -> sign out and throw
        await _auth.signOut();
        throw Exception('Access denied — not an admin');
      }

      currentAdmin.value = adminUser;
      // Successful login: navigate to admin dashboard
      Get.offAllNamed('/admin/dashboard');
    } on FirebaseAuthException {
      rethrow; // bubble up to caller for UI handling
    } finally {
      loading.value = false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    currentAdmin.value = null;
    Get.offAllNamed('/welcome'); // or '/signin'
  }

  // Optional: send password reset
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
}

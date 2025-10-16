import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/widgets/my_textfield.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
// Your custom textfield widget

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String imageUrl = '';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc =
        await FirebaseFirestore.instance.collection("Users").doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      nameController.text = data['name'] ?? '';
      emailController.text = data['email'] ?? '';
      passwordController.text = data['password'] ?? '';
      phoneController.text = data['phone'] ?? '';
      addressController.text = data['address'] ?? '';
      imageUrl = data['imageUrl'] ?? '';
      setState(() {});
    }
  }

  Future<void> _updateProfile() async {
    await _firestore.collection('Users').doc('user_id').set({
      'name': nameController.text,
      'email': emailController.text,
      'password': passwordController.text,
      'phone': phoneController.text,
      'address': addressController.text,
      'imageUrl':
          imageUrl, // Optional: keep if you're storing image URLs manually
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile updated')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Get.toNamed('/signin');
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage:
                  imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
              child:
                  imageUrl.isEmpty ? const Icon(Icons.person, size: 60) : null,
            ),
            const SizedBox(height: 20),
            EditableProfileField(
              label: 'Name',
              value: nameController.text,
              onChanged: (val) {
                nameController.text = val;
                _updateProfile();
              },
            ),
            const SizedBox(height: 12),
            EditableProfileField(
              label: 'Email',
              value: emailController.text,
              onChanged: (val) {
                emailController.text = val;
                _updateProfile();
              },
            ),
            const SizedBox(height: 12),
            EditableProfileField(
              label: 'Password',
              value: passwordController.text,
              obscure: true,
              onChanged: (val) {
                passwordController.text = val;
                _updateProfile();
              },
            ),
            const SizedBox(height: 12),
            EditableProfileField(
              label: 'Phone',
              value: phoneController.text,
              onChanged: (val) {
                phoneController.text = val;
                _updateProfile();
              },
            ),
            const SizedBox(height: 12),
            EditableProfileField(
              label: 'Address',
              value: addressController.text,
              onChanged: (val) {
                addressController.text = val;
                _updateProfile();
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

class EditableProfileField extends StatefulWidget {
  final String label;
  final String value;
  final bool obscure;
  final Function(String) onChanged;

  const EditableProfileField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.obscure = false,
  });

  @override
  State<EditableProfileField> createState() => _EditableProfileFieldState();
}

class _EditableProfileFieldState extends State<EditableProfileField> {
  bool isEditing = false;
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.value);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child:
                isEditing
                    ? TextField(
                      controller: controller,
                      obscureText: widget.obscure,
                      decoration: InputDecoration(
                        labelText: widget.label,
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (val) {
                        widget.onChanged(val);
                        setState(() => isEditing = false);
                      },
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.value.isNotEmpty ? widget.value : 'Not set',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
          ),
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (isEditing) {
                widget.onChanged(controller.text);
              }
              setState(() => isEditing = !isEditing);
            },
          ),
        ],
      ),
    );
  }
}

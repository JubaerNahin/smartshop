import 'package:flutter/material.dart';
import 'package:flutter_app/Employee_Side_Screens/controllers/product_uploader.dart'; // adjust path

class AdminUploadPage extends StatelessWidget {
  const AdminUploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin - Upload Products')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Upload products.json to Firestore'),
          onPressed: () async {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (c) => const Center(child: CircularProgressIndicator()),
            );
            try {
              await ProductUploader.uploadFromAssets();
              Navigator.of(context).pop(); // close progress
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Products uploaded successfully')),
              );
            } catch (e) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
            }
          },
        ),
      ),
    );
  }
}

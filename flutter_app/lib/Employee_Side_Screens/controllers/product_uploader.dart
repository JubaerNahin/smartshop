import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/User_Side_Screens/models/products.dart'; // adjust import path

class ProductUploader {
  /// Upload products.json -> Firestore 'products' collection
  static Future<void> uploadFromAssets({
    String jsonPath = 'assets/data/products.json',
  }) async {
    final firestore = FirebaseFirestore.instance;

    try {
      // 1) load json string
      final jsonStr = await rootBundle.loadString(jsonPath);

      // 2) decode
      final List<dynamic> list = json.decode(jsonStr);

      if (list.isEmpty) {
        print('No products found in $jsonPath');
        return;
      }

      // 3) create a batch write (good for many docs)
      final WriteBatch batch = firestore.batch();

      for (var item in list) {
        if (item is! Map<String, dynamic>) {
          // try to coerce if needed
          item = Map<String, dynamic>.from(item);
        }

        // create a new document ref with generated id
        final docRef = firestore.collection('products').doc();

        // create ProductModel (uses the tolerant fromMap)
        final product = ProductModel.fromMap(
          docRef.id,
          Map<String, dynamic>.from(item),
        );

        // add to batch
        batch.set(docRef, product.toMap());
      }

      // 4) commit
      await batch.commit();
      print('Uploaded ${list.length} products to Firestore successfully.');
    } catch (e, st) {
      print('Error uploading products: $e');
      print(st);
      rethrow;
    }
  }
}

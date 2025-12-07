import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/MyApp.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app/User_Side_Screens/controllers/cart_controller.dart';
import 'package:flutter_app/User_Side_Screens/controllers/product_controller.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Get.put(ProductController(), permanent: true);
  Get.put(CartController(), permanent: true);
  runApp(DevicePreview(enabled: false, builder: (context) => MyApp()));
}

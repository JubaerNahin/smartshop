import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/MyApp.dart';

void main() {
  runApp(DevicePreview(enabled: true, builder: (context) => MyApp()));
}

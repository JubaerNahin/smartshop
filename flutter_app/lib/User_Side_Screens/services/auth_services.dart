import 'package:flutter/material.dart';

void displayMassageToUser(String massage, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(title: Text(massage)),
  );
}

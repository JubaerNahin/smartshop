import 'package:flutter_app/User_Side_Screens/authentication/sign_up_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets("User Registration – Successful Registration", (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignUpScreen()));

    await tester.enterText(find.byKey(Key("nameField")), "Nahin");
    await tester.enterText(find.byKey(Key("emailField")), "test@gmail.com");
    await tester.enterText(find.byKey(Key("passwordField")), "123456");

    await tester.tap(find.byKey(Key("registerButton")));
    await tester.pumpAndSettle();

    expect(find.text("Registration Successful"), findsOneWidget);
  });
}

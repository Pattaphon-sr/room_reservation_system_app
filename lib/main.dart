import 'package:flutter/material.dart';
import 'features/auth/view/initial_screen.dart';
import 'features/auth/view/sign_up_screen.dart';
import 'features/auth/view/sign_in_screen.dart';
import 'features/test_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TestScreen(),
    );
  }
}

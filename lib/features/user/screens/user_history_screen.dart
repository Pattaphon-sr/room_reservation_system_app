import 'package:flutter/material.dart';

class UserHistoryScreen extends StatelessWidget {
  const UserHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('History')),
      body: Center(child: Text('User History')),
    );
  }
}

// lib/features/user/pages/user_account_page.dart
import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/shared/widgets/widgets.dart';
import 'package:room_reservation_system_app/core/theme/theme.dart';
import 'package:room_reservation_system_app/features/auth/auth.dart';

class UserAccountScreen extends StatefulWidget {
  const UserAccountScreen({super.key});

  @override
  State<UserAccountScreen> createState() => _UserAccountScreenState();
}

class _UserAccountScreenState extends State<UserAccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.primaryGradient5C,
            stops: AppColorStops.primaryStop5C,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 80),
              const CircleAvatar(
                radius: 35,
                backgroundColor: Color.fromARGB(255, 192, 47, 3),
                child: Icon(
                  Icons.emoji_emotions,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "Hi, User123!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "user123@gmail.com",
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 30),
              const Divider(color: Colors.white30, indent: 60, endIndent: 60),
              const Spacer(),

              // ปุ่ม Log Out
              Container(
                width: 250,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.red),
                ),
                child: TextButton(
                  onPressed: () => _showSignOutDialog(context),
                  child: const Text(
                    "Log Out",
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 40),
              const Text(
                "Group 2 Project B",
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSignOutDialog(BuildContext context) async {
    await showAirDialog(
      context,
      height: 400,
      title: null,
      content: Center(
        // Center ทำให้ dialog อยู่ตรงกลางแน่นอน
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              // สลับด้านไอคอน
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(3.1416),
                child: Image.asset(
                  'assets/icons/healthicons--running-outline.png',
                  width: 120,
                  height: 120,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Sign out?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "Are you sure you want to sign out?",
                style: TextStyle(fontSize: 14, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 42),
              AppButton.solid(
                label: 'Sign Out',
                onPressed: () async {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 12),
              AppButton.outline(
                label: 'Cancel',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
      actions: const [SizedBox.shrink()],
    );
  }
}

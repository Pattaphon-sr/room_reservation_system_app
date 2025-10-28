import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/features/auth/auth.dart';
import 'package:room_reservation_system_app/shared/widgets/widgets.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
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
            colors: [
              Color(0xFF27145E),
              Color(0xFF1B396B),
              Color(0xFF94D6D0),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 80),
            const CircleAvatar(
              radius: 35,
              backgroundColor: Colors.orange,
              child: Icon(Icons.emoji_emotions, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 15),
            const Text(
              "Hi, User123!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
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
                onPressed: () {
                  _showSignOutDialog(context);
                },
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
    );
  }

  // กล่องยืนยันการออกจากระบบ
  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // ต้องกดปุ่มเท่านั้นถึงปิดได้
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF3C4E7B),
                  Color(0xFF87C6BE),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white30, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.logout, color: Colors.white, size: 60),
                const SizedBox(height: 20),
                const Text(
                  "Sign out?",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Are you sure you want to sign out?",
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),

                // ปุ่ม Sign Out
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      // นำทางกลับไปหน้า SignInScreen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const SignInScreen()),
                      );
                    },
                    child: const Text(
                      "Sign Out",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ปุ่ม Cancel
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

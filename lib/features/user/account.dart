import 'package:flutter/material.dart';


class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _bottomNavBar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF27145E), // mock deep purple
              Color(0xFF1B396B), // mock blue
              Color(0xFF94D6D0), // mock teal
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 80),

            // Profile Section
            const CircleAvatar(
              radius: 35,
              backgroundColor: Colors.orange,
              child: Icon(Icons.emoji_emotions, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 15),
            const Text("Hi, User123!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            const Text("user123@gmail.com", style: TextStyle(fontSize: 14, color: Colors.white70)),
            const SizedBox(height: 30),
            const Divider(color: Colors.white30, indent: 60, endIndent: 60),

            const Spacer(),

            // Logout Button
            Container(
              width: 250,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.red),
              ),
              child: TextButton(
                onPressed: () {}, // ยังไม่ทำงาน
                child: const Text("Log Out", style: TextStyle(color: Colors.red, fontSize: 16)),
              ),
            ),

            const SizedBox(height: 40),
            const Text("Group 2 Project B", style: TextStyle(color: Colors.black54, fontSize: 12)),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _bottomNavBar() {
    return BottomNavigationBar(
      currentIndex: 2, // Account tab active
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.add_box), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
      ],
    );
  }
}

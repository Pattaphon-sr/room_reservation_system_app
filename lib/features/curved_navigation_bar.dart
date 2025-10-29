import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Curved Nav Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F9CA6)),
        useMaterial3: true,
      ),
      home: const CurvedNavHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CurvedNavHome extends StatefulWidget {
  const CurvedNavHome({super.key});
  @override
  State<CurvedNavHome> createState() => _CurvedNavHomeState();
}

class _CurvedNavHomeState extends State<CurvedNavHome> {
  // --- state & controllers ---
  int _page = 0;
  final _pageCtrl = PageController();
  final GlobalKey<CurvedNavigationBarState> _navKey = GlobalKey();

  // --- UI assets ---
  static const _barColor = Color(0xFF7ABDB8); // สีแท็บบาร์
  static const _btnColor = Color(0xFF138B8E); // สีปุ่มกลาง/nob
  final _items = const <Widget>[
    Icon(Icons.home_rounded, size: 28, color: Colors.white),
    Icon(Icons.note_add_rounded, size: 28, color: Colors.white),
    Icon(Icons.menu_book_rounded, size: 28, color: Colors.white),
    Icon(Icons.person_rounded, size: 28, color: Colors.white),
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ให้แท็บบาร์ลอยสวย ๆ กับพื้นหลังของ body
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF2F5F7),

      // ---------- BODY (PageView synced) ----------
      body: PageView(
        controller: _pageCtrl,
        onPageChanged: (i) {
          setState(() => _page = i);
          // sync ปุ่ม nav เมื่อสไลด์เพจด้วยนิ้ว
          _navKey.currentState?.setPage(i);
        },
        children: [
          _demoPage('Home', Icons.home_rounded, Colors.teal.shade600),
          _demoPage('Booking', Icons.note_add_rounded, Colors.teal.shade700),
          _demoPage('History', Icons.menu_book_rounded, Colors.indigo.shade700),
          _demoPage(
            'Account',
            Icons.person_rounded,
            Colors.deepPurple.shade700,
            extra: ElevatedButton(
              onPressed: () {
                // สาธิต: เปลี่ยนไปแท็บ index 1 ด้วยโค้ด
                _navKey.currentState?.setPage(1);
                _pageCtrl.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOut,
                );
              },
              child: const Text('Go To Page of index 1'),
            ),
          ),
        ],
      ),

      // ---------- CURVED NAV BAR ----------
      bottomNavigationBar: CurvedNavigationBar(
        key: _navKey,
        index: _page,
        items: _items,
        height: 62,
        color: _barColor, // สีของแท็บบาร์
        buttonBackgroundColor: _btnColor, // สีปุ่มกลาง (นูน)
        backgroundColor: Colors.transparent, // ให้เห็น body ใต้แท็บบาร์
        animationCurve: Curves.easeOutCubic,
        animationDuration: const Duration(milliseconds: 350),
        onTap: (index) {
          setState(() => _page = index);
          _pageCtrl.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        },
      ),
    );
  }

  // เพจตัวอย่างสี+ไอคอน พร้อมแสดง index ปัจจุบัน
  Widget _demoPage(String title, IconData icon, Color color, {Widget? extra}) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Current index: $_page',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
            ),
            if (extra != null) ...[const SizedBox(height: 16), extra],
          ],
        ),
      ),
    );
  }
}

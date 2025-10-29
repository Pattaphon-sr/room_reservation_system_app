import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/routes/nested_navigator.dart';
import 'package:room_reservation_system_app/features/staff/screens/staff_account_screen.dart';
import 'package:room_reservation_system_app/features/staff/screens/staff_home_screen.dart';
import 'package:room_reservation_system_app/features/staff/screens/staff_booking_screen.dart';
import 'package:room_reservation_system_app/features/staff/screens/staff_history_screen.dart';

class StaffRoot extends StatefulWidget {
  const StaffRoot({super.key});

  /// เรียกจากที่ไหนก็ได้เพื่อสลับแท็บของ Staff
  static void goTo(
    BuildContext context,
    int index, {
    String? route,
    Object? args,
    bool clearStack = false,
  }) {
    final st = context.findAncestorStateOfType<_StaffRootState>();
    st?._switchTo(index, route: route, args: args, clearStack: clearStack);
  }

  @override
  State<StaffRoot> createState() => _StaffRootState();
}

class _StaffRootState extends State<StaffRoot> {
  int _index = 0;
  final _navKeys = List.generate(4, (_) => GlobalKey<NavigatorState>());

  Future<bool> _onWillPop() async {
    final nav = _navKeys[_index].currentState!;
    if (nav.canPop()) {
      nav.pop();
      return false;
    }
    if (_index != 0) {
      setState(() => _index = 0);
      return false;
    }
    return true;
  }

  void _switchTo(
    int i, {
    String? route,
    Object? args,
    bool clearStack = false,
  }) {
    setState(() => _index = i);
    if (route != null) {
      final nav = _navKeys[i].currentState;
      if (nav == null) return;
      if (clearStack) nav.popUntil((r) => r.isFirst);
      nav.pushNamed(route, arguments: args);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            NestedTabNavigator(
              navKey: _navKeys[0],
              initialPageBuilder: (_) => const StaffHomeScreen(),
              routes: {'/': (_) => const StaffHomeScreen()},
            ),
            NestedTabNavigator(
              navKey: _navKeys[1],
              initialPageBuilder: (_) => const StaffBookingScreen(),
              routes: {'/': (_) => const StaffBookingScreen()},
            ),
            NestedTabNavigator(
              navKey: _navKeys[2],
              initialPageBuilder: (_) => const StaffHistoryScreen(),
              routes: {'/': (_) => const StaffHistoryScreen()},
            ),
            NestedTabNavigator(
              navKey: _navKeys[3],
              initialPageBuilder: (_) => const StaffAccountScreen(),
              routes: {'/': (_) => const StaffAccountScreen()},
            ),
          ],
        ),
        bottomNavigationBar: CurvedNavigationBar(
          index: _index,
          height: 60,
          backgroundColor: Colors.transparent,
          color: const Color(0xFF115E9B),
          buttonBackgroundColor: const Color(0xFF115E9B),
          animationCurve: Curves.easeOutCubic,
          animationDuration: const Duration(milliseconds: 360),
          items: const [
            Icon(Icons.home_rounded, size: 28, color: Colors.white),
            Icon(Icons.note_alt_outlined, size: 28, color: Colors.white),
            Icon(Icons.book, size: 28, color: Colors.white),
            Icon(Icons.person_rounded, size: 28, color: Colors.white),
          ],
          onTap: (i) => setState(() => _index = i),
        ),
      ),
    );
  }
}

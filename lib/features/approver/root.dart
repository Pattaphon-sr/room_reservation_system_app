import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/routes/nested_navigator.dart';
import 'package:room_reservation_system_app/features/approver/screens/approver_account_screen.dart';
import 'package:room_reservation_system_app/features/approver/screens/approver_booking_screen.dart';
import 'package:room_reservation_system_app/features/approver/screens/approver_history_screen.dart';
import 'package:room_reservation_system_app/features/approver/screens/approver_home_screen.dart';

class ApproverRoot extends StatefulWidget {
  const ApproverRoot({super.key});
  @override
  State<ApproverRoot> createState() => _ApproverRootState();
}

class _ApproverRootState extends State<ApproverRoot> {
  int _index = 0;
  final _navKeys = List.generate(5, (_) => GlobalKey<NavigatorState>());

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
              initialPageBuilder: (_) => const ApproverHomeScreen(),
              routes: {'/': (_) => const ApproverHomeScreen()},
            ),
            NestedTabNavigator(
              navKey: _navKeys[1],
              initialPageBuilder: (_) => const ApproverBookingScreen(),
              routes: {'/': (_) => const ApproverBookingScreen()},
            ),
            NestedTabNavigator(
              navKey: _navKeys[2],
              initialPageBuilder: (_) => const ApproverHistoryScreen(),
              routes: {'/': (_) => const ApproverHistoryScreen()},
            ),
            NestedTabNavigator(
              navKey: _navKeys[3],
              initialPageBuilder: (_) => const ApproverAccountScreen(),
              routes: {'/': (_) => const ApproverAccountScreen()},
            ),
            NestedTabNavigator(
              navKey: _navKeys[4],
              initialPageBuilder: (_) => const ApproverAccountScreen(),
              routes: {'/': (_) => const ApproverAccountScreen()},
            ),
          ],
        ),
        bottomNavigationBar: CurvedNavigationBar(
          index: _index,
          height: 60,
          backgroundColor: Colors.transparent,
          color: const Color(0xFF3B1C82),
          buttonBackgroundColor: const Color(0xFF3B1C82),
          animationCurve: Curves.easeOutCubic,
          animationDuration: const Duration(milliseconds: 360),
          items: const [
            Icon(Icons.home_rounded, size: 28, color: Colors.white),
            Icon(Icons.map_rounded, size: 28, color: Colors.white),
            Icon(Icons.event_note_rounded, size: 28, color: Colors.white),
            Icon(Icons.book, size: 28, color: Colors.white),
            Icon(Icons.person_rounded, size: 28, color: Colors.white),
          ],
          onTap: (i) => setState(() => _index = i),
        ),
      ),
    );
  }
}

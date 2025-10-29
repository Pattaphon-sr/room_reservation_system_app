import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/routes/nested_navigator.dart';
import 'package:room_reservation_system_app/features/user/screens/user_account_screen.dart';
import 'package:room_reservation_system_app/features/user/screens/user_booking_screen.dart';
import 'package:room_reservation_system_app/features/user/screens/user_history_screen.dart';
import 'package:room_reservation_system_app/features/user/screens/user_home_screen.dart';

class UserRoot extends StatefulWidget {
  const UserRoot({super.key});
  @override
  State<UserRoot> createState() => _UserRootState();
}

class _UserRootState extends State<UserRoot> {
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

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            NestedTabNavigator(
              navKey: _navKeys[0],
              initialPageBuilder: (_) => const UserHomeScreen(),
              routes: {'/': (_) => const UserHomeScreen()},
            ),
            NestedTabNavigator(
              navKey: _navKeys[1],
              initialPageBuilder: (_) => const UserBookingScreen(),
              routes: {'/': (_) => const UserBookingScreen()},
            ),
            NestedTabNavigator(
              navKey: _navKeys[2],
              initialPageBuilder: (_) => const UserHistoryScreen(),
              routes: {'/': (_) => const UserHistoryScreen()},
            ),
            NestedTabNavigator(
              navKey: _navKeys[3],
              initialPageBuilder: (_) => const UserAccountScreen(),
              routes: {'/': (_) => const UserAccountScreen()},
            ),
          ],
        ),
        bottomNavigationBar: CurvedNavigationBar(
          index: _index,
          height: 60,
          backgroundColor: Colors.transparent,
          color: const Color(0xFF0F828C),
          buttonBackgroundColor: const Color(0xFF0F828C),
          animationCurve: Curves.easeOutCubic,
          animationDuration: const Duration(milliseconds: 360),
          items: const [
            Icon(Icons.home_rounded, size: 28, color: Colors.white),
            Icon(Icons.event_note_rounded, size: 28, color: Colors.white),
            Icon(Icons.menu_book_rounded, size: 28, color: Colors.white),
            Icon(Icons.person_rounded, size: 28, color: Colors.white),
          ],
          onTap: (i) => setState(() => _index = i),
        ),
        bottomSheet: bottomPad > 0 ? SizedBox(height: bottomPad) : null,
      ),
    );
  }
}

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/routes/nested_navigator.dart';
import 'package:room_reservation_system_app/features/user/screens/user_account_screen.dart';
import 'package:room_reservation_system_app/features/user/screens/user_booking_screen.dart';
import 'package:room_reservation_system_app/features/user/screens/user_history_screen.dart';
import 'package:room_reservation_system_app/features/user/screens/user_home_screen.dart';

class UserRoot extends StatefulWidget {
  const UserRoot({super.key});

  /// เรียกจากที่ไหนก็ได้: สลับไปยังแท็บ [index]
  /// ถ้าให้ [route] มาด้วย จะ push หน้านั้นบนสแตกของแท็บเป้าหมาย
  static void goTo(
    BuildContext context,
    int index, {
    String? route,
    Object? args,
    bool clearStack = false,
  }) {
    final st = context.findAncestorStateOfType<_UserRootState>();
    st?._switchTo(index, route: route, args: args, clearStack: clearStack);
  }

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

      if (clearStack) {
        nav.popUntil((r) => r.isFirst);
      }
      nav.pushNamed(route, arguments: args);
    }
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
              initialPageBuilder: (_) => const UserHistoryDio(),
              routes: {'/': (_) => const UserHistoryDio()},
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
            Icon(Icons.book, size: 28, color: Colors.white),
            Icon(Icons.person_rounded, size: 28, color: Colors.white),
          ],
          onTap: (i) => setState(() => _index = i),
        ),
        bottomSheet: bottomPad > 0 ? SizedBox(height: bottomPad) : null,
      ),
    );
  }
}

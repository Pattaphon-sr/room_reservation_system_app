import 'package:flutter/material.dart';

class NestedTabNavigator extends StatelessWidget {
  const NestedTabNavigator({
    super.key,
    required this.navKey,
    required this.initialPageBuilder,
    required this.routes,
  });

  final GlobalKey<NavigatorState> navKey;
  final WidgetBuilder initialPageBuilder;
  final Map<String, WidgetBuilder> routes;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navKey,
      onGenerateRoute: (settings) {
        final name = settings.name ?? '/';
        final builder = routes[name];
        if (builder != null) {
          return MaterialPageRoute(builder: builder, settings: settings);
        }
        return MaterialPageRoute(builder: initialPageBuilder);
      },
    );
  }
}

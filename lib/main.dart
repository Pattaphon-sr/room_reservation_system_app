import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/services/auth_service.dart';
import 'package:room_reservation_system_app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.instance.bootstrap();
  runApp(const App());
}

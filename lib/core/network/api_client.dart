import 'package:dio/dio.dart';
import '../config/env.dart';
import 'package:room_reservation_system_app/services/auth_service.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient _i = ApiClient._();
  factory ApiClient() => _i;

  Dio get dio {
    final d = Dio(
      BaseOptions(
        baseUrl: '${Env.baseUrl}/api',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    d.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final t = AuthService.instance.token;
          if (t != null && t.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $t';
          }
          handler.next(options);
        },
        onError: (e, handler) async {
          // ถ้าโดน 401 ให้เคลียร์สถานะล็อกอิน (ป้องกัน token เสีย)
          if (e.response?.statusCode == 401) {
            await AuthService.instance.logout();
          }
          handler.next(e);
        },
      ),
    );

    return d;
  }
}

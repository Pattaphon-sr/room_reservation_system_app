import 'package:dio/dio.dart';
import '../auth/auth_store.dart';
import '../config/env.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient _i = ApiClient._();
  factory ApiClient() => _i;

  final _auth = AuthStore();

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
          final token = await _auth.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

    return d;
  }
}

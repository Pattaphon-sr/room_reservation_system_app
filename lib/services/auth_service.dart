import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:room_reservation_system_app/core/network/api_client.dart';
import 'package:room_reservation_system_app/core/routes/roles.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  String? lastError;

  final Dio _dio = ApiClient().dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _token;
  Map<String, dynamic>? _payload;

  String? get token => _token;
  Map<String, dynamic>? get payload => _payload;

  Role? get role {
    final r = _payload?['role'] as String?;
    switch (r) {
      case 'staff':
        return Role.staff;
      case 'approver':
        return Role.approver;
      case 'user':
      default:
        return Role.user;
    }
  }

  /// โหลด token/payload จาก secure storage ตอนเปิดแอป
  Future<void> bootstrap() async {
    _token = await _storage.read(key: 'auth_token');
    final p = await _storage.read(key: 'auth_payload');
    if (p != null) {
      try {
        _payload = jsonDecode(p) as Map<String, dynamic>;
      } catch (_) {
        _payload = null;
      }
    }
  }

  /// login: ส่ง email หรือ username อย่างใดอย่างหนึ่ง + password
  /// คืนค่า Role ถ้าสำเร็จ, ถ้าไม่สำเร็จ -> null
  Future<Role?> login({
    String? email,
    String? username,
    required String password,
  }) async {
    final dio = ApiClient().dio;

    final body = <String, dynamic>{
      if (email != null && email.isNotEmpty) 'email': email,
      if (username != null && username.isNotEmpty) 'username': username,
      'password': password,
    };

    try {
      lastError = null; // เคลียร์ของเดิม
      final res = await dio.post('/auth/login', data: body);
      final data = res.data as Map<String, dynamic>;

      _token = data['token'] as String?;
      _payload = (data['payload'] as Map?)?.cast<String, dynamic>();

      if (_token == null || _payload == null) {
        lastError = 'Malformed response';
        return null;
      }

      await _storage.write(key: 'auth_token', value: _token);
      await _storage.write(key: 'auth_payload', value: jsonEncode(_payload));
      return role;
    } on DioException catch (e) {
      // เก็บข้อความจากเซิร์ฟเวอร์ ถ้ามี
      lastError =
          e.response?.data is Map && (e.response!.data['message'] != null)
          ? e.response!.data['message'].toString()
          : (e.message ?? 'Network error');
      return null; // ให้ UI ตัดสินใจจาก null
    } catch (e) {
      lastError = 'Unexpected error';
      return null;
    }
  }

  /// คืนค่า `null` = สำเร็จ, ไม่ใช่ null = ข้อความ error
  Future<String?> signup({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      await _dio.post(
        '/auth/signup',
        data: {'email': email, 'username': username, 'password': password},
      );
      return null;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['message'] is String) {
        return data['message'] as String;
      }
      return 'Signup failed';
    }
  }

  Future<void> logout() async {
    _token = null;
    _payload = null;
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'auth_payload');
  }
}

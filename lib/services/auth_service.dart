import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:room_reservation_system_app/core/routes/roles.dart'; // Import Role enum ของคุณ

// TODO: จัดการการเก็บ Token และ User Payload
// แนะนำให้ใช้ flutter_secure_storage หรือ shared_preferences
// เพื่อเก็บ token ไว้หลังจากล็อกอินสำเร็จ

class AuthService {
  // --- Singleton Pattern ---
  AuthService._privateConstructor();
  static final AuthService instance = AuthService._privateConstructor();
  // -------------------------

  // URL ของ Backend (Node.js)
  // 10.0.2.2 คือ "localhost" สำหรับ Android Emulator
  // ถ้าทดสอบบน iOS Simulator หรือ Web/Desktop ให้ใช้ "localhost"
  final String _baseUrl = "http://localhost:3000/api/auth";

  // ฟังก์ชันสำหรับ Login
  Future<Role?> login({required String email, required String password}) async {
    final Uri url = Uri.parse('$_baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final payload = data['payload'];
        final token = data['token'];

        // TODO: เก็บ token และ payload ไว้ในที่ปลอดภัย
        // print('Login Success! Token: $token');
        // print('User Payload: $payload');

        // คืนค่า Role
        return _roleFromString(payload['role']);
      } else {
        // ล็อกอินไม่สำเร็จ (เช่น รหัสผิด)
        final error = jsonDecode(response.body);
        print('Login Error: ${error['message']}');
        return null;
      }
    } catch (e) {
      // ไม่สามารถเชื่อมต่อ Server ได้
      print('Connection Error: $e');
      return null;
    }
  }

  // ฟังก์ชันสำหรับ Signup
  Future<bool> signup(
      {required String email,
      required String username,
      required String password}) async {
    final Uri url = Uri.parse('$_baseUrl/signup');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        // สมัครสำเร็จ
        print('Signup Success!');
        return true;
      } else {
        // สมัครไม่สำเร็จ (เช่น email ซ้ำ)
        final error = jsonDecode(response.body);
        print('Signup Error: ${error['message']}');
        return false;
      }
    } catch (e) {
      // ไม่สามารถเชื่อมต่อ Server ได้
      print('Connection Error: $e');
      return false;
    }
  }

  // Helper สำหรับแปลง String role เป็น Enum
  Role _roleFromString(String roleStr) {
    switch (roleStr.toLowerCase()) {
      case 'staff':
        return Role.staff;
      case 'approver':
        return Role.approver;
      case 'user':
      default:
        return Role.user;
    }
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:room_reservation_system_app/core/routes/roles.dart'; 
// ⭐️ IMPORT เพิ่ม
import 'package:shared_preferences/shared_preferences.dart'; 

class AuthService {
  // --- Singleton Pattern ---
  AuthService._privateConstructor();
  static final AuthService instance = AuthService._privateConstructor();
  // -------------------------

  final String _baseUrl = "http://localhost:3000/api/auth"; // ⭐️ ใช้ 10.0.2.2 (สำหรับ Android)

  // ⭐️⭐️ [เพิ่ม] ฟังก์ชันสำหรับ "อ่าน" Token ⭐️⭐️
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // ⬅️ "อ่าน" Token
  }

  // ⭐️⭐️ [เพิ่ม] ฟังก์ชันสำหรับ "ลบ" Token (ตอน Logout) ⭐️⭐️
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // ⬅️ "ลบ" Token
  }


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

        // ⭐️⭐️ [นี่คือ "กาว" ที่ขาดไป] ⭐️⭐️
        // "เก็บ" Token ลงใน SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token); 
        // ⭐️⭐️ [สิ้นสุดส่วนที่เพิ่ม] ⭐️⭐️

        // คืนค่า Role
        return _roleFromString(payload['role']);
      } else {
        final error = jsonDecode(response.body);
        print('Login Error: ${error['message']}');
        return null;
      }
    } catch (e) {
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
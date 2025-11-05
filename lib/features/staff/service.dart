import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/staff_history_screen.dart';

class StaffHistoryService {
  final String baseUrl = 'http://192.168.1.6:3000';

  Future<List<ActivityItem>> fetchHistory() async {
    try {
      final token = await _getToken();
      print('Token: $token');

      final response = await http.get(
        Uri.parse('$baseUrl/api/reservations/history'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // ✅ กรองเฉพาะ approved และ rejected (ไม่เอา pending)
        final filteredData = data.where((json) {
          final status = json['status']?.toString().toLowerCase();
          return status == 'approved' ||
              status == 'rejected' ||
              status == 'reserved'; // เพิ่ม reserved (ถ้า backend ใช้คำนี้)
        }).toList();

        print('📋 Total items: ${data.length}');
        print('✅ Filtered items: ${filteredData.length}');

        return filteredData.map((json) => _parseActivityItem(json)).toList();
      } else {
        throw Exception('Failed to load history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching history: $e');
    }
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  ActivityItem _parseActivityItem(Map<String, dynamic> json) {
    return ActivityItem(
      status: _parseStatus(json['status']),
      floor: json['floor'] ?? '',
      roomCode: json['room_code'] ?? '',
      slot: json['slot'] ?? '',
      dateTime: DateTime.parse(json['date_time']),
      requestedBy: json['requested_by'] ?? '',
      approvedBy: json['approved_by'],
      note: json['note'],
    );
  }

  ApprovalStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'reserved': // ✅ เพิ่ม reserved
        return ApprovalStatus.approved;
      case 'rejected':
        return ApprovalStatus.rejected;
      default:
        return ApprovalStatus.approved; // ✅ เปลี่ยนจาก pending
    }
  }
}

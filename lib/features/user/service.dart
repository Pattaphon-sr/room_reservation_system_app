import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:room_reservation_system_app/core/config/env.dart';
import 'package:room_reservation_system_app/features/user/screens/user_history_screen.dart';
import 'package:room_reservation_system_app/services/auth_service.dart';

class UserHistoryService {
  final String baseUrl = '${Env.baseUrl}';

  /// ดึงประวัติการจองของ User (กรองเฉพาะของตัวเอง)
  Future<List<ActivityItem>> fetchHistory() async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/api/reservations/history',
            ), // ✅ เปลี่ยนกลับเป็น /api/reservations/history
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      print('📡 Response Status: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('📋 Total items: ${data.length}');

        // ✅ แสดง requested_by ทั้งหมด
        for (var item in data) {
          print(
            '👤 requested_by: ${item['requested_by']} | status: ${item['status']} | date: ${item['date_time']}',
          );
        }

        String currentUserId =
            AuthService.instance.payload?['username']?.toString() ?? '';

        final filtered = data
            .where(
              (json) => json['requested_by'].toString() == currentUserId,
            ) // ✅ แปลงเป็น string
            .toList();
        print('✅ Filtered items: ${filtered.length}');

        return filtered.map((json) => _parseActivityItem(json)).toList();
      } else {
        throw Exception('Failed to load history: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Connection timeout - check your backend');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  ActivityItem _parseActivityItem(Map<String, dynamic> json) {
    return ActivityItem(
      status: _parseStatus(json['status']),
      floor: json['floor'] ?? 'N/A',
      roomCode: json['room_code'] ?? 'N/A',
      slot: json['slot'] ?? 'N/A',
      dateTime: DateTime.parse(json['date_time']),
      note: json['note'],
    );
  }

  ApprovalStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
      case 'reserved':
        return ApprovalStatus.approved;
      case 'rejected':
        return ApprovalStatus.rejected;
      default:
        return ApprovalStatus.pending;
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:room_reservation_system_app/features/approver/screens/approver_history_screen.dart';

/// Model สำหรับคำขอจองที่รอพิจารณา
class PendingReservation {
  final int id;
  final String requestedBy;
  final String floor;
  final String roomCode;
  final String slot;
  final DateTime dateTime;
  final String? note;

  PendingReservation({
    required this.id,
    required this.requestedBy,
    required this.floor,
    required this.roomCode,
    required this.slot,
    required this.dateTime,
    this.note,
  });

  factory PendingReservation.fromJson(Map<String, dynamic> json) {
    return PendingReservation(
      id: json['id'],
      requestedBy: json['requested_by'] ?? 'Unknown',
      floor: json['floor'] ?? 'N/A',
      roomCode: json['room_code'] ?? 'N/A',
      slot: json['slot'] ?? 'N/A',
      dateTime: DateTime.parse(json['date_time']),
      note: json['note'],
    );
  }
}

class ApproverHistoryService {
  final String baseUrl = 'http://192.168.1.6:3000';

  // ==================== HISTORY ====================

  /// ดึงประวัติการพิจารณาของ Approver (กรองเฉพาะที่ตัวเองอนุมัติ/ปฏิเสธ)
  Future<List<ApproverHistoryItem>> fetchHistory() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/reservations/history'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      print('📡 Response Status: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('📋 Total items: ${data.length}');

        // ✅ แสดง approved_by ทั้งหมด
        for (var item in data) {
          print('👤 approved_by: ${item['approved_by']}');
        }

        const String currentApproverId = 'AdPingPong';

        final filtered = data
            .where((json) => json['approved_by'] == currentApproverId)
            .toList();
        print('✅ Filtered items: ${filtered.length}');

        return filtered.map((json) => _parseApproverItem(json)).toList();
      } else {
        throw Exception('Failed to load history: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Connection timeout - check your backend');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  ApproverHistoryItem _parseApproverItem(Map<String, dynamic> json) {
    return ApproverHistoryItem(
      dateTime: DateTime.parse(json['date_time']),
      status: _parseStatus(json['status']),
      floor: json['floor'] ?? 'N/A',
      roomCode: json['room_code'] ?? 'N/A',
      slot: json['slot'] ?? 'N/A',
      requesterName: json['requested_by'] ?? 'Unknown',
      remark: json['note'], // ใช้ฟิลด์ note จาก backend
    );
  }

  DecisionStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
      case 'reserved':
        return DecisionStatus.approved;
      case 'rejected':
      case 'disapproved':
        return DecisionStatus.disapproved;
      default:
        return DecisionStatus.disapproved;
    }
  }

  // ==================== PENDING RESERVATIONS ====================

  /// 1️⃣ ดึงคำขอจองทั้งหมดที่รอพิจารณา
  Future<List<PendingReservation>> fetchPendingReservations() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/reservations'),
            headers: {
              'Content-Type': 'application/json',
              // 'Authorization': 'Bearer $token', // เพิ่มเมื่อมี Login
            },
          )
          .timeout(const Duration(seconds: 10));

      print('📡 GET /reservations - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('📋 Pending reservations: ${data.length}');

        return data.map((json) => PendingReservation.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load reservations: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Connection timeout');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// 2️⃣ อนุมัติคำขอจอง
  Future<void> approveReservation(int id, {String? remark}) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/reservations/$id/approve'),
            headers: {
              'Content-Type': 'application/json',
              // 'Authorization': 'Bearer $token', // เพิ่มเมื่อมี Login
            },
            body: json.encode({if (remark != null) 'remark': remark}),
          )
          .timeout(const Duration(seconds: 10));

      print(
        '📡 PUT /reservations/$id/approve - Status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        print('✅ Approved reservation #$id');
      } else {
        throw Exception('Failed to approve: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Connection timeout');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// 3️⃣ ปฏิเสธคำขอจอง
  Future<void> rejectReservation(int id, {required String remark}) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/reservations/$id/reject'),
            headers: {
              'Content-Type': 'application/json',
              // 'Authorization': 'Bearer $token', // เพิ่มเมื่อมี Login
            },
            body: json.encode({
              'remark': remark, // ✅ บังคับต้องระบุเหตุผล
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('📡 PUT /reservations/$id/reject - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('❌ Rejected reservation #$id');
      } else {
        throw Exception('Failed to reject: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Connection timeout');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

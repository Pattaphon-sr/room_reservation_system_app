import 'package:dio/dio.dart';
import 'package:room_reservation_system_app/core/network/api_client.dart';
import 'package:room_reservation_system_app/features/staff/screens/staff_history_screen.dart';

class StaffHistoryService {
  final Dio _dio = ApiClient().dio;

  /// ดึงประวัติทั้งหมด แล้วกรองให้เหลือเฉพาะ approved/rejected/reserved
  Future<List<ActivityItem>> fetchHistory() async {
    try {
      // เปลี่ยน endpoint เป็นของ staff
      //final res = await _dio.get('/staff/history');
      final res = await _dio.get('/reservations/history/staff');
      if (res.statusCode == 200) {
        final data = (res.data as List).cast<Map<String, dynamic>>();

        final filtered = data.where((e) {
          final st = (e['status'] ?? '').toString().toLowerCase();
          return st == 'approved' || st == 'rejected' || st == 'reserved';
        }).toList();

        return filtered.map(_parseActivityItem).toList();
      } else {
        throw Exception('Failed to load history (${res.statusCode})');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }


  ActivityItem _parseActivityItem(Map<String, dynamic> json) {
    DateTime dt;
    try {
      dt = DateTime.parse(json['date_time'].toString());
    } catch (_) {
      dt = DateTime.now();
    }

    return ActivityItem(
      status: _parseStatus(json['status']?.toString()),
      floor: (json['floor'] ?? '').toString(),
      roomCode: (json['room_code'] ?? '').toString(),
      slot: (json['slot'] ?? '').toString(),
      dateTime: dt,
      requestedBy: (json['requested_by'] ?? '').toString(),
      approvedBy: json['approved_by']?.toString(),
      note: json['note']?.toString(),
    );
  }

  ApprovalStatus _parseStatus(String? s) {
    switch ((s ?? '').toLowerCase()) {
      case 'approved':
      case 'reserved':
        return ApprovalStatus.approved;
      case 'rejected':
      case 'disapproved':
        return ApprovalStatus.rejected;
      default:
        // เดิมเพื่อนเซ็ต default = approved ซึ่งไม่ปลอดภัย
        return ApprovalStatus.pending;
    }
  }
}

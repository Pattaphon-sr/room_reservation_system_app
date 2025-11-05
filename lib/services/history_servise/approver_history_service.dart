import 'package:dio/dio.dart';
import 'package:room_reservation_system_app/core/network/api_client.dart';
import 'package:room_reservation_system_app/services/auth_service.dart';
import 'package:room_reservation_system_app/features/approver/screens/approver_history_screen.dart';

class ApproverHistoryService {
  final Dio _dio = ApiClient().dio;

  /// ดึงเฉพาะรายการที่ "ฉัน" เป็นคนอนุมัติ/ปฏิเสธ (approved_by == me)
  /// จะพยายามใช้ username ก่อน ถ้าไม่มีจะ fallback เป็น id
  Future<List<ApproverHistoryItem>> fetchHistory() async {
    try {
      final payload = AuthService.instance.payload ?? {};
      final me =
          payload['username']?.toString() ?? payload['id']?.toString() ?? '';

      if (me.isEmpty) return <ApproverHistoryItem>[];

      final res = await _dio.get('/reservations/history');
      if (res.statusCode == 200) {
        final data = (res.data as List).cast<Map<String, dynamic>>();

        final filtered = data.where((e) {
          final approver = e['approved_by'];
          return approver != null && approver.toString() == me;
        }).toList();

        return filtered.map(_parseApproverItem).toList();
      } else {
        throw Exception('Failed to load history (${res.statusCode})');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  ApproverHistoryItem _parseApproverItem(Map<String, dynamic> json) {
    DateTime dt;
    try {
      dt = DateTime.parse(json['date_time'].toString());
    } catch (_) {
      dt = DateTime.now();
    }

    final status = _parseStatus(json['status']?.toString());
    final remark = json['note']?.toString();

    return ApproverHistoryItem(
      dateTime: dt,
      status: status,
      floor: (json['floor'] ?? 'N/A').toString(),
      roomCode: (json['room_code'] ?? 'N/A').toString(),
      slot: (json['slot'] ?? 'N/A').toString(),
      requesterName: (json['requested_by'] ?? 'Unknown').toString(),
      remark: status == DecisionStatus.disapproved ? (remark ?? '') : remark,
    );
  }

  DecisionStatus _parseStatus(String? s) {
    switch ((s ?? '').toLowerCase()) {
      case 'approved':
      case 'reserved':
        return DecisionStatus.approved;
      case 'rejected':
      case 'disapproved':
        return DecisionStatus.disapproved;
      default:
        // กรณีไม่รู้จัก ปักเป็น disapproved + ให้ remark ว่างได้ (UI ไม่ assert)
        return DecisionStatus.disapproved;
    }
  }
}

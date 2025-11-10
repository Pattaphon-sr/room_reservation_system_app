// lib/services/history_servise/user_history_service.dart
import 'package:dio/dio.dart';
import 'package:room_reservation_system_app/core/network/api_client.dart';
import 'package:room_reservation_system_app/services/auth_service.dart';
import 'package:room_reservation_system_app/features/user/screens/user_history_screen.dart';

class UserHistoryService {
  final Dio _dio = ApiClient().dio;

  Future<List<ActivityItem>> fetchHistory() async {
    try {
      final payload = AuthService.instance.payload ?? const {};
      final meId = _asString(payload['id']);
      final meUser = _asString(payload['username']);

      if (meId == null && meUser == null) {
        return <ActivityItem>[];
      }

      // ใช้ endpoint เฉพาะ user เท่านั้น
      final endpoint = '/reservations/history';
      final query = {
        if (meId != null) 'requested_by_id': meId,
        if (meUser != null) 'requested_by': meUser,
        'me': 1,
      };

      final res = await _dio.get(
        endpoint,
        queryParameters: query,
      );

      if (res.statusCode != 200) {
        throw Exception('Failed (${res.statusCode})');
      }

      final rawList = _extractList(res.data);

      // กรองข้อมูลให้เหลือเฉพาะของ user ที่ล็อกอิน
      final mineOnly = rawList.where((e) => _isMine(e, meId, meUser)).toList();

      final filtered = mineOnly
          .map(_toItem)
          .where((item) =>
              item.status == ApprovalStatus.approved ||
              item.status == ApprovalStatus.rejected)
          .toList();

      return filtered;
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// รีโหลดข้อมูลใหม่จาก backend (ใช้ในหน้า UI เพื่อ refresh)
  Future<List<ActivityItem>> reloadHistory() async {
    // reload จะได้ข้อมูลล่าสุดและกรองเฉพาะ approved/rejected
    return await fetchHistory();
  }

  // ---------- helpers ----------
  static List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List).cast<Map<String, dynamic>>();
    }
    return <Map<String, dynamic>>[];
  }

  static String? _asString(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  bool _isMine(Map<String, dynamic> e, String? meId, String? meUser) {
    // รองรับหลายชื่อคีย์ที่เพื่อนร่วมทีมอาจใช้ไม่ตรงกัน
    final by = _asString(e['requested_by']);
    final byId = _asString(
      e['requested_by_id'] ?? e['user_id'] ?? e['requester_id'],
    );
    final byName =
        _asString(e['user']) ??
        _asString(e['display_name']) ??
        _asString(e['requestedBy']) ??
        _asString(e['requester_name']);

    final idMatch = (meId != null) && (byId == meId || by == meId);
    final userMatch = (meUser != null) && (by == meUser || byName == meUser);
    return idMatch || userMatch;
  }

  ActivityItem _toItem(Map<String, dynamic> j) {
    final floor = (j['floor'] ?? j['floor_name'] ?? 'N/A').toString();
    final room = (j['room_code'] ?? j['room_name'] ?? 'N/A').toString();
    final slot = (j['slot'] ?? j['slot_label'] ?? 'N/A').toString();
    final note = _asString(j['note']);

    final dtRaw = _asString(
      j['date_time'] ??
          j['full_datetime'] ??
          j['datetime'] ??
          j['created_at'] ??
          j['updated_at'],
    );

    DateTime dt;
    try {
      dt = DateTime.parse(dtRaw!);
    } catch (_) {
      dt = DateTime.now();
    }

    return ActivityItem(
      status: _toStatus(_asString(j['status'])),
      floor: floor,
      roomCode: room,
      slot: slot,
      dateTime: dt,
      note: note,
    );
  }

  ApprovalStatus _toStatus(String? s) {
    switch ((s ?? '').toLowerCase()) {
      case 'approved':
      case 'reserved':
        return ApprovalStatus.approved;
      case 'rejected':
      case 'disapproved':
        return ApprovalStatus.rejected;
      default:
        return ApprovalStatus.pending;
    }
  }
}

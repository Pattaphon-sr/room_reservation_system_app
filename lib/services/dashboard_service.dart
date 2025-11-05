import 'package:dio/dio.dart';
import 'package:room_reservation_system_app/core/network/api_client.dart';

class DashboardApi {
  final Dio _dio = ApiClient().dio;

  /// ดึงข้อมูล dashboard รวม (overall_summary, floor_summary, available_by_floor_slot)
  /// NOTE: baseURL ของ ApiClient รวม /api ไว้แล้ว → ที่นี่ใช้ '/dashboard'
  Future<Map<String, dynamic>> getDashboard() async {
    final res = await _dio.get('/dashboard');
    return (res.data as Map).cast<String, dynamic>();
  }

  /// ถ้าอยากดึงเฉพาะ available_by_floor_slot แบบตรง ๆ
  Future<List<Map<String, dynamic>>> getAvailableByFloorSlot() async {
    final res = await _dio.get('/dashboard');
    final list = (res.data['available_by_floor_slot'] as List?) ?? const [];
    return list.map((e) => (e as Map).cast<String, dynamic>()).toList();
  }

  /// รายการจองของผู้ใช้ประจำวัน (ฝั่ง User)
  /// GET /reservations/daily?userId=xxx
  Future<List<Map<String, dynamic>>> getUserDailyReservations({
    required int userId,
  }) async {
    final res = await _dio.get(
      '/reservations/daily',
      queryParameters: {'userId': userId},
    );
    final list = (res.data['data'] as List?) ?? const [];
    return list.map((e) => (e as Map).cast<String, dynamic>()).toList();
  }

  /// รายการคำขอประจำวัน (ฝั่ง Approver)
  /// GET /dailyRequest
  Future<List<Map<String, dynamic>>> getApproverDailyRequests() async {
    final res = await _dio.get('/dailyRequest');
    final list = (res.data['data'] as List?) ?? const [];
    return list.map((e) => (e as Map).cast<String, dynamic>()).toList();
  }
}

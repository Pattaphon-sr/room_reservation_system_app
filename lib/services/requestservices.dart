import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:room_reservation_system_app/core/network/api_client.dart';

class RequestServices {
  final Dio _dio = ApiClient().dio;

  Future<bool> sendReservationRequest({
    required int cellId,
    required String slotId,
    required int userId,
  }) async {
    try {
      final res = await _dio.post(
        '/reservations/request',
        data: {"cell_id": cellId, "slot_id": slotId, "requested_by": userId},
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        if (kDebugMode) print("REQ OK => ${res.data}");
        return true;
      }
      if (kDebugMode) print("REQ BAD STATUS => ${res.statusCode} ${res.data}");
      return false;
    } on DioException catch (e) {
      if (kDebugMode) {
        print("REQ ERR => ${e.response?.statusCode} ${e.response?.data}");
      }
      return false;
    } catch (e) {
      if (kDebugMode) print("REQ ERR => $e");
      return false;
    }
  }
}

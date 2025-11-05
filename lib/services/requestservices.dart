import 'package:dio/dio.dart';
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

      print("REQ OK => ${res.data}");
      return true;
    } catch (e) {
      print("REQ ERR => $e");
      return false;
    }
  }
}

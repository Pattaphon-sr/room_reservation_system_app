import 'package:dio/dio.dart';
import 'package:room_reservation_system_app/shared/widgets/maps/map_types.dart';
import 'package:room_reservation_system_app/core/network/api_client.dart';
import 'mappers.dart';

class CellsApi {
  final Dio _dio = ApiClient().dio;

  Future<List<Map<String, dynamic>>> getMap({
    required int floor,
    required String slotId,
    required String date, // YYYY-MM-DD
  }) async {
    final res = await _dio.get(
      '/cells/map',
      queryParameters: {'floor': floor, 'slotId': slotId, 'date': date},
    );
    final List data = res.data as List;
    return data.map<Map<String, dynamic>>((e) => mapCellFromApi(e)).toList();
  }

  Future<void> updateType({required int id, required CellType type}) async {
    await _dio.put('/cells/$id/type', data: {'type': type.asApi});
  }

  Future<void> updateBaseStatus({
    required int id,
    required RoomStatus base,
  }) async {
    await _dio.put('/cells/$id/base-status', data: {'base_status': base.asApi});
  }

  Future<void> setHidden({
    required int id,
    required bool hidden,
    bool detach = false,
  }) async {
    await _dio.put(
      '/cells/$id/hide',
      data: {'hidden': hidden, 'detach': detach},
    );
  }

  Future<void> updateRoomNo({required int id, required String roomNo}) async {
    await _dio.put('/cells/$id/room', data: {'room_no': roomNo});
  }

  Future<Map<String, dynamic>> provisionRoom({
    required int floor,
    required int x,
    required int y,
    String? roomNo,
  }) async {
    final res = await _dio.post(
      '/cells/provision-room',
      data: {
        'floor': floor,
        'x': x,
        'y': y,
        if (roomNo != null && roomNo.trim().isNotEmpty)
          'room_no': roomNo.trim(),
      },
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> swapWithHidden({
    required int visibleId,
    required int hiddenId,
  }) async {
    final res = await _dio.post(
      '/cells/swap-with-hidden',
      data: {'visibleId': visibleId, 'hiddenId': hiddenId},
    );
    return (res.data as Map).cast<String, dynamic>();
  }
}

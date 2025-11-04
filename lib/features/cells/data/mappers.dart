import 'package:room_reservation_system_app/shared/widgets/maps/map_types.dart';

extension CellTypeX on CellType {
  String get asApi {
    switch (this) {
      case CellType.empty:
        return 'empty';
      case CellType.corridor:
        return 'corridor';
      case CellType.stair:
        return 'stair';
      case CellType.decoration:
        return 'decoration';
      case CellType.room:
        return 'room';
    }
  }

  static CellType fromApi(String? s) {
    switch (s) {
      case 'empty':
        return CellType.empty;
      case 'corridor':
        return CellType.corridor;
      case 'stair':
        return CellType.stair;
      case 'decoration':
        return CellType.decoration;
      case 'room':
        return CellType.room;
      default:
        return CellType.empty;
    }
  }
}

extension RoomStatusX on RoomStatus {
  String get asApi {
    switch (this) {
      case RoomStatus.free:
        return 'free';
      case RoomStatus.pending:
        return 'pending';
      case RoomStatus.reserved:
        return 'reserved';
      case RoomStatus.disabled:
        return 'disabled';
    }
  }

  static RoomStatus fromApi(String? s) {
    switch (s) {
      case 'free':
        return RoomStatus.free;
      case 'pending':
        return RoomStatus.pending;
      case 'reserved':
        return RoomStatus.reserved;
      case 'disabled':
        return RoomStatus.disabled;
      default:
        return RoomStatus.disabled;
    }
  }
}

/// แปลง JSON cell จาก API -> Map ที่ MapFloor/FloorEditor ใช้
Map<String, dynamic> mapCellFromApi(Map<String, dynamic> j) {
  return {
    'id': j['id'],
    'floor': j['floor'],
    'slotId': j['slotId'],
    'slotLabel': j['slotLabel'],
    'date': j['date'],
    'x': j['x'],
    'y': j['y'],
    'type': CellTypeX.fromApi(j['type']),
    'roomNo': j['roomNo'],
    'baseStatus': RoomStatusX.fromApi(j['baseStatus']),
    'bookingStatus': j['bookingStatus'] == null
        ? null
        : RoomStatusX.fromApi(j['bookingStatus']),
    'status': RoomStatusX.fromApi(j['status']),
    'hidden': j['hidden'] == true,
  };
}

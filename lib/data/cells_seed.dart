// lib/data/cells_seed.dart
import 'package:room_reservation_system_app/shared/widgets/maps/map_types.dart';

// ---------- Slots (ช่วงเวลา) ----------
const List<Map<String, String>> kTimeSlots = [
  {'id': 'S1', 'label': '08:00-10:00'},
  {'id': 'S2', 'label': '10:00-12:00'},
  {'id': 'S3', 'label': '13:00-15:00'},
  {'id': 'S4', 'label': '15:00-17:00'},
];

// ---------- Base grids (8x5) ต่อชั้น (ไม่มี slot ก่อน) ----------
const List<Map<String, dynamic>> _floor3Base = [
  // y = 0
  {
    'x': 0,
    'y': 0,
    'type': CellType.room,
    'status': RoomStatus.free,
    'roomNo': '301',
  },
  {
    'x': 1,
    'y': 0,
    'type': CellType.room,
    'status': RoomStatus.pending,
    'roomNo': '302',
  },
  {'x': 2, 'y': 0, 'type': CellType.empty},
  {
    'x': 3,
    'y': 0,
    'type': CellType.room,
    'status': RoomStatus.free,
    'roomNo': '304',
  },
  {'x': 4, 'y': 0, 'type': CellType.empty},
  {
    'x': 5,
    'y': 0,
    'type': CellType.room,
    'status': RoomStatus.disabled,
    'roomNo': '306',
  },
  {
    'x': 6,
    'y': 0,
    'type': CellType.room,
    'status': RoomStatus.free,
    'roomNo': '307',
  },
  {'x': 7, 'y': 0, 'type': CellType.empty},
  // y = 1
  {
    'x': 0,
    'y': 1,
    'type': CellType.room,
    'status': RoomStatus.reserved,
    'roomNo': '309',
  },
  {'x': 1, 'y': 1, 'type': CellType.corridor},
  {'x': 2, 'y': 1, 'type': CellType.empty},
  {'x': 3, 'y': 1, 'type': CellType.corridor},
  {'x': 4, 'y': 1, 'type': CellType.corridor},
  {'x': 5, 'y': 1, 'type': CellType.empty},
  {'x': 6, 'y': 1, 'type': CellType.corridor},
  {
    'x': 7,
    'y': 1,
    'type': CellType.room,
    'status': RoomStatus.disabled,
    'roomNo': '310',
  },
  // y = 2
  {
    'x': 0,
    'y': 2,
    'type': CellType.room,
    'status': RoomStatus.pending,
    'roomNo': '311',
  },
  {'x': 1, 'y': 2, 'type': CellType.empty},
  {'x': 2, 'y': 2, 'type': CellType.decoration},
  {'x': 3, 'y': 2, 'type': CellType.decoration},
  {'x': 4, 'y': 2, 'type': CellType.decoration},
  {'x': 5, 'y': 2, 'type': CellType.decoration},
  {'x': 6, 'y': 2, 'type': CellType.empty},
  {
    'x': 7,
    'y': 2,
    'type': CellType.room,
    'status': RoomStatus.free,
    'roomNo': '312',
  },
  // y = 3
  {
    'x': 0,
    'y': 3,
    'type': CellType.room,
    'status': RoomStatus.disabled,
    'roomNo': '313',
  },
  {'x': 1, 'y': 3, 'type': CellType.corridor},
  {'x': 2, 'y': 3, 'type': CellType.corridor},
  {'x': 3, 'y': 3, 'type': CellType.empty},
  {'x': 4, 'y': 3, 'type': CellType.corridor},
  {'x': 5, 'y': 3, 'type': CellType.stair},
  {'x': 6, 'y': 3, 'type': CellType.empty},
  {
    'x': 7,
    'y': 3,
    'type': CellType.room,
    'status': RoomStatus.reserved,
    'roomNo': '314',
  },
  // y = 4
  {
    'x': 0,
    'y': 4,
    'type': CellType.room,
    'status': RoomStatus.free,
    'roomNo': '315',
  },
  {'x': 1, 'y': 4, 'type': CellType.empty},
  {
    'x': 2,
    'y': 4,
    'type': CellType.room,
    'status': RoomStatus.disabled,
    'roomNo': '317',
  },
  {
    'x': 3,
    'y': 4,
    'type': CellType.room,
    'status': RoomStatus.free,
    'roomNo': '318',
  },
  {'x': 4, 'y': 4, 'type': CellType.empty},
  {
    'x': 5,
    'y': 4,
    'type': CellType.room,
    'status': RoomStatus.reserved,
    'roomNo': '320',
  },
  {
    'x': 6,
    'y': 4,
    'type': CellType.room,
    'status': RoomStatus.free,
    'roomNo': '321',
  },
  {
    'x': 7,
    'y': 4,
    'type': CellType.room,
    'status': RoomStatus.pending,
    'roomNo': '322',
  },
];

const List<Map<String, dynamic>> _floor4Base = [
  // y = 0
  {
    'x': 0,
    'y': 0,
    'type': CellType.room,
    'status': RoomStatus.free,
    'roomNo': '401',
  },
  {
    'x': 1,
    'y': 0,
    'type': CellType.room,
    'status': RoomStatus.pending,
    'roomNo': '402',
  },
  {'x': 2, 'y': 0, 'type': CellType.empty},
  {
    'x': 3,
    'y': 0,
    'type': CellType.room,
    'status': RoomStatus.free,
    'roomNo': '404',
  },
  {'x': 4, 'y': 0, 'type': CellType.empty},
  {
    'x': 5,
    'y': 0,
    'type': CellType.room,
    'status': RoomStatus.disabled,
    'roomNo': '406',
  },
  {
    'x': 6,
    'y': 0,
    'type': CellType.room,
    'status': RoomStatus.free,
    'roomNo': '407',
  },
  {'x': 7, 'y': 0, 'type': CellType.empty},
  // y = 1
  {
    'x': 0,
    'y': 1,
    'type': CellType.room,
    'status': RoomStatus.reserved,
    'roomNo': '409',
  },
  {'x': 1, 'y': 1, 'type': CellType.corridor},
  {'x': 2, 'y': 1, 'type': CellType.empty},
  {'x': 3, 'y': 1, 'type': CellType.corridor},
  {'x': 4, 'y': 1, 'type': CellType.corridor},
  {'x': 5, 'y': 1, 'type': CellType.empty},
  {'x': 6, 'y': 1, 'type': CellType.corridor},
  {
    'x': 7,
    'y': 1,
    'type': CellType.room,
    'status': RoomStatus.disabled,
    'roomNo': '410',
  },
  // y = 2
  {
    'x': 0,
    'y': 2,
    'type': CellType.room,
    'status': RoomStatus.pending,
    'roomNo': '411',
  },
  {'x': 1, 'y': 2, 'type': CellType.empty},
  {'x': 2, 'y': 2, 'type': CellType.decoration},
  {'x': 3, 'y': 2, 'type': CellType.decoration},
  {'x': 4, 'y': 2, 'type': CellType.decoration},
  {'x': 5, 'y': 2, 'type': CellType.decoration},
  {'x': 6, 'y': 2, 'type': CellType.empty},
  {
    'x': 7,
    'y': 2,
    'type': CellType.room,
    'status': RoomStatus.free,
    'roomNo': '412',
  },
  // y = 3
  {
    'x': 0,
    'y': 3,
    'type': CellType.room,
    'status': RoomStatus.disabled,
    'roomNo': '413',
  },
  {'x': 1, 'y': 3, 'type': CellType.corridor},
  {'x': 2, 'y': 3, 'type': CellType.corridor},
  {'x': 3, 'y': 3, 'type': CellType.empty},
  {'x': 4, 'y': 3, 'type': CellType.corridor},
  {'x': 5, 'y': 3, 'type': CellType.stair},
  {'x': 6, 'y': 3, 'type': CellType.empty},
  {
    'x': 7,
    'y': 3,
    'type': CellType.room,
    'status': RoomStatus.reserved,
    'roomNo': '414',
  },
  // y = 4
  {
    'x': 0,
    'y': 4,
    'type': CellType.room,
    'status': RoomStatus.free,
    'roomNo': '415',
  },
  {'x': 1, 'y': 4, 'type': CellType.empty},
  {
    'x': 2,
    'y': 4,
    'type': CellType.room,
    'status': RoomStatus.disabled,
    'roomNo': '417',
  },
  {
    'x': 3,
    'y': 4,
    'type': CellType.room,
    'status': RoomStatus.free,
    'roomNo': '418',
  },
  {'x': 4, 'y': 4, 'type': CellType.empty},
  {
    'x': 5,
    'y': 4,
    'type': CellType.room,
    'status': RoomStatus.reserved,
    'roomNo': '420',
  },
  {
    'x': 6,
    'y': 4,
    'type': CellType.room,
    'status': RoomStatus.free,
    'roomNo': '421',
  },
  {
    'x': 7,
    'y': 4,
    'type': CellType.room,
    'status': RoomStatus.pending,
    'roomNo': '422',
  },
];

const List<Map<String, dynamic>> _floor5Base = [
  // y = 0
  {
    'x': 0,
    'y': 0,
    'type': CellType.room,
    'status': RoomStatus.free,
    'roomNo': '501',
  },
  {
    'x': 1,
    'y': 0,
    'type': CellType.room,
    'status': RoomStatus.pending,
    'roomNo': '502',
  },
  {'x': 2, 'y': 0, 'type': CellType.empty},
  {
    'x': 3,
    'y': 0,
    'type': CellType.room,
    'status': RoomStatus.free,
    'roomNo': '504',
  },
  {'x': 4, 'y': 0, 'type': CellType.empty},
  {
    'x': 5,
    'y': 0,
    'type': CellType.room,
    'status': RoomStatus.disabled,
    'roomNo': '506',
  },
  {
    'x': 6,
    'y': 0,
    'type': CellType.room,
    'status': RoomStatus.free,
    'roomNo': '507',
  },
  {'x': 7, 'y': 0, 'type': CellType.empty},
  // y = 1
  {
    'x': 0,
    'y': 1,
    'type': CellType.room,
    'status': RoomStatus.reserved,
    'roomNo': '509',
  },
  {'x': 1, 'y': 1, 'type': CellType.corridor},
  {'x': 2, 'y': 1, 'type': CellType.empty},
  {'x': 3, 'y': 1, 'type': CellType.corridor},
  {'x': 4, 'y': 1, 'type': CellType.corridor},
  {'x': 5, 'y': 1, 'type': CellType.empty},
  {'x': 6, 'y': 1, 'type': CellType.corridor},
  {
    'x': 7,
    'y': 1,
    'type': CellType.room,
    'status': RoomStatus.disabled,
    'roomNo': '510',
  },
  // y = 2
  {
    'x': 0,
    'y': 2,
    'type': CellType.room,
    'status': RoomStatus.pending,
    'roomNo': '511',
  },
  {'x': 1, 'y': 2, 'type': CellType.empty},
  {'x': 2, 'y': 2, 'type': CellType.decoration},
  {'x': 3, 'y': 2, 'type': CellType.decoration},
  {'x': 4, 'y': 2, 'type': CellType.decoration},
  {'x': 5, 'y': 2, 'type': CellType.decoration},
  {'x': 6, 'y': 2, 'type': CellType.empty},
  {
    'x': 7,
    'y': 2,
    'type': CellType.room,
    'status': RoomStatus.free,
    'roomNo': '512',
  },
  // y = 3
  {
    'x': 0,
    'y': 3,
    'type': CellType.room,
    'status': RoomStatus.disabled,
    'roomNo': '513',
  },
  {'x': 1, 'y': 3, 'type': CellType.corridor},
  {'x': 2, 'y': 3, 'type': CellType.corridor},
  {'x': 3, 'y': 3, 'type': CellType.empty},
  {'x': 4, 'y': 3, 'type': CellType.corridor},
  {'x': 5, 'y': 3, 'type': CellType.stair},
  {'x': 6, 'y': 3, 'type': CellType.empty},
  {
    'x': 7,
    'y': 3,
    'type': CellType.room,
    'status': RoomStatus.reserved,
    'roomNo': '514',
  },
  // y = 4
  {
    'x': 0,
    'y': 4,
    'type': CellType.room,
    'status': RoomStatus.free,
    'roomNo': '515',
  },
  {'x': 1, 'y': 4, 'type': CellType.empty},
  {
    'x': 2,
    'y': 4,
    'type': CellType.room,
    'status': RoomStatus.disabled,
    'roomNo': '517',
  },
  {
    'x': 3,
    'y': 4,
    'type': CellType.room,
    'status': RoomStatus.free,
    'roomNo': '518',
  },
  {'x': 4, 'y': 4, 'type': CellType.empty},
  {
    'x': 5,
    'y': 4,
    'type': CellType.room,
    'status': RoomStatus.reserved,
    'roomNo': '520',
  },
  {
    'x': 6,
    'y': 4,
    'type': CellType.room,
    'status': RoomStatus.free,
    'roomNo': '521',
  },
  {
    'x': 7,
    'y': 4,
    'type': CellType.room,
    'status': RoomStatus.pending,
    'roomNo': '522',
  },
];

// รวม Base per floor ให้เรียกง่าย
final Map<int, List<Map<String, dynamic>>> _baseByFloor = {
  3: _floor3Base,
  4: _floor4Base,
  5: _floor5Base,
};

// ---------- ตัวช่วย "ทำหลาย slot" ----------
List<Map<String, dynamic>> _cloneWithSlotFloor({
  required int floor,
  required String slotId,
  required String slotLabel,
}) {
  final base = _baseByFloor[floor]!;
  // สร้างสำเนา + อัด floor/slot ใส่ไปในทุก cell
  final list = base
      .map(
        (c) => {
          'floor': floor,
          'slotId': slotId,
          'slotLabel': slotLabel,
          'x': c['x'],
          'y': c['y'],
          'type': c['type'],
          // แก้ status บางจุดตาม slot เพื่อให้ map ต่างกันจริง ๆ (optional)
          'status': _tuneStatusForSlot(c['status'] as RoomStatus?, slotId),
          if (c.containsKey('roomNo')) 'roomNo': c['roomNo'],
        },
      )
      .toList();
  return list;
}

// ปรับสีหน้า/สถานะเล็กน้อยตามช่วงเวลา (เพื่อความสมจริงเล็ก ๆ)
RoomStatus _tuneStatusForSlot(RoomStatus? status, String slotId) {
  final s = status ?? RoomStatus.disabled;
  switch (slotId) {
    case 'S1': // เช้า: ห้องส่วนใหญ่ free/disabled/pending ตาม base
      return s;
    case 'S2': // สาย: pending บางห้องกลายเป็น reserved
      if (s == RoomStatus.pending) return RoomStatus.reserved;
      return s;
    case 'S3': // บ่ายต้น: reserved บางห้องปล่อยเป็น free
      if (s == RoomStatus.reserved) return RoomStatus.free;
      return s;
    case 'S4': // บ่ายแก่: free บางห้องกลายเป็น pending
      if (s == RoomStatus.free) return RoomStatus.pending;
      return s;
    default:
      return s;
  }
}

// ---------- ก้อนรวมทั้งหมด: 3 ชั้น × 4 slot × 40 cell ----------
final List<Map<String, dynamic>> kCellsAll = (() {
  final List<Map<String, dynamic>> all = [];
  for (final floor in [3, 4, 5]) {
    for (final slot in kTimeSlots) {
      all.addAll(
        _cloneWithSlotFloor(
          floor: floor,
          slotId: slot['id']!,
          slotLabel: slot['label']!,
        ),
      );
    }
  }
  return all;
})();

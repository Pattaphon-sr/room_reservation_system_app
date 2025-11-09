import 'package:room_reservation_system_app/shared/widgets/maps/map_types.dart';

/// ---------- Slots (ช่วงเวลา) ----------
const List<Map<String, String>> kTimeSlots = [
  {'id': 'S1', 'label': '08:00-10:00'},
  {'id': 'S2', 'label': '10:00-12:00'},
  {'id': 'S3', 'label': '13:00-15:00'},
  {'id': 'S4', 'label': '15:00-17:00'},
];

/// โครงสร้างข้อมูลฐาน (Base) เก็บชนิดช่อง + ชื่อห้อง + baseStatus(only: free/disabled)
/// เก็บเพียงตำแหน่ง (floor,x,y) เดียว ไม่ผูก slot
/// หมายเหตุ: baseStatus ใช้เฉพาะ free/disabled
class _BaseCell {
  final int floor;
  final int x;
  final int y;
  CellType type;
  String? roomNo;
  RoomStatus baseStatus; // free / disabled ONLY

  _BaseCell({
    required this.floor,
    required this.x,
    required this.y,
    required this.type,
    required this.baseStatus,
  });
}

/// โครงสร้าง Reservations (คำขอ/การจอง) ผูกกับ slot
class _ReservationCell {
  final int floor;
  final int x;
  final int y;
  final String slotId; // S1..S4
  final RoomStatus bookingStatus; // pending / reserved

  _ReservationCell({
    required this.floor,
    required this.x,
    required this.y,
    required this.slotId,
    required this.bookingStatus,
  });
}

/// =======================
/// Base seed (ตัวอย่าง)
/// สร้างพื้น 8x5 ให้ครบทุกจุด: ถ้าไม่มีระบุ = empty
/// แล้วอัดห้องเฉพาะบางจุดพร้อม baseStatus (free/disabled)
/// =======================

const int _W = 8;
const int _H = 5;

final Map<int, List<_BaseCell>> _baseByFloor = {
  3: _generateEmptyFloor(3),
  4: _generateEmptyFloor(4),
  5: _generateEmptyFloor(5),
};

List<_BaseCell> _generateEmptyFloor(int floor) {
  final list = <_BaseCell>[];
  for (int y = 0; y < _H; y++) {
    for (int x = 0; x < _W; x++) {
      list.add(
        _BaseCell(
          floor: floor,
          x: x,
          y: y,
          type: CellType.empty,
          baseStatus: RoomStatus.disabled,
        ),
      );
    }
  }
  return list;
}

/// Helper: ตั้งค่าห้องบนพื้น (type=room) + roomNo + baseStatus
void _setRoom({
  required int floor,
  required int x,
  required int y,
  required String roomNo,
  RoomStatus baseStatus = RoomStatus.free,
}) {
  final list = _baseByFloor[floor]!;
  final idx = list.indexWhere((e) => e.x == x && e.y == y);
  if (idx == -1) return;
  list[idx].type = CellType.room;
  list[idx].roomNo = roomNo;
  list[idx].baseStatus = baseStatus;
}

/// Helper: ตั้งค่าช่องอื่น ๆ
void _setType({
  required int floor,
  required int x,
  required int y,
  required CellType type,
}) {
  final list = _baseByFloor[floor]!;
  final idx = list.indexWhere((e) => e.x == x && e.y == y);
  if (idx == -1) return;
  list[idx].type = type;
  if (type != CellType.room) {
    list[idx].roomNo = null;
    list[idx].baseStatus = RoomStatus.disabled;
  }
}

/// ===== Seed floor 3/4/5 (ย่อจากของเดิม แต่พอให้ทดสอบได้) =====
/// คุณสามารถเติมจุดอื่น ๆ ตามผังเดิมของคุณได้เลย
void _seedFloors() {
  // ------- Floor 3 -------
  _setRoom(floor: 3, x: 0, y: 0, roomNo: '301', baseStatus: RoomStatus.free);
  _setRoom(floor: 3, x: 1, y: 0, roomNo: '302', baseStatus: RoomStatus.free);
  _setType(floor: 3, x: 2, y: 0, type: CellType.empty);
  _setRoom(floor: 3, x: 3, y: 0, roomNo: '304', baseStatus: RoomStatus.free);
  _setType(floor: 3, x: 4, y: 0, type: CellType.empty);
  _setRoom(
    floor: 3,
    x: 5,
    y: 0,
    roomNo: '306',
    baseStatus: RoomStatus.disabled,
  );
  _setRoom(floor: 3, x: 6, y: 0, roomNo: '307', baseStatus: RoomStatus.free);
  _setType(floor: 3, x: 7, y: 0, type: CellType.empty);

  _setRoom(floor: 3, x: 0, y: 1, roomNo: '309', baseStatus: RoomStatus.free);
  _setType(floor: 3, x: 1, y: 1, type: CellType.corridor);
  _setType(floor: 3, x: 2, y: 1, type: CellType.empty);
  _setType(floor: 3, x: 3, y: 1, type: CellType.corridor);
  _setType(floor: 3, x: 4, y: 1, type: CellType.corridor);
  _setType(floor: 3, x: 5, y: 1, type: CellType.empty);
  _setType(floor: 3, x: 6, y: 1, type: CellType.corridor);
  _setRoom(
    floor: 3,
    x: 7,
    y: 1,
    roomNo: '310',
    baseStatus: RoomStatus.disabled,
  );

  _setRoom(floor: 3, x: 0, y: 2, roomNo: '311', baseStatus: RoomStatus.free);
  _setType(floor: 3, x: 1, y: 2, type: CellType.empty);
  _setType(floor: 3, x: 2, y: 2, type: CellType.decoration);
  _setType(floor: 3, x: 3, y: 2, type: CellType.decoration);
  _setType(floor: 3, x: 4, y: 2, type: CellType.decoration);
  _setType(floor: 3, x: 5, y: 2, type: CellType.decoration);
  _setType(floor: 3, x: 6, y: 2, type: CellType.empty);
  _setRoom(floor: 3, x: 7, y: 2, roomNo: '312', baseStatus: RoomStatus.free);

  _setRoom(
    floor: 3,
    x: 0,
    y: 3,
    roomNo: '313',
    baseStatus: RoomStatus.disabled,
  );
  _setType(floor: 3, x: 1, y: 3, type: CellType.corridor);
  _setType(floor: 3, x: 2, y: 3, type: CellType.corridor);
  _setType(floor: 3, x: 3, y: 3, type: CellType.empty);
  _setType(floor: 3, x: 4, y: 3, type: CellType.corridor);
  _setType(floor: 3, x: 5, y: 3, type: CellType.stair);
  _setType(floor: 3, x: 6, y: 3, type: CellType.empty);
  _setRoom(floor: 3, x: 7, y: 3, roomNo: '314', baseStatus: RoomStatus.free);

  _setRoom(floor: 3, x: 0, y: 4, roomNo: '315', baseStatus: RoomStatus.free);
  _setType(floor: 3, x: 1, y: 4, type: CellType.empty);
  _setRoom(
    floor: 3,
    x: 2,
    y: 4,
    roomNo: '317',
    baseStatus: RoomStatus.disabled,
  );
  _setRoom(floor: 3, x: 3, y: 4, roomNo: '318', baseStatus: RoomStatus.free);
  _setType(floor: 3, x: 4, y: 4, type: CellType.empty);
  _setRoom(floor: 3, x: 5, y: 4, roomNo: '320', baseStatus: RoomStatus.free);
  _setRoom(floor: 3, x: 6, y: 4, roomNo: '321', baseStatus: RoomStatus.free);
  _setRoom(floor: 3, x: 7, y: 4, roomNo: '322', baseStatus: RoomStatus.free);

  // ------- Floor 4 -------
  _setRoom(floor: 4, x: 0, y: 0, roomNo: '401', baseStatus: RoomStatus.free);
  _setRoom(floor: 4, x: 1, y: 0, roomNo: '402', baseStatus: RoomStatus.free);
  _setType(floor: 4, x: 2, y: 0, type: CellType.empty);
  _setRoom(floor: 4, x: 3, y: 0, roomNo: '404', baseStatus: RoomStatus.free);
  _setType(floor: 4, x: 4, y: 0, type: CellType.empty);
  _setRoom(
    floor: 4,
    x: 5,
    y: 0,
    roomNo: '406',
    baseStatus: RoomStatus.disabled,
  );
  _setRoom(floor: 4, x: 6, y: 0, roomNo: '407', baseStatus: RoomStatus.free);
  _setType(floor: 4, x: 7, y: 0, type: CellType.empty);

  _setRoom(floor: 4, x: 0, y: 1, roomNo: '409', baseStatus: RoomStatus.free);
  _setType(floor: 4, x: 1, y: 1, type: CellType.corridor);
  _setType(floor: 4, x: 2, y: 1, type: CellType.empty);
  _setType(floor: 4, x: 3, y: 1, type: CellType.corridor);
  _setType(floor: 4, x: 4, y: 1, type: CellType.corridor);
  _setType(floor: 4, x: 5, y: 1, type: CellType.empty);
  _setType(floor: 4, x: 6, y: 1, type: CellType.corridor);
  _setRoom(
    floor: 4,
    x: 7,
    y: 1,
    roomNo: '410',
    baseStatus: RoomStatus.disabled,
  );

  _setRoom(floor: 4, x: 0, y: 2, roomNo: '411', baseStatus: RoomStatus.free);
  _setType(floor: 4, x: 1, y: 2, type: CellType.empty);
  _setType(floor: 4, x: 2, y: 2, type: CellType.decoration);
  _setType(floor: 4, x: 3, y: 2, type: CellType.decoration);
  _setType(floor: 4, x: 4, y: 2, type: CellType.decoration);
  _setType(floor: 4, x: 5, y: 2, type: CellType.decoration);
  _setType(floor: 4, x: 6, y: 2, type: CellType.empty);
  _setRoom(floor: 4, x: 7, y: 2, roomNo: '412', baseStatus: RoomStatus.free);

  _setRoom(
    floor: 4,
    x: 0,
    y: 3,
    roomNo: '413',
    baseStatus: RoomStatus.disabled,
  );
  _setType(floor: 4, x: 1, y: 3, type: CellType.corridor);
  _setType(floor: 4, x: 2, y: 3, type: CellType.corridor);
  _setType(floor: 4, x: 3, y: 3, type: CellType.empty);
  _setType(floor: 4, x: 4, y: 3, type: CellType.corridor);
  _setType(floor: 4, x: 5, y: 3, type: CellType.stair);
  _setType(floor: 4, x: 6, y: 3, type: CellType.empty);
  _setRoom(floor: 4, x: 7, y: 3, roomNo: '414', baseStatus: RoomStatus.free);

  _setRoom(floor: 4, x: 0, y: 4, roomNo: '415', baseStatus: RoomStatus.free);
  _setType(floor: 4, x: 1, y: 4, type: CellType.empty);
  _setRoom(
    floor: 4,
    x: 2,
    y: 4,
    roomNo: '417',
    baseStatus: RoomStatus.disabled,
  );
  _setRoom(floor: 4, x: 3, y: 4, roomNo: '418', baseStatus: RoomStatus.free);
  _setType(floor: 4, x: 4, y: 4, type: CellType.empty);
  _setRoom(floor: 4, x: 5, y: 4, roomNo: '420', baseStatus: RoomStatus.free);
  _setRoom(floor: 4, x: 6, y: 4, roomNo: '421', baseStatus: RoomStatus.free);
  _setRoom(floor: 4, x: 7, y: 4, roomNo: '422', baseStatus: RoomStatus.free);

  // ------- Floor 5 -------
  _setRoom(floor: 5, x: 0, y: 0, roomNo: '501', baseStatus: RoomStatus.free);
  _setRoom(floor: 5, x: 1, y: 0, roomNo: '502', baseStatus: RoomStatus.free);
  _setType(floor: 5, x: 2, y: 0, type: CellType.empty);
  _setRoom(floor: 5, x: 3, y: 0, roomNo: '504', baseStatus: RoomStatus.free);
  _setType(floor: 5, x: 4, y: 0, type: CellType.empty);
  _setRoom(
    floor: 5,
    x: 5,
    y: 0,
    roomNo: '506',
    baseStatus: RoomStatus.disabled,
  );
  _setRoom(floor: 5, x: 6, y: 0, roomNo: '507', baseStatus: RoomStatus.free);
  _setType(floor: 5, x: 7, y: 0, type: CellType.empty);

  _setRoom(floor: 5, x: 0, y: 1, roomNo: '509', baseStatus: RoomStatus.free);
  _setType(floor: 5, x: 1, y: 1, type: CellType.corridor);
  _setType(floor: 5, x: 2, y: 1, type: CellType.empty);
  _setType(floor: 5, x: 3, y: 1, type: CellType.corridor);
  _setType(floor: 5, x: 4, y: 1, type: CellType.corridor);
  _setType(floor: 5, x: 5, y: 1, type: CellType.empty);
  _setType(floor: 5, x: 6, y: 1, type: CellType.corridor);
  _setRoom(
    floor: 5,
    x: 7,
    y: 1,
    roomNo: '510',
    baseStatus: RoomStatus.disabled,
  );

  _setRoom(floor: 5, x: 0, y: 2, roomNo: '511', baseStatus: RoomStatus.free);
  _setType(floor: 5, x: 1, y: 2, type: CellType.empty);
  _setType(floor: 5, x: 2, y: 2, type: CellType.decoration);
  _setType(floor: 5, x: 3, y: 2, type: CellType.decoration);
  _setType(floor: 5, x: 4, y: 2, type: CellType.decoration);
  _setType(floor: 5, x: 5, y: 2, type: CellType.decoration);
  _setType(floor: 5, x: 6, y: 2, type: CellType.empty);
  _setRoom(floor: 5, x: 7, y: 2, roomNo: '512', baseStatus: RoomStatus.free);

  _setRoom(
    floor: 5,
    x: 0,
    y: 3,
    roomNo: '513',
    baseStatus: RoomStatus.disabled,
  );
  _setType(floor: 5, x: 1, y: 3, type: CellType.corridor);
  _setType(floor: 5, x: 2, y: 3, type: CellType.corridor);
  _setType(floor: 5, x: 3, y: 3, type: CellType.empty);
  _setType(floor: 5, x: 4, y: 3, type: CellType.corridor);
  _setType(floor: 5, x: 5, y: 3, type: CellType.stair);
  _setType(floor: 5, x: 6, y: 3, type: CellType.empty);
  _setRoom(floor: 5, x: 7, y: 3, roomNo: '514', baseStatus: RoomStatus.free);

  _setRoom(floor: 5, x: 0, y: 4, roomNo: '515', baseStatus: RoomStatus.free);
  _setType(floor: 5, x: 1, y: 4, type: CellType.empty);
  _setRoom(
    floor: 5,
    x: 2,
    y: 4,
    roomNo: '517',
    baseStatus: RoomStatus.disabled,
  );
  _setRoom(floor: 5, x: 3, y: 4, roomNo: '518', baseStatus: RoomStatus.free);
  _setType(floor: 5, x: 4, y: 4, type: CellType.empty);
  _setRoom(floor: 5, x: 5, y: 4, roomNo: '520', baseStatus: RoomStatus.free);
  _setRoom(floor: 5, x: 6, y: 4, roomNo: '521', baseStatus: RoomStatus.free);
  _setRoom(floor: 5, x: 7, y: 4, roomNo: '522', baseStatus: RoomStatus.free);
}

bool _seeded = false;
void _ensureSeeded() {
  if (_seeded) return;
  _seeded = true;
  _seedFloors();
}

/// ====== ตัวอย่าง Reservations (จำลอง) ======
/// คุณสามารถเพิ่ม/ลบรายการเพื่อเทส overlay ได้
final List<_ReservationCell> _reservations = <_ReservationCell>[
  // Floor 5
  _ReservationCell(
    floor: 5,
    x: 0,
    y: 0,
    slotId: 'S1',
    bookingStatus: RoomStatus.pending,
  ), // 515? (จริงๆ (0,0) คือ 501 บน floor5 ใน seed)
  _ReservationCell(
    floor: 5,
    x: 5,
    y: 4,
    slotId: 'S1',
    bookingStatus: RoomStatus.reserved,
  ), // 520
  // Floor 3
  _ReservationCell(
    floor: 3,
    x: 0,
    y: 1,
    slotId: 'S2',
    bookingStatus: RoomStatus.reserved,
  ), // 309
  _ReservationCell(
    floor: 3,
    x: 7,
    y: 3,
    slotId: 'S3',
    bookingStatus: RoomStatus.pending,
  ), // 314
];

/// Build slice สำหรับแสดงผลใน MapFloor
/// cells ที่คืนมาจะมีคีย์:
/// - floor, slotId, slotLabel, x, y, type, roomNo
/// - baseStatus (free/disabled)
/// - bookingStatus (optional: pending/reserved)
/// - status (display) = bookingStatus ถ้ามี, ไม่งั้น = baseStatus
List<Map<String, dynamic>> buildCellsSlice({
  required int floor,
  required String slotId,
}) {
  _ensureSeeded();

  final slotLabel = kTimeSlots.firstWhere((s) => s['id'] == slotId)['label']!;
  final base = _baseByFloor[floor]!;
  final out = <Map<String, dynamic>>[];

  for (final b in base) {
    final booking = _reservations.firstWhere(
      (r) => r.floor == floor && r.x == b.x && r.y == b.y && r.slotId == slotId,
      orElse: () => _ReservationCell(
        floor: -1,
        x: -1,
        y: -1,
        slotId: '',
        bookingStatus: RoomStatus.disabled,
      ),
    );

    final hasBooking = booking.floor == floor;

    final display = hasBooking ? booking.bookingStatus : b.baseStatus;

    out.add({
      'floor': floor,
      'slotId': slotId,
      'slotLabel': slotLabel,
      'x': b.x,
      'y': b.y,
      'type': b.type,
      if (b.roomNo != null) 'roomNo': b.roomNo,
      'baseStatus': b.baseStatus,
      if (hasBooking) 'bookingStatus': booking.bookingStatus,
      'status': display,
    });
  }
  return out;
}

/// อัปเดต baseStatus (free/disabled) ในทุก slot ของตำแหน่งเดียวกัน
/// ไม่แตะต้อง reservations ใด ๆ
Future<void> applyBaseStatusAllSlotsAt({
  required int floorNo,
  required int x,
  required int y,
  required RoomStatus newBase,
}) async {
  _ensureSeeded();
  final list = _baseByFloor[floorNo]!;
  final idx = list.indexWhere(
    (e) => e.x == x && e.y == y && e.type == CellType.room,
  );
  if (idx == -1) return;
  list[idx].baseStatus = (newBase == RoomStatus.free)
      ? RoomStatus.free
      : RoomStatus.disabled;
  // synchronous → ยังคืน Future<void> เพื่อให้ await ได้เสมอ
}

/// เปลี่ยนชนิดช่องใน Base ที่ตำแหน่ง (floor,x,y)
/// ถ้าเปลี่ยนเป็น room จะตั้งชื่อห้อง (roomNo) ได้
Future<void> updateBaseCellTypeAt({
  required int floor,
  required int x,
  required int y,
  required CellType type,
  String? roomNo,
}) async {
  _ensureSeeded();
  final list = _baseByFloor[floor]!;
  final idx = list.indexWhere((e) => e.x == x && e.y == y);
  if (idx == -1) return;

  final cell = list[idx];
  cell.type = type;
  if (type == CellType.room) {
    cell.roomNo = roomNo ?? cell.roomNo ?? '—';
    // default เปิด (free) ถ้าไม่เคยมีค่า
    cell.baseStatus = cell.baseStatus == RoomStatus.disabled
        ? RoomStatus.free
        : cell.baseStatus;
  } else {
    cell.roomNo = null;
    cell.baseStatus = RoomStatus.disabled;
  }
  // ยังเป็น synchronous เช่นกัน
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/theme/theme.dart';

enum CellType { empty, room, corridor, stair, decoration }

enum RoomStatus { free, pending, disabled, reserved }

enum MapRole { user, staff, approver }

// Status Colors
const _blueFree = AppColors.roomBlue;
const _greyOther = AppColors.roomGrey;
const _roomDecoration = AppColors.roomdecoration;
const _yellowPending = Color(0xFFFFCF71);

/// MOCK ข้อมูล 8×5
final List<Map<String, dynamic>> kCellsDefault = [
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

int _gridCols(List<Map<String, dynamic>> cells) => cells.isEmpty
    ? 0
    : cells.map((e) => (e['x'] as int? ?? 0)).reduce(math.max) + 1;
int _gridRows(List<Map<String, dynamic>> cells) => cells.isEmpty
    ? 0
    : cells.map((e) => (e['y'] as int? ?? 0)).reduce(math.max) + 1;

class MapFloor extends StatelessWidget {
  const MapFloor({
    super.key,
    this.role = MapRole.user,
    this.cells,
    this.onCellTap, // สำหรับ user/staff (เฉพาะ user: free room เท่านั้น)
  });

  final MapRole role;
  final List<Map<String, dynamic>>? cells;
  final double width = 292;
  final double height = 234;
  final double crossAxisSpacing = 0;
  final double mainAxisSpacing = 0;
  final double mainAxisExtent = 46;
  final void Function(int x, int y, Map<String, dynamic> cell)? onCellTap;

  Map<String, dynamic> _normalizeForRole(
    Map<String, dynamic> cell,
    MapRole role,
  ) {
    if (role == MapRole.staff) return cell;
    if (cell['type'] == CellType.empty) {
      return {'x': cell['x'], 'y': cell['y'], 'type': CellType.corridor};
    }
    return cell;
  }

  /// user แตะได้เฉพาะห้อง free
  bool _isUserTappable(Map<String, dynamic> cell) {
    if (cell['type'] != CellType.room) return false;
    final status = (cell['status'] as RoomStatus?) ?? RoomStatus.disabled;
    return status == RoomStatus.free;
  }

  Widget _buildCell(Map<String, dynamic> cell) {
    final type = cell['type'] as CellType;

    Color bg;
    Widget child = const SizedBox.shrink();

    switch (type) {
      case CellType.empty:
        // จะเกิดเฉพาะใน role staff (เพราะ user/approver ถูก normalize เป็น corridor แล้ว)
        bg = const Color(0xFFDBDBDB);
        child = const Icon(Icons.add, size: 16, color: Colors.white);
        break;

      case CellType.corridor:
        bg = _roomDecoration;
        break;

      case CellType.stair:
        bg = _roomDecoration;
        child = LayoutBuilder(
          builder: (_, c) {
            return Image.asset(
              'assets/icons/stairs.png',
              width: 28,
              fit: BoxFit.fitHeight,
            );
          },
        );
        break;

      case CellType.decoration:
        bg = _roomDecoration;
        child = Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0x00000000), Color(0xFF3B3B1A)],
              stops: [0.7, 0.99],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: LayoutBuilder(
            builder: (_, c) {
              return Image.asset(
                'assets/icons/grass.png',
                width: 32,
                height: 42,
                fit: BoxFit.fitHeight,
              );
            },
          ),
        );
        break;

      case CellType.room:
        final status = (cell['status'] as RoomStatus?) ?? RoomStatus.disabled;

        // ถ้าเป็น pending:
        // - staff/approver = เหลือง
        // - user = เทา (ตามกติกา: user เห็นเป็นห้องที่กดไม่ได้)
        switch (status) {
          case RoomStatus.free:
            bg = _blueFree;
            break;
          case RoomStatus.pending:
            bg = (role == MapRole.user) ? _greyOther : _yellowPending;
            break;
          case RoomStatus.reserved:
          case RoomStatus.disabled:
            bg = _greyOther;
            break;
        }

        final roomNo = (cell['roomNo'] ?? '').toString();
        child = Text(
          roomNo.isEmpty ? '—' : roomNo,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        );
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: Colors.white, style: BorderStyle.solid),
        borderRadius: BorderRadius.all(AppShapes.radiusXs),
      ),
      child: Center(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = (cells ?? kCellsDefault);
    final cols = _gridCols(data);
    final rows = _gridRows(data);
    final lookup = {for (final c in data) '${c['x']}:${c['y']}': c};

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: GridView.builder(
        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: rows * cols,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          mainAxisExtent: mainAxisExtent,
        ),
        itemBuilder: (_, i) {
          final x = i % cols;
          final y = i ~/ cols;
          final raw =
              lookup['$x:$y'] ?? {'x': x, 'y': y, 'type': CellType.empty};

          // แปลง cell สำหรับการแสดงผลตาม role
          final cell = _normalizeForRole(raw, role);

          final tile = _buildCell(cell);

          // Approver → preview only
          if (role == MapRole.approver) return tile;

          // User → แตะได้เฉพาะ "room + status = free"
          if (role == MapRole.user) {
            final tappable = _isUserTappable(cell);
            if (!tappable) return tile;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () =>
                  onCellTap?.call(x, y, raw), // ส่ง raw กลับ (ข้อมูลจริง)
              // debugPrint('user tap'),
              child: tile,
            );
          }

          // Staff → แตะได้ทั้งหมด (รวม empty)
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onCellTap?.call(x, y, raw),
            // debugPrint('staff tap'),
            child: tile,
          );
        },
      ),
    );
  }
}

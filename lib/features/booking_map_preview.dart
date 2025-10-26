// booking_map_preview.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

enum CellType { empty, room, corridor, stair, decoration }

enum RoomStatus { free, pending, disabled }

// ---- 1) ข้อมูล hardcode 8×5 ----
final List<Map<String, dynamic>> kCells = [
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
    'status': RoomStatus.free,
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
  {'x': 1, 'y': 2, 'type': CellType.decoration},
  {'x': 2, 'y': 2, 'type': CellType.empty},
  {'x': 3, 'y': 2, 'type': CellType.stair},
  {'x': 4, 'y': 2, 'type': CellType.stair},
  {'x': 5, 'y': 2, 'type': CellType.empty},
  {'x': 6, 'y': 2, 'type': CellType.decoration},
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
  {'x': 5, 'y': 3, 'type': CellType.empty},
  {'x': 6, 'y': 3, 'type': CellType.corridor},
  {
    'x': 7,
    'y': 3,
    'type': CellType.room,
    'status': RoomStatus.pending,
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
    'status': RoomStatus.disabled,
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

// ---- 2) ช่วยคำนวณขนาดกริด + lookup ----
int gridCols(List<Map<String, dynamic>> cells) => cells.isEmpty
    ? 0
    : cells.map((e) => (e['x'] as int?) ?? 0).reduce(math.max) + 1;

int gridRows(List<Map<String, dynamic>> cells) => cells.isEmpty
    ? 0
    : cells.map((e) => (e['y'] as int?) ?? 0).reduce(math.max) + 1;

Map<String, Map<String, dynamic>> buildLookup(
  List<Map<String, dynamic>> cells,
) => {for (final c in cells) '${c['x']}:${c['y']}': c};

// ---- 3) วิดเจ็ตแสดงกริดอย่างเดียว (ไม่มีการกด) ----
class BookingMapPreview extends StatelessWidget {
  const BookingMapPreview({super.key});

  @override
  Widget build(BuildContext context) {
    // ถ้าจะเปลี่ยนชุดข้อมูล เปลี่ยน kCells เป็นลิสต์อื่นได้เลย
    final cells = kCells;
    final cols = gridCols(cells);
    final rows = gridRows(cells);
    final lookup = buildLookup(cells);

    return SizedBox(
      width: 320,
      height: 240,
      child: GridView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cols * rows,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          childAspectRatio: 1, // ช่องสี่เหลี่ยมจัตุรัส
        ),
        itemBuilder: (_, i) {
          final x = i % cols;
          final y = i ~/ cols;
          final cell =
              lookup['$x:$y'] ?? {'x': x, 'y': y, 'type': CellType.empty};
          return _cellTile(cell);
        },
      ),
    );
  }

  // เรนเดอร์แต่ละช่องแบบง่าย ๆ
  Widget _cellTile(Map<String, dynamic> cell) {
    final type = cell['type'] as CellType;

    Color bg;
    Widget child = const SizedBox.shrink();

    switch (type) {
      case CellType.empty:
        bg = const Color(0xFFDBDBDB);
        child = const Icon(Icons.add, size: 16, color: Colors.white);
        break;
      case CellType.corridor:
        bg = const Color(0xFFE6EEF3);
        break;
      case CellType.stair:
        bg = const Color(0xFFF0F3F6);
        child = const Icon(
          Icons.signal_cellular_alt_rounded,
          size: 16,
          color: Colors.black54,
        );
        break;
      case CellType.decoration:
        bg = const Color(0xFFF2F8E9);
        child = const Icon(
          Icons.local_florist_rounded,
          size: 16,
          color: Colors.green,
        );
        break;
      case CellType.room:
        final status = (cell['status'] as RoomStatus?) ?? RoomStatus.disabled;
        bg = switch (status) {
          RoomStatus.free => const Color(0xFF0F828C),
          RoomStatus.pending => const Color(0xFFFF9D23),
          RoomStatus.disabled => const Color(0xFFBDBDBD),
        };
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
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(child: child),
    );
  }
}

// ---- ตัวอย่างการใช้งานหน้าเดี่ยว ๆ ----
class BookingMapPreviewPage extends StatelessWidget {
  const BookingMapPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map Preview')),
      body: const Center(child: BookingMapPreview()),
    );
  }
}

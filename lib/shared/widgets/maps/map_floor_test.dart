import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/theme/app_shapes.dart';

enum CellType { empty, room, corridor, stair, decoration }

enum RoomStatus { free, pending, disabled }

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

// Map<String, Map<String, dynamic>> buildLookup(
//   List<Map<String, dynamic>> cells,
// ) => {for (final c in cells) '${c['x']}:${c['y']}': c};

class MapFloorTest extends StatefulWidget {
  const MapFloorTest({super.key});

  @override
  State<MapFloorTest> createState() => _MapFloorTestState();
}

class _MapFloorTestState extends State<MapFloorTest> {
  final cells = kCells;
  int get cols => gridCols(cells);
  int get rows => gridRows(cells);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: 288,
      height: 230,
      child: GridView.builder(
        padding: EdgeInsets.all(0),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: rows * cols,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          mainAxisSpacing: 0,
          mainAxisExtent: 45,
        ),
        itemBuilder: (_, i) {
          return GestureDetector(
            onTap: () {
              print(i);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                border: Border.all(
                  color: Colors.white,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.all(AppShapes.radiusXs),
              ),
              child: Center(child: Text('${i + 1}')),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/theme/app_colors.dart';
import 'package:room_reservation_system_app/data/cells_seed.dart';
import 'package:room_reservation_system_app/shared/widgets/widgets.dart';
import 'package:room_reservation_system_app/shared/widgets/maps/map_types.dart';

class FloorEditorScreen extends StatefulWidget {
  const FloorEditorScreen({
    super.key,
    this.initialFloor = 5,
    this.initialSlotId = 'S1',
  });

  final int initialFloor;
  final String initialSlotId;

  @override
  State<FloorEditorScreen> createState() => _FloorEditorScreenState();
}

class _FloorEditorScreenState extends State<FloorEditorScreen> {
  // ========= selections (Floor / Time) =========
  late int floor;
  late String slotId;

  // ========= working data of current (floor, slot) =========
  late List<Map<String, dynamic>> working;

  // ========= current selection & form =========
  Map<String, dynamic>? _selected; // cell object from "working"
  final _roomCtrl = TextEditingController();

  // ใช้ baseStatus จริง (free/disabled)
  RoomStatus _status = RoomStatus.disabled;

  // ========= current tool (only for button highlight UI) =========
  CellType? _lastToolPressed;

  @override
  void initState() {
    super.initState();
    floor = widget.initialFloor;
    slotId = widget.initialSlotId;
    _loadWorking();
  }

  @override
  void dispose() {
    _roomCtrl.dispose();
    super.dispose();
  }

  // โหลด snapshot ของ floor/slot ปัจจุบันมาแก้
  void _loadWorking() {
    working = buildCellsSlice(floor: floor, slotId: slotId)
        .map(
          (c) => {
            'floor': c['floor'],
            'slotId': c['slotId'],
            'slotLabel': c['slotLabel'],
            'x': c['x'],
            'y': c['y'],
            'type': c['type'],
            if (c.containsKey('roomNo')) 'roomNo': c['roomNo'],
            if (c.containsKey('baseStatus')) 'baseStatus': c['baseStatus'],
            if (c.containsKey('bookingStatus'))
              'bookingStatus': c['bookingStatus'],
            if (c.containsKey('status')) 'status': c['status'], // display
          },
        )
        .toList();
    _clearSelection();
    setState(() {});
  }

  void _clearSelection() {
    _selected = null;
    _lastToolPressed = null;
    _roomCtrl.text = '';
    _status = RoomStatus.disabled;
  }

  Map<String, dynamic> _cellAt(int x, int y) =>
      working.firstWhere((e) => e['x'] == x && e['y'] == y);

  // ============ Selection & Form sync ============
  void _selectCell(Map<String, dynamic> cell) {
    if (identical(_selected, cell)) {
      _clearSelection();
      setState(() {});
      return;
    }

    if (cell['type'] == CellType.room) {
      final base = (cell['baseStatus'] as RoomStatus?) ?? RoomStatus.disabled;
      _status = base;
      _roomCtrl.text = (cell['roomNo'] ?? '—').toString();
    } else {
      _status = RoomStatus.disabled;
      _roomCtrl.text = '';
    }
    _selected = cell;
    setState(() {});
  }

  // ============ Room auto number ============
  String _autoRoomNo(Map<String, dynamic> cell) {
    final current = (cell['roomNo'] ?? '').toString().trim();
    if (current.isNotEmpty && current != '—') return current;

    final prefix = '$floor';
    final used = working
        .where((c) => c['type'] == CellType.room && c['roomNo'] != null)
        .map((c) => c['roomNo'].toString())
        .toSet();

    for (int n = 1; n <= 999; n++) {
      final candidate = '$prefix${n.toString().padLeft(2, '0')}';
      if (!used.contains(candidate)) return candidate;
    }
    return '—';
  }

  // ============ Confirm popups ============
  Future<bool> _confirmRemoveRoom() async {
    final ok = await showAirDialog<bool>(
      context,
      height: 400,
      content: SizedBox(
        height: 354,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30),
                  Center(
                    child: Text(
                      'Remove room?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  Center(
                    child: Text(
                      'This room will be removed and to accommodate the gap. (Empty)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppButton.solid(
                  label: 'Remove',
                  backgroundColor: AppColors.danger,
                  onPressed: () => Navigator.pop(context, true),
                ),
                const SizedBox(height: 14),
                AppButton.outline(
                  label: 'Cancel',
                  onPressed: () => Navigator.pop(context, false),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: const [SizedBox.shrink()],
    );
    return ok == true;
  }

  // ================= Silent save helpers =================
  Future<void> _saveSliceSilently() async {
    // ตอนนี้อัปเดตลง Base ทันทีผ่านฟังก์ชันใน data layer แล้ว
    _loadWorking(); // reload slice
  }

  Future<void> _closeSelectionAndSave() async {
    await _saveSliceSilently();
    _clearSelection();
    setState(() {});
  }
  // ======================================================

  // ============ TOOL FLOW (กดแล้ว “ทำทันที”) ============
  Future<void> _onToolPress(CellType tool) async {
    if (_selected == null) return;

    final cell = _selected!;
    final type = cell['type'] as CellType;

    setState(() => _lastToolPressed = tool);

    Future<void> _persistType(CellType newType, {String? roomNo}) async {
      await updateBaseCellTypeAt(
        floor: floor,
        x: cell['x'] as int,
        y: cell['y'] as int,
        type: newType,
        roomNo: roomNo,
      );
      await _closeSelectionAndSave();
    }

    // 1) select = empty
    if (type == CellType.empty) {
      if (tool == CellType.corridor ||
          tool == CellType.stair ||
          tool == CellType.decoration) {
        await _persistType(tool);
        return;
      }
      if (tool == CellType.room) {
        final rn = _autoRoomNo(cell);
        await _persistType(CellType.room, roomNo: rn);
        return;
      }
      return;
    }

    // 2) select = corridor / stair / decoration
    if (type == CellType.corridor ||
        type == CellType.stair ||
        type == CellType.decoration) {
      if (tool == CellType.empty) {
        final ok = await _confirmRemoveRoom();
        if (!ok) return;
        await _persistType(CellType.empty);
        return;
      }
      if (tool == CellType.room) {
        final rn = _autoRoomNo(cell);
        await _persistType(CellType.room, roomNo: rn);
        return;
      }
      if (tool == CellType.corridor ||
          tool == CellType.stair ||
          tool == CellType.decoration) {
        await _persistType(tool);
        return;
      }
      return;
    }

    // 3) select = room
    if (type == CellType.room) {
      if (tool == CellType.empty) {
        final ok = await _confirmRemoveRoom();
        if (!ok) return;
        await _persistType(CellType.empty);
        return;
      }
      if (tool == CellType.room) {
        // คง selection → แก้ฟอร์ม (ชื่อ/Enable-Disable)
        _selectCell(cell);
        return;
      }
      return;
    }
  }

  // ============ Confirm ============
  Future<void> _onConfirm() async {
    // ถ้าเลือกเป็นห้อง → อัปเดตชื่อห้อง + baseStatus ข้ามทุก slot
    if (_selected != null && _selected!['type'] == CellType.room) {
      final x = _selected!['x'] as int;
      final y = _selected!['y'] as int;

      final newName = _roomCtrl.text.trim().isEmpty
          ? _autoRoomNo(_selected!)
          : _roomCtrl.text.trim();

      // 1) sync room name ใน Base (ชนิดยังเป็น room)
      await updateBaseCellTypeAt(
        floor: floor,
        x: x,
        y: y,
        type: CellType.room,
        roomNo: newName,
      );

      // 2) อัปเดต BASE status (ทุก slot) โดยไม่แตะ reservations
      final newBase = (_status == RoomStatus.free)
          ? RoomStatus.free
          : RoomStatus.disabled;
      await applyBaseStatusAllSlotsAt(
        floorNo: floor,
        x: x,
        y: y,
        newBase: newBase,
      );
    }

    await showAirDialog(
      context,
      height: 400,
      content: SizedBox(
        height: 354,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Apply changes?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Floor: $floor\nTime: ${kTimeSlots.firstWhere((s) => s["id"] == slotId)["label"]}\n'
                    '• Updated base types immediately (room/decoration/empty)\n'
                    '• Updated BASE status across all time slots (pending/reserved kept)\n',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppButton.solid(
                  label: 'Confirm',
                  onPressed: () async {
                    // ปิด popup ยืนยันก่อน
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 14),
                AppButton.outline(
                  label: 'Cancel',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: const [SizedBox.shrink()],
    );
  }

  // ============ Build ============
  @override
  Widget build(BuildContext context) {
    final hasSelection = _selected != null;
    final showToolbar = hasSelection;
    final showRoomForm = hasSelection && _selected!['type'] == CellType.room;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit (Floor $floor)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.priority_high_rounded),
            tooltip: 'Edit Rules',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const _EditRulesScreen()),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // ===== Dropdowns ใต้ AppBar =====
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            decoration: const BoxDecoration(color: Color(0xFFF7F8FA)),
            child: Row(
              children: [
                _pill(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: floor,
                      items: const [
                        DropdownMenuItem(value: 3, child: Text('Floor 3')),
                        DropdownMenuItem(value: 4, child: Text('Floor 4')),
                        DropdownMenuItem(value: 5, child: Text('Floor 5')),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        floor = v;
                        _loadWorking();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _pill(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: slotId,
                      items: kTimeSlots
                          .map(
                            (s) => DropdownMenuItem(
                              value: s['id'],
                              child: Text(s['label']!),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        slotId = v;
                        _loadWorking();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // ===== แผนที่ (ใช้ MapFloor เดิม) =====
          MapFloor(
            role: MapRole.staff,
            floor: floor,
            slotId: slotId,
            cells: working,
            onCellTap: (x, y, _) {
              final c = _cellAt(x, y);
              _selectCell(c);
            },
          ),

          // ===== Toolbar (แสดงเมื่อมี selection เท่านั้น) =====
          const SizedBox(height: 8),
          Container(
            width: 310,
            height: 66,

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFDBDBDB),
            ),
            child: showToolbar ? _toolBar() : const SizedBox.shrink(),
          ),

          // ===== Form (เฉพาะห้อง) =====
          if (showRoomForm)
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 10, 25, 0),
              child: _roomForm(),
            ),

          // ===== Bottom actions (แสดงเมื่อมี selection เท่านั้น) =====
          const Spacer(),
          if (hasSelection)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton.outline(
                      outlineColor: AppColors.danger,
                      foregroundColor: AppColors.danger,
                      label: 'Cancel',
                      onPressed: () => _loadWorking(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton.solid(
                      label: 'Confirm',
                      onPressed: _onConfirm,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ============ Widgets ============
  Widget _pill({required Widget child}) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            offset: Offset(0, 4),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }

  /// Toolbar ปรับปุ่มตามชนิด cell ที่เลือก
  Widget _toolBar() {
    final cell = _selected!;
    final type = cell['type'] as CellType;

    List<_ToolDef> allButtons = [
      _ToolDef(
        CellType.room,
        Container(
          width: 35,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: AppColors.roomBlue,
          ),
          child: Center(
            child: Text(
              'R',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        'Room',
      ),
      _ToolDef(CellType.corridor, const SizedBox.shrink(), 'Corridor'),
      _ToolDef(
        CellType.stair,
        LayoutBuilder(
          builder: (_, c) {
            return Image.asset(
              'assets/icons/stairs.png',
              width: 28,
              fit: BoxFit.fitHeight,
            );
          },
        ),
        'Stair',
      ),
      _ToolDef(
        CellType.decoration,
        Container(
          decoration: const BoxDecoration(
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
        ),
        'Decoration',
      ),

      _ToolDef(
        CellType.empty,
        Container(
          width: 35,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: const Color(0xFFDBDBDB),
            border: Border.all(color: AppColors.danger, width: 1),
          ),
          child: Center(
            child: Image.asset('assets/icons/cross.png', width: 20, height: 20),
          ),
        ),
        'Empty',
      ),
    ];

    late final List<_ToolDef> buttons;
    if (type == CellType.empty) {
      buttons = allButtons.where((b) => b.type != CellType.empty).toList();
    } else if (type == CellType.room) {
      buttons = allButtons
          .where((b) => b.type == CellType.empty || b.type == CellType.room)
          .toList();
    } else {
      buttons = allButtons;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: buttons.map((b) {
        final active =
            (_lastToolPressed == b.type) ||
            (b.type == type && type != CellType.empty);
        return Tooltip(
          message: b.tooltip,
          child: InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: () => _onToolPress(b.type),
            child: Container(
              width: 35,
              height: 46,
              margin: const EdgeInsets.symmetric(horizontal: 11),
              decoration: BoxDecoration(
                color: AppColors.roomdecoration,
                borderRadius: BorderRadius.circular(5),
                border: active
                    ? Border.all(color: AppColors.iris, width: 2)
                    : null,
              ),
              child: Center(
                child: IconTheme(
                  data: IconThemeData(color: const Color(0xFFFFFFFF), size: 20),
                  child: b.icon,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _roomForm() {
    return Column(
      children: [
        _inputBox(
          label: 'Room name',
          child: TextField(
            controller: _roomCtrl,
            decoration: const InputDecoration(
              hintText: 'Enter room name',
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
        _inputBox(
          label: 'Status',
          child: DropdownButtonHideUnderline(
            child: DropdownButton<RoomStatus>(
              value: _status, // baseStatus (free/disabled)
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: RoomStatus.free, child: Text('Enable')),
                DropdownMenuItem(
                  value: RoomStatus.disabled,
                  child: Text('Disable'),
                ),
              ],
              onChanged: (v) => setState(() => _status = v ?? _status),
            ),
          ),
        ),
      ],
    );
  }

  Widget _inputBox({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE1E5EA)),
            boxShadow: const [
              BoxShadow(
                blurRadius: 10,
                offset: Offset(0, 6),
                color: Color(0x12000000),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }
}

// ====== small helper for toolbar button ======
class _ToolDef {
  final CellType type;
  final Widget icon;
  final String tooltip;
  _ToolDef(this.type, this.icon, this.tooltip);
}

// ====== RULES PAGE ======
class _EditRulesScreen extends StatelessWidget {
  const _EditRulesScreen();

  @override
  Widget build(BuildContext context) {
    final items = <_RuleItem>[
      _RuleItem(
        icon: Icons.touch_app_rounded,
        title: 'การเลือกช่อง (Selection)',
        details: [
          'กดช่องเดิมซ้ำ = ยกเลิกการเลือก',
          'ไม่มีการเลือก → ไม่แสดง Toolbar/ฟอร์ม/ปุ่มบันทึก',
        ],
      ),
      _RuleItem(
        icon: Icons.grid_on_rounded,
        title: 'ชนิดช่อง (Cell Types)',
        details: ['empty, corridor, stair, decoration, room'],
      ),
      _RuleItem(
        icon: Icons.meeting_room_rounded,
        title: 'Room & Base Status',
        details: [
          'สถานะบนแผนที่อาจเป็น free/pending/reserved/disabled',
          'สำหรับการแก้ฐาน (base) ใช้แค่ Enable=free / Disable=disabled',
          'Disable จะปิดทุก slot ของตำแหน่งนั้น (pending/reserved คงไว้)',
        ],
      ),
      _RuleItem(
        icon: Icons.warning_amber_rounded,
        title: 'การลบห้อง (Empty)',
        details: [
          'เลือกห้องแล้วกด Empty → มีหน้าต่างยืนยันก่อนลบ',
          'ลบแล้วช่องกลายเป็น empty และยกเลิกการเลือก',
        ],
      ),
      _RuleItem(
        icon: Icons.save_outlined,
        title: 'การบันทึก (Confirm)',
        details: [
          'อัปเดต base ชนิดช่องทันทีเมื่อกดเครื่องมือ',
          'ปุ่ม Confirm จะ sync ชื่อห้อง + baseStatus (ทุก slot)',
        ],
      ),
      _RuleItem(
        icon: Icons.rule_rounded,
        title: 'ข้อจำกัดทั่วไป',
        details: [
          'ผู้ใช้ทั่วไปไม่เกี่ยวข้องกับหน้านี้ (สำหรับ Staff)',
          'ไอคอน/ปุ่มจะแสดงตามกฎเพื่อป้องกันข้อผิดพลาด',
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Business Rules (Edit)')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final it = items[i];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE7E9ED)),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 10,
                  offset: Offset(0, 4),
                  color: Color(0x11000000),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(it.icon, size: 22, color: const Color(0xFF320A6B)),
                      const SizedBox(width: 8),
                      Text(
                        it.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...it.details.map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('•  '),
                          Expanded(
                            child: Text(
                              t,
                              style: const TextStyle(
                                height: 1.35,
                                color: Color(0xFF3C3F44),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RuleItem {
  final IconData icon;
  final String title;
  final List<String> details;
  _RuleItem({required this.icon, required this.title, required this.details});
}

// lib/screens/floor_editor_screen.dart
import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/data/cells_seed.dart';
import 'package:room_reservation_system_app/shared/widgets/widgets.dart'; // AppButton, showAirDialog
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
  RoomStatus _status =
      RoomStatus.disabled; // ใช้เป็น "baseStatus" (Enable/Disable)

  // ========= current tool (only for button highlight UI) =========
  CellType? _lastToolPressed;

  // ---------- BaseStatus helpers ----------
  RoomStatus _toBaseStatus(RoomStatus? visual) {
    return (visual == RoomStatus.disabled)
        ? RoomStatus.disabled
        : RoomStatus.free;
  }

  // อัปเดต "baseStatus" ของ cell เดียวกัน (floor,x,y ตรงกัน) ในทุก slot
  // - ช่องที่เป็น pending/reserved จะไม่ถูกแก้ (ปล่อยให้รออนุมัติ)
  void _applyBaseStatusAllSlotsAt({
    required int floorNo,
    required int x,
    required int y,
    required RoomStatus newBase,
  }) {
    for (final c in kCellsAll) {
      if (c['floor'] == floorNo &&
          c['x'] == x &&
          c['y'] == y &&
          c['type'] == CellType.room) {
        final st = c['status'] as RoomStatus?;
        if (st == RoomStatus.pending || st == RoomStatus.reserved) {
          continue;
        }
        c['status'] = newBase; // free/disabled
      }
    }
    // sync working ปัจจุบันด้วย
    for (final c in working) {
      if (c['x'] == x && c['y'] == y && c['type'] == CellType.room) {
        final st = c['status'] as RoomStatus?;
        if (st == RoomStatus.pending || st == RoomStatus.reserved) continue;
        c['status'] = newBase;
      }
    }
  }

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
    working = kCellsAll
        .where((c) => c['floor'] == floor && c['slotId'] == slotId)
        .map(
          (c) => {
            'floor': c['floor'],
            'slotId': c['slotId'],
            'slotLabel': c['slotLabel'],
            'x': c['x'],
            'y': c['y'],
            'type': c['type'],
            if (c.containsKey('roomNo')) 'roomNo': c['roomNo'],
            if (c.containsKey('status')) 'status': c['status'],
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
    // toggle: กด cell เดิมซ้ำ → ยกเลิกการเลือก
    if (identical(_selected, cell)) {
      _clearSelection();
      setState(() {});
      return;
    }

    if (cell['type'] == CellType.room) {
      final base = _toBaseStatus(cell['status'] as RoomStatus?);
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
      title: 'Remove room?',
      message: 'ห้องนี้จะถูกถอดออกและเปลี่ยนเป็นช่องว่าง (Empty)',
      actions: [
        AppButton.outline(
          label: 'Cancel',
          onPressed: () =>
              Navigator.of(context, rootNavigator: true).pop(false),
        ),
        AppButton.solid(
          label: 'Remove',
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
        ),
      ],
    );
    return ok == true;
  }

  // ================= NEW: Silent save helpers =================
  Future<void> _saveSliceSilently() async {
    _writeBackWorkingSliceToSeed();
    // TODO: ถ้ามี API จริง ให้เรียก persist ตรงนี้แบบไม่เด้ง dialog
    // await roomApi.saveLayoutSlice(floor, slotId, working);
    _loadWorking(); // reload working ให้เห็นผลล่าสุด
  }

  /// ใช้เมื่อ action บน toolbar ทำให้ toolbar จะปิด (selection หาย)
  Future<void> _closeSelectionAndSave() async {
    await _saveSliceSilently(); // เซฟก่อน
    _clearSelection(); // แล้วค่อยปิด selection (toolbar จะหาย)
    setState(() {});
  }
  // ============================================================

  // ============ TOOL FLOW (กดแล้ว “ทำทันที”) ============
  Future<void> _onToolPress(CellType tool) async {
    if (_selected == null) return; // ต้องมี cell ถูกเลือกก่อน

    final cell = _selected!;
    final type = cell['type'] as CellType;

    setState(() => _lastToolPressed = tool);

    // 1) เมื่อ select = empty
    if (type == CellType.empty) {
      if (tool == CellType.corridor ||
          tool == CellType.stair ||
          tool == CellType.decoration) {
        cell
          ..remove('roomNo')
          ..remove('status')
          ..['type'] = tool;
        _selectCell(cell); // คง selection ให้เห็นปุ่มไฮไลต์
        return;
      }
      if (tool == CellType.room) {
        cell['type'] = CellType.room;
        cell['roomNo'] = _autoRoomNo(cell);
        cell['status'] = RoomStatus.disabled;
        _selectCell(cell);
        return;
      }
      // tool == empty → (ซ่อนไม่ให้กดในกรณีนี้อยู่แล้ว)
      return;
    }

    // 2) เมื่อ select = corridor / stair / decoration
    if (type == CellType.corridor ||
        type == CellType.stair ||
        type == CellType.decoration) {
      if (tool == CellType.empty) {
        // เปลี่ยนเป็น empty และยกเลิกการเลือก
        cell
          ..remove('roomNo')
          ..remove('status')
          ..['type'] = CellType.empty;

        // ===== NEW: save ก่อนแล้วค่อยปิด toolbar =====
        await _closeSelectionAndSave();
        return;
      }
      if (tool == CellType.room) {
        cell['type'] = CellType.room;
        cell['roomNo'] = _autoRoomNo(cell);
        cell['status'] = RoomStatus.disabled;
        _selectCell(cell);
        return;
      }
      if (tool == CellType.corridor ||
          tool == CellType.stair ||
          tool == CellType.decoration) {
        cell
          ..remove('roomNo')
          ..remove('status')
          ..['type'] = tool;
        _selectCell(cell);
        return;
      }
      return;
    }

    // 3) เมื่อ select = room
    if (type == CellType.room) {
      if (tool == CellType.empty) {
        // ขึ้น Air popup ยืนยันก่อนถอดห้อง
        final ok = await _confirmRemoveRoom();
        if (!ok) return;

        cell
          ..remove('roomNo')
          ..remove('status')
          ..['type'] = CellType.empty;

        // ===== NEW: save ก่อนแล้วค่อยปิด toolbar =====
        await _closeSelectionAndSave();
        return;
      }
      if (tool == CellType.room) {
        // คง selection เพื่อแก้ฟอร์ม
        _selectCell(cell);
        return;
      }
      return;
    }
  }

  // ============ เขียนชนิด cell ของ slice ปัจจุบันกลับเข้า seed ============
  void _writeBackWorkingSliceToSeed() {
    for (final w in working) {
      final idx = kCellsAll.indexWhere(
        (c) =>
            c['floor'] == w['floor'] &&
            c['slotId'] == w['slotId'] &&
            c['x'] == w['x'] &&
            c['y'] == w['y'],
      );
      if (idx == -1) continue;

      final target = kCellsAll[idx];
      // อัปเดต type
      target['type'] = w['type'];

      // จัดการ roomNo/status ให้ถูกต้องตามชนิด
      if (w['type'] == CellType.room) {
        if (w.containsKey('roomNo')) {
          target['roomNo'] = w['roomNo'];
        } else {
          target.remove('roomNo');
        }
        if (w.containsKey('status')) {
          target['status'] = w['status'];
        } else {
          target.remove('status');
        }
      } else {
        // ไม่ใช่ห้อง → ลบคีย์ห้องทิ้ง
        target.remove('roomNo');
        target.remove('status');
      }
    }
  }

  // ============ Confirm ============

  Future<void> _onConfirm() async {
    // 1) ถ้าเลือกอยู่และเป็นห้อง → เขียนค่าฟอร์มกลับเข้า working ก่อน
    if (_selected != null && _selected!['type'] == CellType.room) {
      _selected!['roomNo'] = _roomCtrl.text.trim().isEmpty
          ? _autoRoomNo(_selected!)
          : _roomCtrl.text.trim();

      final newBase = (_status == RoomStatus.free)
          ? RoomStatus.free
          : RoomStatus.disabled;

      // อัปเดตฐานทุกช่วงเวลาที่ตำแหน่งเดียวกัน (ยกเว้น pending/reserved)
      _applyBaseStatusAllSlotsAt(
        floorNo: floor,
        x: _selected!['x'] as int,
        y: _selected!['y'] as int,
        newBase: newBase,
      );
    }

    // 2) เขียนชนิด cell ของ slice ปัจจุบัน (floor+slot) กลับเข้า seed
    _writeBackWorkingSliceToSeed();

    // 3) (ถ้ามี API) ตรงนี้คือจุดที่คุณเรียก service จริงเพื่อ persist
    // await roomApi.saveLayoutSlice(floor, slotId, working);
    // หรือส่ง diff เฉพาะห้องที่แก้

    await showAirDialog(
      context,
      title: 'Apply changes?',
      message:
          'Floor: $floor\nTime: ${kTimeSlots.firstWhere((s) => s["id"] == slotId)["label"]}\n'
          '• Saved current slice types (empty/corridor/stair/decoration/room)\n'
          '• Updated BASE status across all time slots for the selected room (pending/reserved kept)',
      actions: [
        AppButton.outline(
          label: 'Close',
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
        AppButton.solid(
          label: 'OK',
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            _loadWorking(); // รีโหลดจาก seed ให้เห็นผลล่าสุด
          },
        ),
      ],
    );
  }

  // ============ Build ============

  @override
  Widget build(BuildContext context) {
    final hasSelection = _selected != null;
    final showToolbar = hasSelection; // ไม่มี selection → ไม่โชว์ tool
    final showRoomForm = hasSelection && _selected!['type'] == CellType.room;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit (Floor $floor)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.priority_high_rounded), // ปุ่มกฎการแก้ไข
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
          if (showToolbar) _toolBar(),

          // ===== Form (เฉพาะห้อง) =====
          if (showRoomForm)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
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
                      outlineColor: Colors.amberAccent,
                      foregroundColor: Colors.amberAccent,
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
        ],
      ),
    );
  }

  // ============ Widgets ============

  Widget _pill({required Widget child}) {
    return Container(
      height: 36,
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

  /// Toolbar จะเปลี่ยน “ปุ่มที่มีให้กด” ตามชนิดของ cell ที่เลือก
  /// - select empty → ปุ่ม: **room, corridor, stair, decoration** (ซ่อน Empty)
  /// - select corridor/stair/decoration → ปุ่ม: **empty, room, corridor, stair, decoration**
  /// - select room → ปุ่ม: **empty, room** (และโชว์ฟอร์ม)
  Widget _toolBar() {
    final cell = _selected!;
    final type = cell['type'] as CellType;

    // ชุดปุ่มเต็ม (รวม Empty)
    List<_ToolDef> allButtons = [
      _ToolDef(CellType.empty, const Icon(Icons.add), 'Empty'),
      _ToolDef(CellType.room, const Icon(Icons.meeting_room_rounded), 'Room'),
      _ToolDef(
        CellType.corridor,
        const Icon(Icons.view_agenda_rounded),
        'Corridor',
      ),
      _ToolDef(
        CellType.stair,
        Image.asset('assets/icons/stairs.png', width: 24, height: 24),
        'Stair',
      ),
      _ToolDef(
        CellType.decoration,
        Image.asset('assets/icons/grass.png', width: 24, height: 24),
        'Decoration',
      ),
    ];

    // กฎการแสดงผลปุ่ม
    late final List<_ToolDef> buttons;
    if (type == CellType.empty) {
      // ซ่อน Empty เมื่อเลือก cell ว่าง
      buttons = allButtons.where((b) => b.type != CellType.empty).toList();
    } else if (type == CellType.room) {
      // room → แสดงเฉพาะ empty, room
      buttons = allButtons
          .where((b) => b.type == CellType.empty || b.type == CellType.room)
          .toList();
    } else {
      // corridor/stair/decoration → แสดงครบทุกปุ่ม
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
            borderRadius: BorderRadius.circular(10),
            onTap: () => _onToolPress(b.type),
            child: Container(
              width: 46,
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF320A6B)
                    : const Color(0xFFEDEFF2),
                borderRadius: BorderRadius.circular(10),
                border: active
                    ? Border.all(color: const Color(0xFFBF8DFF), width: 2)
                    : null,
              ),
              child: Center(
                child: IconTheme(
                  data: IconThemeData(
                    color: active ? Colors.white : const Color(0xFF43505A),
                    size: 20,
                  ),
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
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 6),
        Container(
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
          'ถ้าบันทึกเป็น Disable → เซลล์เดียวกันตำแหน่งเดียวกัน “ทุกเวลา” จะถูกปิด (ยกเว้นรายการที่ยัง pending/reserved จะคงไว้)',
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
          'บันทึกจะเขียนชนิดช่องของ slice ปัจจุบัน (floor+time) กลับไปที่ข้อมูลกลาง',
          'ถ้าเลือกห้องไว้ จะเขียนชื่อห้อง + baseStatus ข้ามทุกเวลา (คง pending/reserved ไว้)',
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

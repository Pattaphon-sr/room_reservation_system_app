import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/theme/app_colors.dart';
// import 'package:room_reservation_system_app/data/cells_seed.dart';
import 'package:room_reservation_system_app/shared/widgets/widgets.dart';
import 'package:room_reservation_system_app/shared/widgets/maps/map_types.dart';

import 'package:room_reservation_system_app/features/cells/data/cells_api.dart';

class FloorEditorScreen extends StatefulWidget {
  const FloorEditorScreen({
    super.key,
    this.initialFloor = 3,
    this.initialSlotId = 'S1',
  });

  final int initialFloor;
  final String initialSlotId;

  @override
  State<FloorEditorScreen> createState() => _FloorEditorScreenState();
}

class _FloorEditorScreenState extends State<FloorEditorScreen> {
  final _api = CellsApi();

  bool _loading = true; // เพิ่ม field

  // ========= selections (Floor / Time) =========
  late int floor;
  late String slotId;

  // ===== keep original values for change detection =====
  String? _initialRoomNo;
  RoomStatus? _initialBaseStatus;

  // ========= working data of current (floor, slot) =========
  List<Map<String, dynamic>> working = [];
  String? _slotLabel; // ใช้โชว์ใน dialog

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
  Future<void> _loadWorking() async {
    // ใช้วันนี้เป็น default date (ตาม API ปัจจุบัน filter ด้วย created_at)
    final today = DateTime.now();
    final dateStr =
        "${today.year.toString().padLeft(4, '0')}-"
        "${today.month.toString().padLeft(2, '0')}-"
        "${today.day.toString().padLeft(2, '0')}";

    if (!mounted) return;
    setState(() => _loading = true);

    try {
      final cells = await _api.getMap(
        floor: floor,
        slotId: slotId,
        date: dateStr,
      );
      working = cells;
      _slotLabel = cells.isNotEmpty
          ? (cells.first['slotLabel'] ?? slotId)
          : slotId;
    } catch (e) {
      working = [];
      if (mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Load map failed')));
      });
    }

    _clearSelection();
    if (mounted) setState(() => _loading = false);
  }

  void _clearSelection() {
    _selected = null;
    _lastToolPressed = null;
    _roomCtrl.text = '';
    _status = RoomStatus.disabled;

    // reset initial snapshot
    _initialRoomNo = null;
    _initialBaseStatus = null;
  }

  Map<String, dynamic> _cellAt(int x, int y) {
    return working.firstWhere(
      (e) => e['x'] == x && e['y'] == y,
      orElse: () => {'x': x, 'y': y, 'type': CellType.empty},
    );
  }

  // ============ Selection & Form sync ============
  void _selectCell(Map<String, dynamic> cell) {
    if (identical(_selected, cell)) {
      _clearSelection();
      setState(() {});
      return;
    }

    if (cell['type'] == CellType.room) {
      final base = (cell['baseStatus'] as RoomStatus?) ?? RoomStatus.disabled;
      final roomNo = (cell['roomNo'] ?? '').toString();

      // fill form
      _status = base;
      _roomCtrl.text = roomNo;

      // snapshot for change detection
      _initialRoomNo = roomNo;
      _initialBaseStatus = base;
    } else {
      _status = RoomStatus.disabled;
      _roomCtrl.text = '';

      _initialRoomNo = null;
      _initialBaseStatus = null;
    }
    _selected = cell;
    setState(() {});
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
                      'Set to Empty?',
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
                      'This room will be hidden and an empty cell will take its place.',
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
                  label: 'Confirm',
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
    await _loadWorking(); // reload slice + clear selection
  }

  Future<void> _closeSelectionAndSave() async {
    await _saveSliceSilently();
    setState(() {});
  }

  // ============ TOOL FLOW (กดแล้ว “ทำทันที”) ============
  Future<void> _onToolPress(CellType tool) async {
    if (_selected == null) return;
    final cell = _selected!;
    final currentType = cell['type'] as CellType;
    final int? id = cell['id'] as int?;
    final int cx = cell['x'] as int;
    final int cy = cell['y'] as int;

    setState(() => _lastToolPressed = tool);

    Future<void> reload() async {
      await _closeSelectionAndSave(); // เรียกโหลดใหม่ + ล้าง selection
    }

    try {
      // 1) จาก empty -> corridor/stair/decoration/room
      if (currentType == CellType.empty) {
        if (tool == CellType.room) {
          await _api.provisionRoom(floor: floor, x: cx, y: cy);
          await reload();
          return;
        }
        if (tool == CellType.corridor ||
            tool == CellType.stair ||
            tool == CellType.decoration) {
          if (id == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cannot update: cell id not found')),
            );
            return;
          }
          await _api.updateType(id: id, type: tool);
          await reload();
          return;
        }
        return;
      }

      // 2) จาก corridor/stair/decoration
      if (currentType == CellType.corridor ||
          currentType == CellType.stair ||
          currentType == CellType.decoration) {
        if (tool == CellType.empty) {
          if (id == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cannot update: cell id not found')),
            );
            return;
          }
          await _api.updateType(id: id, type: CellType.empty);
          await reload();
          return;
        }
        if (tool == CellType.room) {
          await _api.provisionRoom(floor: floor, x: cx, y: cy);
          await reload();
          return;
        }
        // เปลี่ยนเป็นประเภททางเดิน/บันได/ตกแต่งอื่น ๆ
        if (tool == CellType.corridor ||
            tool == CellType.stair ||
            tool == CellType.decoration) {
          if (id == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cannot update: cell id not found')),
            );
            return;
          }
          await _api.updateType(id: id, type: tool);
          await reload();
          return;
        }
        return;
      }

      // 3) จาก room
      if (currentType == CellType.room) {
        if (tool == CellType.empty) {
          final ok = await _confirmRemoveRoom();
          if (!ok) return;
          // ใช้ soft-remove ให้ถูกกติกา: ซ่อนห้อง + เติม empty (detach=true)
          if (id == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cannot update: cell id not found')),
            );
            return;
          }
          await _api.setHidden(id: id, hidden: true, detach: true);
          await reload();
          return;
        }
        if (tool == CellType.room) {
          // เข้าโหมดแก้ฟอร์ม (ชื่อ/สถานะ) เฉย ๆ
          _selectCell(cell);
          return;
        }
        return;
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Operation failed: $e')));
    }
  }

  // ============ Confirm ============
  Future<void> _onConfirm() async {
    if (_selected == null || _selected!['type'] != CellType.room) return;

    final int? id = _selected!['id'] as int?;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot save: cell id not found')),
      );
      return;
    }

    final newName = _roomCtrl.text.trim();
    final oldName = _initialRoomNo ?? '';
    final oldBase = _initialBaseStatus ?? RoomStatus.disabled;
    final newBase = (_status == RoomStatus.free)
        ? RoomStatus.free
        : RoomStatus.disabled;

    final bool needUpdateName = newName.isNotEmpty && newName != oldName;
    final bool needUpdateBase = newBase != oldBase;

    final slotText = _slotLabel ?? slotId;
    final baseTextOld = (oldBase == RoomStatus.free) ? 'Enable' : 'Disable';
    final baseTextNew = (newBase == RoomStatus.free) ? 'Enable' : 'Disable';

    // สร้างข้อความสรุปการเปลี่ยนแปลงใน dialog
    final nameLine = needUpdateName
        ? '• Room name: "$oldName" → "$newName"\n'
        : '• Room name: (no change)\n';

    final baseLine = needUpdateBase
        ? '• BASE status: $baseTextOld → $baseTextNew (applies across all slots; pending/reserved kept)\n'
        : '• BASE status: (no change)\n';

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
                    'Floor: $floor\nTime: $slotText\n$nameLine$baseLine',
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
                    try {
                      // ไม่มีอะไรเปลี่ยน → ปิด dialog + toast เบา ๆ
                      if (!needUpdateName && !needUpdateBase) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No changes')),
                        );
                        return;
                      }

                      // 1) อัปเดตชื่อ—เฉพาะกรณีที่ "มีการเปลี่ยน" และ "ไม่ว่าง"
                      if (needUpdateName) {
                        bool didSwap = false;

                        try {
                          await _api.updateRoomNo(id: id, roomNo: newName);
                          // rename สำเร็จ
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Rename successful'),
                              ),
                            );
                          });
                        } on DioException catch (e) {
                          if (e.response?.statusCode == 409) {
                            final data = (e.response?.data is Map)
                                ? (e.response!.data as Map)
                                : const {};

                            // กรณีชนห้องที่ซ่อนอยู่ (is_hidden = 1) → auto-swap ผ่าน API เดิม
                            if (data['duplicate_hidden'] == true &&
                                data['hidden_cell_id'] != null) {
                              final swapRes = await _api.swapWithHidden(
                                visibleId: id,
                                hiddenId: (data['hidden_cell_id'] as num)
                                    .toInt(),
                              );
                              final fromName =
                                  (swapRes['from']?['room_no'] ??
                                          swapRes['from']?['roomNo'] ??
                                          _initialRoomNo ??
                                          '')
                                      .toString();
                              final toName =
                                  (swapRes['to']?['room_no'] ??
                                          swapRes['to']?['roomNo'] ??
                                          newName)
                                      .toString();

                              didSwap = true;
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Swapped "$fromName" ↔ "$toName"',
                                    ),
                                  ),
                                );
                              });
                            } else {
                              // กรณีชนกับห้องที่มองเห็นอยู่ (is_hidden = 0) → หา cell ต้นเหตุจาก working แล้วสั่ง swap (visible↔visible)
                              final conflict = working.firstWhere(
                                (c) =>
                                    c['type'] == CellType.room &&
                                    (c['hidden'] != true) &&
                                    (c['roomNo']?.toString() == newName),
                                orElse: () => <String, dynamic>{},
                              );

                              if (conflict.isNotEmpty &&
                                  conflict['id'] != null) {
                                final swapRes = await _api.swapWithHidden(
                                  visibleId: id,
                                  hiddenId: (conflict['id'] as num)
                                      .toInt(), // ใช้เอ็นพอยต์เดิม แต่มือถือ visible↔visible ได้แล้ว
                                );
                                final fromName =
                                    (swapRes['from']?['room_no'] ??
                                            swapRes['from']?['roomNo'] ??
                                            _initialRoomNo ??
                                            '')
                                        .toString();
                                final toName =
                                    (swapRes['to']?['room_no'] ??
                                            swapRes['to']?['roomNo'] ??
                                            newName)
                                        .toString();

                                didSwap = true;
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Swapped "$fromName" ↔ "$toName"',
                                      ),
                                    ),
                                  );
                                });
                              } else {
                                // หา conflict ไม่เจอ → โยนต่อให้ handler เดิม
                                rethrow;
                              }
                            }
                          } else {
                            // error อื่น ๆ → โยนต่อ
                            rethrow;
                          }
                        }
                      }

                      // 2) อัปเดตสถานะ BASE—เฉพาะกรณีที่เปลี่ยนจริง
                      if (needUpdateBase) {
                        await _api.updateBaseStatus(id: id, base: newBase);
                      }

                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text('Saved')));
                        await _closeSelectionAndSave();
                      }
                    } on DioException catch (e) {
                      Navigator.pop(context);
                      // 409 (duplicate) → อาจชนกับห้อง visible/hidden
                      final code = e.response?.statusCode;
                      final msg =
                          (e.response?.data is Map &&
                              e.response?.data['message'] != null)
                          ? e.response?.data['message'].toString()
                          : e.message;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Save failed${code != null ? ' ($code)' : ''}: $msg',
                          ),
                        ),
                      );
                    } catch (e) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Save failed: $e')),
                      );
                    }
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
      backgroundColor: AppColors.onPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.oceanDeep,
        foregroundColor: Colors.white,
        title: Text(
          'Edit (Floor $floor)',
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.w500),
        ),
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
                const SizedBox(width: 8),
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
                      items: const [
                        DropdownMenuItem(
                          value: 'S1',
                          child: Text('08:00-10:00'),
                        ),
                        DropdownMenuItem(
                          value: 'S2',
                          child: Text('10:00-12:00'),
                        ),
                        DropdownMenuItem(
                          value: 'S3',
                          child: Text('13:00-15:00'),
                        ),
                        DropdownMenuItem(
                          value: 'S4',
                          child: Text('15:00-17:00'),
                        ),
                      ],
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

          // ===== MapFloor เดิม) =====
          SizedBox(
            height: 234,
            child: _loading
                ? const SizedBox.shrink()
                : MapFloor(
                    role: MapRole.staff,
                    floor: floor,
                    slotId: slotId,
                    cells: working,
                    onCellTap: (x, y, _) {
                      final c = _cellAt(x, y);
                      _selectCell(c);
                    },
                  ),
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
            child: showToolbar
                ? _toolBar()
                : Align(
                    child: Text(
                      'Please select a cell',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
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
            showRoomForm
                ? Padding(
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
                  )
                : Padding(
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
        title: 'Cell Selection',
        details: [
          'Tap the same cell again to deselect it.',
          'When nothing is selected → Toolbar / form / save buttons are hidden.',
        ],
      ),
      _RuleItem(
        icon: Icons.grid_on_rounded,
        title: 'Cell Types',
        details: ['empty, corridor, stair, decoration, room'],
      ),
      _RuleItem(
        icon: Icons.meeting_room_rounded,
        title: 'Room & Base Status',
        details: [
          'Map status can be: free / pending / reserved / disabled.',
          'For base editing, use only Enable = free / Disable = disabled.',
          'Disable will close that position for all slots (pending/reserved are kept).',
        ],
      ),
      _RuleItem(
        icon: Icons.warning_amber_rounded,
        title: 'Remove Room (Empty)',
        details: [
          'Select a room and press Empty → a confirmation dialog appears.',
          'After confirming, the cell becomes empty and the selection is cleared.',
          'Note: The room is not permanently deleted; it is only hidden (soft-remove).',
        ],
      ),
      _RuleItem(
        icon: Icons.save_outlined,
        title: 'Saving (Confirm)',
        details: [
          'Base cell type is updated immediately when a tool is pressed.',
          'The Confirm button syncs room name + baseStatus across all slots.',
        ],
      ),
      _RuleItem(
        icon: Icons.rule_rounded,
        title: 'General Constraints',
        details: [
          'This page is for Staff; regular users do not use it.',
          'Icons/buttons are shown based on rules to prevent mistakes.',
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

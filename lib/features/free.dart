// lib/floor_editor_screen.dart
import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/shared/widgets/widgets.dart';
// ^ รวมพวก AppButton, showAirDialog, (ถ้ามี PanelPresets)

enum CellType { empty, room, corridor, stair, decoration }

enum RoomStatus { free, pending, disabled }

const int kGridW = 8;
const int kGridH = 5;

// สีสถานะ
const _teal = Color(0xFF0F828C); // free (จองได้)
const _yellow = Color(0xFFFF9D23); // pending
const _grey = Color(0xFFBDBDBD); // disabled

class FloorEditorScreen extends StatefulWidget {
  const FloorEditorScreen({super.key, this.floorName = 'Floor 5'});
  final String floorName;

  @override
  State<FloorEditorScreen> createState() => _FloorEditorScreenState();
}

class _FloorEditorScreenState extends State<FloorEditorScreen> {
  late List<Map<String, dynamic>> cells;
  int? selectedIndex; // index ที่เลือกในกริด
  CellType _tool = CellType.room; // เครื่องมือปัจจุบัน

  // ฟอร์ม
  final _roomNameCtrl = TextEditingController();
  RoomStatus _status = RoomStatus.disabled;

  @override
  void initState() {
    super.initState();
    cells = _sampleCells();
  }

  @override
  void dispose() {
    _roomNameCtrl.dispose();
    super.dispose();
  }

  // ====== DATA MOCK ======
  List<Map<String, dynamic>> _sampleCells() {
    final List<Map<String, dynamic>> out = [];
    for (int y = 0; y < kGridH; y++) {
      for (int x = 0; x < kGridW; x++) {
        out.add({'x': x, 'y': y, 'type': CellType.empty});
      }
    }
    // ตัวอย่าง: สร้างห้องขอบนอกนิดหน่อย
    void set(int x, int y, CellType t, {RoomStatus? s, String? no}) {
      final i = y * kGridW + x;
      out[i] = {
        'x': x,
        'y': y,
        'type': t,
        if (t == CellType.room) 'status': s ?? RoomStatus.disabled,
        if (t == CellType.room) 'roomNo': no ?? '501',
      };
    }

    for (int x = 1; x < kGridW - 1; x++) {
      set(x, 0, CellType.room, s: RoomStatus.free, no: '501');
      set(x, kGridH - 1, CellType.room, s: RoomStatus.pending, no: '501');
    }
    for (int y = 1; y < kGridH - 1; y++) {
      set(0, y, CellType.room, s: RoomStatus.disabled, no: '501');
      set(kGridW - 1, y, CellType.room, s: RoomStatus.free, no: '501');
    }
    set(3, 2, CellType.stair);
    set(4, 2, CellType.decoration);
    return out;
  }

  // ====== UI ======
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F4),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            const SizedBox(height: 8),
            _canvasCard(
              child: Column(
                children: [
                  _gridBoard(),
                  const SizedBox(height: 12),
                  if (selectedIndex == null)
                    _pleaseSelectHint()
                  else
                    _toolBar(),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _formSection(),
            const Spacer(),
            _bottomActions(),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNavStub(),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: const Color(0xFF320A6B),
            onPressed: () => Navigator.maybePop(context),
          ),
          Text(
            widget.floorName,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF320A6B),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            color: const Color(0xFF320A6B),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _canvasCard({required Widget child}) {
    // ถ้ามี PanelPresets.air ใช้แทน Container ตรงนี้ได้
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x26FFFFFF), Color(0x0FFFFFFF)],
          ),
          border: Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: const [
            BoxShadow(
              blurRadius: 12,
              offset: Offset(0, 6),
              color: Color(0x220F828C),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  Widget _gridBoard() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE1E5EA)),
      ),
      child: SizedBox(
        width: 320,
        height: 240,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: kGridW * kGridH,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: kGridW,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemBuilder: (context, i) {
            final c = cells[i];
            final selected = selectedIndex == i;
            return GestureDetector(
              onTap: () => _onTapCell(i),
              child: _cellTile(c, selected),
            );
          },
        ),
      ),
    );
  }

  Widget _cellTile(Map<String, dynamic> cell, bool selected) {
    final CellType type = cell['type'] as CellType;
    Color bg = const Color(0xFFE0E0E0);
    Widget fg = const Icon(Icons.add, size: 16, color: Colors.white);
    Border? border;

    switch (type) {
      case CellType.empty:
        bg = const Color(0xFFDBDBDB);
        fg = const Icon(Icons.add, size: 16, color: Colors.white);
        break;
      case CellType.corridor:
        bg = const Color(0xFFE6EEF3);
        fg = const SizedBox.shrink();
        break;
      case CellType.stair:
        bg = const Color(0xFFF0F3F6);
        fg = const Icon(
          Icons.signal_cellular_alt_rounded,
          size: 16,
          color: Colors.black54,
        );
        break;
      case CellType.decoration:
        bg = const Color(0xFFF2F8E9);
        fg = const Icon(
          Icons.local_florist_rounded,
          size: 16,
          color: Colors.green,
        );
        break;
      case CellType.room:
        final s = (cell['status'] as RoomStatus?) ?? RoomStatus.disabled;
        if (s == RoomStatus.free) bg = _teal;
        if (s == RoomStatus.pending) bg = _yellow;
        if (s == RoomStatus.disabled) bg = _grey;

        final roomNo = (cell['roomNo'] ?? '501').toString();
        fg = Text(
          roomNo,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        );
        break;
    }

    if (selected) {
      border = Border.all(
        color: const Color(0xFFBF8DFF),
        width: 2,
      ); // ขอบม่วงตอนเลือก
    }

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: border,
      ),
      child: Center(child: fg),
    );
  }

  // ไม่มีการเลือก → แสดงคำใบ้
  Widget _pleaseSelectHint() {
    return Container(
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: const Text(
        'Please select grid',
        style: TextStyle(color: Colors.black54),
      ),
    );
  }

  // เลือกแล้ว → โชว์แถบเครื่องมือ
  Widget _toolBar() {
    Widget tool(CellType t, IconData icon) {
      final selected = _tool == t;
      return GestureDetector(
        onTap: () => setState(() => _tool = t),
        child: Container(
          width: 40,
          height: 36,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF320A6B) : const Color(0xFFEDEFF2),
            borderRadius: BorderRadius.circular(8),
            border: selected
                ? Border.all(color: const Color(0xFFBF8DFF), width: 2)
                : null,
          ),
          child: Icon(
            icon,
            size: 18,
            color: selected ? Colors.white : const Color(0xFF43505A),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        tool(CellType.room, Icons.meeting_room_rounded),
        tool(CellType.corridor, Icons.view_agenda_rounded),
        tool(CellType.stair, Icons.bar_chart_rounded),
        tool(CellType.decoration, Icons.local_florist_rounded),
        tool(CellType.empty, Icons.close_rounded),
      ],
    );
  }

  Widget _formSection() {
    final selected = selectedIndex != null ? cells[selectedIndex!] : null;
    final isRoom = selected?['type'] == CellType.room;

    // sync ค่าฟอร์มเมื่อเลือก cell ใหม่
    if (selected != null) {
      _roomNameCtrl.text = (selected['roomNo'] ?? '501').toString();
      _status = (selected['status'] as RoomStatus?) ?? RoomStatus.disabled;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IgnorePointer(
        ignoring: selected == null, // ยังไม่เลือก → disable
        child: Opacity(
          opacity: selected == null ? 0.4 : 1,
          child: Column(
            children: [
              _inputBox(
                label: 'Room name',
                child: TextField(
                  controller: _roomNameCtrl,
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
                    value: _status,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: RoomStatus.free,
                        child: Text('Enable'),
                      ),
                      DropdownMenuItem(
                        value: RoomStatus.disabled,
                        child: Text('Disable'),
                      ),
                      DropdownMenuItem(
                        value: RoomStatus.pending,
                        child: Text('Pending'),
                      ),
                    ],
                    onChanged: (v) => setState(() => _status = v ?? _status),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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

  Widget _bottomActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: AppButton.outline(label: 'Cancel', onPressed: _onCancel),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppButton.solid(label: 'Confirm', onPressed: _onConfirm),
          ),
        ],
      ),
    );
  }

  Widget _bottomNavStub() {
    return BottomNavigationBar(
      currentIndex: 1,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.edit_note_rounded),
          label: 'Edit',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.apps_rounded), label: ' '),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: ' '),
      ],
    );
  }

  // ====== EVENTS ======

  void _onTapCell(int index) async {
    final cell = cells[index];

    // ถ้ากด delete tool และ cell เป็นห้อง → warning ก่อน
    if (_tool == CellType.empty && cell['type'] == CellType.room) {
      final ok = await showAirDialog<bool>(
        context,
        title: 'Remove room?',
        message: 'This will keep the history and mark cell as empty.',
        actions: [
          AppButton.outline(
            label: 'Cancel',
            onPressed: () => Navigator.pop(context, false),
          ),
          AppButton.solid(
            label: 'Remove',
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      );
      if (ok == true) {
        setState(() {
          cell
            ..clear()
            ..addAll({
              'x': index % kGridW,
              'y': index ~/ kGridW,
              'type': CellType.empty,
            });
          selectedIndex = index;
        });
      }
      return;
    }

    // มิฉะนั้น: ใช้เครื่องมือวางชนิด
    setState(() {
      selectedIndex = index;
      switch (_tool) {
        case CellType.room:
          cell['type'] = CellType.room;
          cell['status'] ??= RoomStatus.disabled;
          cell['roomNo'] ??= '501';
          break;
        case CellType.corridor:
        case CellType.stair:
        case CellType.decoration:
          cell
            ..remove('status')
            ..remove('roomNo')
            ..['type'] = _tool;
          break;
        case CellType.empty:
          // ถ้าไม่ใช่ห้อง → เคลียร์เป็น empty ได้ทันที
          cell
            ..remove('status')
            ..remove('roomNo')
            ..['type'] = CellType.empty;
          break;
      }
    });
  }

  void _onCancel() {
    setState(() {
      selectedIndex = null;
      _tool = CellType.room;
    });
  }

  Future<void> _onConfirm() async {
    if (selectedIndex == null) return;
    final cell = cells[selectedIndex!];

    // เขียนค่าฟอร์มกลับเข้า cell หากเป็นห้อง
    if (cell['type'] == CellType.room) {
      cell['roomNo'] = _roomNameCtrl.text.trim().isEmpty
          ? '501'
          : _roomNameCtrl.text.trim();
      cell['status'] = _status;
    }

    // Confirm dialog (ตามดีไซน์)
    await showAirDialog(
      context,
      title: 'Room: ${cell['roomNo'] ?? '-'}',
      message:
          'By: User111\n\nWould you like to ${cell['type'] == CellType.room ? 'add/update' : 'apply'} this cell?',
      actions: [
        AppButton.outline(
          label: 'Cancel',
          onPressed: () => Navigator.pop(context),
        ),
        AppButton.solid(
          label: 'Confirm',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

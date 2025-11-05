// lib/features/user/pages/user_booking_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/theme/app_colors.dart';
import 'package:room_reservation_system_app/features/Staff/screens/floor_editor_screen.dart';
import 'package:room_reservation_system_app/shared/widgets/widgets.dart';
import 'package:room_reservation_system_app/shared/widgets/maps/map_types.dart';
import 'package:room_reservation_system_app/features/cells/data/cells_api.dart';

class StaffBookingScreen extends StatefulWidget {
  const StaffBookingScreen({super.key});

  @override
  State<StaffBookingScreen> createState() => _StaffBookingScreenPageState();
}

class _StaffBookingScreenPageState extends State<StaffBookingScreen>
    with TickerProviderStateMixin {
  final _api = CellsApi();
  int? expandedFloor; // null = ยังไม่กดอะไรเลย

  /// ใช้ slotId จริง (S1–S4) แล้วค่อย map เป็น label ตอนโชว์
  String _selectedSlotId = 'S1';

  /// helper แปลง slotId <-> label
  static const _slotIdToLabel = {
    'S1': '08:00 - 10:00',
    'S2': '10:00 - 12:00',
    'S3': '13:00 - 15:00',
    'S4': '15:00 - 17:00',
  };

  static String _labelOf(String slotId) => _slotIdToLabel[slotId] ?? '-';

  // ========= cache จาก API + สถานะโหลด =========
  final Map<String, List<Map<String, dynamic>>> _cellsCache = {};
  final Set<String> _loadingKeys = {};
  String _key(int floor, String slotId) => '$floor-$slotId';

  Future<void> _ensureCellsLoaded(int floor, String slotId) async {
    final key = _key(floor, slotId);
    if (_cellsCache.containsKey(key) || _loadingKeys.contains(key)) return;
    _loadingKeys.add(key);
    if (mounted) setState(() {});
    // today -> YYYY-MM-DD
    final now = DateTime.now();
    final dateStr =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    try {
      final cells = await _api.getMap(
        floor: floor,
        slotId: slotId,
        date: dateStr,
      );
      _cellsCache[key] = cells;
    } catch (_) {
      // ปล่อยว่างไว้ก่อน (จะได้ไม่พัง)
    } finally {
      _loadingKeys.remove(key);
      if (mounted) setState(() {});
    }
  }

  // กำหนด slot เริ่มต้นตามเวลาปัจจุบัน
  String _resolveSlotIdForNow(DateTime t) {
    final hm = t.hour * 60 + t.minute;
    bool inRange(int h1, int m1, int h2, int m2) {
      final a = h1 * 60 + m1, b = h2 * 60 + m2;
      return hm >= a && hm < b;
    }

    if (inRange(8, 0, 10, 0)) return 'S1';
    if (inRange(10, 0, 12, 0)) return 'S2';
    if (inRange(13, 0, 15, 0)) return 'S3';
    if (inRange(15, 0, 17, 0)) return 'S4';
    // นอกช่วง ให้เลือกช่วงถัดไปที่ใกล้สุดแบบง่าย ๆ
    if (hm < 8 * 60) return 'S1';
    if (hm < 10 * 60) return 'S1';
    if (hm < 12 * 60) return 'S2';
    if (hm < 13 * 60) return 'S3';
    if (hm < 15 * 60) return 'S3';
    return 'S4';
  }

  // ใช้ระยะเวลาและ curve เดียวเพื่อให้ลื่น
  static const _kAnimDur = Duration(milliseconds: 260);
  static const _kAnimCurve = Curves.easeOutCubic;

  @override
  void initState() {
    super.initState();
    // initial slot = ตามเวลาปัจจุบัน (เช่น 10:51 -> S2)
    _selectedSlotId = _resolveSlotIdForNow(DateTime.now());
    // prefetch แต่ละชั้นที่มี (3,4,5) สำหรับ slot ปัจจุบัน
    for (final f in [3, 4, 5]) {
      _ensureCellsLoaded(f, _selectedSlotId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient5C,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: AppColorStops.primaryStop5C,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),

              /// ======= Header: วันที่ + เวลา =======
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [_dateBox(), const SizedBox(width: 47), _timeBox()],
                ),
              ),
              const SizedBox(height: 20),

              // ======= Floor List =======
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      _buildFloorCard(
                        floor: 5,
                        imagePath: "assets/images/Photoroom_Floor5.png",
                        panelType: PanelPresets.pink,
                      ),
                      _buildFloorCard(
                        floor: 4,
                        imagePath: "assets/images/Photoroom_Floor4.png",
                        panelType: PanelPresets.purple,
                      ),
                      _buildFloorCard(
                        floor: 3,
                        imagePath: "assets/images/Photoroom_Floor3.png",
                        panelType: PanelPresets.sky,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------------- Date Box ----------------
  Widget _dateBox() {
    return PanelPresets.air(
      width: 70,
      height: 70,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text("Today", style: TextStyle(color: Colors.white, fontSize: 14)),
          SizedBox(height: 5),
          Text(
            "17",
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- Time Box ----------------
  Widget _timeBox() {
    final items = const [
      DropdownMenuItem(value: 'S1', child: Text('08:00 - 10:00')),
      DropdownMenuItem(value: 'S2', child: Text('10:00 - 12:00')),
      DropdownMenuItem(value: 'S3', child: Text('13:00 - 15:00')),
      DropdownMenuItem(value: 'S4', child: Text('15:00 - 17:00')),
    ];

    return Center(
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 8.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF9DB4F2).withOpacity(0.25),
              const Color(0xFF6C7EE1).withOpacity(0.10),
            ],
          ),
          border: Border.all(color: Colors.white54, width: 0.5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedSlotId,
            icon: const SizedBox.shrink(),
            isExpanded: true,
            alignment: Alignment.center,
            dropdownColor: const Color.fromARGB(
              255,
              50,
              61,
              141,
            ).withOpacity(0.85),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            onChanged: (v) {
              if (v == null) return;
              setState(() {
                _selectedSlotId = v;
              });
              // โหลดข้อมูล map ของ slot ใหม่นี้ (ทั้ง 3 ชั้น)
              for (final f in [3, 4, 5]) {
                _ensureCellsLoaded(f, _selectedSlotId);
              }
            },
            items: items,
          ),
        ),
      ),
    );
  }

  /// ---------------- Floor Card ----------------
  Widget _buildFloorCard({
    required int floor,
    required String imagePath,
    required Widget Function({
      required double width,
      required double height,
      required Widget child,
    })
    panelType,
  }) {
    final bool isExpanded = expandedFloor == floor;
    final bool isOtherCollapsed =
        expandedFloor != null && expandedFloor != floor;

    // เรียกโหลด map จาก API (ครั้งแรก/เมื่อยังไม่มี cache)
    _ensureCellsLoaded(floor, _selectedSlotId);

    // ความสูงใช้ค่า double แน่นอนเพื่อเลี่ยง layout jitter
    final double targetContainerHeight = isExpanded
        ? 380.0
        : (isOtherCollapsed ? 56.0 : 160.0);
    final double targetPanelHeight = isExpanded
        ? 380.0
        : (isOtherCollapsed ? 56.0 : 160.0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          expandedFloor = (expandedFloor == floor) ? null : floor;
        });
      },
      child: ClipRect(
        child: AnimatedContainer(
          duration: _kAnimDur,
          curve: _kAnimCurve,
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          height: targetContainerHeight,
          width: double.infinity,
          child: Align(
            alignment: Alignment.topCenter,
            child: panelType(
              width: double.infinity,
              height: targetPanelHeight,
              child: AnimatedSwitcher(
                duration: _kAnimDur,
                switchInCurve: _kAnimCurve,
                switchOutCurve: _kAnimCurve,
                transitionBuilder: (child, anim) {
                  // Fade + Slide (เบาและลื่น)
                  final offsetAnim = Tween<Offset>(
                    begin: const Offset(0, .06),
                    end: Offset.zero,
                  ).animate(anim);
                  return FadeTransition(
                    opacity: anim,
                    child: SlideTransition(position: offsetAnim, child: child),
                  );
                },
                child: isOtherCollapsed
                    ? Center(
                        key: ValueKey("collapsed$floor"),
                        child: Text(
                          "Floor $floor",
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : Container(
                        key: ValueKey("expanded$floor"),
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            // 1) รูปชั้น (ตัด Animation ซ้อนหลายชั้น ให้เรียบขึ้น)
                            Positioned(
                              top: isExpanded ? 12 : 18,
                              left: 20,
                              child: Image.asset(
                                imagePath,
                                height: isExpanded ? 100 : 130,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.medium,
                              ),
                            ),

                            // 2) ชื่อชั้น
                            Positioned(
                              top: isExpanded ? 40 : 60,
                              right: 20,
                              child: Text(
                                "Floor $floor",
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            // 3) แผนที่ห้องจริง (ใช้ RepaintBoundary + cache cells)
                            Positioned(
                              top: isExpanded ? 130 : 160,
                              left: 0,
                              right: 0,
                              child: AnimatedSize(
                                duration: _kAnimDur,
                                curve: _kAnimCurve,
                                alignment: Alignment.topCenter,
                                child: (expandedFloor == floor)
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 1,
                                        ),
                                        child: RepaintBoundary(
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.of(
                                                context,
                                                rootNavigator: true,
                                              ).push(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      FloorEditorScreen(
                                                        initialFloor: floor,
                                                        initialSlotId:
                                                            _selectedSlotId,
                                                      ),
                                                ),
                                              );
                                            },
                                            child: MapFloor(
                                              floor: floor,
                                              slotId: _selectedSlotId,
                                              role: MapRole.staff,
                                              cells:
                                                  _cellsCache[_key(
                                                    floor,
                                                    _selectedSlotId,
                                                  )] ??
                                                  const [],
                                              onCellTap: (x, y, cell) {
                                                // เปิดหน้า Editor ทับทั้งแอป (ไม่ให้เห็น bottom bar)
                                                Navigator.of(
                                                  context,
                                                  rootNavigator: true,
                                                ).push(
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        FloorEditorScreen(
                                                          initialFloor: floor,
                                                          initialSlotId:
                                                              _selectedSlotId,
                                                        ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

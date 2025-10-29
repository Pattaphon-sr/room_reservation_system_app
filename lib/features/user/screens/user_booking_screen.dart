// lib/features/user/pages/user_booking_page.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/theme/app_colors.dart';
import 'package:room_reservation_system_app/shared/widgets/widgets.dart';
import 'package:room_reservation_system_app/shared/widgets/maps/map_types.dart';
import 'package:room_reservation_system_app/data/cells_seed.dart';

class UserBookingScreen extends StatefulWidget {
  const UserBookingScreen({super.key});

  @override
  State<UserBookingScreen> createState() => _UserBookingScreenPageState();
}

class _UserBookingScreenPageState extends State<UserBookingScreen>
    with TickerProviderStateMixin {
  int? expandedFloor; // null = ยังไม่กดอะไรเลย
  final String _currentUsername = 'User123';

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

  // ========= NEW: cache เพื่อลด rebuild หนักของ cells =========
  final Map<String, List<Map<String, dynamic>>> _cellsCache = {};

  List<Map<String, dynamic>> _getCells(int floor, String slotId) {
    final key = '$floor-$slotId';
    final cached = _cellsCache[key];
    if (cached != null) return cached;

    final built = buildCellsSlice(floor: floor, slotId: slotId);
    _cellsCache[key] = built;
    return built;
  }

  // ใช้ระยะเวลาและ curve เดียวเพื่อให้ลื่น
  static const _kAnimDur = Duration(milliseconds: 260);
  static const _kAnimCurve = Curves.easeOutCubic;

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
                // ไม่ล้าง cache ทั้งหมด เพื่อให้การสลับชั้นยังใช้แคชได้
                // เคลียร์เฉพาะ key ของ slot เก่าถ้าต้องการก็ได้
                // แต่เพื่อความลื่น เรา "ไม่" ล้าง (ใช้ทิ้งไว้)
              });
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
                                          child: MapFloor(
                                            floor: floor,
                                            slotId: _selectedSlotId,
                                            role: MapRole.user,
                                            cells: _getCells(
                                              floor,
                                              _selectedSlotId,
                                            ),
                                            onCellTap: (x, y, cell) =>
                                                _showBookingPopup(cell),
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

  // ======== Popup ฟังก์ชันจองเหมือนใน MapPreview ========
  Future<void> _showBookingPopup(Map<String, dynamic> cell) async {
    final String roomNo = (cell['roomNo'] ?? '-').toString();
    final String byUser = _currentUsername;
    final String slotLabel = _labelOf(_selectedSlotId);

    await showAirDialog(
      context,
      height: 400,
      title: null,
      content: SizedBox(
        height: 354,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 66),
                  _popupRow(label: 'Room', value: roomNo),
                  const SizedBox(height: 12),
                  _popupRow(label: 'Time', value: slotLabel),
                  const SizedBox(height: 12),
                  _popupRow(label: 'By', value: byUser),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppButton.solid(
                  label: 'Confirm',
                  onPressed: () async {
                    Navigator.of(context, rootNavigator: true).pop();
                    final ok = await _submitReservation(
                      roomNo: roomNo,
                      slot: slotLabel,
                      user: byUser,
                    );
                    await Future.delayed(const Duration(milliseconds: 120));
                    await _showResultPopup(ok: ok);
                  },
                ),
                const SizedBox(height: 14),
                AppButton.outline(
                  label: 'Cancel',
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: const [SizedBox.shrink()],
    );
  }

  Future<bool> _submitReservation({
    required String roomNo,
    required String slot,
    required String user,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Random().nextDouble() < 0.6;
  }

  Future<void> _showResultPopup({required bool ok}) async {
    final icon = ok ? Icons.check_circle_outline_rounded : Icons.cancel_rounded;
    final iconColor = ok ? const Color(0xFFBFFF7A) : const Color(0xFFE62727);
    final titleText = ok ? 'Request sent' : 'Request failed';
    final subtitleText = ok
        ? 'Your booking request has been\nsent for approval.'
        : 'Could not create your request.\nPlease try again later.';
    final countdown = ValueNotifier<int>(5);
    Timer? timer;

    void startTimer() {
      timer?.cancel();
      timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) {
          t.cancel();
          return;
        }
        if (countdown.value <= 1) {
          t.cancel();
          Navigator.of(context, rootNavigator: true).maybePop();
        } else {
          countdown.value = countdown.value - 1;
        }
      });
    }

    startTimer();

    final dialogFuture = showAirDialog(
      context,
      height: 400,
      title: null,
      content: SizedBox(
        height: 290,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: iconColor),
            const SizedBox(height: 16),
            Text(
              titleText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitleText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
      actions: [
        ValueListenableBuilder<int>(
          valueListenable: countdown,
          builder: (_, secs, __) {
            return AppButton.solid(
              label: 'Close ($secs)',
              onPressed: () {
                timer?.cancel();
                Navigator.of(context, rootNavigator: true).maybePop();
              },
            );
          },
        ),
      ],
    );

    await dialogFuture;
    timer?.cancel();
    countdown.dispose();
  }

  Widget _popupRow({required String label, required String value}) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 18, height: 1.4, color: Colors.white),
        children: [
          TextSpan(
            text: '$label : ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}

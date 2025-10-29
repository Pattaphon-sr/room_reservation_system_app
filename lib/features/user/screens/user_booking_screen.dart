// lib/features/user/pages/user_booking_page.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/theme/app_colors.dart';
import 'package:room_reservation_system_app/shared/widgets/widgets.dart';
import 'package:room_reservation_system_app/shared/widgets/maps/map_types.dart';
import 'package:room_reservation_system_app/data/cells_seed.dart'; // เพิ่มสำหรับ MapFloor

class UserBookingScreen extends StatefulWidget {
  const UserBookingScreen({super.key});

  @override
  State<UserBookingScreen> createState() => _UserBookingScreenPageState();
}

class _UserBookingScreenPageState extends State<UserBookingScreen>
    with TickerProviderStateMixin {
  int? expandedFloor; // null = ยังไม่กดอะไรเลย
  final String _currentUsername = 'User123';
  final String _selectedSlot = '08:00 - 10:00';

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
    final slots = [
      "08:00 - 10:00",
      "10:00 - 12:00",
      "13:00 - 15:00",
      "15:00 - 17:00",
    ];
    String? selected = slots.first;

    return StatefulBuilder(
      builder: (context, setState) {
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
                  const Color(0xFF9DB4F2).withValues(alpha: 0.25),
                  const Color(0xFF6C7EE1).withValues(alpha: 0.10),
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
              child: DropdownButton(
                value: selected,
                icon: const SizedBox.shrink(),
                isExpanded: true,
                alignment: Alignment.center,
                dropdownColor: const Color.fromARGB(
                  255,
                  50,
                  61,
                  141,
                ).withValues(alpha: 0.85),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                onChanged: (v) => setState(() => selected = v),
                items: slots
                    .map(
                      (s) => DropdownMenuItem(
                        alignment: Alignment.center,
                        value: s,
                        child: Text(s),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        );
      },
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
    bool isExpanded = expandedFloor == floor;
    bool isOtherCollapsed = expandedFloor != null && expandedFloor != floor;

    double targetContainerHeight = isExpanded
        ? 380
        : (isOtherCollapsed ? 50 : 160);
    double targetPanelHeight = isExpanded ? 380 : (isOtherCollapsed ? 50 : 160);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          expandedFloor = (expandedFloor == floor) ? null : floor;
        });
      },
      child: ClipRect(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          height: targetContainerHeight,
          width: double.infinity,
          child: Align(
            alignment: Alignment.topCenter,
            child: panelType(
              width: double.infinity,
              height: targetPanelHeight,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
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
                            // 1. รูปชั้น
                            Positioned(
                              top: isExpanded ? 10 : 15,
                              left: 20,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 320),
                                opacity: isOtherCollapsed ? 0.0 : 1.0,
                                child: Image.asset(
                                  imagePath,
                                  height: isExpanded ? 100 : 130,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

                            // 2. ชื่อชั้น
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

                            // 3. แผนที่ห้องจริง (แทนกล่องขาวเดิม)
                            Positioned(
                              top: isExpanded ? 130 : 160,
                              left: 0,
                              right: 0,
                              child: AnimatedSize(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                                child: (expandedFloor == floor)
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 1,
                                        ),

                                        child: MapFloor(
                                          floor: floor,
                                          slotId: 'S1',
                                          role: MapRole.user,
                                          cells: kCellsAll,
                                          onCellTap: (x, y, cell) =>
                                              _showBookingPopup(cell),
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
    final String slotLabel = _selectedSlot;

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

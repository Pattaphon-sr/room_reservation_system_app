// lib/features/user/pages/user_booking_page.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/theme/app_colors.dart';
import 'package:room_reservation_system_app/shared/widgets/widgets.dart';
import 'package:room_reservation_system_app/shared/widgets/maps/map_types.dart';
import 'package:room_reservation_system_app/data/cells_seed.dart'; // เพิ่มสำหรับ MapFloor

class StaffBookingScreen extends StatefulWidget {
  const StaffBookingScreen({super.key});

  @override
  State<StaffBookingScreen> createState() => _StaffBookingScreenPageState();
}

class _StaffBookingScreenPageState extends State<StaffBookingScreen>
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
              const SizedBox(height: 20),
              // ======= Header: วันที่ + เวลา =======
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [_dateBox(), const SizedBox(width: 60), _timeBox()],
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
              fontSize: 18,
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
            width: 180,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  fontSize: 16,
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
                                          role: MapRole.staff,
                                          cells: kCellsAll,
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

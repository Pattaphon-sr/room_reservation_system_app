import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/theme/app_colors.dart';
import 'package:room_reservation_system_app/shared/widgets/widgets.dart';

class Booking extends StatefulWidget {
  const Booking({super.key});

  @override
  State<Booking> createState() => _BookingPageState();
}

class _BookingPageState extends State<Booking> with TickerProviderStateMixin {
  int? expandedFloor; // null = ยังไม่กดอะไรเลย

  @override
  Widget build(BuildContext context) {
    // ... (ส่วน Theme และ Scaffold เหมือนเดิม)
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

              /// ======= Header: วันที่ + เวลา =======
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [_dateBox(), const SizedBox(width: 60), _timeBox()],
                ),
              ),

              const SizedBox(height: 20),

              /// ======= Floor List =======
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

  /// ---------------- Date Box ---------------- (เหมือนเดิม)
  Widget _dateBox() {
    return PanelPresets.air(
      width: 70,
      height: 70,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            "Today",
            style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 14,
            ),
          ),
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

  /// ---------------- Time Box ---------------- (เหมือนเดิม)
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
                  const Color(
                    0xFF9DB4F2,
                  ).withValues(alpha: 0.25), // ฟ้าอ่อนโปร่งแสง
                  const Color(0xFF6C7EE1).withValues(alpha: 0.10), // ม่วงอมฟ้า
                ],
              ),
              border: Border.all(color: Colors.white54, width: 0.5),
              boxShadow: [
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
                icon: const SizedBox.shrink(), // ❌ ไม่มีลูกศร
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

    // 🌟 กำหนดความสูงที่ Panel ควรจะเป็น
    double targetContainerHeight = isExpanded
        ? 300
        : (isOtherCollapsed ? 50 : 160);
    double targetPanelHeight = isExpanded ? 300 : (isOtherCollapsed ? 50 : 160);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          expandedFloor = (expandedFloor == floor) ? null : floor;
        });
      },
      // 🌟 ใช้ ClipRect ห่อ AnimatedContainer เพื่อบังคับตัดเนื้อหาที่ล้น
      child: ClipRect(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          height: targetContainerHeight,
          width: double.infinity,

          // 🌟 Align: ยึดเนื้อหาไว้ด้านบนสุด (Top Center)
          child: Align(
            alignment: Alignment.topCenter,
            child: panelType(
              width: double.infinity,
              height: targetPanelHeight,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),

                // ------------------ เนื้อหาเมื่อยุบเล็ก (isOtherCollapsed) ------------------
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
                    // ------------------ เนื้อหาเมื่อขยายหรือสถานะปกติ ------------------
                    : Container(
                        // 🌟 ใช้ Container ห่อเพื่อกำหนด Key
                        key: ValueKey("expanded$floor"),
                        // 🌟 แก้ไข: ใช้ Stack เพื่อวางรูปภาพและข้อความให้ไม่ผลักกัน
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            // 1. รูปภาพ (ถูกจัดวางด้วย Positioned)
                            Positioned(
                              top: isExpanded
                                  ? 10
                                  : 15, // เลื่อนตำแหน่งเมื่อขยาย/ยุบ
                              left: 20,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 320),
                                opacity: isOtherCollapsed ? 0.0 : 1.0,
                                child: Image.asset(
                                  imagePath,
                                  height: isExpanded
                                      ? 100
                                      : 130, // ควบคุมขนาดรูปภาพ
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

                            // 2. ชื่อชั้น
                            Positioned(
                              top: isExpanded ? 40 : 60, // ปรับตำแหน่งตามสถานะ
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

                            // 3. ส่วนขยาย (รายละเอียด)
                            // 🌟 ใช้ Column ห่อ AnimatedSize เพื่อให้มันอยู่ด้านล่าง Stack
                            Positioned(
                              top: isExpanded
                                  ? 120
                                  : 160, // ให้เริ่มที่ด้านล่างของเนื้อหาหลัก
                              left: 0,
                              right: 0,
                              child: AnimatedSize(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                                child: (expandedFloor == floor)
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                        child: Container(
                                          width: double.infinity,
                                          constraints: const BoxConstraints(
                                            minHeight: 120,
                                            maxHeight: 170,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                              230,
                                              255,
                                              255,
                                              255,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                          child: SingleChildScrollView(),
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

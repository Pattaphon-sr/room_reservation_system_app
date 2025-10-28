import 'package:flutter/material.dart';

class Booking extends StatefulWidget {
  const Booking({super.key});

  @override
  State<Booking> createState() => _BookingPageState();
}

class _BookingPageState extends State<Booking> with TickerProviderStateMixin {
  int? expandedFloor; // ถ้า null = ยังไม่กดอะไรเลย (แสดงรูปครบ)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF3a0ca3),
                Color(0xFF4361ee),
                Color(0xFF4cc9f0),
                Color(0xFFFFFFFF),
                Color(0xFFFFFFFF),
              ],
            ),
          ),
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
                  child: Column(
                    children: [
                      _buildFloorCard(
                        floor: 5,
                        imagePath: "assets/images/Photoroom_Floor5.png",
                        color1: const Color(0xFFE0D3F9),
                        color2: const Color(0xFFD6C1EE),
                      ),
                      _buildFloorCard(
                        floor: 4,
                        imagePath: "assets/images/Photoroom_Floor4.png",
                        color1: const Color(0xFFD3D8F9),
                        color2: const Color(0xFFB5B9E7),
                      ),
                      _buildFloorCard(
                        floor: 3,
                        imagePath: "assets/images/Photoroom_Floor3.png",
                        color1: const Color(0xFFD6F2EE),
                        color2: const Color(0xFFB0E4DA),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          colors: [Color(0xFF74ABE2), Color(0xFF5563DE)],
        ),
      ),
      child: Column(
        children: const [
          Text("Today", style: TextStyle(color: Colors.white70, fontSize: 14)),
          SizedBox(height: 5),
          Text(
            "17",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- Time Box ----------------
  Widget _timeBox() {
    return Container(
      width: 160,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          colors: [Color(0xFF74ABE2), Color(0xFF5563DE)],
        ),
      ),
      child: const Center(
        child: Text(
          "08:00 - 10:00",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// ---------------- Floor Card ----------------
  Widget _buildFloorCard({
    required int floor,
    required String imagePath,
    required Color color1,
    required Color color2,
  }) {
    bool isExpanded = expandedFloor == floor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(colors: [color1, color2]),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          setState(() {
            // ✅ ถ้ากดซ้ำ จะ toggle หดกลับ
            if (expandedFloor == floor) {
              expandedFloor = null;
            } else {
              expandedFloor = floor;
            }
          });
        },
        child: Column(
          children: [
            /// ======= ส่วนหัว (รูป + ชื่อ) =======
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✅ แสดงรูปครบทุก Floor ถ้ายังไม่กดอะไร
                if (expandedFloor == null || isExpanded)
                  Padding(
                    padding: const EdgeInsets.only(right: 60),
                    child: Image.asset(
                      imagePath,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                Text(
                  "Floor $floor",
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            /// ======= พื้นที่ขยายตอนกด =======
            AnimatedSize(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              child: isExpanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Center(
                          child: Text(
                            "",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

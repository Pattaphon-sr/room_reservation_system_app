import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/theme/theme.dart';
import 'package:room_reservation_system_app/features/staff/service.dart'; // ไม่มี lib/

/// --------------------- MODEL ---------------------
enum ApprovalStatus { pending, approved, rejected }

class ActivityItem {
  final ApprovalStatus status;
  final String floor;
  final String roomCode;
  final String slot;
  final DateTime dateTime;

  /// ผู้ร้องขอ (อาจารย์/ผู้ใช้ที่จอง)
  final String requestedBy;

  /// ผู้อนุมัติ/ผู้พิจารณา (ถ้า pending ให้เป็น null)
  final String? approvedBy;

  /// เหตุผลเพิ่มเติม (เช่น rejected)
  final String? note;

  const ActivityItem({
    required this.status,
    required this.floor,
    required this.roomCode,
    required this.slot,
    required this.dateTime,
    required this.requestedBy,
    this.approvedBy,
    this.note,
  });
}

/// --------------------- PAGE ---------------------
class StaffHistoryScreen extends StatefulWidget {
  const StaffHistoryScreen({super.key});

  @override
  State<StaffHistoryScreen> createState() => _StaffHistoryScreenState();
}

class _StaffHistoryScreenState extends State<StaffHistoryScreen> {
  final TextEditingController _search = TextEditingController();
  final StaffHistoryService _service = StaffHistoryService(); // เพิ่มบรรทัดนี้

  List<ActivityItem> connectedApiItems = [];
  bool _isLoading = true; // เพิ่มบรรทัดนี้
  String? _errorMessage; // เพิ่มบรรทัดนี้

  @override
  void initState() {
    super.initState();
    _loadHistory(); // เพิ่มบรรทัดนี้
  }

  // เพิ่ม method นี้
  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await _service.fetchHistory();
      setState(() {
        connectedApiItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Mock data (เห็นทุกคน ทั้ง Pending/Done)
  // final List<ActivityItem> _items = [
  //   // Pending (Oct)
  //   ActivityItem(
  //     status: ApprovalStatus.pending,
  //     floor: 'Floor5',
  //     roomCode: 'R501',
  //     slot: '08:00-10:00',
  //     dateTime: DateTime(2025, 10, 22, 7, 48),
  //     requestedBy: 'Mr. Adam',
  //   ),
  //   ActivityItem(
  //     status: ApprovalStatus.pending,
  //     floor: 'Floor4',
  //     roomCode: 'R402',
  //     slot: '10:00-12:00',
  //     dateTime: DateTime(2025, 10, 21, 9, 20),
  //     requestedBy: 'Ms. Bella',
  //   ),
  //   ActivityItem(
  //     status: ApprovalStatus.pending,
  //     floor: 'Floor3',
  //     roomCode: 'R303',
  //     slot: '13:00-15:00',
  //     dateTime: DateTime(2025, 10, 20, 14, 10),
  //     requestedBy: 'Dr. Chan',
  //   ),

  //   // Done (Oct)
  //   ActivityItem(
  //     status: ApprovalStatus.approved,
  //     floor: 'Floor5',
  //     roomCode: 'R501',
  //     slot: '08:00-10:00',
  //     dateTime: DateTime(2025, 10, 19, 7, 56),
  //     requestedBy: 'Mr. David',
  //     approvedBy: 'Dr. Parker',
  //   ),
  //   ActivityItem(
  //     status: ApprovalStatus.approved,
  //     floor: 'Floor5',
  //     roomCode: 'R503',
  //     slot: '08:00-10:00',
  //     dateTime: DateTime(2025, 10, 18, 8, 10),
  //     requestedBy: 'Ms. Eva',
  //     approvedBy: 'Assoc. Prof. Somchai',
  //   ),
  //   ActivityItem(
  //     status: ApprovalStatus.rejected,
  //     floor: 'Floor3',
  //     roomCode: 'R304',
  //     slot: '10:00-12:00',
  //     dateTime: DateTime(2025, 10, 17, 10, 48),
  //     requestedBy: 'Mr. Ford',
  //     approvedBy: 'Dr. Jane',
  //     note: 'The ceiling collapsed',
  //   ),
  //   ActivityItem(
  //     status: ApprovalStatus.approved,
  //     floor: 'Floor4',
  //     roomCode: 'R405',
  //     slot: '09:00-11:00',
  //     dateTime: DateTime(2025, 10, 16, 9, 12),
  //     requestedBy: 'Dr. Grace',
  //     approvedBy: 'Dean Kitti',
  //   ),
  //   ActivityItem(
  //     status: ApprovalStatus.approved,
  //     floor: 'Floor3',
  //     roomCode: 'R302',
  //     slot: '13:00-15:00',
  //     dateTime: DateTime(2025, 10, 15, 13, 45),
  //     requestedBy: 'Mr. Henry',
  //     approvedBy: 'Dr. Mia',
  //   ),

  //   // Done (Sep)
  //   ActivityItem(
  //     status: ApprovalStatus.approved,
  //     floor: 'Floor5',
  //     roomCode: 'R501',
  //     slot: '08:00-10:00',
  //     dateTime: DateTime(2025, 9, 27, 7, 39),
  //     requestedBy: 'Mr. Leo',
  //     approvedBy: 'Dr. Mia',
  //   ),
  //   ActivityItem(
  //     status: ApprovalStatus.approved,
  //     floor: 'Floor4',
  //     roomCode: 'R408',
  //     slot: '10:00-12:00',
  //     dateTime: DateTime(2025, 9, 13, 10, 48),
  //     requestedBy: 'Ms. Nora',
  //     approvedBy: 'Dr. Parker',
  //   ),
  //   ActivityItem(
  //     status: ApprovalStatus.rejected,
  //     floor: 'Floor3',
  //     roomCode: 'R307',
  //     slot: '09:00-11:00',
  //     dateTime: DateTime(2025, 9, 5, 9, 12),
  //     requestedBy: 'Mr. Omar',
  //     approvedBy: 'Assoc. Prof. Somchai',
  //     note: 'Room under maintenance',
  //   ),

  //   // ตัวอย่าง (Nov) — เผื่อให้เห็นแท็บต่อไปทางขวา
  //   ActivityItem(
  //     status: ApprovalStatus.pending,
  //     floor: 'Floor3',
  //     roomCode: 'R301',
  //     slot: '09:00-11:00',
  //     dateTime: DateTime(2025, 11, 5, 9, 15),
  //     requestedBy: 'Ms. Pam',
  //   ),
  // ];

  // final List<ActivityItem> connectedApiItems = [];

  /// ---------- Helpers: สำหรับ grouping เดือน ----------
  String _monthYearLabel(DateTime dt) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }

  /// กลุ่มเดือน: เก่า → ใหม่ (ใช้เฉพาะสำหรับ "แท็บ" ให้ Sep อยู่ซ้าย, Oct ขวา)
  List<MapEntry<String, List<ActivityItem>>> _groupByMonthAsc(
    List<ActivityItem> items,
  ) {
    final map = <String, List<ActivityItem>>{};
    for (final e in items) {
      final key =
          '${e.dateTime.year}-${e.dateTime.month.toString().padLeft(2, '0')}';
      map.putIfAbsent(key, () => []).add(e);
    }
    for (final list in map.values) {
      list.sort(
        (a, b) => b.dateTime.compareTo(a.dateTime),
      ); // ในเดือน: ใหม่ → เก่า
    }
    final entries = map.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key)); // เดือน: เก่า → ใหม่
    return entries;
  }

  /// เนื้อหาใน "หนึ่งแท็บของเดือน" (ไม่ต้องมีหัวเดือนซ้ำ)
  List<Widget> _buildOneMonthTabBody(List<ActivityItem> monthItems) {
    final done =
        monthItems.where((e) => e.status != ApprovalStatus.pending).toList()
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return [
      // const SizedBox(height: 24),
      // // const Divider(height: 0, thickness: 0.8, color: Color(0xFFE1E6EB)),
      // const SizedBox(height: 18),

      // _SectionHeader(title: 'Done'),
      // const SizedBox(height: 10),

      // ✅ แก้ตรงนี้ - เพิ่ม else
      if (done.isNotEmpty) ..._tilesWithDividers(done, isStaff: true),

      const SizedBox(height: 12),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // เพิ่มการตรวจสอบ loading และ error ที่ต้นฟังก์ชัน
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Error: $_errorMessage',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loadHistory,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final query = _search.text.trim().toLowerCase();

    // ค้นหาในทุกฟิลด์ที่เกี่ยวข้อง
    final filtered = connectedApiItems.where((e) {
      if (query.isEmpty) return true;
      final hay =
          '${e.floor} ${e.roomCode} ${e.slot} ${e.requestedBy} '
                  '${e.approvedBy ?? ''} ${e.note ?? ''}'
              .toLowerCase();
      return hay.contains(query);
    }).toList();

    // กลุ่มเดือนสำหรับ “แท็บ” — เก่า → ใหม่ (เช่น Sep | Oct | Nov)
    final tabGroups = _groupByMonthAsc(filtered);

    // ถ้าไม่มีข้อมูลเลย
    if (tabGroups.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(
          child: Text('No data', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          // พื้นหลัง gradient หลัก
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.primaryGradient5C,
              ),
            ),
          ),

          // เนื้อหา + TabBar
          SafeArea(
            child: DefaultTabController(
              length: tabGroups.length,
              // ถ้าอยากให้เริ่มที่แท็บล่าสุด ให้ใช้ initialIndex: tabGroups.length - 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'History',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 35,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Search
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.oceanDeep,
                            blurRadius: 18,
                            spreadRadius: -2,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _search,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                          hintText: 'Search ...',
                          hintStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                          filled: true,
                          fillColor: const Color(0x334A74A8),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.25),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.25),
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(28)),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ===== TabBar ด้านบน (แบบเดียวกับ User) =====
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: TabBar(
                      isScrollable: true,
                      labelPadding: const EdgeInsets.symmetric(
                        horizontal: 14.0,
                      ),
                      indicatorColor: Colors.white,
                      indicatorWeight: 2,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      labelStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                      tabs: [
                        for (final g in tabGroups)
                          Tab(text: _monthYearLabel(g.value.first.dateTime)),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.0),
                    child: Divider(
                      height: 18,
                      thickness: 1,
                      color: Color(0x66FFFFFF),
                    ),
                  ),

                  // ===== เนื้อหาในแต่ละแท็บ =====
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(26),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 24,
                            spreadRadius: -8,
                            color: Colors.black26,
                            offset: Offset(0, -6),
                          ),
                        ],
                      ),
                      child: TabBarView(
                        children: [
                          for (final g in tabGroups)
                            ListView(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                20,
                                20,
                                28,
                              ),
                              children: _buildOneMonthTabBody(g.value),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// แทรก Divider ให้สวยงาม
  static List<Widget> _tilesWithDividers(
    List<ActivityItem> items, {
    required bool isStaff,
  }) {
    final out = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      out.add(_ActivityTileStaff(item: items[i], isStaff: isStaff));
      if (i != items.length - 1) {
        out.add(
          const Divider(height: 22, thickness: 0.9, color: Color(0xFFE1E6EB)),
        );
      }
    }
    return out;
  }
}

/// --------------------- SMALL WIDGETS ---------------------
class _SectionHeader extends StatelessWidget {
  final String title;
  final Color? color;
  const _SectionHeader({required this.title, this.color});
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: color ?? Colors.black,
        fontSize: 28,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

// ignore: unused_element
class _MonthLabel extends StatelessWidget {
  final String text;
  const _MonthLabel({required this.text});
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color.fromARGB(255, 75, 77, 79),
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String text;
  const _Empty({required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Text(text, style: const TextStyle(color: Color(0xFF9AA1A9))),
    );
  }
}

class _ActivityTileStaff extends StatelessWidget {
  final ActivityItem item;
  final bool isStaff;
  const _ActivityTileStaff({required this.item, required this.isStaff});

  Color get _statusColor {
    switch (item.status) {
      case ApprovalStatus.pending:
        return AppColors.warning; // ส้ม
      case ApprovalStatus.approved:
        return AppColors.success; // เขียว
      case ApprovalStatus.rejected:
        return AppColors.danger; // แดง
    }
  }

  String get _statusText {
    switch (item.status) {
      case ApprovalStatus.pending:
        return 'Pending';
      case ApprovalStatus.approved:
        return 'Approved';
      case ApprovalStatus.rejected:
        return 'Rejected';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = _formatDate(item.dateTime);
    final reviewerLabel = item.status == ApprovalStatus.approved
        ? 'Approved by'
        : 'Reviewed by';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // แถวบน: สถานะ + Floor / Room Code
          Row(
            children: [
              Text(
                _statusText,
                style: TextStyle(
                  color: _statusColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                item.floor,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              Text(
                item.roomCode,
                style: TextStyle(
                  color: item.status == ApprovalStatus.rejected
                      ? const Color(0xFFE62727) // ✅ แดง (rejected)
                      : item.status == ApprovalStatus.approved
                      ? const Color(0xFF399918) // เขียว (approved)
                      : Colors.black87, // ดำ (pending)
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ],
          ),

          // เหตุผล (ถ้า Rejected และมี note)
          if (item.status == ApprovalStatus.rejected &&
              (item.note ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6.0, bottom: 2),
              child: Text(
                item.note!,
                style: const TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),

          const SizedBox(height: 6),

          // แถว: Slot + วันที่เวลา
          Row(
            children: [
              const Text(
                'Slot: ',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              Text(
                item.slot,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Text(
                dateStr,
                style: const TextStyle(
                  color: Color(0xFF6A6F77),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // ผู้ร้องขอ + ผู้อนุมัติ/ผู้ตรวจ
          Row(
            children: [
              const Text(
                'Requested by: ',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              Text(
                item.requestedBy,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                ),
              ),
            ],
          ),

          if (item.status != ApprovalStatus.pending &&
              (item.approvedBy ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Row(
                children: [
                  Text(
                    '$reviewerLabel: ',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    item.approvedBy!,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${m[dt.month - 1]} ${dt.year} - ${hour.toString().padLeft(2, '0')}:$mm $ampm';
  }
}

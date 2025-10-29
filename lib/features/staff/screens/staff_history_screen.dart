import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/theme/theme.dart';

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

  /// Mock data (เห็นทุกคน ทั้ง Pending/Done) + ตัวอย่าง Sep 2025
  final List<ActivityItem> _items = [
    // Pending (Oct)
    ActivityItem(
      status: ApprovalStatus.pending,
      floor: 'Floor5',
      roomCode: 'R501',
      slot: '08:00-10:00',
      dateTime: DateTime(2025, 10, 22, 7, 48),
      requestedBy: 'Mr. Adam',
    ),
    ActivityItem(
      status: ApprovalStatus.pending,
      floor: 'Floor4',
      roomCode: 'R402',
      slot: '10:00-12:00',
      dateTime: DateTime(2025, 10, 21, 9, 20),
      requestedBy: 'Ms. Bella',
    ),
    ActivityItem(
      status: ApprovalStatus.pending,
      floor: 'Floor3',
      roomCode: 'R303',
      slot: '13:00-15:00',
      dateTime: DateTime(2025, 10, 20, 14, 10),
      requestedBy: 'Dr. Chan',
    ),

    // Done (Oct)
    ActivityItem(
      status: ApprovalStatus.approved,
      floor: 'Floor5',
      roomCode: 'R501',
      slot: '08:00-10:00',
      dateTime: DateTime(2025, 10, 19, 7, 56),
      requestedBy: 'Mr. David',
      approvedBy: 'Dr. Parker',
    ),
    ActivityItem(
      status: ApprovalStatus.approved,
      floor: 'Floor5',
      roomCode: 'R503',
      slot: '08:00-10:00',
      dateTime: DateTime(2025, 10, 18, 8, 10),
      requestedBy: 'Ms. Eva',
      approvedBy: 'Assoc. Prof. Somchai',
    ),
    ActivityItem(
      status: ApprovalStatus.rejected,
      floor: 'Floor3',
      roomCode: 'R304',
      slot: '10:00-12:00',
      dateTime: DateTime(2025, 10, 17, 10, 48),
      requestedBy: 'Mr. Ford',
      approvedBy: 'Dr. Jane',
      note: 'The ceiling collapsed',
    ),
    ActivityItem(
      status: ApprovalStatus.approved,
      floor: 'Floor4',
      roomCode: 'R405',
      slot: '09:00-11:00',
      dateTime: DateTime(2025, 10, 16, 9, 12),
      requestedBy: 'Dr. Grace',
      approvedBy: 'Dean Kitti',
    ),
    ActivityItem(
      status: ApprovalStatus.approved,
      floor: 'Floor3',
      roomCode: 'R302',
      slot: '13:00-15:00',
      dateTime: DateTime(2025, 10, 15, 13, 45),
      requestedBy: 'Mr. Henry',
      approvedBy: 'Dr. Mia',
    ),

    // Done (Sep)
    ActivityItem(
      status: ApprovalStatus.approved,
      floor: 'Floor5',
      roomCode: 'R501',
      slot: '08:00-10:00',
      dateTime: DateTime(2025, 9, 27, 7, 39),
      requestedBy: 'Mr. Leo',
      approvedBy: 'Dr. Mia',
    ),
    ActivityItem(
      status: ApprovalStatus.approved,
      floor: 'Floor4',
      roomCode: 'R408',
      slot: '10:00-12:00',
      dateTime: DateTime(2025, 9, 13, 10, 48),
      requestedBy: 'Ms. Nora',
      approvedBy: 'Dr. Parker',
    ),
    ActivityItem(
      status: ApprovalStatus.rejected,
      floor: 'Floor3',
      roomCode: 'R307',
      slot: '09:00-11:00',
      dateTime: DateTime(2025, 9, 5, 9, 12),
      requestedBy: 'Mr. Omar',
      approvedBy: 'Assoc. Prof. Somchai',
      note: 'Room under maintenance',
    ),
  ];

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

  List<MapEntry<String, List<ActivityItem>>> _groupByMonth(
    List<ActivityItem> items,
  ) {
    final map = <String, List<ActivityItem>>{};
    for (final e in items) {
      final key =
          '${e.dateTime.year}-${e.dateTime.month.toString().padLeft(2, '0')}';
      map.putIfAbsent(key, () => []).add(e);
    }
    // sort ในกลุ่ม: ใหม่ → เก่า
    for (final list in map.values) {
      list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    }
    // sort กลุ่ม: ใหม่ → เก่า
    final entries = map.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();

    // ค้นหาในทุกฟิลด์ที่เกี่ยวข้อง
    final filtered = _items.where((e) {
      if (query.isEmpty) return true;
      final hay =
          '${e.floor} ${e.roomCode} ${e.slot} ${e.requestedBy} '
                  '${e.approvedBy ?? ''} ${e.note ?? ''}'
              .toLowerCase();
      return hay.contains(query);
    }).toList();

    final pending =
        filtered.where((e) => e.status == ApprovalStatus.pending).toList()
          ..sort(
            (a, b) => b.dateTime.compareTo(a.dateTime),
          ); // ให้รายการใหม่อยู่บน
    final done =
        filtered.where((e) => e.status != ApprovalStatus.pending).toList()
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime)); // ใหม่ → เก่า

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Staff Activity History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Search (แก้วใส + เงาเรืองนิดๆ)
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
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      filled: true,
                      fillColor: const Color(0x334A74A8), // แก้วใส
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
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
              const SizedBox(height: 16),

              // ตัวการ์ดพื้นหลังอ่อน + เนื้อหา
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(26),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromARGB(255, 218, 255, 253),
                        Color(0xFFEFF7FF),
                      ],
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
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                    children: [
                      // ---------- PENDING (บล็อกเดี่ยว) ----------
                      const _SectionHeader(
                        title: 'Pending Approval',
                        color: AppColors.warning,
                      ),
                      const SizedBox(height: 10),
                      if (pending.isEmpty)
                        const _Empty(text: 'No pending requests')
                      else ...[
                        _MonthLabel(
                          text: _monthYearLabel(pending.first.dateTime),
                        ),
                        const SizedBox(height: 8),
                        ..._tilesWithDividers(pending, isStaff: true),
                      ],

                      const SizedBox(height: 18),

                      // ---------- DONE (จัดกลุ่มตามเดือนอัตโนมัติ) ----------
                      const _SectionHeader(title: 'Done'),
                      const SizedBox(height: 10),
                      if (done.isEmpty) ...[
                        const _Empty(text: 'No history yet'),
                      ] else ...[
                        for (final entry in _groupByMonth(done)) ...[
                          _MonthLabel(
                            text: _monthYearLabel(entry.value.first.dateTime),
                          ),
                          const SizedBox(height: 8),
                          ..._tilesWithDividers(entry.value, isStaff: true),
                          const SizedBox(height: 12),
                        ],
                      ],
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
        color: color ?? Colors.black87,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

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
                ),
              ),
              const SizedBox(width: 6),
              Text(
                item.floor,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                item.roomCode,
                style: TextStyle(
                  color: item.status == ApprovalStatus.approved
                      ? AppColors.success
                      : Colors.black,
                  fontWeight: FontWeight.w800,
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
                ),
              ),
            ),

          // แถว: Slot + วันที่เวลา
          Row(
            children: [
              RichText(
                text: const TextSpan(
                  text: 'Slot ',
                  style: TextStyle(
                    color: Color(0xFF6A6F77),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                item.slot,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
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
          Text(
            'Requested by: ${item.requestedBy}',
            style: const TextStyle(
              color: Color(0xFF4A4F57),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          if (item.status != ApprovalStatus.pending &&
              (item.approvedBy ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                '$reviewerLabel: ${item.approvedBy!}',
                style: const TextStyle(
                  color: Color(0xFF4A4F57),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
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

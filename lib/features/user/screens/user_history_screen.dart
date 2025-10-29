import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/theme/theme.dart';

/// ===================== MODEL =====================
enum ApprovalStatus { pending, approved, rejected }

class ActivityItem {
  final ApprovalStatus status;
  final String floor;
  final String roomCode;
  final String slot;
  final DateTime dateTime;
  final String? note;

  ActivityItem({
    required this.status,
    required this.floor,
    required this.roomCode,
    required this.slot,
    required this.dateTime,
    this.note,
  });
}

/// ===================== PAGE =====================
class UserHistoryScreen extends StatefulWidget {
  const UserHistoryScreen({super.key});
  @override
  State<UserHistoryScreen> createState() => _UserHistoryScreenState();
}

class _UserHistoryScreenState extends State<UserHistoryScreen> {
  final TextEditingController _search = TextEditingController();

  /// ---- Mock data (ตัวอย่าง) รวม Oct & Sep 2025 ----
  final List<ActivityItem> _items = [
    // ---------- October 2025 ----------
    ActivityItem(
      status: ApprovalStatus.pending,
      floor: 'Floor5',
      roomCode: 'R501',
      slot: '08:00-10:00',
      dateTime: DateTime(2025, 10, 22, 7, 48),
    ),
    ActivityItem(
      status: ApprovalStatus.pending,
      floor: 'Floor4',
      roomCode: 'R402',
      slot: '10:00-12:00',
      dateTime: DateTime(2025, 10, 21, 9, 20),
    ),
    ActivityItem(
      status: ApprovalStatus.pending,
      floor: 'Floor3',
      roomCode: 'R303',
      slot: '13:00-15:00',
      dateTime: DateTime(2025, 10, 20, 14, 10),
    ),
    ActivityItem(
      status: ApprovalStatus.approved,
      floor: 'Floor5',
      roomCode: 'R501',
      slot: '08:00-10:00',
      dateTime: DateTime(2025, 10, 19, 7, 56),
    ),
    ActivityItem(
      status: ApprovalStatus.approved,
      floor: 'Floor5',
      roomCode: 'R503',
      slot: '08:00-10:00',
      dateTime: DateTime(2025, 10, 18, 8, 10),
    ),
    ActivityItem(
      status: ApprovalStatus.rejected,
      floor: 'Floor3',
      roomCode: 'R304',
      slot: '10:00-12:00',
      dateTime: DateTime(2025, 10, 17, 10, 48),
      note: 'The ceiling collapsed',
    ),
    ActivityItem(
      status: ApprovalStatus.approved,
      floor: 'Floor5',
      roomCode: 'R505',
      slot: '09:00-11:00',
      dateTime: DateTime(2025, 10, 16, 9, 12),
    ),
    ActivityItem(
      status: ApprovalStatus.approved,
      floor: 'Floor4',
      roomCode: 'R402',
      slot: '13:00-15:00',
      dateTime: DateTime(2025, 10, 15, 13, 45),
    ),
    ActivityItem(
      status: ApprovalStatus.rejected,
      floor: 'Floor3',
      roomCode: 'R307',
      slot: '10:00-12:00',
      dateTime: DateTime(2025, 10, 14, 10, 33),
      note: 'Room under maintenance',
    ),
    ActivityItem(
      status: ApprovalStatus.approved,
      floor: 'Floor3',
      roomCode: 'R306',
      slot: '14:00-16:00',
      dateTime: DateTime(2025, 10, 13, 14, 55),
    ),

    // ---------- September 2025 ----------
    ActivityItem(
      status: ApprovalStatus.approved,
      floor: 'Floor5',
      roomCode: 'R501',
      slot: '08:00-10:00',
      dateTime: DateTime(2025, 9, 27, 7, 39),
    ),
    ActivityItem(
      status: ApprovalStatus.approved,
      floor: 'Floor4',
      roomCode: 'R408',
      slot: '10:00-12:00',
      dateTime: DateTime(2025, 9, 13, 10, 48),
    ),
    ActivityItem(
      status: ApprovalStatus.rejected,
      floor: 'Floor4',
      roomCode: 'R407',
      slot: '09:00-11:00',
      dateTime: DateTime(2025, 9, 5, 9, 12),
      note: 'Room under maintenance',
    ),
  ];

  /// ============ Group by Month-Year (ใหม่ → เก่า) ============
  List<MapEntry<String, List<ActivityItem>>> _groupByMonth(
      List<ActivityItem> items) {
    final map = <String, List<ActivityItem>>{};
    for (final it in items) {
      final key =
          '${it.dateTime.year}-${it.dateTime.month.toString().padLeft(2, '0')}';
      (map[key] ??= []).add(it);
    }

    // sort รายการในแต่ละเดือน (ใหม่ → เก่า)
    for (final list in map.values) {
      list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    }

    // sort เดือน (ใหม่ → เก่า)
    final keys = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return [for (final k in keys) MapEntry(k, map[k]!)];
  }

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
      'December'
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }

  /// ===== สร้าง Section บล็อกรายเดือน + เว้นระยะห่างระหว่างเดือน =====
  List<Widget> _buildSectionByMonth({
    required String sectionTitle,
    required List<ActivityItem> items,
    Color? titleColor,
  }) {
    const monthTopGap = 24.0;
    const monthBottomGap = 12.0;

    final out = <Widget>[];
    out.add(_SectionHeader(title: sectionTitle, color: titleColor));
    out.add(const SizedBox(height: 10));

    if (items.isEmpty) {
      out.add(const _Empty(text: 'No data'));
      return out;
    }

    final groups = _groupByMonth(items);

    for (var gi = 0; gi < groups.length; gi++) {
      final g = groups[gi];

      // เว้นระยะก่อนเริ่มเดือนถัดไป (ยกเว้นเดือนแรก)
      if (gi > 0) {
        out.add(const SizedBox(height: monthTopGap));
        // out.add(const Divider(height: 0, thickness: 0.8, color: Color(0xFFE1E6EB)));
        out.add(const SizedBox(height: 3));
      }

      // ชื่อเดือน
      out.add(_MonthLabel(text: _monthYearLabel(g.value.first.dateTime)));
      out.add(const SizedBox(height: 18));

      // รายการในเดือนนั้น
      out.addAll(_tilesWithDividers(g.value));

      // เว้นท้ายบล็อกเดือน
      out.add(const SizedBox(height: monthBottomGap));
    }

    return out;
  }

  @override
  Widget build(BuildContext context) {
    final q = _search.text.trim().toLowerCase();

    // Filter (ค้นหา floor/room/slot/note)
    final filtered = _items.where((e) {
      if (q.isEmpty) return true;
      final hay =
          '${e.floor} ${e.roomCode} ${e.slot} ${(e.note ?? '')}'.toLowerCase();
      return hay.contains(q);
    }).toList();

    // แยก Pending / Done
    final pending =
        filtered.where((e) => e.status == ApprovalStatus.pending).toList();
    final done = filtered
        .where((e) => e.status != ApprovalStatus.pending)
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          // พื้นหลัง gradient (ใช้ list จาก AppColors ถ้ามี)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                // ถ้าโปรเจ็กต์คุณมี AppColors.primaryGradient5C ให้ใช้ได้เลย
                // ไม่ต้องใส่ stops ถ้าไม่มี AppColorStops
                colors: AppColors.primaryGradient5C,
              ),
            ),
          ),

          // ---------- CONTENT ----------
          SafeArea(
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
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Search
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x802B9CFF),
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
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.white),
                        filled: true,
                        fillColor: const Color(0x334A74A8),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.25)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.25)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(28)),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // การ์ดเนื้อหา
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(26)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFFFFFFF),
                          Color(0xFFFFFFFF),
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
                        // Pending by month
                        ..._buildSectionByMonth(
                          sectionTitle: 'Pending Approval',
                          items: pending,
                          titleColor: const Color(0xFFF5A623),
                        ),

                        const SizedBox(height: 18),

                        // Done by month
                        ..._buildSectionByMonth(
                          sectionTitle: 'Done',
                          items: done,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ===== แปะ Tile + Divider =====
  static List<Widget> _tilesWithDividers(List<ActivityItem> items) {
    final out = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      out.add(_ActivityTile(item: items[i]));
      if (i != items.length - 1) {
        out.add(const Divider(
            height: 22, thickness: 0.9, color: Color(0xFFE1E6EB)));
      }
    }
    return out;
  }
}

/// ===================== SMALL WIDGETS =====================
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
        color: Colors.black54,
        fontSize: 19,
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
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFF9AA1A9)),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final ActivityItem item;
  const _ActivityTile({required this.item});

  Color get _statusColor {
    switch (item.status) {
      case ApprovalStatus.pending:
        return const Color(0xFFF5A623); // orange
      case ApprovalStatus.approved:
        return const Color(0xFF399918); // green
      case ApprovalStatus.rejected:
        return const Color(0xFFE62727); // red
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // แถวบน
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
              const Text(' ', style: TextStyle(fontSize: 12)),
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
                  color: item.status == ApprovalStatus.approved
                      ? const Color(0xFF399918)
                      : Colors.black87,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ],
          ),

          // เหตุผลเมื่อ Rejected
          if (item.status == ApprovalStatus.rejected &&
              (item.note ?? '').isNotEmpty)
            const SizedBox(height: 4),
          if (item.status == ApprovalStatus.rejected &&
              (item.note ?? '').isNotEmpty)
            Text(
              item.note!,
              style: const TextStyle(
                color: Color(0xFFE62727),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),

          const SizedBox(height: 6),

          // แถวล่าง
          Row(
            children: [
              RichText(
                text: TextSpan(
                  text: 'Slot: ',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                  children: [
                    TextSpan(
                      text: item.slot,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                dateStr,
                style: const TextStyle(
                    color: Color(0xFF6A6F77),
                    fontWeight: FontWeight.w600,
                    fontSize: 15),
              ),
            ],
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
      'Dec'
    ];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${m[dt.month - 1]} ${dt.year} - '
        '${hour.toString().padLeft(2, '0')}:$mm $ampm';
  }
}

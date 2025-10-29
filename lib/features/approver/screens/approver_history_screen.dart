import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/theme/theme.dart';

// --------------------- MODEL ---------------------
enum DecisionStatus { approved, disapproved }

class ApproverHistoryItem {
  final DateTime dateTime; // วัน-เวลาอนุมัติ/ไม่อนุมัติ
  final DecisionStatus status; // approved | disapproved
  final String floor; // เช่น Floor5
  final String roomCode; // เช่น R501
  final String slot; // เช่น 08:00-10:00
  final String requesterName; // คนขอห้อง (อาจารย์)
  final String? remark; // หมายเหตุ/เหตุผล (โชว์เมื่อ disapproved)

  ApproverHistoryItem({
    required this.dateTime,
    required this.status,
    required this.floor,
    required this.roomCode,
    required this.slot,
    required this.requesterName,
    this.remark,
  });
}

// --------------------- PAGE ---------------------
class ApproverHistoryScreen extends StatefulWidget {
  const ApproverHistoryScreen({super.key});
  @override
  State<ApproverHistoryScreen> createState() => _ApproverHistoryScreenState();
}

class _ApproverHistoryScreenState extends State<ApproverHistoryScreen> {
  final TextEditingController _search = TextEditingController();

  // Mock data: ตัวอย่างทั้ง Oct 2025 และ Sep 2025
  final List<ApproverHistoryItem> _items = [
    // ---------- October 2025 ----------
    ApproverHistoryItem(
      dateTime: DateTime(2025, 10, 22, 8, 25),
      status: DecisionStatus.approved,
      floor: 'Floor5',
      roomCode: 'R501',
      slot: '08:00-10:00',
      requesterName: 'Mr. Adam',
    ),
    ApproverHistoryItem(
      dateTime: DateTime(2025, 10, 21, 10, 15),
      status: DecisionStatus.disapproved,
      floor: 'Floor4',
      roomCode: 'R402',
      slot: '10:00-12:00',
      requesterName: 'Ms. Bella',
      remark: 'The room is currently being renovated.',
    ),
    ApproverHistoryItem(
      dateTime: DateTime(2025, 10, 19, 7, 56),
      status: DecisionStatus.approved,
      floor: 'Floor5',
      roomCode: 'R503',
      slot: '08:00-10:00',
      requesterName: 'Mr. David',
    ),
    ApproverHistoryItem(
      dateTime: DateTime(2025, 10, 18, 14, 10),
      status: DecisionStatus.approved,
      floor: 'Floor3',
      roomCode: 'R305',
      slot: '14:00-16:00',
      requesterName: 'Dr. Grace',
    ),
    ApproverHistoryItem(
      dateTime: DateTime(2025, 10, 17, 9, 20),
      status: DecisionStatus.disapproved,
      floor: 'Floor3',
      roomCode: 'R304',
      slot: '10:00-12:00',
      requesterName: 'Mr. Ford',
      remark: 'Power maintenance scheduled.',
    ),

    // ---------- September 2025 ----------
    ApproverHistoryItem(
      dateTime: DateTime(2025, 9, 27, 7, 39),
      status: DecisionStatus.approved,
      floor: 'Floor5',
      roomCode: 'R501',
      slot: '08:00-10:00',
      requesterName: 'Mr. Ken',
    ),
    ApproverHistoryItem(
      dateTime: DateTime(2025, 9, 13, 10, 48),
      status: DecisionStatus.approved,
      floor: 'Floor4',
      roomCode: 'R408',
      slot: '10:00-12:00',
      requesterName: 'Ms. Iris',
    ),
    ApproverHistoryItem(
      dateTime: DateTime(2025, 9, 5, 9, 12),
      status: DecisionStatus.disapproved,
      floor: 'Floor4',
      roomCode: 'R407',
      slot: '09:00-11:00',
      requesterName: 'Mr. John',
      remark: 'Room under maintenance',
    ),
  ];

  // ===== Helpers: Format =====
  String _formatDateOnly(DateTime dt) {
    const m = [
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
    return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
  }

  String _formatTimeOnly(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final mm = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${h.toString().padLeft(2, '0')}:$mm $ampm';
  }

  String _monthYearLabel(DateTime dt) {
    const m = [
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
    return '${m[dt.month - 1]} ${dt.year}';
  }

  // ===== Group by Month-Year (ใหม่ → เก่า) =====
  List<MapEntry<String, List<ApproverHistoryItem>>> _groupByMonth(
    List<ApproverHistoryItem> items,
  ) {
    final map = <String, List<ApproverHistoryItem>>{};
    for (final it in items) {
      final key =
          '${it.dateTime.year}-${it.dateTime.month.toString().padLeft(2, '0')}';
      (map[key] ??= []).add(it);
    }
    for (final list in map.values) {
      list.sort(
        (a, b) => b.dateTime.compareTo(a.dateTime),
      ); // ใหม่ → เก่าในกลุ่ม
    }
    final keys = map.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // กลุ่มใหม่ → เก่า
    return [for (final k in keys) MapEntry(k, map[k]!)];
  }

  // ===== สร้าง Section บล็อกรายเดือน =====
  List<Widget> _buildSectionByMonth({
    required String sectionTitle,
    required List<ApproverHistoryItem> items,
    Color? titleColor,
  }) {
    final children = <Widget>[];

    children.add(_SectionHeader(title: sectionTitle, color: titleColor));
    children.add(const SizedBox(height: 10));

    if (items.isEmpty) {
      children.add(const _Empty(text: 'No data'));
      return children;
    }

    final groups = _groupByMonth(items);
    for (final g in groups) {
      children.add(_MonthLabel(text: _monthYearLabel(g.value.first.dateTime)));
      children.add(const SizedBox(height: 8));

      // รายการในเดือนนี้
      children.addAll(
        List<Widget>.generate(g.value.length * 2 - 1, (index) {
          if (index.isOdd) {
            return const Divider(
              height: 22,
              thickness: 0.9,
              color: Color(0xFFE1E6EB),
            );
          }
          final i = index ~/ 2;
          return _ApproverTile(item: g.value[i]);
        }),
      );

      children.add(const SizedBox(height: 12));
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    // ค้นหาจากทุกฟิลด์
    final q = _search.text.trim().toLowerCase();
    final filtered = _items.where((e) {
      if (q.isEmpty) return true;
      final hay =
          '${_formatDateOnly(e.dateTime)} ${_formatTimeOnly(e.dateTime)} '
                  '${e.floor} ${e.roomCode} ${e.slot} ${e.requesterName} '
                  '${e.status == DecisionStatus.approved ? 'approved' : 'disapproved'} '
                  '${e.remark ?? ''}'
              .toLowerCase();
      return hay.contains(q);
    }).toList()..sort((a, b) => b.dateTime.compareTo(a.dateTime)); // ใหม่ → เก่า

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
                  'Approval History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Search (แก้วใส + เงา)
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
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      filled: true,
                      fillColor: const Color(0x334A74A8),
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

              // การ์ดพื้นหลังอ่อน + โค้งด้านบน
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
                      // กลุ่มรายเดือนทั้งหมด (อนุมัติ/ไม่อนุมัติปะปน)
                      ..._buildSectionByMonth(
                        sectionTitle: 'Done by Month',
                        items:
                            filtered, // ในมุม Approver ทุกอันคือการตัดสินแล้ว
                      ),
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
}

// --------------------- SMALL WIDGETS ---------------------
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
        color: Color(0xFF9AA1A9),
        fontSize: 20,
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

// --------------------- TILE ---------------------
class _ApproverTile extends StatelessWidget {
  final ApproverHistoryItem item;
  const _ApproverTile({required this.item});

  Color get _statusColor => item.status == DecisionStatus.approved
      ? const Color(0xFF399918)
      : const Color(0xFFE62727);

  String get _statusText =>
      item.status == DecisionStatus.approved ? 'Approved' : 'Disapproved';

  @override
  Widget build(BuildContext context) {
    final dateStr = _formatDateOnly(item.dateTime);
    final timeStr = _formatTimeOnly(item.dateTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // วันที่
        Text(
          dateStr,
          style: const TextStyle(
            color: Color(0xFF9AA1A9),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),

        // สถานะ + Floor (ซ้าย) | Room code (ขวา)
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
                color: item.status == DecisionStatus.approved
                    ? const Color(0xFF399918)
                    : const Color(0xFFE62727),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        // Slot | เวลา
        Row(
          children: [
            RichText(
              text: TextSpan(
                text: 'Slot ',
                style: const TextStyle(
                  color: Color(0xFF6A6F77),
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
                children: [
                  TextSpan(
                    text: item.slot,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Text(
              timeStr,
              style: const TextStyle(
                color: Color(0xFF9AA1A9),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // ผู้ร้องขอ
        Text(
          item.requesterName,
          style: const TextStyle(
            color: Color(0xFF4A4F57),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),

        // Remark: แสดงทุกบล็อกของ disapproved
        if (item.status == DecisionStatus.disapproved) ...[
          const SizedBox(height: 8),
          Text(
            (item.remark?.isNotEmpty ?? false)
                ? item.remark!
                : '— No remark provided —',
            style: const TextStyle(
              color: Color(0xFFE62727),
              fontWeight: FontWeight.w800,
              fontSize: 16,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ],
    );
  }

  String _formatDateOnly(DateTime dt) {
    const m = [
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
    return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
  }

  String _formatTimeOnly(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final mm = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${h.toString().padLeft(2, '0')}:$mm $ampm';
  }
}

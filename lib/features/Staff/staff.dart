import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StaffHistoryPage(),
    );
  }
}

// --------------------- MODEL ---------------------
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

  final String? note; // เหตุผลเพิ่มเติม (เช่น rejected)

  ActivityItem({
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

// --------------------- STAFF PAGE ---------------------
class StaffHistoryPage extends StatefulWidget {
  const StaffHistoryPage({super.key});

  @override
  State<StaffHistoryPage> createState() => _StaffHistoryPageState();
}

class _StaffHistoryPageState extends State<StaffHistoryPage> {
  final TextEditingController _search = TextEditingController();

  // mock data (เห็นทุกคน ทั้ง Pending/Done)
  final List<ActivityItem> _items = [
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
      approvedBy: 'Dr. Jane', // reviewer (ผู้พิจารณา)
      note: 'The ceiling collapsed',
    ),
    ActivityItem(
      status: ApprovalStatus.approved,
      floor: 'Floor2',
      roomCode: 'R205',
      slot: '09:00-11:00',
      dateTime: DateTime(2025, 10, 16, 9, 12),
      requestedBy: 'Dr. Grace',
      approvedBy: 'Dean Kitti',
    ),
    ActivityItem(
      status: ApprovalStatus.approved,
      floor: 'Floor1',
      roomCode: 'R102',
      slot: '13:00-15:00',
      dateTime: DateTime(2025, 10, 15, 13, 45),
      requestedBy: 'Mr. Henry',
      approvedBy: 'Dr. Mia',
    ),
    ActivityItem(
      status: ApprovalStatus.rejected,
      floor: 'Floor2',
      roomCode: 'R207',
      slot: '10:00-12:00',
      dateTime: DateTime(2025, 10, 14, 10, 33),
      requestedBy: 'Ms. Iris',
      approvedBy: 'Dr. John',
      note: 'Room under maintenance',
    ),
    ActivityItem(
      status: ApprovalStatus.approved,
      floor: 'Floor3',
      roomCode: 'R306',
      slot: '14:00-16:00',
      dateTime: DateTime(2025, 10, 13, 14, 55),
      requestedBy: 'Mr. Ken',
      approvedBy: 'Dr. Nancy',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();

    // Search ทั้งหมด: floor, room, slot, requestedBy, approvedBy, note
    final filtered = _items.where((e) {
      if (query.isEmpty) return true;
      final hay =
          '${e.floor} ${e.roomCode} ${e.slot} ${e.requestedBy} ${(e.approvedBy ?? '')} ${(e.note ?? '')}'
              .toLowerCase();
      return hay.contains(query);
    }).toList();

    final pending = filtered.where((e) => e.status == ApprovalStatus.pending).toList();
    final done = filtered.where((e) => e.status != ApprovalStatus.pending).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime)); // newest → oldest

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          // HEADER GRADIENT (top)
          Container(
            height: 260,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2D136A), // purple
                  Color(0xFF0068CF), // blue
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 18),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Staff Activity History',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        colors: [Color(0x3340A4FF), Color(0x3340E0FF)],
                      ),
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
                        hintText: 'Search (room, floor, requester, approver, ...)',
                        hintStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.search, color: Colors.white),
                        filled: true,
                        fillColor: const Color(0x334A74A8),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.25)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.25)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // BODY CARD (rounded, light gradient)
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFF8FBFF),
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
                        const _SectionHeader(
                          title: 'Pending Approval',
                          color: Color(0xFFF5A623),
                        ),
                        const SizedBox(height: 10),
                        const _MonthLabel(text: 'October 2025'),
                        const SizedBox(height: 8),
                        if (pending.isEmpty)
                          const _Empty(text: 'No pending requests'),
                        ..._tilesWithDividers(pending, isStaff: true),

                        const SizedBox(height: 18),
                        const _SectionHeader(title: 'Done'),
                        const SizedBox(height: 10),
                        const _MonthLabel(text: 'October 2025'),
                        const SizedBox(height: 8),
                        if (done.isEmpty)
                          const _Empty(text: 'No history yet'),
                        ..._tilesWithDividers(done, isStaff: true),
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

  static List<Widget> _tilesWithDividers(List<ActivityItem> items, {required bool isStaff}) {
    final out = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      out.add(_ActivityTileStaff(item: items[i], isStaff: isStaff));
      if (i != items.length - 1) {
        out.add(const Divider(height: 22, thickness: 0.9, color: Color(0xFFE1E6EB)));
      }
    }
    return out;
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
        fontSize: 14,
        fontWeight: FontWeight.w600,
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

class _ActivityTileStaff extends StatelessWidget {
  final ActivityItem item;
  final bool isStaff;
  const _ActivityTileStaff({required this.item, required this.isStaff});

  Color get _statusColor {
    switch (item.status) {
      case ApprovalStatus.pending:
        return const Color(0xFFF05A28); // orange
      case ApprovalStatus.approved:
        return const Color(0xFF22A657); // green
      case ApprovalStatus.rejected:
        return const Color(0xFFE53935); // red
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

    // ป้ายกำกับผู้พิจารณา: Approved → "Approved by", Rejected → "Reviewed by"
    final reviewerLabel =
        item.status == ApprovalStatus.approved ? 'Approved by' : 'Reviewed by';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // บรรทัดบนสุด: สถานะ + floor + room code
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
                      ? const Color(0xFF22A657)
                      : Colors.black87,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          // บรรทัดเหตุผล (ถ้า Rejected และมี note)
          if (item.status == ApprovalStatus.rejected && (item.note ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                item.note!,
                style: const TextStyle(
                  color: Color(0xFFE53935),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          const SizedBox(height: 4),

          // บรรทัด Slot + วันที่
          Row(
            children: [
              RichText(
                text: TextSpan(
                  text: 'Slot ',
                  style: const TextStyle(
                    color: Color(0xFF6A6F77),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
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
                dateStr,
                style: const TextStyle(
                  color: Color(0xFF6A6F77),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          // ------- (S2) แสดง 2 บรรทัด: Requested by / Approved by (หรือ Reviewed by) -------
          const SizedBox(height: 6),
          Text(
            'Requested by: ${item.requestedBy}',
            style: const TextStyle(
              color: Color(0xFF4A4F57),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          if (item.status != ApprovalStatus.pending && (item.approvedBy ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                '$reviewerLabel: ${item.approvedBy!}',
                style: const TextStyle(
                  color: Color(0xFF4A4F57),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const m = [
      'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${m[dt.month - 1]} ${dt.year} - ${hour.toString().padLeft(2,'0')}:$mm $ampm';
  }
}

import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HistoryPage(),
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

// --------------------- PAGE ---------------------
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final TextEditingController _search = TextEditingController();

  // mock data
  final List<ActivityItem> _items = [
    ActivityItem(status: ApprovalStatus.pending, floor: 'Floor5', roomCode: 'R501', slot: '08:00-10:00', dateTime: DateTime(2025,10,22,7,48)),
    ActivityItem(status: ApprovalStatus.pending, floor: 'Floor4', roomCode: 'R402', slot: '10:00-12:00', dateTime: DateTime(2025,10,21,9,20)),
    ActivityItem(status: ApprovalStatus.pending, floor: 'Floor3', roomCode: 'R303', slot: '13:00-15:00', dateTime: DateTime(2025,10,20,14,10)),
    ActivityItem(status: ApprovalStatus.approved, floor: 'Floor5', roomCode: 'R501', slot: '08:00-10:00', dateTime: DateTime(2025,10,19,7,56)),
    ActivityItem(status: ApprovalStatus.approved, floor: 'Floor5', roomCode: 'R503', slot: '08:00-10:00', dateTime: DateTime(2025,10,18,8,10)),
    ActivityItem(status: ApprovalStatus.rejected, floor: 'Floor3', roomCode: 'R304', slot: '10:00-12:00', dateTime: DateTime(2025,10,17,10,48), note:'The ceiling collapsed'),
    ActivityItem(status: ApprovalStatus.approved, floor: 'Floor2', roomCode: 'R205', slot: '09:00-11:00', dateTime: DateTime(2025,10,16,9,12)),
    ActivityItem(status: ApprovalStatus.approved, floor: 'Floor1', roomCode: 'R102', slot: '13:00-15:00', dateTime: DateTime(2025,10,15,13,45)),
    ActivityItem(status: ApprovalStatus.rejected, floor: 'Floor2', roomCode: 'R207', slot: '10:00-12:00', dateTime: DateTime(2025,10,14,10,33), note: 'Room under maintenance'),
    ActivityItem(status: ApprovalStatus.approved, floor: 'Floor3', roomCode: 'R306', slot: '14:00-16:00', dateTime: DateTime(2025,10,13,14,55)),
  ];

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final filtered = _items.where((e) {
      if (query.isEmpty) return true;
      final hay = '${e.floor} ${e.roomCode} ${e.slot} ${(e.note ?? '')}'.toLowerCase();
      return hay.contains(query);
    }).toList();

    final pending = filtered.where((e) => e.status == ApprovalStatus.pending).toList();
    final done = filtered.where((e) => e.status != ApprovalStatus.pending).toList()
      ..sort((a,b) => b.dateTime.compareTo(a.dateTime)); // newest → oldest

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // พื้นหลังรอบนอกให้เข้มเหมือนภาพ
      body: Stack(
        children: [
          // ---------- TOP GRADIENT ----------
          Container(
            height: 260,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2D136A), // ม่วงเข้ม
                  Color(0xFF0068CF), // น้ำเงิน
                ],
              ),
            ),
          ),

          // ---------- CONTENT ----------
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 18),
                // Title
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Activity',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Search with glow
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
                        )
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

                // Rounded container with light gradient
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFF8FBFF), // almost white with cool tone
                          Color(0xFFEFF7FF), // very light blue bottom
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
                        // Pending
                        const _SectionHeader(
                          title: 'Pending Approval',
                          color: Color(0xFFF5A623),
                        ),
                        const SizedBox(height: 10),
                        const _MonthLabel(text: 'October 2025'),
                        const SizedBox(height: 8),
                        if (pending.isEmpty)
                          const _Empty(text: 'No pending requests'),
                        ..._tilesWithDividers(pending),

                        const SizedBox(height: 18),

                        // Done
                        const _SectionHeader(title: 'Done'),
                        const SizedBox(height: 10),
                        const _MonthLabel(text: 'October 2025'),
                        const SizedBox(height: 8),
                        if (done.isEmpty)
                          const _Empty(text: 'No history yet'),
                        ..._tilesWithDividers(done),
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

  static List<Widget> _tilesWithDividers(List<ActivityItem> items) {
    final out = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      out.add(_ActivityTile(item: items[i]));
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

class _ActivityTile extends StatelessWidget {
  final ActivityItem item;
  const _ActivityTile({required this.item});

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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
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
              const Text(
                ' ',
                style: TextStyle(fontSize: 12),
              ),
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

          if (item.status == ApprovalStatus.rejected && (item.note ?? '').isNotEmpty)
            const SizedBox(height: 4),

          if (item.status == ApprovalStatus.rejected && (item.note ?? '').isNotEmpty)
            Text(
              item.note!,
              style: const TextStyle(
                color: Color(0xFFE53935),
                fontWeight: FontWeight.w600,
              ),
            ),

          const SizedBox(height: 4),

          // Bottom row
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
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${m[dt.month - 1]} ${dt.year} - ${hour.toString().padLeft(2,'0')}:$mm $ampm';
  }
}

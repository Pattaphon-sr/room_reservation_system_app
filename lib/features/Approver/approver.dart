import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ApproverHistoryPage(),
    );
  }
}

// --------------------- MODEL ---------------------
enum DecisionStatus { approved, disapproved }

class ApproverHistoryItem {
  final DateTime dateTime;       // วัน-เวลาอนุมัติ/ไม่อนุมัติ
  final DecisionStatus status;   // approved | disapproved
  final String floor;            // เช่น Floor5
  final String roomCode;         // เช่น R501
  final String slot;             // เช่น 08:00-10:00
  final String requesterName;    // คนขอห้อง (อาจารย์)
  final String? remark;          // หมายเหตุ/เหตุผล (โชว์เมื่อ disapproved)

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
class ApproverHistoryPage extends StatefulWidget {
  const ApproverHistoryPage({super.key});
  @override
  State<ApproverHistoryPage> createState() => _ApproverHistoryPageState();
}

class _ApproverHistoryPageState extends State<ApproverHistoryPage> {
  final TextEditingController _search = TextEditingController();

  // Mock data (คุณแทนที่ด้วย DB ภายหลังได้ทันที)
  final List<ApproverHistoryItem> _items = [
    ApproverHistoryItem(
      dateTime: DateTime(2025, 10, 17, 7, 0),
      status: DecisionStatus.approved,
      floor: 'Floor5',
      roomCode: 'R501',
      slot: '08:00-10:00',
      requesterName: 'สมพงศ์ ผู้ใจ',
    ),
    ApproverHistoryItem(
      dateTime: DateTime(2025, 10, 17, 9, 20),
      status: DecisionStatus.disapproved,
      floor: 'Floor3',
      roomCode: 'R502',
      slot: '10:00-12:00',
      requesterName: 'สมพงศ์ ผู้ใจ',
      remark: 'The room is currently being renovated.',
    ),
    ApproverHistoryItem(
      dateTime: DateTime(2025, 10, 17, 7, 0),
      status: DecisionStatus.approved,
      floor: 'Floor5',
      roomCode: 'R501',
      slot: '08:00-10:00',
      requesterName: 'สมพงศ์ ผู้ใจ',
    ),
    ApproverHistoryItem(
      dateTime: DateTime(2025, 10, 17, 9, 20),
      status: DecisionStatus.disapproved,
      floor: 'Floor3',
      roomCode: 'R502',
      slot: '10:00-12:00',
      requesterName: 'สมพงศ์ ผู้ใจ',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // ค้นหาจากทุกฟิลด์ที่ผู้ใช้คาดหวัง (All)
    final q = _search.text.trim().toLowerCase();
    final filtered = _items.where((e) {
      if (q.isEmpty) return true;
      final hay =
          '${_formatDateOnly(e.dateTime)} ${_formatTimeOnly(e.dateTime)} '
          '${e.floor} ${e.roomCode} ${e.slot} ${e.requesterName} '
          '${e.status == DecisionStatus.approved ? 'approved' : 'disapprove'} '
          '${e.remark ?? ''}'
          .toLowerCase();
      return hay.contains(q);
    }).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime)); // ใหม่ → เก่า

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
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
                  Color(0xFF2D136A), // purple
                  Color(0xFF0068CF), // blue
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Approval History',
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
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.25)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.25)),
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

                // Rounded light-gradient card
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
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 22, thickness: 0.9, color: Color(0xFFE1E6EB)),
                      itemBuilder: (context, i) => _ApproverTile(item: filtered[i]),
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

  // ---- helpers ----
  String _formatDateOnly(DateTime dt) {
    const m = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
  }

  String _formatTimeOnly(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final mm = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${h.toString().padLeft(2, '0')}:$mm $ampm';
  }
}

// --------------------- TILE ---------------------
class _ApproverTile extends StatelessWidget {
  final ApproverHistoryItem item;
  const _ApproverTile({required this.item});

  Color get _statusColor =>
      item.status == DecisionStatus.approved ? const Color(0xFF22A657) : const Color(0xFFE53935);

  String get _statusText =>
      item.status == DecisionStatus.approved ? 'Approved' : 'Disapprove';

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
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),

        // บรรทัด: สถานะ + Floor | Room code (ขวา)
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
              style: const TextStyle(
                color: Color(0xFF22A657),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        // บรรทัด: Slot | เวลา
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

        // Remark (เฉพาะ disapprove + มี remark)
        if (item.status == DecisionStatus.disapproved && (item.remark ?? '').isNotEmpty) ...[
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFE1E6EB)),
          const SizedBox(height: 10),
          const Text(
            'Remark',
            style: TextStyle(
              color: Color(0xFF9AA1A9),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.remark!,
            style: const TextStyle(
              color: Color(0xFF4A4F57),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  String _formatDateOnly(DateTime dt) {
    const m = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
  }

  String _formatTimeOnly(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final mm = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${h.toString().padLeft(2, '0')}:$mm $ampm';
  }
}

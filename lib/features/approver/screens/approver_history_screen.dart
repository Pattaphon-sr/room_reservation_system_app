import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/theme/theme.dart';
import 'package:room_reservation_system_app/features/approver/service.dart'; // ✅ เพิ่มบรรทัดนี้

// --------------------- MODEL ---------------------
enum DecisionStatus { approved, disapproved }

class ApproverHistoryItem {
  final DateTime dateTime;
  final DecisionStatus status;
  final String floor;
  final String roomCode;
  final String slot;
  final String requesterName;
  final String? remark; // ต้องมีเมื่อ disapproved

  ApproverHistoryItem({
    required this.dateTime,
    required this.status,
    required this.floor,
    required this.roomCode,
    required this.slot,
    required this.requesterName,
    this.remark,
  }) : assert(
         status == DecisionStatus.approved ||
             (remark != null && remark.trim().isNotEmpty),
         'Disapproved items must include a non-empty remark.',
       );
}

// --------------------- PAGE ---------------------
class ApproverHistoryScreen extends StatefulWidget {
  const ApproverHistoryScreen({super.key});
  @override
  State<ApproverHistoryScreen> createState() => _ApproverHistoryScreenState();
}

class _ApproverHistoryScreenState extends State<ApproverHistoryScreen> {
  final TextEditingController _search = TextEditingController();
  final ApproverHistoryService _service =
      ApproverHistoryService(); // ✅ เพิ่ม service

  List<ApproverHistoryItem> _items = []; // ✅ เปลี่ยนจาก final เป็น var
  // ignore: unused_field
  bool _isLoading = true; // ✅ เพิ่ม loading state
  // ignore: unused_field
  String? _errorMessage; // ✅ เพิ่ม error state

  @override
  void initState() {
    super.initState();
    _loadHistory(); // ✅ โหลดข้อมูลตอนเปิดหน้า
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await _service.fetchHistory();
      setState(() {
        _items = items;
        _isLoading = false;
      });
      print('✅ Loaded ${items.length} items');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      print('❌ Error: $e');
    }
  }
  final List<ApproverHistoryItem> connected_api_items = [];

  // ===== Helpers: format =====
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

  // Group by month-year (new → old)  [ใช้กับบล็อกแบบรวม]

  // Group by month-year (old → new) [ใช้ทำ TabBar ให้ Sep อยู่ซ้าย Oct อยู่ขวา]
  List<MapEntry<String, List<ApproverHistoryItem>>> _groupByMonthAsc(
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
      ); // ในเดือน: ใหม่ → เก่า
    }
    final keys = map.keys.toList()
      ..sort((a, b) => a.compareTo(b)); // เดือน: เก่า → ใหม่
    return [for (final k in keys) MapEntry(k, map[k]!)];
  }

  // บล็อกแบบรวมรายเดือน (ยังเก็บไว้ เผื่อใช้)

  // เนื้อหา "หนึ่งแท็บของเดือน" (แยก Approved / Rejected)
  List<Widget> _buildOneMonthTabBody(List<ApproverHistoryItem> monthItems) {
    final approved =
        monthItems.where((e) => e.status == DecisionStatus.approved).toList()
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    final rejected =
        monthItems.where((e) => e.status == DecisionStatus.disapproved).toList()
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    List<Widget> tiles(List<ApproverHistoryItem> list) => List<Widget>.generate(
      list.isEmpty ? 1 : (list.length * 2 - 1),
      (index) {
        if (list.isEmpty) return SizedBox.shrink();
        if (index.isOdd) {
          return const Divider(
            height: 22,
            thickness: 0.9,
            color: Color(0xFFE1E6EB),
          );
        }
        final i = index ~/ 2;
        return _ApproverTile(item: list[i]);
      },
    );

    return [
      // const Text(
      //   'Approved',
      //   style: TextStyle(color: Colors.black54, fontSize: 17, fontWeight: FontWeight.w700),
      // ),
      const SizedBox(height: 10),
      ...tiles(approved),

      // const SizedBox(height: 24),
      // const Divider(height: 0, thickness: 0.8, color: Color(0xFFE1E6EB)),
      // const SizedBox(height: 18),

      // const Text(
      //   'Rejected',
      //   style: TextStyle(color: Colors.black54, fontSize: 17, fontWeight: FontWeight.w700),
      // ),
      const SizedBox(height: 5),
      ...tiles(rejected),

      const SizedBox(height: 12),
    ];
  }

  @override
  Widget build(BuildContext context) {
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
    }).toList()..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    // กลุ่มสำหรับแท็บ (เก่า → ใหม่)
    final tabGroups = _groupByMonthAsc(filtered);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          // Gradient พื้นหลังจาก theme
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.primaryGradient5C,
                stops: AppColorStops.primaryStop5C,
              ),
            ),
          ),
          SafeArea(
            child: DefaultTabController(
              length: tabGroups.length,
              // ถ้าอยากเริ่มที่เดือนล่าสุด ให้ใช้ initialIndex: tabGroups.length - 1,
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

                  // ===== TabBar =====
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
                          colors: [
                            Color.fromARGB(255, 255, 255, 255),
                            Color.fromARGB(255, 255, 255, 255),
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
                      child: TabBarView(
                        children: [
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
                                    Color.fromARGB(255, 255, 255, 255),
                                    Color.fromARGB(255, 255, 255, 255),
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
                              child: TabBarView(
                                children: [
                                  for (final g in tabGroups)
                                    RefreshIndicator(
                                      onRefresh: _loadHistory,
                                      child: ListView(
                                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                                        children: _buildOneMonthTabBody(g.value),
                                      ),
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
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------- SMALL WIDGETS ---------------------
// ignore: unused_element
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

// ignore: unused_element
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
      item.status == DecisionStatus.approved ? 'Approved' : 'Rejected';

  @override
  Widget build(BuildContext context) {
    final dateStr = _formatDateOnly(item.dateTime);
    _formatTimeOnly(item.dateTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),

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
                color: item.status == DecisionStatus.approved
                    ? const Color(0xFF399918)
                    : const Color(0xFFE62727),
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ],
        ),

        if (item.status == DecisionStatus.disapproved) ...[
          const SizedBox(height: 6),
          Text(
            item.remark!, // รับรองไม่ null จาก assert
            style: const TextStyle(
              color: Color(0xFFE62727),
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],

        const SizedBox(height: 6),

        Row(
          children: [
            RichText(
              text: TextSpan(
                text: 'Slot: ',
                style: const TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
                children: [
                  TextSpan(
                    text: item.slot,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
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
                fontSize: 15,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        Row(
          children: [
            const Text(
              'Requested by: ',
              style: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
            Text(
              item.requesterName,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w400,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDateOnly(DateTime dt) {
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

  String _formatTimeOnly(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${hour.toString().padLeft(2, '0')}:$mm $ampm';
  }
}

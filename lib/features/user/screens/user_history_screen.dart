import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/theme/theme.dart';
import 'package:room_reservation_system_app/features/user/service.dart';

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
  final UserHistoryService _service = UserHistoryService(); // เพิ่ม

  List<ActivityItem> _items = []; // เปลี่ยนจาก final
  bool _isLoading = true; // เพิ่ม loading state
  String? _errorMessage; // เพิ่ม error message

  @override
  void initState() {
    super.initState();
    _loadHistory(); // เรียกตอน init
  }

  /// ดึงข้อมูลจาก API
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
        _isLoading = false;
        _errorMessage = e.toString();
      });
      print('❌ Error: $e');
    }
  }

  /// ============ Group by Month-Year (เก่า → ใหม่) ============
  List<MapEntry<String, List<ActivityItem>>> _groupByMonth(
    List<ActivityItem> items,
  ) {
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

    // sort เดือน (เก่า → ใหม่)  << เพื่อให้ Sep อยู่ซ้าย Oct อยู่ขวา >>
    final keys = map.keys.toList()..sort((a, b) => a.compareTo(b));
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
      'December',
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppColors.primaryGradient5C,
                ),
              ),
            ),
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          ],
        ),
      );
    }

    // ✅ แสดง Error
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppColors.primaryGradient5C,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Error: $_errorMessage',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadHistory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    final q = _search.text.trim().toLowerCase();

    // ✅ Filter + กรองเฉพาะ approved และ rejected
    final filtered = _items.where((e) {
      // กรองออก pending
      if (e.status == ApprovalStatus.pending) return false;

      // Search filter
      if (q.isEmpty) return true;
      final hay = '${e.floor} ${e.roomCode} ${e.slot} ${(e.note ?? '')}'
          .toLowerCase();
      return hay.contains(q);
    }).toList();

    final groups = _groupByMonth(filtered);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.primaryGradient5C,
              ),
            ),
          ),

          SafeArea(
            child: DefaultTabController(
              length: groups.length,
              initialIndex: (groups.length - 1 < 0) ? 0 : groups.length - 1,
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
                        for (final g in groups)
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
                      child: (groups.isEmpty)
                          ? Center(child: _Empty(text: 'No history found.'))
                          : TabBarView(
                              children: [
                                for (final g in groups)
                                  // ✅ เพิ่ม RefreshIndicator
                                  RefreshIndicator(
                                    onRefresh: _loadHistory,
                                    child: ListView(
                                      padding: const EdgeInsets.fromLTRB(
                                        20,
                                        20,
                                        20,
                                        28,
                                      ),
                                      children: () {
                                        final monthItems = g.value;

                                        final done =
                                            monthItems
                                                .where(
                                                  (e) =>
                                                      e.status !=
                                                      ApprovalStatus.pending,
                                                )
                                                .toList()
                                              ..sort(
                                                (a, b) => b.dateTime.compareTo(
                                                  a.dateTime,
                                                ),
                                              );

                                        return [
                                          // const SizedBox(height: 24),
                                          // const Divider(height: 0, thickness: 0.8, color: Color(0xFFE1E6EB)),
                                          // const SizedBox(height: 18),

                                          // _SectionHeader(title: 'Done'),
                                          // const SizedBox(height: 10),
                                          if (done.isNotEmpty)
                                            ...() {
                                              final widgets = <Widget>[];
                                              for (
                                                var i = 0;
                                                i < done.length;
                                                i++
                                              ) {
                                                widgets.add(
                                                  _ActivityTile(item: done[i]),
                                                );
                                                if (i != done.length - 1) {
                                                  widgets.add(
                                                    const Divider(
                                                      height: 22,
                                                      thickness: 0.9,
                                                      color: Color(0xFFE1E6EB),
                                                    ),
                                                  );
                                                }
                                              }
                                              return widgets;
                                            }(),

                                          const SizedBox(height: 12),
                                        ];
                                      }(),
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

/// ===== Widgets ย่อย =====
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
        fontSize: 28,
        fontWeight: FontWeight.w800,
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
      child: Text(text, style: const TextStyle(color: Color(0xFF9AA1A9))),
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
                  fontSize: 15,
                ),
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
      'Dec',
    ];
    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${m[dt.month - 1]} ${dt.year} - ${hour12.toString().padLeft(2, '0')}:$mm $ampm';
  }
}

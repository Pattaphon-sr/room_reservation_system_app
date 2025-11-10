import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:room_reservation_system_app/core/network/api_client.dart';
import 'package:room_reservation_system_app/core/theme/theme.dart';
import 'package:room_reservation_system_app/services/auth_service.dart';
// import 'package:room_reservation_system_app/features/user/service.dart';
//import 'package:room_reservation_system_app/services/history/user_history_service.dart';
// ignore: unused_import
import 'package:room_reservation_system_app/services/history_servise/user_history_service.dart';

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
class UserHistoryDio extends StatefulWidget {
  const UserHistoryDio({Key? key}) : super(key: key);
  @override
  State<UserHistoryDio> createState() => _UserHistoryDioState();
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class _UserHistoryDioState extends State<UserHistoryDio> with RouteAware {
  final TextEditingController _search = TextEditingController();
  final Dio _dio = ApiClient().dio;

  List<ActivityItem> _items = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Replace these with your actual user info
  // final String? meId = null; // TODO: set user id
  // final String? meUser = null; // TODO: set username

  // ตัวอย่างการดึงข้อมูลจาก AuthService (แก้ให้ตรงกับโปรเจคจริง)
  String? get meId => AuthService.instance.payload?['id']?.toString();
  String? get meUser => AuthService.instance.payload?['username']?.toString();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Register route observer correctly
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    // Unregister route observer correctly
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when returning to this screen (e.g. after approve/reject)
    _loadHistory();
  }

  // ...existing code...
  /// ดึงข้อมูลจาก API ด้วย Dio
  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _dio.get(
        '/reservations/history',
        queryParameters: {
          if (meId != null) 'requested_by_id': meId,
          if (meUser != null) 'requested_by': meUser,
          'me': 1,
        },
      );
      final List data = res.data as List;

      // เพิ่มฟังก์ชันกรองข้อมูลของ user ที่ล็อกอิน
      List mineOnly = data.where((json) {
        final by = json['requested_by']?.toString();
        final byId = json['requested_by_id']?.toString();
        return (meId != null && byId == meId) || (meUser != null && by == meUser);
      }).toList();

      final items = mineOnly
          .map<ActivityItem>((json) {
            return ActivityItem(
              status: _parseStatus(json['status']),
              floor: json['floor'] ?? '',
              roomCode: json['room_code'] ?? '',
              slot: json['slot'] ?? '',
              dateTime: DateTime.parse(json['date_time']),
              note: json['note'],
            );
          })
          .where((item) => item.status != ApprovalStatus.pending)
          .toList();

      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }
// ...existing code...

  ApprovalStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return ApprovalStatus.pending;
      case 'approved':
      case 'approve':
      case 'reserved':
      case 'success':
      case 'done':
      case 'accept':
      case 'pass':
        return ApprovalStatus.approved;
      case 'rejected':
      case 'disapproved':
      case 'fail':
      case 'denied':
        return ApprovalStatus.rejected;
      default:
        return ApprovalStatus.pending;
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
    // เฉพาะผู้ใช้ที่มีการจองห้องและได้รับการ approved หรือ rejected เท่านั้นถึงจะมีประวัติ
    // ถ้าเป็นผู้ใช้ใหม่ที่ยังไม่เคยจอง จะไม่มีข้อมูลในหน้านี้
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
                            child: filtered.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No history found',
                                      style: TextStyle(
                                        color: Color(0xFF9AA1A9),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  )
                                : groups.isEmpty
                                    ? const Center(
                                        child: _Empty(
                                          text: 'ยังไม่มีประวัติการจอง\n(จะมีข้อมูลหลังได้รับการอนุมัติหรือถูกปฏิเสธการจองห้อง)',
                                        ),
                                      )
                                    : TabBarView(
                                        children: [
                                          for (final g in groups)
                                            RefreshIndicator(
                                              onRefresh: _loadHistory,
                                              child: ListView(
                                                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                                                children: () {
                                                  final monthItems = g.value;
                                                  final done = monthItems
                                                      .where((e) => e.status != ApprovalStatus.pending)
                                                      .toList()
                                                    ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
                                                  return [
                                                    if (done.isNotEmpty)
                                                      ...() {
                                                        final widgets = <Widget>[];
                                                        for (var i = 0; i < done.length; i++) {
                                                          widgets.add(_ActivityTile(item: done[i]));
                                                          if (i != done.length - 1) {
                                                            widgets.add(const Divider(
                                                              height: 22,
                                                              thickness: 0.9,
                                                              color: Color(0xFFE1E6EB),
                                                            ));
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
// ignore: unused_element
class _SectionHeader extends StatelessWidget {
  final String title;
  final Color? color;
  // ignore: unused_element_parameter
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

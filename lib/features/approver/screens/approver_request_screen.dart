// 1. IMPORTs ที่จำเป็น (สำหรับ API, Date Formatting, และ AuthService)
import 'dart:async'; // ⭐️ [NEW] เพิ่ม Timer
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:room_reservation_system_app/core/config/env.dart';
import 'package:room_reservation_system_app/services/auth_service.dart';
// ------------------------------

import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/theme/theme.dart';
import 'package:room_reservation_system_app/shared/widgets/widgets.dart';

class ApproverRequestScreen extends StatefulWidget {
  const ApproverRequestScreen({super.key});

  @override
  State<ApproverRequestScreen> createState() => _ApproverRequestScreenState();
}

class _ApproverRequestScreenState extends State<ApproverRequestScreen> {
  final TextEditingController _search = TextEditingController();

  final String _apiBaseUrl = '${Env.baseUrl}/api';

  // 3. ปรับปรุง STATE
  String? _token; 
  bool _isLoading = true; 
  List<Map<String, dynamic>> _requests = []; 

  // ⭐️ [NEW] ตัวแปรสำหรับเก็บ Timer
  Timer? _pollingTimer;

  Map<String, String> get _authHeaders => {
    'Authorization': 'Bearer $_token',
    'Content-Type': 'application/json',
  };

  // 4. [AUTO-LOAD]
  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchData();
  }

  // ⭐️ [NEW] เพิ่ม dispose() เพื่อหยุด Timer
  @override
  void dispose() {
    _pollingTimer?.cancel(); // ⬅️ หยุด Timer ตอนปิดหน้า
    _search.dispose();
    super.dispose();
  }


  // 5. [MODIFIED] แก้ไขฟังก์ชัน "อ่าน Token" ให้เริ่ม Polling
  Future<void> _loadTokenAndFetchData() async {
    final String? loadedToken = AuthService.instance.token;

    if (loadedToken == null) {
      print("No token found. User is not logged in.");
      setState(() { _isLoading = false; });
      return;
    }

    setState(() { _token = loadedToken; });

    // 1. ดึงข้อมูลครั้งแรก (โชว์วงกลมหมุน)
    await _fetchReservations(showLoading: true);

    // 2. เริ่มยิง API ทุก 3 วิ (หลังจากโหลดครั้งแรกเสร็จ)
    _startPolling();
  }

  // ⭐️ [NEW] ฟังก์ชันสำหรับ "เริ่ม" Timer
  void _startPolling() {
    _pollingTimer?.cancel(); // เคลียร์ Timer เก่า (ถ้ามี)
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) {
        timer.cancel(); // ถ้าหน้าปิดไปแล้ว ให้หยุด
        return;
      }
      // ยิง API แบบเงียบๆ (ไม่โชว์วงกลมหมุน)
      _fetchReservations(showLoading: false);
    });
  }


  // 6. ⭐️ [MODIFIED] แก้ไข _fetchReservations ให้รองรับ "Silent Refresh"
  Future<void> _fetchReservations({bool showLoading = false}) async {
    if (_token == null) {
      print("Token is not loaded yet.");
      return;
    }

    // ถ้าถูกสั่งให้โชว์ Loading (เช่น โหลดครั้งแรก) และยังไม่ได้ Loading อยู่
    if (showLoading && !_isLoading) {
      setState(() { _isLoading = true; });
    }

    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/reservations'),
        headers: _authHeaders, 
      );
      
      if (!mounted) return; // ⬅️ Safety Check!

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          _requests = data.map((item) {
            final createdAt = DateTime.parse(item['created_at']);
            return {
              'reservation_id': item['reservation_id'], 
              'date': DateFormat('d MMMM yyyy').format(createdAt),
              'floor': 'Floor${item['floor']}',
              'room': 'R${item['room_no']}',
              'slot': 'Slot ${item['slot']}',
              'time': DateFormat('hh:mm a').format(createdAt), 
              'name': item['requested_by_username'],
            };
          }).toList();
          
          if (_isLoading) {
            _isLoading = false; // ⬅️ ปิดวงกลมหมุน (ถ้ามันเปิดอยู่)
          }
        });
      } else {
        print('Failed to load reservations: ${response.statusCode}');
        if (_isLoading) setState(() { _isLoading = false; });
      }
    } catch (e) {
      print('Error fetching reservations: $e');
      if (mounted && _isLoading) setState(() { _isLoading = false; });
    }
  }

  // ⭐️ [MODIFIED] แก้ไข Approve/Reject ให้รีเฟรชทันที
  Future<void> _approveRequest(dynamic reservationId) async {
    if (_token == null) return; 
    try {
      final response = await http.put(
        Uri.parse('$_apiBaseUrl/reservations/$reservationId/approve'),
        headers: _authHeaders,
      );
      Navigator.of(context, rootNavigator: true).pop();
      if (response.statusCode == 200) {
        _showApproveSuccessDialog(context);
        await _fetchReservations(showLoading: false); // ⬅️ รีเฟรชทันที (แบบเงียบ)
      } else {
        print('Failed to approve: ${response.statusCode}');
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      print('Error approving: $e');
    }
  }

  Future<void> _rejectRequest(dynamic reservationId, String note) async {
    if (_token == null) return; 
    try {
      final response = await http.put(
        Uri.parse('$_apiBaseUrl/reservations/$reservationId/reject'), 
        headers: _authHeaders,
        body: jsonEncode({'note': note}),
      );
      Navigator.of(context, rootNavigator: true).pop();
      if (response.statusCode == 200) {
        _showDisapproveSuccessDialog(context);
        await _fetchReservations(showLoading: false); // ⬅️ รีเฟรชทันที (แบบเงียบ)
      } else {
        print('Failed to reject: ${response.statusCode}');
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      print('Error rejecting: $e');
    }
  }

  // ================== SEARCH FILTER ==================
  // (เหมือนเดิม)
  List<Map<String, dynamic>> get _filteredRequests {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return _requests;
    return _requests.where((e) {
      final hay =
          '${e['reservation_id']} ${e['date']} ${e['floor']} ${e['room']} ${e['slot']} ${e['time']} ${e['name']} }'
              .toLowerCase();
      return hay.contains(q);
    }).toList();
  }

  // ================== APPROVE DIALOGS ==================
  
  // ⭐️ [FIXED] เปลี่ยนจาก int เป็น dynamic
  Future<void> _showApproveConfirmDialog(
    BuildContext context,
    dynamic reservationId, // ⬅️ แก้ไข
  ) async {
    await showAirDialog(
      height: 333,
      context,
      title: null,
      content: IntrinsicHeight(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.help_outline, color: Colors.white, size: 72),
            SizedBox(height: 24),
            Text(
              "Are you sure you want to approve this request?",
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 28),
            AppButton.solid(
              label: 'Confirm',
              onPressed: () {
                _approveRequest(reservationId);
              },
            ),
            const SizedBox(height: 12),
            AppButton.outline(
              label: 'Cancel',
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showApproveSuccessDialog(BuildContext context) async {
    // (เหมือนเดิม)
  }

  // ================== DISAPPROVE DIALOGS ==================
  
  // ⭐️ [FIXED] เปลี่ยนจาก int เป็น dynamic
  Future<void> _showDisapproveReasonDialog(
    BuildContext context,
    dynamic reservationId, // ⬅️ แก้ไข
  ) async {
    final TextEditingController reasonController = TextEditingController();
    await showAirDialog(
      height: 333,
      context,
      title: null,
      content: IntrinsicHeight(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Please provide reason",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              style: const TextStyle(color: Colors.black54),
              decoration: InputDecoration(
                hintText: 'Comment...',
                hintStyle: const TextStyle(color: Colors.black54),
                filled: true,
                fillColor: Colors.white.withOpacity(0.80),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.white54),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 28),
            AppButton.solid(
              label: 'Submit',
              onPressed: () {
                final String note = reasonController.text.trim();
                _rejectRequest(reservationId, note);
              },
            ),
            const SizedBox(height: 12),
            AppButton.outline(
              label: 'Cancel',
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showDisapproveSuccessDialog(BuildContext context) async {
    // (เหมือนเดิม)
  }

  // ================== BUILD ==================
  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRequests;

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
              // ... (ส่วน Title และ Search Bar เหมือนเดิม)
              const SizedBox(height: 32),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Room Request',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
              const SizedBox(height: 20),

              // 8. อัปเดต List View
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : filtered.isEmpty
                        ? const Center(
                            child: Text(
                              'No pending requests found.',
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              
                              // ⭐️ [FIXED] เปลี่ยนจาก int เป็น dynamic
                              final dynamic reservationId = item['reservation_id'];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 18),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ⭐️ [FIXED] ใช้ ?? '...' เพื่อป้องกัน null
                                    Text(
                                      item['date']?.toString() ?? 'No Date',
                                      style: const TextStyle(
                                        color: Color(0xFF4A4A4A),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item['floor']?.toString() ?? 'N/A',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          item['room']?.toString() ?? 'N/A',
                                          style: const TextStyle(
                                            color: Color(0xFF00B35A),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item['slot']?.toString() ?? 'No Slot',
                                          style: const TextStyle(
                                            color: Color(0xFF7A7A7A),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          item['time']?.toString() ?? '',
                                          style: const TextStyle(
                                            color: Color(0xFF00B35A),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item['name']?.toString() ?? 'Unknown User',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 130,
                                          height: 44,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.redAccent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                  12,
                                                ),
                                              ),
                                            ),
                                            onPressed: () =>
                                                _showDisapproveReasonDialog(
                                              context,
                                              reservationId,
                                            ),
                                            child: const Text(
                                              'Disapprove',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        SizedBox(
                                          width: 130,
                                          height: 44,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.teal,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                  12,
                                                ),
                                              ),
                                            ),
                                            onPressed: () =>
                                                _showApproveConfirmDialog(
                                              context,
                                              reservationId,
                                            ),
                                            child: const Text(
                                              'Approve',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
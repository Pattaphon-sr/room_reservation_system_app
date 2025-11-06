// 1. IMPORTs ที่จำเป็น (สำหรับ API, Date Formatting, และ AuthService)
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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

  // 2. กำหนดค่า API
  // ⚠️ ต้องตรงกับที่ AuthService ใช้ (10.0.2.2 คือ localhost สำหรับ Android)
  final String _apiBaseUrl = 'http://localhost:3000/api'; 
  
  // 3. ปรับปรุง STATE
  String? _token; // ตัวแปรสำหรับเก็บ Token ที่ "อ่าน" มาได้
  bool _isLoading = true; // เริ่มต้นที่ "กำลังโหลด"
  List<Map<String, dynamic>> _requests = []; // รายการคำขอจาก Database

  // Helper สำหรับสร้าง Headers (จะใช้ _token จาก State)
  Map<String, String> get _authHeaders => {
    'Authorization': 'Bearer $_token',
    'Content-Type': 'application/json',
  };

  // 4. [AUTO-LOAD]
  @override
  void initState() {
    super.initState();
    // เรียกฟังก์ชัน "อ่าน Token" และ "ดึงข้อมูล" ทันที
    _loadTokenAndFetchData(); 
  }
  
  // 5. [AUTO-LOAD] ฟังก์ชัน "อ่าน Token"
  Future<void> _loadTokenAndFetchData() async {
    // "อ่าน" Token จาก AuthService
    final String? loadedToken = await AuthService.instance.getToken();

    if (loadedToken == null) {
      // ถ้าไม่มี Token (เช่น ยังไม่ Login หรือ Token หมดอายุ)
      print("No token found. User is not logged in.");
      setState(() { _isLoading = false; });
      // ⚠️ ที่จริงตรงนี้ควรเด้งกลับไปหน้า Login
      // Navigator.of(context).pushAndRemoveUntil(...)
      return;
    }

    // ✅ ถ้ามี Token, เก็บไว้ใน State
    setState(() {
      _token = loadedToken; 
    });

    // ค่อยเรียก API ดึงข้อมูล
    await _fetchReservations();
  }
  
  // 6. ฟังก์ชันสำหรับเรียก API (GET, PUT, PUT)

  Future<void> _fetchReservations() async {
    // ป้องกันการยิง API ถ้ายังไม่มี Token
    if (_token == null) {
       print("Token is not loaded yet.");
       return; 
    }
    
    // ไม่ต้อง setState(true) ซ้ำซ้อน ถ้า _loadTokenAndFetchData เรียก
    // แต่ถ้าจะทำ pull-to-refresh ในอนาคต ให้เปิดบรรทัดนี้
    // setState(() { _isLoading = true; });

    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/reservations'),
        headers: _authHeaders, // ⬅️ ใช้ Token ที่อ่านมาได้
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        // แปลงข้อมูล API ให้ตรงกับที่ UI ต้องการ
        setState(() {
          _requests = data.map((item) {
            final createdAt = DateTime.parse(item['created_at']);
            return {
              'reservation_id': item['reservation_id'], // รับมาแบบ dynamic
              'date': DateFormat('d MMMM yyyy').format(createdAt),
              'floor': 'Floor${item['floor']}',
              'room': 'R${item['room_no']}',
              'slot': 'Slot ${item['slot']}',
              'time': DateFormat('hh:mm a').format(createdAt), // เวลาที่ส่งคำขอ
              'name': item['requested_by_username'],
            };
          }).toList();
          _isLoading = false; // ⬅️ โหลดเสร็จแล้ว
        });
      } else {
        // จัดการ Error (เช่น 401, 403)
        print('Failed to load reservations: ${response.statusCode}');
        setState(() { _isLoading = false; });
      }
    } catch (e) {
      // จัดการ Error (เช่น Network error)
      print('Error fetching reservations: $e');
      setState(() { _isLoading = false; });
    }
  }

  // ⭐️ 8. ปรับฟังก์ชัน Approve/Reject ให้เช็ค Token ก่อน (เพื่อความปลอดภัย)
  Future<void> _approveRequest(dynamic reservationId) async {
    if (_token == null) return; // ⬅️ ถ้า Token ไม่มี ก็ไม่ต้องทำ
    try {
      final response = await http.put(
        Uri.parse('$_apiBaseUrl/reservations/$reservationId/approve'), // ⬅️ แก้ไขตรงนี้
        headers: _authHeaders,
      );
      Navigator.of(context, rootNavigator: true).pop(); 
      if (response.statusCode == 200) {
        _showApproveSuccessDialog(context);
        await _fetchReservations(); 
      } else {
        print('Failed to approve: ${response.statusCode}');
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      print('Error approving: $e');
    }
  }

  Future<void> _rejectRequest(dynamic reservationId, String note) async {
    if (_token == null) return; // ⬅️ ถ้า Token ไม่มี ก็ไม่ต้องทำ
    try {
      final response = await http.put(
        Uri.parse('$_apiBaseUrl/reservations/$reservationId/reject'), // ⬅️ แก้ไขตรงนี้
        headers: _authHeaders,
        body: jsonEncode({'note': note}), 
      );
      Navigator.of(context, rootNavigator: true).pop(); 
      if (response.statusCode == 200) {
        _showDisapproveSuccessDialog(context);
        await _fetchReservations();
      } else {
        print('Failed to reject: ${response.statusCode}');
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      print('Error rejecting: $e');
    }
  }

  // ================== SEARCH FILTER ==================
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
  // 6. อัปเดต Dialogs ให้รับ ID และเรียก API
  Future<void> _showApproveConfirmDialog(
    BuildContext context,
    int reservationId,
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
                // ⚠️ เรียก API ที่นี่
                _approveRequest(reservationId);
                // (ตัวฟังก์ชัน _approveRequest จะ pop dialog นี้เอง)
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
    // ... (โค้ดส่วนนี้เหมือนเดิม ไม่ต้องแก้)
    await showAirDialog(
      height: 300,
      context,
      title: null,
      content: IntrinsicHeight(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle, size: 68, color: Colors.lightGreenAccent),
            SizedBox(height: 24),
            Text(
              "Success!",
              style: TextStyle(
                color: Colors.lightGreenAccent,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Approved",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
      actions: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 28),
            Center(
              child: SizedBox(
                width: 120,
                child: AppButton.solid(
                  label: 'Close',
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ================== DISAPPROVE DIALOGS ==================
  // 7. อัปเดต Dialogs ให้รับ ID และเรียก API
  Future<void> _showDisapproveReasonDialog(
    BuildContext context,
    int reservationId,
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
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Comment...',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
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
                // ⚠️ เรียก API ที่นี่
                final String note = reasonController.text.trim();
                _rejectRequest(reservationId, note);
                // (ตัวฟังก์ชัน _rejectRequest จะ pop dialog นี้เอง)
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
    // ... (โค้ดส่วนนี้เหมือนเดิม ไม่ต้องแก้)
    await showAirDialog(
      height: 300,
      context,
      title: null,
      content: IntrinsicHeight(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle, size: 68, color: Colors.lightGreenAccent),
            SizedBox(height: 24),
            Text(
              "Success!",
              style: TextStyle(
                color: Colors.lightGreenAccent,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Disapproved",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
      actions: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 28),
            Center(
              child: SizedBox(
                width: 120,
                child: AppButton.solid(
                  label: 'Close',
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
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
                // ... (Search Bar - ไม่ต้องแก้)
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
                          final int reservationId = item['reservation_id'];

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
                                Text(
                                  item['date']!,
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
                                      item['floor']!,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      item['room']!,
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
                                      item['slot']!,
                                      style: const TextStyle(
                                        color: Color(0xFF7A7A7A),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      item['time']!,
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
                                  item['name']!,
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

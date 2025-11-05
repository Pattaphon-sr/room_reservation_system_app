// ⭐️ 1. IMPORT
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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

  final String _baseUrl = 'http://localhost:3000/api'; 

  // ⭐️ 2. เอา Token ที่ Hardcode ออก
  // final String _token = 'YOUR_APPROVER_TOKEN_HERE'; // ⬅️ ลบทิ้ง
  String? _token; // ⬅️ เปลี่ยนเป็นตัวแปร State (Nullable)

  Map<String, String> get _authHeaders => {
    // ⭐️ 3. Header จะดึง Token จาก State
    'Authorization': 'Bearer $_token', 
    'Content-Type': 'application/json',
  };

  bool _isLoading = true;
  List<Map<String, dynamic>> _requests = []; 

  @override
  void initState() {
    super.initState();
    // ⭐️ 4. เปลี่ยนฟังก์ชันที่เรียกตอนเริ่ม
    // _fetchReservations(); // ⬅️ ไม่เรียกอันนี้ตรงๆ แล้ว
    _loadTokenAndFetchData(); // ⬅️ เรียกฟังก์ชันใหม่ที่ "อ่าน" Token ก่อน
  }
  
  // ⭐️ 5. ฟังก์ชันใหม่สำหรับ "อ่าน" Token
  Future<void> _loadTokenAndFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? loadedToken = prefs.getString('token'); // ⬅️ อ่าน Token จากเครื่อง

    if (loadedToken == null) {
      // ❌ ถ้าไม่มี Token (เช่น โดนลบ หรือยังไม่ Login)
      // ⚠️ ควรเด้งกลับไปหน้า Login
      print("No token found. User is not logged in.");
      setState(() { _isLoading = false; });
      // (ตัวอย่าง: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen())));
      return;
    }

    // ✅ ถ้ามี Token, เก็บไว้ใน State แล้วค่อยเรียก API
    setState(() {
      _token = loadedToken; // ⬅️ เก็บ Token ที่อ่านได้ไว้ใน State
    });

    // ⭐️ 6. ค่อยเรียก fetch ข้อมูล
    await _fetchReservations();
  }

  // ⭐️ 7. ปรับ _fetchReservations ให้ใช้ Token จาก State
  Future<void> _fetchReservations() async {
    if (_token == null) {
      print("Token is not loaded yet.");
      return; 
    }
    
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/reservations'),
        headers: _authHeaders, // ⬅️ _authHeaders จะดึง _token จาก State อัตโนมัติ
      );

      // (.... ที่เหลือเหมือนเดิม ....)
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
          _isLoading = false;
        });
      } else {
        print('Failed to load reservations: ${response.statusCode}');
        setState(() { _isLoading = false; });
      }
    } catch (e) {
      print('Error fetching reservations: $e');
      setState(() { _isLoading = false; });
    }
  }

  // ⭐️ 8. ปรับฟังก์ชัน Approve/Reject ให้เช็ค Token ก่อน (เพื่อความปลอดภัย)
  Future<void> _approveRequest(dynamic reservationId) async {
    if (_token == null) return; // ⬅️ ถ้า Token ไม่มี ก็ไม่ต้องทำ
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/reservations/$reservationId/approve'),
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
        Uri.parse('$_baseUrl/reservations/$reservationId/reject'),
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

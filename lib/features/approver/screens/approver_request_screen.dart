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

  final List<Map<String, String>> _requests = [
    {
      'date': '17 October 2025',
      'floor': 'Floor5',
      'room': 'R501',
      'slot': 'Slot 08:00-10:00',
      'time': '08:00 AM',
      'name': 'สมพงษ์ ชูใจ',
    },
    {
      'date': '17 October 2025',
      'floor': 'Floor5',
      'room': 'R501',
      'slot': 'Slot 08:00-10:00',
      'time': '08:30 AM',
      'name': 'สมพงษ์ ชูใจ',
    },
    {
      'date': '17 October 2025',
      'floor': 'Floor5',
      'room': 'R501',
      'slot': 'Slot 08:00-10:00',
      'time': '09:45 AM',
      'name': 'สมพงษ์ ชูใจ',
    },
  ];

  // ================== SEARCH FILTER ==================
  List<Map<String, String>> get _filteredRequests {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return _requests;
    return _requests.where((e) {
      final hay =
          '${e['date']} ${e['floor']} ${e['room']} ${e['slot']} ${e['time']} ${e['name']} }'
              .toLowerCase();
      return hay.contains(q);
    }).toList();
  }

  // ================== APPROVE DIALOGS ==================
  Future<void> _showApproveConfirmDialog(BuildContext context) async {
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
                Navigator.of(context, rootNavigator: true).pop();
                _showApproveSuccessDialog(context);
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
  Future<void> _showDisapproveReasonDialog(BuildContext context) async {
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
                Navigator.of(context, rootNavigator: true).pop();
                _showDisapproveSuccessDialog(context);
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

              //  List of requests
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () =>
                                      _showDisapproveReasonDialog(context),
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
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () =>
                                      _showApproveConfirmDialog(context),
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

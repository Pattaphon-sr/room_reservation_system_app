import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/theme/app_colors.dart';
import 'package:room_reservation_system_app/services/booking_state_service.dart';
import 'package:room_reservation_system_app/shared/widgets/widgets.dart';
import 'package:room_reservation_system_app/features/approver/root.dart';
import 'package:room_reservation_system_app/services/dashboard_service.dart';

class ApproverHomeScreen extends StatefulWidget {
  const ApproverHomeScreen({super.key});

  @override
  State<ApproverHomeScreen> createState() => _ApproverHomeScreenState();
}

class _ApproverHomeScreenState extends State<ApproverHomeScreen> {
  final _dashboardApi = DashboardApi();
  final _reservationsApi = DashboardApi();

  Map<String, dynamic>? overallSummary;
  List<Map<String, dynamic>> floorSummary = [];
  List<Map<String, dynamic>> dailyRequests = [];

   final List<Map<String, dynamic>> floorData = const [
    {
      'id': 3,
      'title': 'Floor 3',
      'asset': 'assets/images/Photoroom_Floor3.png',
      'panel': PanelPresets.sky,
    },
    {
      'id': 4,
      'title': 'Floor 4',
      'asset': 'assets/images/Photoroom_Floor4.png',
      'panel': PanelPresets.purple,
    },
    {
      'id': 5,
      'title': 'Floor 5',
      'asset': 'assets/images/Photoroom_Floor5.png',
      'panel': PanelPresets.pink,
    },
  ];

  @override
  void initState() {
    super.initState();
    fetchDashboard();
    fetchDailyRequests();
  }

  Future<void> fetchDashboard() async {
    try {
      final data = await _dashboardApi.getDashboard();
      setState(() {
        overallSummary = (data['overall_summary'] as Map?)
            ?.cast<String, dynamic>();
        floorSummary = ((data['floor_summary'] as List?) ?? const [])
            .map((e) => (e as Map).cast<String, dynamic>())
            .toList();
      });
    } catch (e) {
      debugPrint('Error fetching dashboard: $e');
    }
  }

  Widget _buildStatCard(Color color, String count, String label) {
    return PanelPresets.air(
      width: 150,
      height: 70,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 27,
                  height: 27,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                const SizedBox(width: 30),
                Text(
                  count,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 40),
            Text(
              label,
              style: const TextStyle(fontSize: 17, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchDailyRequests() async {
    try {
      final list = await _reservationsApi.getApproverDailyRequests();
      setState(() => dailyRequests = list);
    } catch (e) {
      debugPrint('Error fetching daily requests: $e');
    }
  }

  Widget _buildFloorCard(
    Map<String, dynamic> floor,
  ) {
    final String title = floor['title'] as String;
    final String imageAsset = floor['asset'] as String;
    final panelBuilder =
        floor['panel']
            as Widget Function({
              required double width,
              required double height,
              required Widget child,
            });
    final int floorId = floor['id'] as int; 

    return GestureDetector(
      onTap: () {
        BookingStateService.instance.setInitialFloor(floorId);
        ApproverRoot.goTo(context, 1);
      },
      child: panelBuilder(
        width: 80,
        height: 80,
        child: Center(
          child: Image.asset(
            imageAsset,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.apartment, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestItem(Map<String, dynamic> request) {
    final fullDateTime = request['full_datetime'] ?? '';
    final parts = fullDateTime.split(' ');
    String datePart = '';
    String timePart = '';

    if (parts.length >= 4) {
      datePart = '${parts[0]} ${parts[1]} ${parts[2]}';
      timePart = parts[3];
    }

    return Container(
      child: Column(
        children: [
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Room: ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${request['room_name'] ?? '-'}  ${request['slot_label'] ?? ''}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Request by: ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${request['requested_by'] ?? '-'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        (request['status'] ?? '').toString().toUpperCase(),
                        style: TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        timePart,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        ' • ',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        datePart,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          Container(height: 1, color: Colors.white30),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.primaryGradient5C,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: AppColorStops.primaryStop5C,
          ),
        ),
        child: Padding(
          padding: EdgeInsetsGeometry.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  _buildStatCard(
                    AppColors.success,
                    overallSummary?['free']?.toString() ?? '0',
                    'Free slots',
                  ),
                  _buildStatCard(
                    AppColors.warning,
                    overallSummary?['pending']?.toString() ?? '0',
                    'Pending slots',
                  ),
                  _buildStatCard(
                    AppColors.primary,
                    overallSummary?['booked']?.toString() ?? '0',
                    'Booked Slots',
                  ),
                  _buildStatCard(
                    AppColors.danger,
                    overallSummary?['disabled']?.toString() ?? '0',
                    'Disabled rooms',
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "DAILY ROOM REQUEST",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => ApproverRoot.goTo(context, 2),
                    child: Text(
                      "See All",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              PanelPresets.purple(
                width: double.infinity,
                height: 210,
                child: dailyRequests.isEmpty
                    ? const Padding(
                        // 1. คง Padding นี้ไว้สำหรับกรณีที่ 'list' ว่าง
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'No pending requests today.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          20.0,
                          16.0,
                          10.0,
                        ),
                        itemCount: dailyRequests.length,
                        itemBuilder: (context, index) {
                          return _buildRequestItem(dailyRequests[index]);
                        },
                      ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "FLOOR LIST",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => ApproverRoot.goTo(context, 1),
                    child: Text(
                      "See All",
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  // floorData ถูกเรียง 5, 4, 3 แล้ว
                  itemCount: floorData.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                   itemBuilder: (context, index) {
                        final floor = floorData[index];
                        return _buildFloorCard(floor);
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

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:room_reservation_system_app/core/theme/app_colors.dart';
import 'package:room_reservation_system_app/shared/widgets/widgets.dart';
import 'package:room_reservation_system_app/features/approver/root.dart';

class ApproverHomeScreen extends StatefulWidget {
  const ApproverHomeScreen({super.key});

  @override
  State<ApproverHomeScreen> createState() => _ApproverHomeScreenState();
}

class _ApproverHomeScreenState extends State<ApproverHomeScreen> {
  Map<String, dynamic>? overallSummary;
  List<Map<String, dynamic>> floorSummary = [];
  List<Map<String, dynamic>> dailyRequests = [];

  final List<Map<String, dynamic>> floorData = const [
    {
      'title': 'Floor 3',
      'asset': 'assets/images/Photoroom_Floor3.png',
      'panel': PanelPresets.sky,
    },
    {
      'title': 'Floor 4',
      'asset': 'assets/images/Photoroom_Floor4.png',
      'panel': PanelPresets.purple,
    },
    {
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

  // final apiBaseUrl = 'http://192.168.3.100:3000';
  final apiBaseUrl = 'http://172.25.21.26:3000';

  Future<void> fetchDashboard() async {
    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/api/dashboard'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          overallSummary = Map<String, dynamic>.from(
            jsonData['overall_summary'],
          );
          floorSummary = List<Map<String, dynamic>>.from(
            jsonData['floor_summary'],
          );
        });
      } else {
        debugPrint('Failed to load dashboard: ${response.statusCode}');
      }
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
      final response = await http.get(
        Uri.parse('$apiBaseUrl/api/dailyRequest'),
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          dailyRequests = List<Map<String, dynamic>>.from(
            jsonData['data'] ?? [],
          );
        });
      } else {
        debugPrint(
          'Failed to load daily requests: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching daily requests: $e');
    }
  }

  Widget _buildFloorCard(
    String title,
    String imageAsset,
    Widget Function({
      required double width,
      required double height,
      required Widget child,
    })
    panelBuilder,
  ) {
    return GestureDetector(
      onTap: () => ApproverRoot.goTo(context, 1),
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

  Widget _buildStatusRow(Color color, String label, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ],
          ),
          Text(
            count,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildFloorPanel(
    String title,
    String imageAsset,
    Map<String, dynamic> floorInfo,
    Widget Function({
      required double width,
      required double height,
      required Widget child,
    })
    panelBuilder,
  ) {
    return panelBuilder(
      width: double.infinity,
      height: 170,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Image.asset(
                    imageAsset,
                    fit: BoxFit.contain,
                    height: 100,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.image_not_supported,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatusRow(
                    Colors.green,
                    "Free Slots",
                    floorInfo['free']?.toString() ?? '0',
                  ),
                  _buildStatusRow(
                    Colors.amber,
                    "Pending Slots",
                    floorInfo['pending']?.toString() ?? '0',
                  ),
                  _buildStatusRow(
                    Colors.blue,
                    "Booked Slots",
                    floorInfo['booked']?.toString() ?? '0',
                  ),
                  _buildStatusRow(
                    Colors.red,
                    "Disabled rooms",
                    floorInfo['disabled']?.toString() ?? '0',
                  ),
                ],
              ),
            ),
          ],
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
      
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    datePart,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    timePart,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'By: ${request['requested_by'] ?? '-'}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Room: ${request['room_name'] ?? '-'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      request['slot_label'] ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
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
          const SizedBox(height: 12),
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: dailyRequests.isEmpty
                      ? const Center(
                          child: Text(
                            'No pending requests today.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: dailyRequests.length,
                          itemBuilder: (context, index) {
                            return _buildRequestItem(dailyRequests[index]);
                          },
                        ),
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
                    return _buildFloorCard(
                      floor['title'] as String,
                      floor['asset'] as String,
                      floor['panel']
                          as Widget Function({
                            required double width,
                            required double height,
                            required Widget child,
                          }),
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

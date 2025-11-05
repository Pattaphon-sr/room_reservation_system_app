import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:room_reservation_system_app/core/theme/theme.dart';
import 'package:room_reservation_system_app/core/theme/app_colors.dart';
import 'package:room_reservation_system_app/features/user/root.dart';
import 'package:room_reservation_system_app/shared/widgets/widgets.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  // String apiUrl = 'http://192.168.3.100:3000/api/dashboard';
  String apiUrl = 'http://172.25.21.26:3000/api/dashboard';
  // String apiDailyReservation =
  //     'http://192.168.3.100:3000/api/reservations/daily?userId=1';
  String apiDailyReservation =
      'http://172.25.21.26:3000/api/reservations/daily?userId=1';

  // String apiDailyReservation =
  // 'http://192.168.3.100:3000/api/reservations/daily?userId=';

  List<Map<String, dynamic>> _availabilityData = [];
  List<Map<String, dynamic>> _dailyReservations = [];

  bool _isLoading = true;
  String _errorMessage = '';
  Timer? _timer;

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
    _fetchData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    await _fetchDashboardSummary();
    await _fetchDailyReservation();
  }

  Future<void> _fetchDashboardSummary() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> rawList = data['available_by_floor_slot'] ?? [];
        final List<dynamic> list = rawList;

        final grouped = <String, Map<String, dynamic>>{};
        for (var item in list) {
          final slot = item['slot_label'];
          final floor = item['floor'];
          final available = item['available_rooms'];

          grouped.putIfAbsent(
            slot,
            () => {'time': slot, 'f3': 0, 'f4': 0, 'f5': 0},
          );
          if (floor == 3) grouped[slot]!['f3'] = available;
          if (floor == 4) grouped[slot]!['f4'] = available;
          if (floor == 5) grouped[slot]!['f5'] = available;
        }

        setState(() {
          _availabilityData = grouped.values.toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load data (Status: ${response.statusCode})');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to connect to server';
        _availabilityData = [];
        _isLoading = false;
      });

      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) _fetchDashboardSummary();
      });
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
      onTap: () => UserRoot.goTo(context, 1),
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

  Widget _buildDashboardTable() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (_availabilityData.isEmpty) {
      return const Center(
        child: Text(
          "No available time slots or data is empty.",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Column(
      children: _availabilityData.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  row['time'],
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${row['f3']}',
                    style: const TextStyle(
                      color: Color(0xFFADFF2F),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${row['f4']}',
                    style: const TextStyle(
                      color: Color(0xFFADFF2F),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${row['f5']}',
                    style: const TextStyle(
                      color: Color(0xFFADFF2F),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<void> _fetchDailyReservation() async {
    try {
      final response = await http.get(Uri.parse(apiDailyReservation));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _dailyReservations = List<Map<String, dynamic>>.from(
            data['data'] ?? [],
          );
        });
      } else {
        print('Failed to fetch daily reservation (${response.statusCode})');
      }
    } catch (e) {
      print('Error fetching daily reservation: $e');
    }
  }

  Widget _buildDailyReservationPanel() {
    if (_dailyReservations.isEmpty) {
      return const Center(
        child: Text(
          'There are no reservation requests today.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      itemCount: _dailyReservations.length,
      itemBuilder: (context, index) {
        final item = _dailyReservations[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          (item['status'] ?? '').toUpperCase(),
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Floor ${item['floor']}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  'R ${item['room_name']}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Slot ${item['slot_label']}',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
                Text(
                  '${item['full_datetime'] ?? ''}',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: Colors.white30),
          ],
        );
      },
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                'HOME',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              PanelPresets.air(
                width: double.infinity,
                height: 135,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 11,
                    horizontal: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Expanded(
                            flex: 2,
                            child: Text(
                              "Time",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                "Floor 3",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                "Floor 4",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                "Floor 5",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Expanded(child: _buildDashboardTable()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "DAILY RESERVATION",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => UserRoot.goTo(context, 2),
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
                height: 205,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildDailyReservationPanel(),
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
                    onTap: () => UserRoot.goTo(context, 2),
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

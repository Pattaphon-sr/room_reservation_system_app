import 'dart:async';
import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/theme/theme.dart';
import 'package:room_reservation_system_app/core/theme/app_colors.dart';
import 'package:room_reservation_system_app/services/booking_state_service.dart';
import 'package:room_reservation_system_app/shared/widgets/widgets.dart';
import 'package:room_reservation_system_app/features/user/root.dart';
import 'package:room_reservation_system_app/services/auth_service.dart';
import 'package:room_reservation_system_app/services/dashboard_service.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final _dashboardApi = DashboardApi();
  final _reservationsApi = DashboardApi();

  List<Map<String, dynamic>> _availabilityData = [];
  List<Map<String, dynamic>> _dailyReservations = [];

  bool _isLoading = true;
  String _errorMessage = '';
  Timer? _timer;
  bool _refreshing = false;

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
    _fetchData(initial: true); 
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _tickRefresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData({bool initial = false}) async {
    await _fetchDashboardSummary(
      silent: !initial,
    );
    await _fetchDailyReservation();
  }

  Future<void> _tickRefresh() async {
    if (!mounted || _refreshing) return;
    _refreshing = true;
    try {
      await Future.wait([
        _fetchDashboardSummary(silent: true),
        _fetchDailyReservation(), 
      ]);
    } finally {
      _refreshing = false;
    }
  }

  Future<void> _fetchDashboardSummary({bool silent = false}) async {
    try {
      if (!silent) {
        setState(() {
          _isLoading = true;
          _errorMessage = '';
        });
      }

      final data = await _dashboardApi.getDashboard();
      final List rawList =
          (data['available_by_floor_slot'] as List?) ?? const [];

      final grouped = <String, Map<String, dynamic>>{};
      for (final item in rawList) {
        final m = (item as Map).cast<String, dynamic>();
        final slot = m['slot_label'];
        final floor = m['floor'];
        final available = m['available_rooms'];

        grouped.putIfAbsent(
          slot,
          () => {'time': slot, 'f3': 0, 'f4': 0, 'f5': 0},
        );
        if (floor == 3) grouped[slot]!['f3'] = available;
        if (floor == 4) grouped[slot]!['f4'] = available;
        if (floor == 5) grouped[slot]!['f5'] = available;
      }

      if (!mounted) return;
      setState(() {
        _availabilityData = grouped.values.toList();
        if (!silent) _isLoading = false;
        _errorMessage = '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (!silent) {
          _errorMessage = 'Unable to connect to server';
          _availabilityData = [];
          _isLoading = false;
        }
      });
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
        UserRoot.goTo(context, 1);
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
        return Column(
          children: [
            Row(
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
            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }

  Future<void> _fetchDailyReservation() async {
    try {
      final userId = AuthService.instance.payload?['id'] as int?;
      if (userId == null) {
        setState(() => _dailyReservations = []);
        return;
      }
      final list = await _reservationsApi.getUserDailyReservations(
        userId: userId,
      );
      setState(() {
        _dailyReservations = list;
      });
    } catch (e) {
      debugPrint('Error fetching daily reservation: $e');
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

    return Column(
      children: _dailyReservations.map((item) {
        final String status = item['status'] ?? '';
        final String displayStatus = status.isEmpty
            ? ''
            : '${status[0].toUpperCase()}${status.substring(1).toLowerCase()}';

        return Column(
          children: [
            const SizedBox(height: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          displayStatus,
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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
                  'Room: ${item['room_name']}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Slot ${item['slot_label']}',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                Text(
                  '${item['full_datetime'] ?? ''}',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ],
        );
      }).toList(),
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
                height: 160,
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
              const SizedBox(height: 25),
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
                height: 90,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildDailyReservationPanel(),
                ),
              ),
              const SizedBox(height: 40),
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
                    onTap: () => UserRoot.goTo(context, 1),
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
                      floor,
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

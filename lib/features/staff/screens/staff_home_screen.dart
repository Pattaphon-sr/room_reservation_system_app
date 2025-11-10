import 'dart:async';
import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/theme/app_colors.dart';
import 'package:room_reservation_system_app/shared/widgets/widgets.dart';
import 'package:room_reservation_system_app/features/staff/root.dart';
import 'package:room_reservation_system_app/services/dashboard_service.dart';
import 'package:room_reservation_system_app/services/booking_state_service.dart';

class StaffHomeScreen extends StatefulWidget {
  const StaffHomeScreen({super.key});

  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> {
  final _dashboardApi = DashboardApi();

  Map<String, dynamic>? overallSummary;
  List<Map<String, dynamic>> floorSummary = [];
  List<Map<String, dynamic>> availableByFloorSlot = [];

  Timer? _refreshTimer;
  bool _isLoading = false;

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
    _startTimer();
  }

  void _startTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isLoading) {
        fetchDashboard();
      }
    });
  }

  Future<void> fetchDashboard() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await _dashboardApi.getDashboard();

      if (mounted) {
        setState(() {
          overallSummary = (data['overall_summary'] as Map?)
              ?.cast<String, dynamic>();

          floorSummary = ((data['floor_summary'] as List?) ?? const [])
              .map((e) => (e as Map).cast<String, dynamic>())
              .toList();

          availableByFloorSlot =
              ((data['available_by_floor_slot'] as List?) ?? const [])
                  .map((e) => (e as Map).cast<String, dynamic>())
                  .toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching dashboard: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
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

  Widget _buildFloorCard(Map<String, dynamic> floor) {
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
        StaffRoot.goTo(context, 1);
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

  @override
  Widget build(BuildContext context) {
    final reversedFloorData = floorData.reversed.toList();

    final int totalFreeSlots = availableByFloorSlot.fold(
      0,
      (sum, slot) =>
          sum + (int.tryParse(slot['available_rooms']?.toString() ?? '0') ?? 0),
    );

    final int totalPendingSlots = availableByFloorSlot.fold(
      0,
      (sum, slot) =>
          sum + (int.tryParse(slot['pending_rooms']?.toString() ?? '0') ?? 0),
    );

    final int totalBookedSlots = availableByFloorSlot.fold(
      0,
      (sum, slot) =>
          sum + (int.tryParse(slot['booked_rooms']?.toString() ?? '0') ?? 0),
    );

    final String totalDisabled = overallSummary?['disabled']?.toString() ?? '0';

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.primaryGradient5C,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: AppColorStops.primaryStop5C,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
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
                    totalFreeSlots.toString(),
                    'Free slots',
                  ),
                  _buildStatCard(
                    AppColors.warning,
                    totalPendingSlots.toString(),
                    'Pending slots',
                  ),
                  _buildStatCard(
                    AppColors.primary,
                    totalBookedSlots.toString(),
                    'Booked Slots',
                  ),
                  _buildStatCard(
                    AppColors.danger,
                    totalDisabled,
                    'Disabled rooms',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "FLOOR LIST",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => StaffRoot.goTo(context, 1),
                        child: const Text(
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
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
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
              const SizedBox(height: 35),

              for (var i = 0; i < reversedFloorData.length; i++) ...[
                Builder(
                  builder: (context) {
                    final floorData = reversedFloorData[i];
                    final floorTitle = floorData['title'] as String;
                    final floorNumber = int.tryParse(
                      floorTitle.replaceAll('Floor ', ''),
                    );

                    final Map<String, dynamic> floorInfo = floorSummary
                        .firstWhere(
                          (f) => f['floor'] == floorNumber,
                          orElse: () => {
                            'free': 0,
                            'pending': 0,
                            'booked': 0,
                            'disabled': 0,
                          },
                        );

                    final int timeAdjustedFreeSlots = availableByFloorSlot
                        .where((slot) => slot['floor'] == floorNumber)
                        .fold(
                          0,
                          (sum, slot) =>
                              sum +
                              (int.tryParse(
                                    slot['available_rooms']?.toString() ?? '0',
                                  ) ??
                                  0),
                        );

                    final Map<String, dynamic> displayFloorInfo = Map.from(
                      floorInfo,
                    );

                    displayFloorInfo['free'] = timeAdjustedFreeSlots;

                    return _buildFloorPanel(
                      floorData['title'] as String,
                      floorData['asset'] as String,
                      displayFloorInfo,
                      floorData['panel']
                          as Widget Function({
                            required double width,
                            required double height,
                            required Widget child,
                          }),
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

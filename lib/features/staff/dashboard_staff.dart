import 'package:flutter/material.dart';

import 'package:room_reservation_system_app/core/theme/app_colors.dart';
import 'package:room_reservation_system_app/shared/widgets/widgets.dart';

class DashboardStaff extends StatefulWidget {
  const DashboardStaff({super.key});

  @override
  State<DashboardStaff> createState() => _DashboardStaffState();
}

class _DashboardStaffState extends State<DashboardStaff> {
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
                const SizedBox(width: 40),
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 40),
            Text(label, style: TextStyle(fontSize: 17, color: Colors.white)),
          ],
        ),
      ),
    );
  }

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
    return panelBuilder(
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
              flex:2,
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
                  _buildStatusRow(Colors.green, "Free Slots", "10"),
                  _buildStatusRow(Colors.amber, "Pending Slots", "6"),
                  _buildStatusRow(Colors.blue, "Booked Slots", "3"),
                  _buildStatusRow(Colors.red, "Disabled rooms", "3"),
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
          padding: const EdgeInsets.all(16), // Use const here
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  _buildStatCard(AppColors.success, '30', 'Free slots'),
                  _buildStatCard(AppColors.warning, '18', 'Pending slots'),
                  _buildStatCard(AppColors.primary, '9', 'Booked Slots'),
                  _buildStatCard(AppColors.danger, '9', 'Disabled rooms'),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "FLOOR LIST",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "See All",
                        style: TextStyle(
                          color: Colors.white, 
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
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
              const SizedBox(height: 35),
              for (var floor in floorData.reversed.toList()) ...[
                _buildFloorPanel(
                  floor['title'] as String,
                  floor['asset'] as String,
                  floor['panel']
                      as Widget Function({
                        required double width,
                        required double height,
                        required Widget child,
                      }),
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

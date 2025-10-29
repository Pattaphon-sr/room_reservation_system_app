import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/theme/theme.dart';

import 'package:room_reservation_system_app/core/theme/app_colors.dart';
import 'package:room_reservation_system_app/shared/widgets/widgets.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final List<Map<String, dynamic>> availabilityData = [
    {'time': '8am-10am', 'f3': 10, 'f4': 5, 'f5': 13},
    {'time': '10am-12pm', 'f3': 6, 'f4': 8, 'f5': 16},
    {'time': '1pm-3pm', 'f3': 2, 'f4': 3, 'f5': 9},
    {'time': '3pm-5pm', 'f3': 10, 'f4': 5, 'f5': 4},
  ];

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
              PanelPresets.air(
                width: double.infinity,
                height: 135,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
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
                              textAlign: TextAlign.center,
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
                      const SizedBox(height: 2),
                      for (var row in availabilityData)
                        Padding(
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
                                      color: Color(0xFFADFF2F), // เขียวเรืองแสง
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
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "DAILY RESERVATION",
                    style: TextStyle(
                      color: Colors.white70,
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
              PanelPresets.purple(
                width: double.infinity,
                height: 205,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
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
                                    'Pending',
                                    style: TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Floor 5',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Text(
                            'R501',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Slot 08:00-10:00',
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                          Text(
                            '22 Oct 2025 - 07:48 AM',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(height: 1, color: Colors.white30),
                    ],
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
                  Text(
                    "See All",
                    style: TextStyle(
                      color: Colors.grey[700],
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
        ),
      ),
    );
  }
}

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
                Stack(
                  children: [
                    Text(
                      count,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 3
                          ..color = Colors.black,
                      ),
                    ),
                    Text(
                      count,
                      style: TextStyle(
                        fontSize: 20,
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 40),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.primaryGradient5C,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: AppColorStops.primaryStop5C,
          ),
        ),
        padding: EdgeInsetsGeometry.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                _buildStatCard(Colors.green, '8', 'Free slots'),
                _buildStatCard(Colors.amber, '4', 'Pending slots'),
                _buildStatCard(Colors.blue, '3', 'Booked Slots'),
                _buildStatCard(Colors.red, '2', 'Disabled rooms'),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Text(
                  "See All",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Column(
              children: [
                Container(
                  color: Colors.grey,
                  width: double.infinity,
                  height: 420,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

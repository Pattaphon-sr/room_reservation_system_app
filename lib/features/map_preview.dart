import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/theme/theme.dart';
import 'package:room_reservation_system_app/shared/widgets/widgets.dart';

class MapPreview extends StatefulWidget {
  const MapPreview({super.key});

  @override
  State<MapPreview> createState() => _MapPreviewState();
}

class _MapPreviewState extends State<MapPreview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.roomBlue,
      body: Center(
        child: MapFloor(
          role: MapRole.user,
          onCellTap: (x, y, cell) {
            debugPrint('tap ($x,$y) ${cell['type']} ${cell['roomNo'] ?? ''}');
          },
        ),
      ),
    );
  }
}

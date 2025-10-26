import 'package:flutter/material.dart';
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
      body: Center(child: MapFloor(role: MapRole.user)),
    );
  }
}

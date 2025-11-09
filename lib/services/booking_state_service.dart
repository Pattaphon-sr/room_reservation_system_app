import 'package:flutter/material.dart';

class BookingStateService {
  BookingStateService._();
  static final instance = BookingStateService._();

  final ValueNotifier<int?> initialFloorNotifier = ValueNotifier<int?>(null);

  void setInitialFloor(int floor) {
    initialFloorNotifier.value = floor;
  }

  int? consumeInitialFloor() {
    final floor = initialFloorNotifier.value;
    
    initialFloorNotifier.value = null; 
    
    return floor;
  }
}
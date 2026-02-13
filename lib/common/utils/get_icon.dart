import 'package:flutter/material.dart';

IconData iconFromString(String iconName) {
  switch (iconName) {
    case 'bike':
      return Icons.bike_scooter;
    case 'car':
      return Icons.directions_car;
    case 'truck':
      return Icons.fire_truck;
    default:
      return Icons.info; // Fallback icon
  }
}

import 'package:flutter/material.dart';

class RatingState {
  double initialRating = 0.0;
  final TextEditingController commentController = TextEditingController();
  Map<String, dynamic>? requestInfo;
  String? driverId;
  String? tripId; // Add trip ID for better tracking
}

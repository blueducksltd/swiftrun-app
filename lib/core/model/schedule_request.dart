import 'package:google_maps_flutter/google_maps_flutter.dart';

class ScheduleRequestModel {
  String? userID;
  String? userName;
  String? userPhone;
  String? status;
  String? imageSent;
  String? imageDelivered;
  int? riderType;
  String? pickupLocation;
  String? dropOffLocation;
  String? itemType;
  String? recipientName;
  String? recipientNumber;
  LatLng? pickupLatLng;
  LatLng? dropOffLatLng;
  String? amount;
  DateTime? dateTime;

  ScheduleRequestModel({
    this.userID,
    this.userName,
    this.userPhone,
    this.status,
    this.imageSent,
    this.imageDelivered,
    this.riderType,
    this.pickupLocation,
    this.dropOffLocation,
    this.itemType,
    this.recipientName,
    this.recipientNumber,
    this.pickupLatLng,
    this.dropOffLatLng,
    this.amount,
    this.dateTime,
  });
}

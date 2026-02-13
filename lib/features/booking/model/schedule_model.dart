import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ScheduleDeliveryModel {
  final String? vehicleType,
      quantity,
      recipientName,
      recipientNumber,
      imageUrl,
      userID,
      status,
      cancelReason,
      driverAssigned,
      pickupAddress,
      dropOffAddress;
  LatLng? pickupLatLng, dropOffLatLng;
  String? deliveryAmount;
  final String? items;
  final DateTime? dateCreated,
      dateUpdated,
      dateScheduled,
      dateDelivered,
      dateCancelled,
      timeScheduled;
  // Webhook verification fields
  final bool? paymentStatus;
  final bool? paymentVerified;
  final String? paymentReference;
  final double? amountPaid;
  final DateTime? paymentDate;

  ScheduleDeliveryModel({
    this.vehicleType,
    this.userID,
    this.status,
    this.cancelReason,
    this.driverAssigned,
    this.pickupAddress,
    this.dropOffAddress,
    this.pickupLatLng,
    this.dropOffLatLng,
    this.deliveryAmount,
    this.items,
    this.quantity,
    this.recipientName,
    this.recipientNumber,
    this.imageUrl,
    this.dateCreated,
    this.dateUpdated,
    this.dateScheduled,
    this.dateDelivered,
    this.dateCancelled,
    this.timeScheduled,
    this.paymentStatus,
    this.paymentVerified,
    this.paymentReference,
    this.amountPaid,
    this.paymentDate,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'courierType': vehicleType,
      'userID': userID,
      'status': status,
      'cancelReason': cancelReason,
      'driverAssigned': driverAssigned,
      'pickupAddress': pickupAddress,
      'dropOffAddress': dropOffAddress,
      'pickupLatLng': pickupLatLng != null
          ? {'latitude': pickupLatLng!.latitude, 'longitude': pickupLatLng!.longitude}
          : null,
      'dropOffLatLng': dropOffLatLng != null
          ? {'latitude': dropOffLatLng!.latitude, 'longitude': dropOffLatLng!.longitude}
          : null,
      'deliveryAmount': deliveryAmount,
      'items': items,
      'quantity': quantity,
      'recipientName': recipientName,
      'recipientNumber': recipientNumber,
      'imageUrl': imageUrl,
      'dateCreated': dateCreated != null ? Timestamp.now() : null,
      'dateUpdated': dateUpdated != null ? Timestamp.now() : null,
      'dateScheduled': dateScheduled != null
          ? Timestamp.fromDate(dateScheduled!).toDate()
          : null,
      'dateDelivered': dateDelivered != null ? Timestamp.now() : null,
      'dateCancelled': dateCancelled != null ? Timestamp.now() : null,
      'timeScheduled': timeScheduled != null
          ? Timestamp.fromDate(timeScheduled!).toDate()
          : null,
      // Initialize webhook fields with default values
      'paymentStatus': paymentStatus ?? false,
      'paymentVerified': paymentVerified ?? false,
      'paymentReference': paymentReference,
      'amountPaid': amountPaid,
      'paymentDate': paymentDate != null ? Timestamp.fromDate(paymentDate!) : null,
    };
  }

  factory ScheduleDeliveryModel.fromMap(Map<String, dynamic> map) {
    return ScheduleDeliveryModel(
      vehicleType: map['courierType'] as String?,
      userID: map['userID'] as String?,
      status: map['status'] as String?,
      cancelReason: map['cancelReason'] as String?,
      driverAssigned: map['driverAssigned'] as String?,
      pickupAddress: map['pickupAddress'] as String,
      dropOffAddress: map['dropOffAddress'] as String,
      pickupLatLng: map['pickupLatLng'] != null
          ? LatLng(
              map['pickupLatLng']['latitude'], map['pickupLatLng']['longitude'])
          : null,
      dropOffLatLng: map['dropOffLatLng'] != null
          ? LatLng(map['dropOffLatLng']['latitude'],
              map['dropOffLatLng']['longitude'])
          : null,
      deliveryAmount: map['deliveryAmount'] as String?,
      items: map['items'] as String,
      quantity: map['quantity'] as String?,
      recipientName: map['recipientName'] as String?,
      recipientNumber: map['recipientNumber'] as String?,
      imageUrl: map['imageUrl'] as String?,
      dateCreated: (map['dateCreated'] as Timestamp?)?.toDate(),
      dateUpdated: (map['dateUpdated'] as Timestamp?)?.toDate(),
      dateScheduled: (map['dateScheduled'] as Timestamp?)?.toDate(),
      dateDelivered: (map['dateDelivered'] as Timestamp?)?.toDate(),
      dateCancelled: (map['dateCancelled'] as Timestamp?)?.toDate(),
      timeScheduled: (map['timeScheduled'] as Timestamp?)?.toDate(),
      paymentStatus: map['paymentStatus'] as bool?,
      paymentVerified: map['paymentVerified'] as bool?,
      paymentReference: map['paymentReference'] as String?,
      amountPaid: map['amountPaid']?.toDouble(),
      paymentDate: (map['paymentDate'] as Timestamp?)?.toDate(),
    );
  }
}

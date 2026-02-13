import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DeliveryRequest {
  String? userID;
  String? userName;
  String? userPhone;
  String? status;
  String? imageSent;
  String? imageDelivered;
  String? driverRating;
  String? driverID;
  String? vehicleType;
  String? pickupLocation;
  String? dropOffLocation;
  String? itemType;
  String? recipientName;
  String? recipientNumber;
  String? paymentMethod;
  LatLng? pickupLatLng;
  LatLng? dropOffLatLng;
  String? deliveryAmount;
  DateTime? dateCreated;
  String? userToken;
  bool? paymentStatus;
  // Webhook verification fields
  bool? paymentVerified;
  String? paymentReference;
  double? amountPaid;
  DateTime? paymentDate;

  DeliveryRequest(
      {this.userID,
      this.userName,
      this.userPhone,
      this.status,
      this.imageSent,
      this.imageDelivered,
      this.driverRating,
      this.driverID,
      this.vehicleType,
      this.pickupLocation,
      this.dropOffLocation,
      this.itemType,
      this.recipientName,
      this.recipientNumber,
      this.paymentMethod,
      this.pickupLatLng,
      this.dropOffLatLng,
      this.deliveryAmount,
      this.dateCreated,
      this.userToken,
      this.paymentStatus,
      this.paymentVerified,
      this.paymentReference,
      this.amountPaid,
      this.paymentDate});

  factory DeliveryRequest.fromJson(Map<String, dynamic> json) {
    return DeliveryRequest(
      userID: json['userID'],
      userName: json['userName'],
      userPhone: json['userPhone'],
      status: json['status'],
      imageSent: json['imageSent'],
      imageDelivered: json['imageDelivered'],
      driverRating: json['driverRating']?.toString(),
      driverID: json['driverID'],
      vehicleType: json['vehicleType'],
      pickupLocation: json['pickupLocation'],
      dropOffLocation: json['dropOffLocation'],
      itemType: json['itemType'],
      recipientName: json['recipientName'],
      recipientNumber: json['recipientNumber'],
      paymentMethod: json['paymentMethod'],
      pickupLatLng: LatLng(
        json['pickupLatLng']['latitude'],
        json['pickupLatLng']['longitude'],
      ),
      dropOffLatLng: LatLng(
        json['dropOffLatLng']['latitude'],
        json['dropOffLatLng']['longitude'],
      ),
      deliveryAmount: json['deliveryAmount'],
      dateCreated: (json["dateCreated"] as Timestamp?)?.toDate(),
      userToken: json['userToken'],
      paymentStatus: json['paymentStatus'],
      paymentVerified: json['paymentVerified'],
      paymentReference: json['paymentReference'],
      amountPaid: json['amountPaid']?.toDouble(),
      paymentDate: (json["paymentDate"] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'userName': userName,
      'userPhone': userPhone,
      'status': status,
      'imageSent': imageSent,
      'imageDelivered': imageDelivered,
      'driverRating': driverRating,
      'driverID': driverID,
      'vehicleType': vehicleType,
      'pickupLocation': pickupLocation,
      'dropOffLocation': dropOffLocation,
      'itemType': itemType,
      'recipientName': recipientName,
      'recipientNumber': recipientNumber,
      'paymentMethod': paymentMethod,
      'pickupLatLng': {
        'latitude': pickupLatLng!.latitude,
        'longitude': pickupLatLng!.longitude,
      },
      'dropOffLatLng': {
        'latitude': dropOffLatLng!.latitude,
        'longitude': dropOffLatLng!.longitude,
      },
      'deliveryAmount': deliveryAmount,
      'dateCreated':
          dateCreated != null ? Timestamp.fromDate(dateCreated!) : null,
      'userToken': userToken,
      'paymentStatus': paymentStatus ?? false,
      // Initialize webhook fields with default values
      'paymentVerified': paymentVerified ?? false,
      'paymentReference': paymentReference,
      'amountPaid': amountPaid,
      'paymentDate': paymentDate != null ? Timestamp.fromDate(paymentDate!) : null,
    };
  }
}

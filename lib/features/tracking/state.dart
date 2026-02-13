import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:swiftrun/core/model/driver_model.dart';
import 'package:swiftrun/features/booking/presentation/atoms/confirm_details/confirmation.con.dart';

class TrackingStates {
  var driverInfo = DriverModel().obs;
  RxString? driverID = "".obs;
  RxString docRefID = "".obs;
  RxList<LatLng> polylineCoordinatesList = <LatLng>[].obs;
  var userRideRequestStatus = UserRideRequestStatus.waiting.obs;
  var driverRideStatus = "".obs;
  var paymentMethod = "".obs;
  var tripAmount = "".obs;
  RxBool paymentStatus = false.obs;
  var requestPositionInfo = true.obs;

  var polylineSet = <Polyline>{}.obs;
  var markerSet = <Marker>{}.obs;

  DocumentSnapshot? docRef;
  dynamic requestData;
  RxBool isInitialized = false.obs; // Track if tracking data is initialized
  Rx<LatLng?> dropOffLatLng = Rx<LatLng?>(null);
  Rx<LatLng?> pickupLatLng = Rx<LatLng?>(null);
  Rx<LatLng?> driverPosition = Rx<LatLng?>(null);
  StreamSubscription<DocumentSnapshot>? realTimeLocation;
  RxDouble averageRating = 0.0.obs;
  RxInt totalDelivery = 0.obs;
}

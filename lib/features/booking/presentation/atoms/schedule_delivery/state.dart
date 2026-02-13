import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ScheduleState {
  RxList<LatLng> polylineCoordinatesList = <LatLng>[].obs;
  RxString paymentMethod = "".obs;
  RxBool paymentStatus = false.obs;

  var polylineSet = <Polyline>{}.obs;
  var markerSet = <Marker>{}.obs;

  late dynamic requestData;
  RxString dropOffLocation = "".obs;
  RxString pickupLocation = "".obs;
  RxString receipientContact = "".obs;
  RxString receipientname = "".obs;
  RxString vehicleType = "".obs;
  RxString itemType = "".obs;
  RxString vehicleTypeId = "".obs;
  RxString pickupDate = "".obs;
  RxString pickupTime = "".obs;
  RxString imageUrl = "".obs;
  late DocumentSnapshot docRef;

  RxString totalAmount = "".obs;
  var deliveryAmount = "".obs;

  Rx<LatLng?> dropOffLatLng = Rx<LatLng?>(null);
  Rx<LatLng?> pickupLatLng = Rx<LatLng?>(null);
  
  // Loading flag to prevent multiple submissions
  RxBool isSaving = false.obs;
  
  // Store scheduled delivery ID for payment metadata
  RxString scheduledDeliveryId = "".obs;
}

import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/state_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:swiftrun/core/model/driver_model.dart';
import 'package:swiftrun/features/booking/model/nearby_driver_model.dart';
import 'package:swiftrun/features/booking/presentation/atoms/confirm_details/confirmation.con.dart';

class ConfirmPackageState {
  RxString paymentMethod = "".obs;
  RxBool paymentStatus = false.obs;
  RxBool isPaymentProcessing = false.obs; // New: Track payment processing state
  RxInt paymentUIUpdateTrigger = 0.obs; // New: Force UI updates
  var dropOffLocation = "".obs;
  var pickupLocation = "".obs;
  String imagePath = "";
  RxString imageUrlPath = "".obs;
  RxString? requestID = "".obs;
  RxString vehicleType = "".obs;
  RxString vehicleTypeId = "".obs;
  var itemType = "".obs;
  var receipientContact = "".obs;
  var receipientname = "".obs;
  late LatLng dropOffLatLng;
  late LatLng pickupLatLng;
  var userRideRequestStatus = UserRideRequestStatus.waiting.obs;
  RxBool isRiderRequesting = false.obs;
  RxBool fetchedDriver = false.obs;
  RxString tripAmount = "".obs;
  CloseByDriverModel? nearestDriver;
  var driverDetails = DriverModel().obs;
  RxString acceptedDriverID = "".obs;

  var driversFound = false.obs;
  var isSearchingDrivers = true.obs; // New: Loading state while searching for drivers
  bool isUpdated = false;

  var driverRideStatus = "".obs;
  var requestPositionInfo = true.obs;
  RxInt? totalDelivery = 0.obs;
  RxDouble? averageRating = 0.0.obs;
}

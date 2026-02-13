import 'package:get/get.dart';
import 'package:swiftrun/core/model/driver_model.dart';

class HistoryState {
  var driverInfo = DriverModel().obs;
  RxString? driverID = "".obs;
  RxString? requestID = "".obs; // Add request ID for rating checks
  RxInt? totalDelivery = 0.obs;
  RxDouble averageRating = 0.0.obs;
  RxBool hasRatedDriver = false.obs;
}

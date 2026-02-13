import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum WhoPays { sender, recipient }

class PaymentState {
  final RxString selectedPayment = "".obs;
  final RxBool saveCardCondidion = false.obs;
  final RxInt selectedPaymentCard = 0.obs;
  final RxBool acceptCondition = false.obs;
  var paymentModes = <String>[].obs;
  String imagePath = "";
  var dropOffLocation = "".obs;
  var pickupLocation = "".obs;
  late LatLng pickupLatLng;
  late LatLng dropOffLatLng;
  RxString vehicleType = "".obs;
  RxString vehicleTypeId = "".obs;
  var itemType = "".obs;
  var receipientContact = "".obs;
  var receipientname = "".obs;
//  WhoPays? payer;

  var whoPaysOption = WhoPays.sender.obs;
  
  // Scheduled delivery fields
  bool isScheduledDelivery = false;
  String scheduledDate = "";
  String scheduledTime = "";
}

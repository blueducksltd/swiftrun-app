import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:swiftrun/common/routes/route_name.dart';
import 'package:swiftrun/common/utils/logger.dart';
import 'package:swiftrun/common/utils/progress_indicator.dart';
import 'package:swiftrun/features/booking/presentation/atoms/confirm_details/confirm_details.dart';
import 'package:swiftrun/features/payment/presentation/card_details.dart';
import 'package:swiftrun/features/payment/state.dart';
import 'package:swiftrun/global/global.dart';
import 'package:swiftrun/services/network/network.dart';

class PaymentController extends GetxController {
  var paymentState = PaymentState();
  dynamic bookingInfosUpdate;

  @override
  void onInit() {
    super.onInit();

    // bookingInfosUpdate = Get.parameters;
    bookingInfosUpdate = Get.arguments;
    paymentState.pickupLocation.value = bookingInfosUpdate['pickupLocation'];
    paymentState.dropOffLocation.value = bookingInfosUpdate['dropOffLocation'];
    paymentState.receipientContact.value =
        bookingInfosUpdate['receipientNumber'];
    paymentState.receipientname.value = bookingInfosUpdate['receipientName'];
    paymentState.vehicleType.value = bookingInfosUpdate['vehicleType'];
    paymentState.vehicleTypeId.value = bookingInfosUpdate['vehicleTypeId'];
    paymentState.itemType.value = bookingInfosUpdate['itemType'];
    paymentState.pickupLatLng = LatLng(
      double.parse(bookingInfosUpdate['pickupLat'].toString()),
      double.parse(bookingInfosUpdate['pickupLng'].toString()),
    );
    paymentState.dropOffLatLng = LatLng(
      double.parse(bookingInfosUpdate['dropOffLat'].toString()),
      double.parse(bookingInfosUpdate['dropOffLng'].toString()),
    );
    paymentState.imagePath = bookingInfosUpdate['imagePath'];
    
    // Check if this is a scheduled delivery
    if (bookingInfosUpdate['isScheduled'] == "true") {
      paymentState.isScheduledDelivery = true;
      paymentState.scheduledDate = bookingInfosUpdate['dateScheduled'] ?? "";
      paymentState.scheduledTime = bookingInfosUpdate['timeScheduled'] ?? "";
    }
    
    fetchedPaymentMode();
  }

  setPaymentMethod(String method) {
    paymentState.selectedPayment.value = method;
  }

  setCondition(bool index) {
    paymentState.acceptCondition.value = index;
  }

  saveCardCondition(bool index) {
    paymentState.saveCardCondidion.value = index;
  }

  setCardPayment(int index) {
    paymentState.selectedPaymentCard.value = index;
  }

  // chooseWhoPays(WhoPays whoPays) {
  //   paymentState.whoPaysOption.value = whoPays;
  //   if (paymentState.whoPaysOption.value == WhoPays.recipient) {
  //     paymentState.selectedPayment.value = "recipient";
  //     log(paymentState.selectedPayment.value.toString());
  //   }
  //   debugPrint(paymentState.whoPaysOption.value.toString());
  // }
  chooseWhoPays(WhoPays whoPays) {
    paymentState.whoPaysOption.value = whoPays;
    if (paymentState.whoPaysOption.value == WhoPays.recipient) {
      paymentState.selectedPayment.value = "The Recipient";
    } else {
      // Reset to empty when sender is selected so they can choose a payment method
      paymentState.selectedPayment.value = "";
    }
  }

  Future<void> fetchedPaymentMode() async {
    try {
      List<String> fetchedPaymentMode = await getPaymentMode();
      paymentState.paymentModes.assignAll(fetchedPaymentMode);
    } catch (e) {
      // Handle any errors
      Get.snackbar("Error", "Failed to fetch vehicle types");
    }
  }

  Future<List<String>> getPaymentMode() async {
    List<String> paymentModes = [];
    try {
      QuerySnapshot snapshot = await fDataBase
          .collection("PaymentMode")
          .where("status", isEqualTo: "Active")
          .get();
      for (var docResult in snapshot.docs) {
        var docResults = docResult.data() as Map<String, dynamic>;
        var paymentMode = docResults['mode'];
        paymentModes.add(paymentMode);
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        Logger.error("Error fetching payment modes: $error", stackTrace: stackTrace);
      }
      return [];
    }
    return paymentModes;
  }

  // goToPackageDetails() async {
  //   Map<String, dynamic> data = {
  //     "vehicleType": paymentState.vehicleType.value,
  //     "vehicleTypeId": paymentState.vehicleTypeId.value,
  //     "pickupLocation": paymentState.pickupLocation.value,
  //     "dropOffLocation": paymentState.dropOffLocation.value,
  //     "itemType": paymentState.itemType.value,
  //     "receipientName": paymentState.receipientname.value,
  //     "receipientNumber": paymentState.receipientContact.value,
  //     "paymentMethod": paymentState.selectedPayment.value,
  //     "pickupLatLng": paymentState.pickupLatLng,
  //     "dropOffLatLng": paymentState.dropOffLatLng,
  //     "imagePath": paymentState.imagePath,
  //   };
  //   ProgressDialogUtils.showProgressDialog();
  //   await Network.getRiderDirection(
  //     paymentState.pickupLatLng,
  //     paymentState.dropOffLatLng,
  //   );
  //   ProgressDialogUtils.hideProgressDialog();
  //   Get.to(() => const ConfirmDeliveryScreen(fromPage: 0), arguments: data);
  //
  //   log("From Package Details $bookingInfosUpdate");
  // }

  // And update your goToPackageDetails method to better handle the payment method:
  goToPackageDetails() async {
    String finalPaymentMethod;

    if (paymentState.whoPaysOption.value == WhoPays.recipient) {
      finalPaymentMethod = "The Recipient";
    } else {
      finalPaymentMethod = paymentState.selectedPayment.value;
    }

    // Check if this is a scheduled delivery
    if (paymentState.isScheduledDelivery) {
      // For scheduled delivery, go to schedule confirmation screen
      Map<String, String> scheduleData = {
        "vehicleType": paymentState.vehicleType.value,
        "vehicleTypeId": paymentState.vehicleTypeId.value,
        "pickupAddress": paymentState.pickupLocation.value,
        "dropOffAddress": paymentState.dropOffLocation.value,
        "items": paymentState.itemType.value,
        "receipientName": paymentState.receipientname.value,
        "receipientNumber": paymentState.receipientContact.value,
        "paymentMethod": finalPaymentMethod,
        "pickupLat": paymentState.pickupLatLng.latitude.toString(),
        "pickupLng": paymentState.pickupLatLng.longitude.toString(),
        "dropOffLat": paymentState.dropOffLatLng.latitude.toString(),
        "dropOffLng": paymentState.dropOffLatLng.longitude.toString(),
        "imageUrl": paymentState.imagePath,
        "dateScheduled": paymentState.scheduledDate,
        "timeScheduled": paymentState.scheduledTime,
      };

      ProgressDialogUtils.showProgressDialog();
      await Network.getRiderDirection(
        paymentState.pickupLatLng,
        paymentState.dropOffLatLng,
      );
      ProgressDialogUtils.hideProgressDialog();
      Get.toNamed(AppRoutes.scheduleDelivery, arguments: scheduleData);
    } else {
      // For instant delivery, go to instant confirmation screen
    Map<String, dynamic> data = {
      "vehicleType": paymentState.vehicleType.value,
      "vehicleTypeId": paymentState.vehicleTypeId.value,
      "pickupLocation": paymentState.pickupLocation.value,
      "dropOffLocation": paymentState.dropOffLocation.value,
      "itemType": paymentState.itemType.value,
      "receipientName": paymentState.receipientname.value,
      "receipientNumber": paymentState.receipientContact.value,
      "paymentMethod": finalPaymentMethod, // Use the processed payment method
      "pickupLatLng": paymentState.pickupLatLng,
      "dropOffLatLng": paymentState.dropOffLatLng,
      "imagePath": paymentState.imagePath,
    };

    ProgressDialogUtils.showProgressDialog();
    await Network.getRiderDirection(
      paymentState.pickupLatLng,
      paymentState.dropOffLatLng,
    );
    ProgressDialogUtils.hideProgressDialog();
    Get.to(() => const ConfirmDeliveryScreen(fromPage: 0), arguments: data);
    }
  }

  goToCardDetails() async {
    Map<String, dynamic> data = {
      "vehicleType": paymentState.vehicleType.value,
      "vehicleTypeId": paymentState.vehicleTypeId.value,
      "pickupLocation": paymentState.pickupLocation.value,
      "dropOffLocation": paymentState.dropOffLocation.value,
      "itemType": paymentState.itemType.value,
      "receipientName": paymentState.receipientname.value,
      "receipientNumber": paymentState.receipientContact.value,
      "paymentMethod": paymentState.selectedPayment.value,
      "pickupLatLng": paymentState.pickupLatLng,
      "dropOffLatLng": paymentState.dropOffLatLng,
      "imagePath": paymentState.imagePath,
    };

    Get.to(() => const CardDetailsScreen(), arguments: data);
  }
}

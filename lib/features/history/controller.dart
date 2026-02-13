import 'dart:developer';

import 'package:get/get.dart';
import 'package:swiftrun/common/utils/geofire_assistant.dart';
import 'package:swiftrun/common/utils/logger.dart';
import 'package:swiftrun/features/history/history_state.dart';
import 'package:swiftrun/global/global.dart';

class HistoryController extends GetxController {
  static HistoryController get to => Get.find();

  var historyState = HistoryState();
  dynamic driverid;

  @override
  void onInit() {
    log('Initializing with arguments: ${Get.arguments}');
    driverid = Get.arguments;
    if (driverid != null && driverid["driverID"] != null) {
      historyState.driverID!.value = driverid["driverID"];
      log('Driver ID set: ${historyState.driverID!.value}');
      getDriverDetails();
      getRatingAndDeliveries();
    } else {
      log('Driver info or driverID is null - will be set manually');
    }
    super.onInit();
  }

  getDriverDetails() async {
    try {
      log("Fetching driver details for ID: ${historyState.driverID!.value}");
      var details =
          await GeoFireAssistant.getDriverDetails(historyState.driverID!.value);
      if (details != null) {
        historyState.driverInfo.value = details;
        log("Driver details fetched: ${historyState.driverInfo.value.firstName}");
        log("Driver picture path: ${historyState.driverInfo.value.picturePath}");
      } else {
        log("Driver details not found for ID: ${historyState.driverID!.value}");
      }
    } catch (e) {
      log("Error fetching driver details: $e");
    }
  }

  Future<void> getRatingAndDeliveries() async {
    try {
      Map<String, dynamic> stats =
          await GeoFireAssistant.getTotalDeliveredAndRating(
              driverID: historyState.driverID!.value);

      // Ensure we have valid data
      if (stats.containsKey('error')) {
        Logger.error("Error fetching rating data: ${stats['error']}");
        historyState.averageRating.value = 0.0;
        historyState.totalDelivery!.value = 0;
        return;
      }

      // Update with fetched data
      historyState.averageRating.value = (stats['averageRating'] ?? 0.0).toDouble();
      historyState.totalDelivery!.value = stats['totalDeliveries'] ?? 0;

      Logger.i("Rating data updated - Average: ${historyState.averageRating.value}, Deliveries: ${historyState.totalDelivery!.value}");

      // Check if current user has already rated this driver
      checkIfUserHasRated();
    } catch (e) {
      Logger.error("Error in getRatingAndDeliveries: $e");
      historyState.averageRating.value = 0.0;
      historyState.totalDelivery!.value = 0;
    }
  }

  // Method to refresh rating data after a new rating is submitted
  Future<void> refreshRatingData() async {
    if (historyState.driverID!.value.isNotEmpty) {
      await getRatingAndDeliveries();
    }
  }

  // Method to force refresh rating data by bypassing cache
  Future<void> getRatingAndDeliveriesForceRefresh() async {
    try {
      // Clear any existing data first
      historyState.averageRating.value = 0.0;
      historyState.totalDelivery!.value = 0;

      Map<String, dynamic> stats =
          await GeoFireAssistant.getTotalDeliveredAndRatingForceRefresh(
              historyState.driverID!.value);

      // Ensure we have valid data
      if (stats.containsKey('error')) {
        Logger.error("Error force fetching rating data: ${stats['error']}");
        historyState.averageRating.value = 0.0;
        historyState.totalDelivery!.value = 0;
        return;
      }

      // Update with fetched data using the same unified system
      double newRating = (stats['averageRating'] ?? 0.0).toDouble();
      int newDeliveries = stats['totalDeliveries'] ?? 0;

      historyState.averageRating.value = newRating;
      historyState.totalDelivery!.value = newDeliveries;

      Logger.i("History rating data force refreshed:");
      Logger.i("- Driver ID: ${historyState.driverID!.value}");
      Logger.i("- Average Rating: ${historyState.averageRating.value}");
      Logger.i("- Total Deliveries: ${historyState.totalDelivery!.value}");
      Logger.i("- Raw stats: $stats");

      // Check if current user has already rated this driver
      checkIfUserHasRated();
    } catch (e) {
      Logger.error("Error in getRatingAndDeliveriesForceRefresh: $e");
      historyState.averageRating.value = 0.0;
      historyState.totalDelivery!.value = 0;
    }
  }

  void checkIfUserHasRated() async {
    try {
      String currentUser = firebaseAuth.currentUser!.uid;
      if (currentUser.isNotEmpty && historyState.requestID!.value.isNotEmpty) {

        log('🔍 Checking rating status for trip: ${historyState.requestID!.value}');

        // METHOD 1: Check DriversRatings collection for this specific trip
        var ratingsQuery = await fDataBase
            .collection("DriversRatings")
            .where("customerId", isEqualTo: currentUser)
            .where("tripId", isEqualTo: historyState.requestID!.value)
            .get();

        bool hasRatingRecord = ratingsQuery.docs.isNotEmpty;

        // METHOD 2: Check DeliveryRequests document
        var deliveryDoc = await fDataBase
            .collection("DeliveryRequests")
            .doc(historyState.requestID!.value)
            .get();

        bool hasRatedInDelivery = false;
        if (deliveryDoc.exists) {
          var deliveryData = deliveryDoc.data() as Map<String, dynamic>;
          hasRatedInDelivery = deliveryData['ratingSubmitted'] == true ||
                              deliveryData['driverRating'] != null;

          log('📋 DeliveryRequest check:');
          log('  - ratingSubmitted: ${deliveryData['ratingSubmitted']}');
          log('  - driverRating: ${deliveryData['driverRating']}');
        }

        // Trip is rated if EITHER method confirms it
        bool hasRatedThisTrip = hasRatingRecord || hasRatedInDelivery;
        historyState.hasRatedDriver.value = hasRatedThisTrip;

        log('✅ Rating status summary:');
        log('  - Trip ID: ${historyState.requestID!.value}');
        log('  - Has Rating Record: $hasRatingRecord');
        log('  - Has Rated in Delivery: $hasRatedInDelivery');
        log('  - Final Status: ${hasRatedThisTrip ? "RATED ✓" : "NOT RATED ✗"}');

        // If there's inconsistency, log it
        if (hasRatingRecord != hasRatedInDelivery) {
          log('⚠️ INCONSISTENCY DETECTED:');
          log('  - DriversRatings says: ${hasRatingRecord ? "RATED" : "NOT RATED"}');
          log('  - DeliveryRequests says: ${hasRatedInDelivery ? "RATED" : "NOT RATED"}');

          // Auto-fix: If there's a rating record but delivery not marked
          if (hasRatingRecord && !hasRatedInDelivery) {
            var ratingDoc = ratingsQuery.docs.first;
            var ratingData = ratingDoc.data();
            log('🔧 Auto-fixing: Updating DeliveryRequest with rating data');
            try {
              await fDataBase.collection("DeliveryRequests")
                  .doc(historyState.requestID!.value)
                  .update({
                'driverRating': ratingData['rating'],
                'ratingSubmitted': true,
                'ratingDate': ratingData['dateCreated'],
              });
              log('✅ Auto-fix successful');
            } catch (e) {
              log('❌ Auto-fix failed: $e');
            }
          }
        }

      } else {
        log('⚠️ Cannot check rating: currentUser=$currentUser, requestID=${historyState.requestID!.value}');
        historyState.hasRatedDriver.value = false;
      }
    } catch (e) {
      log('❌ Error checking if user has rated: $e');
      historyState.hasRatedDriver.value = false;
    }
  }

  // @override
  // void onClose() {
  //   super.onClose();
  // }
}

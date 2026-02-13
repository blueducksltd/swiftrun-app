import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swiftrun/features/rating/state.dart';
import 'package:swiftrun/features/history/controller.dart';
import 'package:swiftrun/features/tracking/controller.dart';
import 'package:swiftrun/global/global.dart';
import 'package:swiftrun/common/routes/route_name.dart';

class RatingController extends GetxController {
  RatingState ratingState = RatingState();

  @override
  void onInit() {
    super.onInit();
    _initializeRating();
  }

  Future<void> _initializeRating() async {
    var arguments = Get.arguments;

    if (arguments != null && arguments is Map<String, dynamic>) {
      ratingState.driverId = arguments['driverId'];
      ratingState.tripId = arguments['tripId'] ?? arguments['requestId'] ?? "";

      // Check if tripId is empty and try to get it from other sources
      if (ratingState.tripId == null || ratingState.tripId!.isEmpty) {
        // Try to get tripId from other possible argument names
        ratingState.tripId = arguments['tripId'] ??
                            arguments['requestId'] ??
                            arguments['request_id'] ??
                            arguments['trip_id'] ??
                            arguments['docId'] ??
                            arguments['documentId'] ?? "";

        // If still empty, try to find the most recent delivery request for this user
        if (ratingState.tripId == null || ratingState.tripId!.isEmpty) {
          await findRecentDeliveryRequest();
        }
      }

      // Verify the driver exists in the Drivers collection
      _verifyDriverExists();
    }
    super.onInit();
  }

  // Find the most recent delivery request for this user and driver
  Future<void> findRecentDeliveryRequest() async {
    try {
      String currentUser = firebaseAuth.currentUser!.uid;
      if (currentUser.isNotEmpty && ratingState.driverId != null && ratingState.driverId!.isNotEmpty) {
        // SIMPLIFIED: Since driver ID is only assigned when accepted, this is always correct
        var query = await fDataBase
            .collection("DeliveryRequests")
            .where("userID", isEqualTo: currentUser)
            .where("driverID", isEqualTo: ratingState.driverId)
            .where("status", isEqualTo: "ended")
            .orderBy("dateCreated", descending: true)
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          var doc = query.docs.first;
          ratingState.tripId = doc.id;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error finding recent delivery request: $e');
      }
    }
  }

  // Verify that the driver exists in the Drivers collection
  Future<void> _verifyDriverExists() async {
    if (ratingState.driverId != null && ratingState.driverId!.isNotEmpty) {
      try {
        var driverDoc = await fDataBase.collection("Drivers").doc(ratingState.driverId).get();
        if (!driverDoc.exists) {
          if (kDebugMode) {
            print('❌ Driver not found in Drivers collection: ${ratingState.driverId}');
          }
        }

        // Also verify the driver ID from the delivery request document
        if (ratingState.tripId != null && ratingState.tripId!.isNotEmpty) {
          var deliveryDoc = await fDataBase.collection("DeliveryRequests").doc(ratingState.tripId).get();
          if (deliveryDoc.exists) {
            var deliveryData = deliveryDoc.data() as Map<String, dynamic>;
            String deliveryDriverId = deliveryData['driverID'] ?? '';

            if (deliveryDriverId != ratingState.driverId) {
              if (kDebugMode) {
                print('⚠️ WARNING: Driver ID mismatch! Delivery request has $deliveryDriverId but rating will go to ${ratingState.driverId}');
              }
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Error verifying driver existence: $e');
        }
      }
    }
  }

  void rateDriver() async {
    String currentUser = firebaseAuth.currentUser!.uid;

    if (currentUser.isEmpty) {
      Get.snackbar('Error', 'User not logged in');
      return;
    }

    if (ratingState.driverId == null || ratingState.driverId!.isEmpty) {
      Get.snackbar('Error', 'Driver information not found');
      return;
    }

    // Validate rating is not 0
    if (ratingState.initialRating <= 0) {
      Get.snackbar(
        'Rating Required',
        'Please select a rating from 1 to 5 stars',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Show loading indicator
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    // Add timeout to prevent hanging
    try {
      await Future.any([
        _performRatingSubmission(),
        Future.delayed(const Duration(seconds: 30), () {
          throw TimeoutException('Rating submission timed out', const Duration(seconds: 30));
        }),
      ]);
    } catch (e) {
      Get.back(); // Close loading dialog
      if (e is TimeoutException) {
        Get.snackbar('Error', 'Rating submission timed out. Please try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar('Error', 'Failed to submit rating: ${e.toString()}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      return;
    }
  }

  Future<void> _performRatingSubmission() async {
    try {
      // Get current user ID
      String currentUser = firebaseAuth.currentUser!.uid;

      // Step 1: Check if user has already rated this driver
      var existingRating = await fDataBase
          .collection("DriversRatings")
          .where("customerId", isEqualTo: currentUser)
          .where("driverId", isEqualTo: ratingState.driverId)
          .get();

      // Check if there's a rating for this specific trip
      bool hasRatedThisTrip = false;
      if (ratingState.tripId != null && ratingState.tripId!.isNotEmpty) {
        for (var doc in existingRating.docs) {
          var data = doc.data();
          if (data['tripId'] == ratingState.tripId) {
            hasRatedThisTrip = true;
            break;
          }
        }
      }

      // Also check if the delivery request already has a rating
      bool deliveryRequestRated = false;
      if (ratingState.tripId != null && ratingState.tripId!.isNotEmpty) {
        try {
          var deliveryDoc = await fDataBase.collection("DeliveryRequests").doc(ratingState.tripId!).get();
          if (deliveryDoc.exists) {
            var deliveryData = deliveryDoc.data() as Map<String, dynamic>;
            deliveryRequestRated = deliveryData['ratingSubmitted'] == true || deliveryData['driverRating'] != null;
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Error checking delivery request rating status: $e');
          }
        }
      }

      // If there's a rating in DriversRatings but not in DeliveryRequests, fix the inconsistency
      if (hasRatedThisTrip && !deliveryRequestRated) {
        try {
          await fDataBase.collection("DeliveryRequests").doc(ratingState.tripId!).update({
            'driverRating': ratingState.initialRating,
            'ratingSubmitted': true,
            'ratingDate': FieldValue.serverTimestamp(),
          });

          Get.back(); // Close loading dialog
          Get.snackbar('Info', 'Rating already submitted for this trip');
          return;
        } catch (e) {
          if (kDebugMode) {
            print('❌ Error fixing inconsistent rating records: $e');
          }
        }
      }

      if (hasRatedThisTrip && deliveryRequestRated) {
        Get.back(); // Close loading dialog
        Get.snackbar('Info', 'You have already rated this driver for this trip');
        return;
      }

      // Step 2: Verify driver exists
      var driverDoc = await fDataBase.collection("Drivers").doc(ratingState.driverId!).get();
      if (!driverDoc.exists) {
        Get.back(); // Close loading dialog
        Get.snackbar('Error', 'Driver not found');
        return;
      }

      // Step 3: Create rating data with unique ID
      String ratingId = fDataBase.collection("DriversRatings").doc().id;
      Map<String, dynamic> ratingData = {
        "id": ratingId,
        "customerId": currentUser,
        "driverId": ratingState.driverId,
        "comment": ratingState.commentController.text.trim(),
        "dateCreated": FieldValue.serverTimestamp(),
        "rating": ratingState.initialRating,
        "tripId": ratingState.tripId ?? "", // Add trip ID if available
      };

      // Step 4: Save rating first (without transaction to avoid complexity)
      try {
        await fDataBase.collection("DriversRatings").doc(ratingId).set(ratingData);

        // Step 5: Update driver's rating stats
        var driverData = driverDoc.data() as Map<String, dynamic>;
        double currentAverage = (driverData['averageRating'] ?? 0.0).toDouble();
        int currentCount = driverData['totalRatings'] ?? 0;

        // Calculate new average
        double newTotal = (currentAverage * currentCount) + ratingState.initialRating;
        int newCount = currentCount + 1;
        double newAverage = newTotal / newCount;

        await fDataBase.collection("Drivers").doc(ratingState.driverId!).update({
          'averageRating': newAverage,
          'totalRatings': newCount,
          'lastRatingUpdate': FieldValue.serverTimestamp(),
        });

        // Step 6: Update the delivery request with the rating
        if (ratingState.tripId != null && ratingState.tripId!.isNotEmpty) {
          try {
            await fDataBase.collection("DeliveryRequests").doc(ratingState.tripId!).update({
              'driverRating': ratingState.initialRating,
              'ratingSubmitted': true,
              'ratingDate': FieldValue.serverTimestamp(),
            });
          } catch (e) {
            if (kDebugMode) {
              print('❌ Error updating delivery request: $e');
            }
            // Don't fail the entire rating process if delivery request update fails
          }
        }

      } catch (e, stackTrace) {
        if (kDebugMode) {
          print('❌ Error saving rating: $e');
          print('❌ Stack trace: $stackTrace');
        }
        Get.back(); // Close loading dialog
        Get.snackbar('Error', 'Failed to save rating: $e');
        return;
      }

      // Step 7: Verify the rating was saved
      var savedRating = await fDataBase.collection("DriversRatings").doc(ratingId).get();
      if (!savedRating.exists) {
        Get.back(); // Close loading dialog
        Get.snackbar('Error', 'Rating verification failed');
        return;
      }

      // Step 8: Update UI controllers
      await _updateAllControllers();

      // Step 9: Close loading and show success
      Get.back(); // Close loading dialog
      Get.snackbar('Success', 'Rating submitted successfully!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Step 10: Navigate back to dashboard
      await Future.delayed(const Duration(seconds: 1));
      Get.offAllNamed(AppRoutes.dashboard);

    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error submitting rating: $e');
        print('📋 Stack trace: $stackTrace');
      }

      Get.back(); // Close loading dialog
      Get.snackbar('Error', 'Failed to submit rating. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }



  // DEBUG METHOD: Reset rating status for a trip (for testing)
  Future<void> resetTripRatingStatus() async {
    if (ratingState.tripId != null && ratingState.tripId!.isNotEmpty) {
      try {
        // Reset delivery request rating status
        await fDataBase.collection("DeliveryRequests").doc(ratingState.tripId!).update({
          'driverRating': null,
          'ratingSubmitted': false,
          'ratingDate': null,
        });
      } catch (e) {
        if (kDebugMode) {
          print('🔧 DEBUG: Error resetting trip rating status: $e');
        }
      }
    }
  }

  // DEBUG METHOD: Clear inconsistent rating records
  Future<void> clearInconsistentRatings() async {
    try {
      String currentUser = firebaseAuth.currentUser!.uid;
      if (currentUser.isNotEmpty && ratingState.driverId != null && ratingState.driverId!.isNotEmpty) {
        // Find all ratings for this user-driver combination
        var ratingsQuery = await fDataBase
            .collection("DriversRatings")
            .where("customerId", isEqualTo: currentUser)
            .where("driverId", isEqualTo: ratingState.driverId)
            .get();

        // Delete all existing ratings for this user-driver combination
        for (var doc in ratingsQuery.docs) {
          await fDataBase.collection("DriversRatings").doc(doc.id).delete();
        }

        // Reset delivery request if we have a trip ID
        if (ratingState.tripId != null && ratingState.tripId!.isNotEmpty) {
          await fDataBase.collection("DeliveryRequests").doc(ratingState.tripId!).update({
            'driverRating': null,
            'ratingSubmitted': false,
            'ratingDate': null,
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔧 DEBUG: Error clearing inconsistent ratings: $e');
      }
    }
  }

  // Helper method to update all controllers
  Future<void> _updateAllControllers() async {
    try {
      // Update history controller
      if (Get.isRegistered<HistoryController>()) {
        var historyController = Get.find<HistoryController>();
        historyController.historyState.hasRatedDriver.value = true;
        await historyController.getRatingAndDeliveriesForceRefresh();
      }

      // Update tracking controller
      if (Get.isRegistered<TrackingController>()) {
        var trackingController = Get.find<TrackingController>();
        trackingController.getRatingAndTotalDeliveryForceRefresh();
      }

      // Note: No need to manually refresh HomeController - its persistent 
      // Firestore listener will automatically detect any changes to delivery documents

    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Critical error in _performRatingSubmission: $e');
        print('❌ Stack trace: $stackTrace');
      }
      Get.back(); // Close loading dialog
      Get.snackbar('Critical Error', 'Rating submission failed: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

}

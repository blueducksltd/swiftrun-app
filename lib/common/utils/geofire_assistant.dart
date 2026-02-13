import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For compute()
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:swiftrun/common/utils/utils.dart';
import 'package:swiftrun/core/model/driver_model.dart';
import 'package:swiftrun/features/booking/model/nearby_driver_model.dart';
import 'package:swiftrun/global/global.dart';

class GeoFireAssistant {
  static List<CloseByDriverModel> nearestDrivers = [];
  static late Stream<List<DocumentSnapshot>> stream;
  static late StreamSubscription<DocumentSnapshot>? tripStreamSubscription;

  static void deleteOfflineDriverFromList(String driverId) {
    int indexNumber =
        nearestDrivers.indexWhere((element) => element.driversId == driverId);
    if (indexNumber != -1) {
      nearestDrivers.removeAt(indexNumber);
      Logger.i("Removed driver $driverId from list");
    } else {
      Logger.i("Driver $driverId not found in list - already removed");
    }
  }

  static void updateCloseByDrivers(CloseByDriverModel closeByDriverModel) {
    int indexNumber = nearestDrivers.indexWhere(
        (element) => element.driversId == closeByDriverModel.driversId);

    nearestDrivers[indexNumber].latitude = closeByDriverModel.latitude;
    nearestDrivers[indexNumber].longitude = closeByDriverModel.longitude;
    log("updateCloseByDrivers");
  }

  static Future<DriverModel?> getDriverDetails(String driverID) async {
    try {
      Logger.i("Fetching driver details for ID: $driverID");
      final docSnapshot =
          await fDataBase.collection("Drivers").doc(driverID).get();
      if (docSnapshot.exists) {
        var data = docSnapshot.data() as Map<String, dynamic>;
        Logger.i("Raw driver data: $data");
        Logger.i("Profile picture URL: ${data['profilePic']}");

        var driverModel = DriverModel.fromJson(data);
        Logger.i(
            "Parsed driver model: firstName=${driverModel.firstName}, picturePath=${driverModel.picturePath}");
        return driverModel;
      } else {
        Logger.error("Driver not found for ID: $driverID");
        return null;
      }
    } catch (e) {
      Logger.error("Error fetching driver details: $e");
      return null;
    }
  }

  static Future<Map<String, List<DocumentSnapshot>>>
      getDeliveriesHistory() async {
    try {
      if (currentUser == null) {
        return {};
      }

      // Fetch instant delivery requests from Firestore
      // Include all statuses except 'waiting' (pending requests)
      // This includes: ended, cancelled, declined, accepted, arrived, onTrip
      final requestData = await fDataBase
          .collection("DeliveryRequests")
          .where("userID", isEqualTo: currentUser!.uid)
          .where("status", isNotEqualTo: "waiting")
          .orderBy("dateCreated", descending: true)
          .get();

      // Fetch scheduled delivery requests
      final scheduledData = await fDataBase
          .collection("ScheduleRequest")
          .where("userID", isEqualTo: currentUser!.uid)
          .orderBy("dateCreated", descending: true)
          .get();

      // Group the documents by status
      Map<String, List<DocumentSnapshot>> groupedData = {};

      // Add instant deliveries
      for (var doc in requestData.docs) {
        String status = doc['status'];
        if (!groupedData.containsKey(status)) {
          groupedData[status] = [];
        }
        groupedData[status]!.add(doc);
      }

      // Add scheduled deliveries
      for (var doc in scheduledData.docs) {
        String status = doc['status'];
        if (status.isNotEmpty) {
          if (!groupedData.containsKey(status)) {
            groupedData[status] = [];
          }
          groupedData[status]!.add(doc);
        }
      }

      log("Active ${currentUser!.uid}");
      Logger.i(groupedData);
      // Return the grouped data
      return groupedData;
    } catch (e, stackTrace) {
      log("Error getting request $e, $stackTrace");
      return {};
    }
  }

  static void onSendCallInvitationFinished(
    String code,
    String message,
    List<String> errorInvitees,
  ) {
    if (errorInvitees.isNotEmpty) {
      var userIDs = '';
      for (var index = 0; index < errorInvitees.length; index++) {
        if (index >= 5) {
          userIDs += '... ';
          break;
        }

        final userID = errorInvitees.elementAt(index);
        userIDs += '$userID ';
      }
      if (userIDs.isNotEmpty) {
        userIDs = userIDs.substring(0, userIDs.length - 1);
      }

      var message = "User doesn't exist or is offline: $userIDs";
      if (code.isNotEmpty) {
        message += ', code: $code, message:$message';
      }
      toastification.show(
        title: Text(message),
        autoCloseDuration: const Duration(milliseconds: 2300),
        alignment: Alignment.topCenter,
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        showProgressBar: false,
      );
    } else if (code.isNotEmpty) {
      toastification.show(
        title: Text('code: $code, message:$message'),
        autoCloseDuration: const Duration(milliseconds: 2300),
        alignment: Alignment.topCenter,
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        showProgressBar: false,
      );
    }
  }

  static Future<Map<String, dynamic>> getTotalDeliveredAndRating(
      {required String driverID}) async {
    int totalDeliveries = 0;
    double averageRating = 0.0;

    var currentUser = firebaseAuth.currentUser?.uid;
    if (currentUser == null) {
      return {'error': 'User not logged in'};
    }

    try {
      // Fetch total completed deliveries
      QuerySnapshot deliverySnap = await fDataBase
          .collection("DeliveryRequests")
          .where("driverID", isEqualTo: driverID)
          .where("status", isEqualTo: "ended")
          .get();

      totalDeliveries = deliverySnap.size;

      // Skip cached rating to ensure accuracy - always calculate fresh
      Logger.i("Calculating fresh rating data for driver: $driverID");

      // If no cached rating, calculate from DriversRatings collection
      QuerySnapshot ratingSnap = await fDataBase
          .collection("DriversRatings")
          .where("driverId", isEqualTo: driverID)
          .get();

      Logger.i(
          "Calculating rating from ${ratingSnap.size} ratings for driver: $driverID");

      // Convert QuerySnapshot to a List of Maps for background processing
      List<Map<String, dynamic>> ratingsData = ratingSnap.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // Use compute() to calculate ratings on background thread
      Map<String, dynamic> calculationResult = await compute(
        _calculateRatingsInBackground,
        ratingsData,
      );

      averageRating = calculationResult['averageRating'] as double;
      int ratingCount = calculationResult['ratingCount'] as int;

      Logger.i(
          "Final rating calculation for driver $driverID: Average=$averageRating, Deliveries=$totalDeliveries, RatingCount=$ratingCount");

      return {
        'totalDeliveries': totalDeliveries,
        'averageRating': averageRating,
      };
    } catch (e, stackTrace) {
      Logger.error("Error fetching data: $e \n$stackTrace");
      return {'error': e.toString()};
    }
  }

  // Method to force refresh rating data by bypassing cache
  static Future<Map<String, dynamic>> getTotalDeliveredAndRatingForceRefresh(
      String driverID) async {
    try {
      Logger.i("Force refreshing rating data for driver: $driverID");

      // Always calculate from scratch, bypassing any cached data
      QuerySnapshot deliverySnap = await fDataBase
          .collection("DeliveryRequests")
          .where("driverID", isEqualTo: driverID)
          .where("status", isEqualTo: "ended")
          .get();

      int totalDeliveries = deliverySnap.size;

      // Calculate rating from DriversRatings collection
      QuerySnapshot ratingSnap = await fDataBase
          .collection("DriversRatings")
          .where("driverId", isEqualTo: driverID)
          .get();

      Logger.i(
          "Force refresh - Calculating rating from ${ratingSnap.size} ratings for driver: $driverID");

      // Convert QuerySnapshot to a List of Maps that can be passed to compute()
      List<Map<String, dynamic>> ratingsData = ratingSnap.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // Use compute() to calculate ratings on background thread (isolate)
      // This prevents blocking the main thread with heavy calculations
      Map<String, dynamic> calculationResult = await compute(
        _calculateRatingsInBackground,
        ratingsData,
      );

      double averageRating = calculationResult['averageRating'] as double;

      Logger.i(
          "Force refresh result - Average: $averageRating, Deliveries: $totalDeliveries");

      return {
        'totalDeliveries': totalDeliveries,
        'averageRating': averageRating,
      };
    } catch (e, stackTrace) {
      Logger.error("Error force refreshing data: $e \n$stackTrace");
      return {'error': e.toString()};
    }
  }

  // Static function to run in background isolate
  // Must be top-level or static, cannot access instance variables
  static Map<String, dynamic> _calculateRatingsInBackground(
      List<Map<String, dynamic>> ratingsData) {
    double totalRating = 0.0;
    int ratingCount = 0;

    for (var data in ratingsData) {
      if (data.containsKey("rating")) {
        double rating = (data["rating"] as num).toDouble();
        totalRating += rating;
        ratingCount += 1;
      }
    }

    // Calculate average rating - only if there are actual ratings
    double averageRating = ratingCount > 0 ? totalRating / ratingCount : 0.0;

    return {
      'averageRating': averageRating,
      'ratingCount': ratingCount,
    };
  }
}

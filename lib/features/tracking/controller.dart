// import 'dart:async';
// import 'dart:developer';
// import 'dart:math' as maths;
//
// import 'package:flutter/material.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:toastification/toastification.dart';
// import 'package:swiftrun/common/styles/style.dart';
// import 'package:swiftrun/common/utils/geofire_assistant.dart';
// import 'package:swiftrun/common/utils/utils.dart';
// import 'package:swiftrun/core/controller/location_controller.dart';
// import 'package:swiftrun/core/controller/session_controller.dart';
// import 'package:swiftrun/core/model/direction_model.dart';
// import 'package:swiftrun/features/booking/model/delivery_request_model.dart';
// import 'package:swiftrun/features/booking/presentation/atoms/confirm_details/confirmation.con.dart';
// import 'package:swiftrun/features/rating/view.dart';
// import 'package:swiftrun/features/tracking/state.dart';
// import 'package:swiftrun/global/global.dart';
// import 'package:swiftrun/services/network/network.dart';
//
// class TrackingController extends GetxController {
//   static TrackingController get to => Get.find();
//   var trackingState = TrackingStates();
//   var locationController = Get.put(LocationController());
//   var sesssionController = Get.put(SessionController());
//
//   GoogleMapController? googleMapController;
//   Completer<GoogleMapController> mapControllerDriver = Completer();
//   // final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
//
//   dynamic requestInfos;
//
//   @override
//   void onInit() {
//     super.onInit();
//
//     requestInfos = Get.arguments;
//     trackingState.driverID!.value = requestInfos['driverID'];
//
//     trackingState.docRef = requestInfos['request'];
//
//     trackingState.requestData =
//         trackingState.docRef.data() as Map<String, dynamic>;
//
//     trackingState.pickupLatLng.value = LatLng(
//         trackingState.requestData['pickupLatLng']['latitude'],
//         trackingState.requestData['pickupLatLng']['longitude']);
//     trackingState.dropOffLatLng.value = LatLng(
//         trackingState.requestData['dropOffLatLng']['latitude'],
//         trackingState.requestData['dropOffLatLng']['longitude']);
//     getRealTimeLocation();
//     getRiderDriverStatus();
//     getRatingAndTotalDelivery();
//   }
//
//
//
//   void onMapCreated(GoogleMapController controller) async {
//     mapControllerDriver.complete(controller);
//     googleMapController = controller;
//
//     _addMarker();
//   }
//
//   final initalLocation = const CameraPosition(
//     zoom: 12,
//     bearing: 192.8334901395799,
//     tilt: 59.440717697143555,
//     target: LatLng(
//       5.498073099999999,
//       7.0215017,
//     ),
//   );
//
//   getRealTimeLocation() {
//     log("getRealTime");
//     trackingState.realTimeLocation = fDataBase
//         .collection("DriverLocation")
//         .doc(trackingState.driverID!.value)
//         .snapshots()
//         .listen((event) async {
//       try {
//         if (event.exists) {
//           final result = event.data() as Map<String, dynamic>;
//           trackingState.driverPosition.value = LatLng(
//             double.parse(result['latitude']),
//             double.parse(result['longitude']),
//           );
//
//           log("realLocation ${trackingState.driverPosition}");
//           _animateCameraToPosition(trackingState.driverPosition.value!);
//           // _addMarker();
//         }
//       } catch (e, stacktrace) {
//         Logger.error(e, stackTrace: stacktrace);
//       }
//     }, onError: (error) {
//       log("snapShot error: $error");
//     });
//   }
//
//   void _animateCameraToPosition(LatLng position) {
//     final pickupLocation = trackingState.pickupLatLng.value;
//
//     if (pickupLocation == null) return;
//
//     // Calculate the bounds to include both the driver and pickup locations
//     LatLngBounds bounds = LatLngBounds(
//       southwest: LatLng(
//         maths.min(position.latitude, pickupLocation.latitude),
//         maths.min(position.longitude, pickupLocation.longitude),
//       ),
//       northeast: LatLng(
//         maths.max(position.latitude, pickupLocation.latitude),
//         maths.max(position.longitude, pickupLocation.longitude),
//       ),
//     );
//
//     // LatLngBounds bounds = _calculateBounds(pickupLocation, liveLocation);
//
//     // Animate camera to include both positions
//     googleMapController
//         ?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 65));
//   }
//
//   getDriverDetails() async {
//     try {
//       var details = await GeoFireAssistant.getDriverDetails(
//           trackingState.driverID!.value);
//       if (details != null) {
//         trackingState.driverInfo.value = details;
//
//         log(trackingState.docRef.id);
//         // log("Return ${trackingState.docRefID}");
//         log("Data ${trackingState.requestData['recipientName']}");
//         log("Driver details fetched: ${trackingState.driverInfo.value.firstName}");
//         log("Driver details fetched: ${trackingState.driverInfo.value.driversId}");
//       } else {
//         log("Driver details not found for ID: ${trackingState.driverID!.value}");
//       }
//     } catch (e) {
//       log("Error fetching driver details: $e");
//     }
//   }
//
//   getRiderDriverStatus() {
//     GeoFireAssistant.tripStreamSubscription = fDataBase
//         .collection("DeliveryRequests")
//         .doc(trackingState.docRef.id)
//         .snapshots()
//         .listen((event) async {
//       try {
//         if (event.exists) {
//           final data = event.data() as Map<String, dynamic>;
//           final resultData = DeliveryRequest.fromJson(data);
//           log("Result ${resultData.driverID}");
//           log("docRef ${trackingState.docRef.id}");
//           getPaymentMethod(resultData.paymentMethod!);
//           getPaymentStatus(resultData.paymentStatus!);
//           updateTripAmount(resultData.deliveryAmount!);
//           UserRideRequestStatus? status =
//               getUserRideRequestStatusFromString(resultData.status!);
//           log("Status $status");
//
//           if (status != null && trackingState.driverPosition.value != null) {
//             trackingState.userRideRequestStatus.value = status;
//             Logger.error(
//                 "Updated UserRideRequestStatus: ${trackingState.userRideRequestStatus.value}");
//
//             handleRideRequestStatus(
//                 trackingState.driverPosition.value!, resultData.paymentMethod);
//           }
//         }
//       } catch (e, stackTrace) {
//         log("Error in getRiderDriverStatus: $e");
//         log("Stack Trace: $stackTrace");
//       }
//     });
//   }
//
//   updateTripAmount(String tripAmount) {
//     trackingState.tripAmount.value = tripAmount;
//     Logger.i("Payment Method: $tripAmount");
//     update();
//   }
//
//   getPaymentMethod(String paymentMethod) {
//     trackingState.paymentMethod.value = paymentMethod;
//     Logger.i("Payment Method: $paymentMethod");
//     update();
//   }
//
//   getPaymentStatus(bool paymentStatus) {
//     trackingState.paymentStatus.value = paymentStatus;
//     Logger.i(
//         "Payment Status: $paymentStatus ${trackingState.paymentStatus.value}");
//     update();
//   }
//
//   void updatePaymentStatus(bool paymentStatus) {
//     fDataBase
//         .collection('DeliveryRequests')
//         .doc(trackingState.docRef.id)
//         .update({'paymentStatus': paymentStatus});
//
//     Logger.i(
//         "Payment Status: $paymentStatus ${trackingState.paymentStatus.value}");
//   }
//
//   void _addPolyline() {
//     log("Adding Polyline...");
//     final polylinePoints = PolylinePoints();
//
//     trackingState.polylineCoordinatesList.clear();
//     trackingState.polylineSet();
//
//     List<PointLatLng> data = polylinePoints
//         .decodePolyline(locationController.directionDetails!.polylinePoints!);
//
//     trackingState.polylineCoordinatesList
//         .addAll(data.map((point) => LatLng(point.latitude, point.longitude)));
//
//     trackingState.polylineSet.add(
//       Polyline(
//         polylineId: const PolylineId("path"),
//         points: trackingState.polylineCoordinatesList,
//         color: AppColor.primaryColor,
//         width: 5,
//         jointType: JointType.round,
//         startCap: Cap.roundCap,
//         endCap: Cap.squareCap,
//         geodesic: true,
//       ),
//     );
//     log("Polyline Coordinates: ${trackingState.polylineCoordinatesList}");
//     log("Polyline Points: ${locationController.directionDetails?.polylinePoints}");
//   }
//
//   void _addMarker() {
//     log("Adding markers...");
//     log("Pickup LatLng: ${trackingState.pickupLatLng.value}");
//     log("Dropoff LatLng: ${trackingState.dropOffLatLng.value}");
//     trackingState.markerSet.clear();
//     trackingState.markerSet.add(
//       Marker(
//         markerId: const MarkerId('Destination'),
//         position: trackingState.dropOffLatLng.value!,
//         infoWindow: InfoWindow(
//             title: '${trackingState.requestData['dropOffLocation']}'),
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//       ),
//     );
//     debugPrint("Destination.......${trackingState.markerSet}");
//     trackingState.markerSet.add(
//       Marker(
//         markerId: const MarkerId('pickup'),
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//         position: trackingState.pickupLatLng.value!,
//         infoWindow: const InfoWindow(title: 'Pickup Location'),
//       ),
//     );
//   }
//
//   void updateDriversTimeToPickupLocation(LatLng driverLatLng) async {
//     if (trackingState.requestPositionInfo.value) {
//       trackingState.requestPositionInfo.value = false;
//
//       DirectionModel directionInfo = await Network.getRiderDirection(
//         driverLatLng,
//         trackingState.pickupLatLng.value!,
//       );
//
//       trackingState.driverRideStatus.value =
//           "${formatDuration(directionInfo.duration)} to your location for pickup";
//       // Ensure polylinePoints are valid
//       if (locationController.directionDetails?.polylinePoints != null) {
//         _addPolyline(); // Attempt to add polyline
//       } else {
//         log("No polyline points available to draw.");
//       }
//       Logger.error("DriverLatLng $driverLatLng");
//       trackingState.requestPositionInfo.value = true;
//     }
//   }
//
//   void updateDriversTimeToDropOffLocation(LatLng driverLatLng) async {
//     if (trackingState.requestPositionInfo.value) {
//       trackingState.requestPositionInfo.value = false;
//
//       try {
//         DirectionModel directionInfo = await Network.getRiderDirection(
//           driverLatLng,
//           trackingState.dropOffLatLng.value!,
//         );
//
//         trackingState.driverRideStatus.value =
//             "${formatDuration(directionInfo.duration)} to the drop-off location";
//         // Ensure polylinePoints are valid
//         if (locationController.directionDetails?.polylinePoints != null) {
//           _addPolyline(); // Attempt to add polyline
//         } else {
//           log("No polyline points available to draw.");
//         }
//         Logger.error(
//             "DriverLatLng2: $driverLatLng, Duration: ${directionInfo.duration}");
//       } catch (e) {
//         Logger.error("Error in getting direction: $e");
//       } finally {
//         trackingState.requestPositionInfo.value = true;
//       }
//     } else {
//       Logger.error("Request position info is already being updated.");
//     }
//   }
//
//   void handleRideRequestStatus(
//       LatLng driverCurrentPositionLatLng, String? paymentTpye) {
//     Logger.error(
//         "Current UserRideRequestStatus: ${trackingState.userRideRequestStatus.value}");
//     switch (trackingState.userRideRequestStatus.value) {
//       case UserRideRequestStatus.accepted:
//         updateDriversTimeToPickupLocation(driverCurrentPositionLatLng);
//         break;
//
//       case UserRideRequestStatus.arrived:
//         trackingState.driverRideStatus.value = "Driver has Arrived";
//         break;
//
//       case UserRideRequestStatus.onTrip:
//         updateDriversTimeToDropOffLocation(driverCurrentPositionLatLng);
//         break;
//       case UserRideRequestStatus.declined:
//         successMethod("Driver Declined The Request");
//         // updateDriversTimeToDropOffLocation(driverCurrentPositionLatLng);
//         break;
//
//       case UserRideRequestStatus.ended:
//         // if (paymentTpye == "Cash") {
//         //   successMethod("Cash");
//         // } else {
//         //   successMethod("PayStack");
//         // }
//         successMethod("Package Delivered");
//         Map<String, String?> data = {
//           "driverId": trackingState.driverID!.value,
//         };
//         Get.offAll(() => const RatingScreen(), arguments: data);
//         //  if(trackingState.requestData['']){
//
//         //  }
//         Logger.error("Status is ended, completing trip.");
//         break;
//
//       default:
//         // Handle unknown status
//         break;
//     }
//
//     Logger.error("Unknown");
//   }
//
//   UserRideRequestStatus? getUserRideRequestStatusFromString(String status) {
//     // Log the incoming status string
//     Logger.error("Incoming status: $status");
//
//     UserRideRequestStatus? userRideRequestStatus;
//
//     switch (status) {
//       case "declined":
//         userRideRequestStatus = UserRideRequestStatus.declined;
//         break;
//       case "accepted":
//         userRideRequestStatus = UserRideRequestStatus.accepted;
//         break;
//       case "arrived":
//         userRideRequestStatus = UserRideRequestStatus.arrived;
//         break;
//       case "onTrip":
//         userRideRequestStatus = UserRideRequestStatus.onTrip;
//         break;
//       case "ended":
//         userRideRequestStatus = UserRideRequestStatus.ended;
//         break;
//       default:
//         break;
//     }
//
//     // Log the mapped UserRideRequestStatus
//     Logger.error("Mapped UserRideRequestStatus: $userRideRequestStatus");
//
//     return userRideRequestStatus;
//   }
//
//   @override
//   void onClose() {
//     trackingState.realTimeLocation.cancel();
//     GeoFireAssistant.tripStreamSubscription!.cancel();
//     super.onClose();
//   }
//
//   void onSendCallInvitationFinished(
//     String code,
//     String message,
//     List<String> errorInvitees,
//   ) {
//     if (errorInvitees.isNotEmpty) {
//       var userIDs = '';
//       for (var index = 0; index < errorInvitees.length; index++) {
//         if (index >= 5) {
//           userIDs += '... ';
//           break;
//         }
//
//         final userID = errorInvitees.elementAt(index);
//         userIDs += '$userID ';
//       }
//       if (userIDs.isNotEmpty) {
//         userIDs = userIDs.substring(0, userIDs.length - 1);
//       }
//
//       var message = "User doesn't exist or is offline: $userIDs";
//       if (code.isNotEmpty) {
//         message += ', code: $code, message:$message';
//       }
//       toastification.show(
//         title: Text(message),
//         autoCloseDuration: const Duration(milliseconds: 2300),
//         alignment: Alignment.topCenter,
//         type: ToastificationType.error,
//         style: ToastificationStyle.flatColored,
//         showProgressBar: false,
//       );
//     } else if (code.isNotEmpty) {
//       toastification.show(
//         title: Text('code: $code, message:$message'),
//         autoCloseDuration: const Duration(milliseconds: 2300),
//         alignment: Alignment.topCenter,
//         type: ToastificationType.error,
//         style: ToastificationStyle.flatColored,
//         showProgressBar: false,
//       );
//     }
//   }
//
//   void getRatingAndTotalDelivery() async {
//     Map<String, dynamic> stats =
//         await GeoFireAssistant.getTotalDeliveredAndRating(
//             driverID: trackingState.driverID!.value);
//     trackingState.averageRating.value = stats['averageRating'];
//     trackingState.totalDelivery.value = stats['totalDeliveries'];
//   }
// }


import 'dart:async';
import 'dart:developer';
import 'dart:math' as maths;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:toastification/toastification.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/utils/geofire_assistant.dart';
import 'package:swiftrun/common/utils/utils.dart';
import 'package:swiftrun/core/controller/location_controller.dart';
import 'package:swiftrun/core/controller/session_controller.dart';
import 'package:swiftrun/core/model/direction_model.dart';
import 'package:swiftrun/features/booking/model/delivery_request_model.dart';
import 'package:swiftrun/features/booking/presentation/atoms/confirm_details/confirmation.con.dart';
import 'package:swiftrun/features/rating/view.dart';
import 'package:swiftrun/features/tracking/state.dart';
import 'package:swiftrun/global/global.dart';
import 'package:swiftrun/services/network/network.dart';
import 'package:swiftrun/common/routes/route_name.dart';


class TrackingController extends GetxController {
  static TrackingController get to => Get.find();
  var trackingState = TrackingStates();
  var locationController = Get.put(LocationController());
  var sesssionController = Get.put(SessionController());

  GoogleMapController? googleMapController;
  Completer<GoogleMapController> mapControllerDriver = Completer();
  dynamic requestInfos;

  @override
  void onInit() {
    super.onInit();

    // Validate arguments
    requestInfos = Get.arguments;
    if (requestInfos == null) {
      if (kDebugMode) {
        log("Error: No arguments provided to TrackingController");
      }
      errorMethod( "Invalid tracking data");
      Get.back();
      return;
    }

    // Validate driverID - check both 'driverID' and 'driverAssigned' fields
    // Scheduled deliveries use 'driverAssigned', instant use 'driverID'
    String? driverID = requestInfos['driverID'] as String?;
    if (driverID == null || driverID.isEmpty) {
      // Try to get from requestData if available
      if (requestInfos['requestData'] != null) {
        Map<String, dynamic> requestData = requestInfos['requestData'];
        driverID = requestData['driverID'] ?? requestData['driverAssigned'];
      }
    }
    
    if (driverID != null && driverID.isNotEmpty && driverID != 'null') {
      trackingState.driverID!.value = driverID;
    } else {
      trackingState.driverID!.value = "";
      // Don't return - continue initialization to show delivery details even without driver
    }

    trackingState.docRef = requestInfos['request'];
    
    if (trackingState.docRef == null) {
      if (kDebugMode) {
        log("❌ Error: docRef is null, cannot initialize tracking");
      }
      trackingState.isInitialized.value = true; // Set to true so error can be shown
      errorMethod("Tracking data not available");
      return;
    }
    
    // Extract and store the delivery ID from docRef
    trackingState.docRefID.value = trackingState.docRef!.id;
    if (kDebugMode) {
      log("✅ Delivery ID extracted: ${trackingState.docRefID.value}");
    }
    
    try {
      trackingState.requestData = trackingState.docRef!.data() as Map<String, dynamic>?;
      
      if (trackingState.requestData == null) {
        if (kDebugMode) {
          log("❌ Error: requestData is null, cannot initialize tracking");
        }
        trackingState.isInitialized.value = true; // Set to true so error can be shown
        errorMethod("Delivery request data not found");
        return;
      }

      // IMPORTANT: Check driver ID from document data (for scheduled deliveries that get driver after screen opens)
      // This ensures we get the latest driver ID even if it was set after initialization
      String? driverIDFromDoc = trackingState.requestData['driverID'] ?? trackingState.requestData['driverAssigned'];
      if (driverIDFromDoc != null && driverIDFromDoc.isNotEmpty && driverIDFromDoc != 'null') {
        if (trackingState.driverID!.value != driverIDFromDoc) {
          if (kDebugMode) {
            log("🔄 Driver ID updated from document: ${trackingState.driverID!.value} -> $driverIDFromDoc");
          }
          trackingState.driverID!.value = driverIDFromDoc;
        }
      }

      trackingState.pickupLatLng.value = LatLng(
          trackingState.requestData['pickupLatLng']['latitude'],
          trackingState.requestData['pickupLatLng']['longitude']);
      trackingState.dropOffLatLng.value = LatLng(
          trackingState.requestData['dropOffLatLng']['latitude'],
          trackingState.requestData['dropOffLatLng']['longitude']);

      // Mark as initialized after all data is set
      trackingState.isInitialized.value = true;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        Logger.error("Tracking initialization error: $e", stackTrace: stackTrace);
      }
      trackingState.isInitialized.value = true; // Set to true so error can be shown
      errorMethod("Failed to load tracking data: $e");
      return;
    }

    // Only start real-time tracking if driver ID is available
    if (trackingState.driverID!.value.isNotEmpty) {
      getRealTimeLocation();
      getRiderDriverStatus();
      getRatingAndTotalDelivery(); // Fetch driver's rating and delivery count
      getDriverDetails();
    }
  }

  void onMapCreated(GoogleMapController controller) async {
    mapControllerDriver.complete(controller);
    googleMapController = controller;
    _addMarker();
  }

  final initalLocation = const CameraPosition(
    zoom: 12,
    bearing: 192.8334901395799,
    tilt: 59.440717697143555,
    target: LatLng(5.498073099999999, 7.0215017),
  );


  // void cancelTrip() {
  //   try {
  //     print("TrackingController: cancelTrip called");
  //
  //     // Use the docRef.id that you already have in your controller
  //     String requestID = trackingState.docRef.id;
  //     print("TrackingController: Request ID from docRef: '$requestID'");
  //
  //     if (requestID.isEmpty) {
  //       print("TrackingController: Request ID is empty");
  //       errorMethod("Cannot cancel: No active request found");
  //       return;
  //     }
  //
  //     print("TrackingController: Updating Firestore document");
  //     Map<String, dynamic> data = {"status": "cancelled"};
  //
  //     fDataBase
  //         .collection('DeliveryRequests')
  //         .doc(requestID)
  //         .update(data)
  //         .then((_) async {
  //
  //       print("TrackingController: Firestore updated successfully");
  //
  //       // Send cancellation notification to driver
  //       String? driverToken = trackingState.driverInfo.value.userToken;
  //
  //       if (driverToken != null && driverToken.isNotEmpty) {
  //         print("TrackingController: Sending notification to driver");
  //         try {
  //           await Network.notifyDriver(
  //               driverToken: driverToken,
  //               requestID: requestID,
  //               title: "Delivery Cancelled",
  //               message: "The customer has cancelled this delivery request.",
  //               status: "cancelled",
  //               type: "delivery_cancelled"
  //           );
  //           print("TrackingController: Notification sent successfully");
  //         } catch (notificationError) {
  //           print("TrackingController: Notification failed: $notificationError");
  //         }
  //       }
  //     }).catchError((error) {
  //       print("TrackingController: Firestore update failed: $error");
  //       errorMethod("Failed to cancel trip: $error");
  //     });
  //
  //     // Clean up streams
  //     try {
  //       trackingState.realTimeLocation?.cancel();
  //       GeoFireAssistant.tripStreamSubscription?.cancel();
  //       print("TrackingController: Streams cancelled");
  //     } catch (e) {
  //       print("TrackingController: Stream cancellation issue: $e");
  //     }
  //
  //     successMethod("Trip cancelled successfully");
  //     print("TrackingController: Cancel process completed");
  //
  //   } catch (e) {
  //     print("TrackingController: Error in cancelTrip: $e");
  //     errorMethod("Failed to cancel trip");
  //   }
  // }


  Future<void> cancelTrip() async {
    try {
      if (trackingState.docRef == null) {
        return;
      }
      String requestID = trackingState.docRef!.id;

      if (requestID.isEmpty) {
        errorMethod("Cannot cancel: No active request found");
        return;
      }

      // Determine if this is a scheduled delivery or instant delivery
      // by checking the document reference path
      String docPath = trackingState.docRef!.reference.path;
      bool isScheduled = docPath.contains('ScheduleRequest');
      String collectionName = isScheduled ? 'ScheduleRequest' : 'DeliveryRequests';
      
      Map<String, dynamic> data = {
        "status": "cancelled",
        "dateCancelled": Timestamp.now(),
        "cancelReason": "Cancelled by user",
        "dateUpdated": Timestamp.now(), // Also update the dateUpdated field
      };

      // Use await to ensure the update completes before proceeding
      await fDataBase
          .collection(collectionName)
          .doc(requestID)
          .update(data);
      
      // Verify the update by reading the document back
      DocumentSnapshot verifyDoc = await fDataBase
          .collection(collectionName)
          .doc(requestID)
          .get();
      
      if (verifyDoc.exists) {
        Map<String, dynamic>? verifyData = verifyDoc.data() as Map<String, dynamic>?;
        String verifyStatus = verifyData?['status'] ?? '';
        
        if (verifyStatus != 'cancelled') {
          // Try updating again
          await fDataBase
              .collection(collectionName)
              .doc(requestID)
              .update({"status": "cancelled"});
        }
      }

      // Now proceed with notifications and cleanup
      try {

        // Send cancellation notification to driver
        String? driverToken = trackingState.driverInfo.value.userToken;

        if (driverToken != null && driverToken.isNotEmpty) {
          try {
            await Network.notifyDriver(
                driverToken: driverToken,
                requestID: requestID,
                title: "🚫 Delivery Cancelled",
                message: "The customer has cancelled this ${isScheduled ? 'scheduled ' : ''}delivery request.",
                status: "cancelled",
                type: isScheduled ? "scheduled_cancelled" : "delivery_cancelled"
            );
          } catch (notificationError) {
            if (kDebugMode) {
              log("Notification failed: $notificationError");
            }
          }
        }

        // Clean up streams
        try {
          trackingState.realTimeLocation?.cancel();
          GeoFireAssistant.tripStreamSubscription?.cancel();
        } catch (e) {
          if (kDebugMode) {
            log("Stream cancellation issue: $e");
          }
        }

        successMethod("${isScheduled ? 'Scheduled delivery' : 'Trip'} cancelled successfully");

        // Navigate to DashboardScreen (which includes bottom navigation) after successful cancellation
        Get.offAllNamed(AppRoutes.dashboard);

      } catch (updateError) {
        if (kDebugMode) {
          log("Firestore update failed: $updateError");
        }
        errorMethod("Failed to cancel ${isScheduled ? 'scheduled delivery' : 'trip'}: $updateError");
      }

    } catch (e) {
      if (kDebugMode) {
        log("Error in cancelTrip: $e");
      }
      errorMethod("Failed to cancel delivery");
    }
  }



  getRealTimeLocation() {
    if (trackingState.driverID!.value.isEmpty) {
      return;
    }

    trackingState.realTimeLocation = fDataBase
        .collection("DriverLocation")
        .doc(trackingState.driverID!.value)
        .snapshots()
        .listen((event) async {
      try {
        if (event.exists) {
          final result = event.data() as Map<String, dynamic>;
          LatLng newDriverLocation = LatLng(
            double.parse(result['latitude']),
            double.parse(result['longitude']),
          );

          trackingState.driverPosition.value = newDriverLocation;

          // Update driver marker on map
          _updateDriverMarkerOnMap(newDriverLocation);

          // IMPORTANT: If status was set before driver location was available, trigger route drawing now
          // This ensures scheduled deliveries get their route drawn when driver location first arrives
          if (trackingState.userRideRequestStatus.value == UserRideRequestStatus.accepted && 
              trackingState.requestPositionInfo.value) {
            // Driver is on the way to pickup - draw route to pickup
            updateDriversTimeToPickupLocation(newDriverLocation);
          } else if (trackingState.userRideRequestStatus.value == UserRideRequestStatus.onTrip && 
                     trackingState.requestPositionInfo.value) {
            // Driver is on the way to dropoff - draw route to dropoff
            updateDriversTimeToDropOffLocation(newDriverLocation);
          }

          _animateCameraToPosition(newDriverLocation);
        }
      } catch (e, stacktrace) {
        if (kDebugMode) {
          Logger.error("Error getting driver location: $e", stackTrace: stacktrace);
        }
      }
    }, onError: (error) {
      if (kDebugMode) {
        log("Driver location snapshot error: $error");
      }
    });
  }



  void _animateCameraToPosition(LatLng position) {
    final pickupLocation = trackingState.pickupLatLng.value;
    if (pickupLocation == null) return;

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        maths.min(position.latitude, pickupLocation.latitude),
        maths.min(position.longitude, pickupLocation.longitude),
      ),
      northeast: LatLng(
        maths.max(position.latitude, pickupLocation.latitude),
        maths.max(position.longitude, pickupLocation.longitude),
      ),
    );

    googleMapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 65));
  }

  getDriverDetails() async {
    try {
      if (trackingState.driverID!.value.isEmpty) {
        return;
      }

      var details = await GeoFireAssistant.getDriverDetails(trackingState.driverID!.value);
      if (details != null) {
        trackingState.driverInfo.value = details;
      }
    } catch (e) {
      if (kDebugMode) {
        log("Error fetching driver details: $e");
      }
    }
  }

  getRiderDriverStatus() {
    if (trackingState.docRef == null) {
      if (kDebugMode) {
        log("Error: docRef is null, cannot listen to trip status");
      }
      return;
    }
    
    // Determine if this is a scheduled delivery or instant delivery
    String docPath = trackingState.docRef!.reference.path;
    bool isScheduled = docPath.contains('ScheduleRequest');
    String collectionName = isScheduled ? 'ScheduleRequest' : 'DeliveryRequests';
    
    GeoFireAssistant.tripStreamSubscription = fDataBase
        .collection(collectionName)
        .doc(trackingState.docRef!.id)
        .snapshots()
        .listen((event) async {
      try {
        if (event.exists) {
          final data = event.data() as Map<String, dynamic>;
          
          // For scheduled deliveries, try to parse as DeliveryRequest, but handle both driverID and driverAssigned
          String? driverIDFromData = data['driverID'] ?? data['driverAssigned'];
          
          log("📋 Status update - driverID: $driverIDFromData");
          log("📋 docRef ${trackingState.docRef?.id ?? 'null'}");
          
          // IMPORTANT: If driver ID becomes available (driver accepted), start tracking
          if (driverIDFromData != null && driverIDFromData.isNotEmpty && driverIDFromData != 'null') {
            // Check if driver ID changed or was just assigned
            if (trackingState.driverID!.value != driverIDFromData) {
              log("🔄 Driver ID changed/assigned: ${trackingState.driverID!.value} -> $driverIDFromData");
              trackingState.driverID!.value = driverIDFromData;
              
              // Start real-time location tracking if not already started
              if (trackingState.realTimeLocation == null) {
                log("🚀 Starting real-time location tracking for driver: $driverIDFromData");
                getRealTimeLocation();
                getDriverDetails();
                getRatingAndTotalDelivery();
                
                // Trigger route drawing once driver position is available
                // This will be called when first location update arrives in getRealTimeLocation
                log("📍 Route will be drawn when driver location is first received");
              } else {
                log("✅ Real-time tracking already active");
              }
            }
          } else {
            // Handle empty driverID gracefully
            log("⚠️ Driver ID is empty or null, skipping driver-specific operations");
            // Still update status even without driver
            String? statusString = data['status'];
            if (statusString != null) {
              UserRideRequestStatus? status = getUserRideRequestStatusFromString(statusString);
              if (status != null) {
                trackingState.userRideRequestStatus.value = status;
                log("✅ Updated status to: $status (without driver)");
              }
            }
            return;
          }

          // Try to parse as DeliveryRequest model (works for both instant and scheduled)
          try {
            final resultData = DeliveryRequest.fromJson(data);
            getPaymentMethod(resultData.paymentMethod ?? "");
            getPaymentStatus(resultData.paymentStatus ?? false);
            updateTripAmount(resultData.deliveryAmount ?? "");
          } catch (e) {
            // If parsing fails (might be scheduled delivery with different structure), use raw data
            log("⚠️ Could not parse as DeliveryRequest, using raw data: $e");
            getPaymentMethod(data['paymentMethod'] ?? "");
            getPaymentStatus(data['paymentStatus'] ?? false);
            updateTripAmount(data['deliveryAmount'] ?? "");
          }

          String? statusString = data['status'];
          UserRideRequestStatus? status = statusString != null ? getUserRideRequestStatusFromString(statusString) : null;
          log("📊 Status: $status");

          if (status != null && trackingState.driverPosition.value != null) {
            trackingState.userRideRequestStatus.value = status;
            Logger.error("Updated UserRideRequestStatus: ${trackingState.userRideRequestStatus.value}");
            handleRideRequestStatus(trackingState.driverPosition.value!, data['paymentMethod']);
          } else if (status != null) {
            // Update status even if driver position is not available yet
            // When driver position becomes available, route will be drawn in getRealTimeLocation
            UserRideRequestStatus? oldStatus = trackingState.userRideRequestStatus.value;
            trackingState.userRideRequestStatus.value = status;
            log("✅ Updated status to: $status (driver position not available yet)");
            
            // If status changed and we have driver position, trigger route drawing
            if (oldStatus != status && trackingState.driverPosition.value != null) {
              log("🔄 Status changed, triggering route drawing");
              handleRideRequestStatus(trackingState.driverPosition.value!, data['paymentMethod']);
            }
          }
        }
      } catch (e, stackTrace) {
        log("Error in getRiderDriverStatus: $e");
        log("Stack Trace: $stackTrace");
      }
    });
  }

  // ADD THIS METHOD to your TrackingController
  void _updateDriverMarkerOnMap(LatLng driverLocation) {
    log("Updating driver marker at: $driverLocation");

    // Remove old driver marker if it exists
    trackingState.markerSet.removeWhere((marker) => marker.markerId.value == "Driver");

    // Add new driver marker
    trackingState.markerSet.add(
      Marker(
        markerId: const MarkerId("Driver"),
        position: driverLocation,
        infoWindow: InfoWindow(
          title: 'Driver Location',
          snippet: '${trackingState.driverInfo.value.firstName ?? "Your driver"} is here',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    log("Driver marker updated. Total markers: ${trackingState.markerSet.length}");
    update(); // This updates the UI
  }

// ADD THIS METHOD to show driver tracking status
  Widget buildDriverTrackingWidget() {
    return Obx(() => trackingState.driverPosition.value != null
        ? Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade600, Colors.green.shade400],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Tracking ${trackingState.driverInfo.value.firstName ?? 'driver'} in real-time",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    )
        : const SizedBox.shrink(),
    );
  }

  updateTripAmount(String tripAmount) {
    trackingState.tripAmount.value = tripAmount;
    update();
  }

  getPaymentMethod(String paymentMethod) {
    trackingState.paymentMethod.value = paymentMethod;
    update();
  }

  getPaymentStatus(bool paymentStatus) {
    trackingState.paymentStatus.value = paymentStatus;
    update();
  }

  void updatePaymentStatus(bool paymentStatus) {
    if (trackingState.docRef == null) {
      return;
    }
    
    fDataBase
        .collection('DeliveryRequests')
        .doc(trackingState.docRef!.id)
        .update({'paymentStatus': paymentStatus});
  }

  void _addPolyline() {
    final polylinePoints = PolylinePoints();

    trackingState.polylineCoordinatesList.clear();
    trackingState.polylineSet();

    List<PointLatLng> data = polylinePoints
        .decodePolyline(locationController.directionDetails!.polylinePoints!);

    trackingState.polylineCoordinatesList
        .addAll(data.map((point) => LatLng(point.latitude, point.longitude)));

    trackingState.polylineSet.add(
      Polyline(
        polylineId: const PolylineId("path"),
        points: trackingState.polylineCoordinatesList,
        color: AppColor.primaryColor,
        width: 5,
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.squareCap,
        geodesic: true,
      ),
    );
  }

  // void _addMarker() {
  //   log("Adding markers...");
  //   trackingState.markerSet.clear();
  //
  //   trackingState.markerSet.add(
  //     Marker(
  //       markerId: const MarkerId('Destination'),
  //       position: trackingState.dropOffLatLng.value!,
  //       infoWindow: InfoWindow(title: '${trackingState.requestData['dropOffLocation']}'),
  //       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
  //     ),
  //   );
  //
  //   trackingState.markerSet.add(
  //     Marker(
  //       markerId: const MarkerId('pickup'),
  //       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
  //       position: trackingState.pickupLatLng.value!,
  //       infoWindow: const InfoWindow(title: 'Pickup Location'),
  //     ),
  //   );
  // }

  void _addMarker() {
    log("Adding markers...");
    trackingState.markerSet.clear();

    // Add destination marker
    trackingState.markerSet.add(
      Marker(
        markerId: const MarkerId('Destination'),
        position: trackingState.dropOffLatLng.value!,
        infoWindow: InfoWindow(title: '${trackingState.requestData['dropOffLocation']}'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    // Add pickup marker
    trackingState.markerSet.add(
      Marker(
        markerId: const MarkerId('pickup'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        position: trackingState.pickupLatLng.value!,
        infoWindow: const InfoWindow(title: 'Pickup Location'),
      ),
    );

    // ADD THIS: Add initial driver marker if position is available
    if (trackingState.driverPosition.value != null) {
      _updateDriverMarkerOnMap(trackingState.driverPosition.value!);
    }
  }


  void updateDriversTimeToPickupLocation(LatLng driverLatLng) async {
    if (trackingState.requestPositionInfo.value) {
      trackingState.requestPositionInfo.value = false;

      DirectionModel directionInfo = await Network.getRiderDirection(
        driverLatLng,
        trackingState.pickupLatLng.value!,
      );

      // CRITICAL FIX: Update location controller with new direction details
      // This ensures directionDetails is available for polyline drawing
      if (directionInfo.polylinePoints != null && directionInfo.polylinePoints!.isNotEmpty) {
        locationController.updateDirection(directionInfo);

      trackingState.driverRideStatus.value =
      "${formatDuration(directionInfo.duration)} to your location for pickup";

        // Now draw the polyline with the updated direction details
        _addPolyline();

        Logger.error("DriverLatLng $driverLatLng, Duration: ${directionInfo.duration}, Polyline points: ${directionInfo.polylinePoints?.length ?? 0}");
      } else {
        trackingState.driverRideStatus.value = "Calculating route to pickup location...";
        log("No polyline points available to draw - direction calculation may have failed.");
      }

      trackingState.requestPositionInfo.value = true;
    }
  }

  void updateDriversTimeToDropOffLocation(LatLng driverLatLng) async {
    // Allow updates - this ensures route is drawn for scheduled deliveries
    // The requestPositionInfo guard might prevent updates, so we'll update it
    if (!trackingState.requestPositionInfo.value) {
      trackingState.requestPositionInfo.value = true;
    }
    
    if (trackingState.requestPositionInfo.value) {
      trackingState.requestPositionInfo.value = false;

      try {
        DirectionModel directionInfo = await Network.getRiderDirection(
          driverLatLng,
          trackingState.dropOffLatLng.value!,
        );

        // CRITICAL FIX: Update location controller with new direction details
        // This ensures directionDetails is available for polyline drawing
        if (directionInfo.polylinePoints != null && directionInfo.polylinePoints!.isNotEmpty) {
          locationController.updateDirection(directionInfo);

        trackingState.driverRideStatus.value =
        "${formatDuration(directionInfo.duration)} to the drop-off location";

          // Now draw the polyline with the updated direction details
          _addPolyline();

          Logger.error("DriverLatLng2: $driverLatLng, Duration: ${directionInfo.duration}, Polyline points: ${directionInfo.polylinePoints?.length ?? 0}");
        } else {
          trackingState.driverRideStatus.value = "Calculating route to drop-off location...";
          log("No polyline points available to draw - direction calculation may have failed.");
        }
      } catch (e) {
        Logger.error("Error in getting direction: $e");
        trackingState.driverRideStatus.value = "Unable to calculate route at this time";
      } finally {
        trackingState.requestPositionInfo.value = true;
      }
    } else {
      Logger.error("Request position info is already being updated.");
    }
  }

  void handleRideRequestStatus(LatLng driverCurrentPositionLatLng, String? paymentTpye) {
    Logger.error("Current UserRideRequestStatus: ${trackingState.userRideRequestStatus.value}");

    switch (trackingState.userRideRequestStatus.value) {
      case UserRideRequestStatus.accepted:
        updateDriversTimeToPickupLocation(driverCurrentPositionLatLng);
        break;
      case UserRideRequestStatus.arrived:
        trackingState.driverRideStatus.value = "Driver has Arrived";
        break;
      case UserRideRequestStatus.onTrip:
        updateDriversTimeToDropOffLocation(driverCurrentPositionLatLng);
        break;
      case UserRideRequestStatus.declined:
        successMethod("Driver Declined The Request");
        break;
      case UserRideRequestStatus.ended:
        successMethod("Package Delivered");
        
        // Get the driver ID from the delivery request document (assigned when they accepted)
        String? requestDriverId = trackingState.requestData['driverID'];
        String correctDriverId = (requestDriverId != null && requestDriverId.isNotEmpty) 
            ? requestDriverId 
            : trackingState.driverID!.value;
        
        if (trackingState.docRef == null) {
          if (kDebugMode) {
            log("Error: docRef is null, cannot navigate to rating screen");
          }
          return;
        }
        
        Map<String, String?> data = {
          "driverId": correctDriverId,
          "tripId": trackingState.docRef!.id, // Pass the trip/document ID
        };
        Get.offAll(() => const RatingScreen(), arguments: data);
        break;
      default:
        break;
    }
  }

  UserRideRequestStatus? getUserRideRequestStatusFromString(String status) {
    UserRideRequestStatus? userRideRequestStatus;

    switch (status) {
      case "declined":
        userRideRequestStatus = UserRideRequestStatus.declined;
        break;
      case "accepted":
        userRideRequestStatus = UserRideRequestStatus.accepted;
        break;
      case "arrived":
        userRideRequestStatus = UserRideRequestStatus.arrived;
        break;
      case "onTrip":
        userRideRequestStatus = UserRideRequestStatus.onTrip;
        break;
      case "ended":
        userRideRequestStatus = UserRideRequestStatus.ended;
        break;
      default:
        break;
    }

    return userRideRequestStatus;
  }

  @override
  void onClose() {
    trackingState.realTimeLocation?.cancel();
    GeoFireAssistant.tripStreamSubscription?.cancel();
    super.onClose();
  }

  void onSendCallInvitationFinished(String code, String message, List<String> errorInvitees) {
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

  void getRatingAndTotalDelivery() async {
    if (trackingState.driverID!.value.isNotEmpty) {
      try {
        Map<String, dynamic> stats = await GeoFireAssistant.getTotalDeliveredAndRating(
            driverID: trackingState.driverID!.value);
        
        // Ensure we have valid data
        if (stats.containsKey('error')) {
          Logger.error("Error fetching rating data: ${stats['error']}");
          trackingState.averageRating.value = 0.0;
          trackingState.totalDelivery.value = 0;
          return;
        }
        
        // Update with fetched data using the same unified system
        trackingState.averageRating.value = (stats['averageRating'] ?? 0.0).toDouble();
        trackingState.totalDelivery.value = stats['totalDeliveries'] ?? 0;
        
        Logger.i("Tracking rating data updated - Average: ${trackingState.averageRating.value}, Deliveries: ${trackingState.totalDelivery.value}");
      } catch (e) {
        Logger.error("Error in getRatingAndTotalDelivery: $e");
        trackingState.averageRating.value = 0.0;
        trackingState.totalDelivery.value = 0;
      }
    }
  }

  void getRatingAndTotalDeliveryForceRefresh() async {
    if (trackingState.driverID!.value.isNotEmpty) {
      try {
        Map<String, dynamic> stats = await GeoFireAssistant.getTotalDeliveredAndRatingForceRefresh(
            trackingState.driverID!.value);
        
        // Ensure we have valid data
        if (stats.containsKey('error')) {
          Logger.error("Error force fetching rating data: ${stats['error']}");
          trackingState.averageRating.value = 0.0;
          trackingState.totalDelivery.value = 0;
          return;
        }
        
        // Update with fetched data using the same unified system
        trackingState.averageRating.value = (stats['averageRating'] ?? 0.0).toDouble();
        trackingState.totalDelivery.value = stats['totalDeliveries'] ?? 0;
        
        Logger.i("Tracking rating data force refreshed - Average: ${trackingState.averageRating.value}, Deliveries: ${trackingState.totalDelivery.value}");
      } catch (e) {
        Logger.error("Error in getRatingAndTotalDeliveryForceRefresh: $e");
        trackingState.averageRating.value = 0.0;
        trackingState.totalDelivery.value = 0;
      }
    }
  }

  /// Listens for webhook payment verification updates from Firestore
  void startPaymentVerificationListener(String deliveryId, bool isScheduled) {
    final collection = isScheduled ? 'ScheduleRequest' : 'DeliveryRequests';
    
    log('🔄 Starting payment verification listener for $collection/$deliveryId');
    
    bool isFirstSnapshot = true;
    Timer? timeoutTimer;
    
    // Set timeout for webhook verification (60 seconds)
    timeoutTimer = Timer(const Duration(seconds: 60), () {
      log('⏰ Payment verification timeout - webhook took too long');
      errorMethod('Payment verification timeout. Please contact support if money was deducted.');
    });
    
    fDataBase
        .collection(collection)
        .doc(deliveryId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) return;

      final data = snapshot.data();
      if (data == null) return;

      final paymentVerified = data['paymentVerified'] as bool?;
      final paymentStatus = data['paymentStatus'] as bool?;

      log('Payment status update: verified=$paymentVerified, status=$paymentStatus, isFirstSnapshot=$isFirstSnapshot');

      // Skip the initial snapshot (before webhook processes)
      if (isFirstSnapshot) {
        isFirstSnapshot = false;
        log('📸 Initial state captured, waiting for webhook update...');
        return;
      }

      // Webhook has updated the document - cancel timeout
      timeoutTimer?.cancel();

      if (paymentVerified == true && paymentStatus == true) {
        log('✅ Payment verified by webhook!');
        updatePaymentStatus(true);
        
        // Show success notification
        successMethod('Payment confirmed! ✅');
      } else if (paymentVerified == false || paymentStatus == false) {
        log('❌ Payment verification failed by webhook');
        errorMethod('Payment failed. Please try again.');
        // Note: We don't update payment status to false because user might retry
      }
    });
  }
}
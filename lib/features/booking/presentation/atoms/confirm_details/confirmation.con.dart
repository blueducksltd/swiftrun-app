import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart' as fstorage;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:swiftrun/common/utils/fare_cal.dart';
import 'package:swiftrun/common/utils/geofire_assistant.dart';
import 'package:swiftrun/common/utils/utils.dart';
import 'package:swiftrun/core/controller/get_driver_near.dart';
import 'package:swiftrun/core/controller/location_controller.dart';
import 'package:swiftrun/core/controller/session_controller.dart';
import 'package:swiftrun/core/model/direction_model.dart';
import 'package:swiftrun/core/model/driver_model.dart';
import 'package:swiftrun/features/auth/data/model/user_model.dart';
import 'package:swiftrun/features/booking/model/delivery_request_model.dart';
import 'package:swiftrun/features/booking/model/nearby_driver_model.dart';


import 'package:swiftrun/features/booking/presentation/atoms/confirm_details/conifrm_state.dart';
import 'package:swiftrun/features/rating/view.dart';
import 'package:swiftrun/global/global.dart';
import 'package:swiftrun/services/network/network.dart';
import 'package:swiftrun/services/network/network_utils.dart';
import 'package:swiftrun/features/homepage/controller.dart';

class ConfirmPackageController extends GetxController {
  static ConfirmPackageController get to => Get.find();

  var confirmPackageState = ConfirmPackageState();
  var locationController = Get.put(LocationController());

  // Add static flags to prevent duplicate messages across all instances
  static bool _hasShownAcceptedMessage = false;
  static bool _hasShownArrivedMessage = false;
  static bool _hasShownOnTripMessage = false;

  final Completer<GoogleMapController> _mapControllerDriver = Completer();
  GoogleMapController? googleMapController;

  @override
  void onInit() {
    // BREAK CIRCULAR DEPENDENCY: Manually register this controller with GetNearByDriver
    // This prevents GetNearByDriver from trying to create a new instance when we call getActiveDriver()
    GetNearByDriver.setController(this);
    
    super.onInit();
    var packageDetails = Get.arguments;

    // Check if arguments are null
    // Only show error if we're actually on the confirm details screen (not accidentally initialized)
    if (packageDetails == null) {
      if (kDebugMode) {
        print(
            '⚠️ ConfirmPackageController: packageDetails is null - this may be normal if controller was initialized accidentally');
      }
      // Don't show error or navigate - just return silently
      // This prevents errors when the controller is accidentally initialized for scheduled deliveries
      return;
    }

    // Only proceed if we have valid arguments
    GetNearByDriver.getActiveDriver();

    confirmPackageState.pickupLocation.value = packageDetails['pickupLocation'];
    confirmPackageState.dropOffLocation.value =
        packageDetails['dropOffLocation'];
    confirmPackageState.receipientContact.value =
        packageDetails['receipientNumber'];
    confirmPackageState.receipientname.value = packageDetails['receipientName'];
    confirmPackageState.vehicleType.value = packageDetails['vehicleType'];
    confirmPackageState.vehicleTypeId.value = packageDetails['vehicleTypeId'];
    confirmPackageState.itemType.value = packageDetails['itemType'];
    confirmPackageState.paymentMethod.value = packageDetails['paymentMethod'];
    confirmPackageState.paymentStatus.value =
        packageDetails['paymentStatus'] ?? false;
    confirmPackageState.pickupLatLng = packageDetails['pickupLatLng'];
    confirmPackageState.dropOffLatLng = packageDetails['dropOffLatLng'];
    confirmPackageState.imagePath = packageDetails['imagePath'];

    // Calculate trip amount once on initialization
    getTripAmount(vehicleTypeId: confirmPackageState.vehicleTypeId.value);
  }

  void onMapDetail(GoogleMapController controller) {
    _mapControllerDriver.complete(controller);
    googleMapController = controller;
    locationController.decodePolylineAndUpdatePolylineField();
    locationController.addMark();
  }

  void getRatingAndDeliveries(String driveID) async {
    try {
      // Clear any cached data first
      confirmPackageState.averageRating = RxDouble(0.0);
      confirmPackageState.totalDelivery = RxInt(0);

      Map<String, dynamic> stats =
          await GeoFireAssistant.getTotalDeliveredAndRating(driverID: driveID);

      // Ensure we have valid data
      if (stats.containsKey('error')) {
        if (kDebugMode) {
          Logger.error("Error fetching rating data: ${stats['error']}");
        }
        confirmPackageState.averageRating = RxDouble(0.0);
        confirmPackageState.totalDelivery = RxInt(0);
        return;
      }

      // Update with fetched data using the same unified system
      confirmPackageState.averageRating =
          RxDouble((stats['averageRating'] ?? 0.0).toDouble());
      confirmPackageState.totalDelivery = RxInt(stats['totalDeliveries'] ?? 0);
    } catch (e) {
      if (kDebugMode) {
        Logger.error("Error in getRatingAndDeliveries: $e");
      }
      confirmPackageState.averageRating = RxDouble(0.0);
      confirmPackageState.totalDelivery = RxInt(0);
    }
  }

  void getRatingAndDeliveriesForceRefresh(String driveID) async {
    try {
      // Clear any cached data first
      confirmPackageState.averageRating = RxDouble(0.0);
      confirmPackageState.totalDelivery = RxInt(0);

      Map<String, dynamic> stats =
          await GeoFireAssistant.getTotalDeliveredAndRatingForceRefresh(
              driveID);

      // Ensure we have valid data
      if (stats.containsKey('error')) {
        if (kDebugMode) {
          Logger.error("Error force fetching rating data: ${stats['error']}");
        }
        confirmPackageState.averageRating = RxDouble(0.0);
        confirmPackageState.totalDelivery = RxInt(0);
        return;
      }

      // Update with fetched data using the same unified system
      confirmPackageState.averageRating =
          RxDouble((stats['averageRating'] ?? 0.0).toDouble());
      confirmPackageState.totalDelivery = RxInt(stats['totalDeliveries'] ?? 0);
    } catch (e) {
      if (kDebugMode) {
        Logger.error("Error in getRatingAndDeliveriesForceRefresh: $e");
      }
      confirmPackageState.averageRating = RxDouble(0.0);
      confirmPackageState.totalDelivery = RxInt(0);
    }
  }

  // bookNearestDriver() async {
  //   double minDistance = double.infinity;
  //
  //   for (CloseByDriverModel driver in GeoFireAssistant.nearestDrivers) {
  //     double distance = Geolocator.distanceBetween(
  //       confirmPackageState.pickupLatLng.latitude,
  //       confirmPackageState.pickupLatLng.longitude,
  //       driver.latitude!,
  //       driver.longitude!,
  //     );
  //     if (distance < minDistance) {
  //       minDistance = distance;
  //       confirmPackageState.nearestDriver = driver;
  //       Logger.i(confirmPackageState.nearestDriver);
  //     }
  //   }
  //
  //   if (confirmPackageState.nearestDriver != null) {
  //     setSelectedDriver(false);
  //     locationController.addMark();
  //
  //     // Get driver details BEFORE saving delivery request
  //     DriverModel? driverData = await GeoFireAssistant.getDriverDetails(
  //         confirmPackageState.nearestDriver!.driversId!
  //     );
  //
  //     if (driverData != null) {
  //       confirmPackageState.driverDetails.value = driverData;
  //       Logger.i("✅ Driver found: ${driverData.firstName} ${driverData.lastName}");
  //     }
  //
  //     DocumentReference documentReference = await saveDeliveryRequest();
  //     await uploadSentImage(documentReference.id);
  //     String requestPath = documentReference.id;
  //     confirmPackageState.requestID!.value = documentReference.id;
  //
  //     sendDriverNotification(
  //       driverID: confirmPackageState.nearestDriver!.driversId,
  //       requestPath: requestPath,
  //     );
  //     getRiderDriverStatus(documentReference);
  //
  //     // Better success message with driver name
  //     if (driverData != null) {
  //       successMethod('🚗 Request sent to ${driverData.firstName}! Waiting for response...');
  //     } else {
  //       successMethod('🚗 Found a driver nearby! Sending your request...');
  //     }
  //
  //     Logger.error('✅ Delivery request sent to: ${driverData?.firstName ?? 'Driver'}');
  //   } else if (GeoFireAssistant.nearestDrivers.isEmpty) {
  //     Get.to(() => const ConfirmDeliveryScreen(fromPage: 0));
  //   } else {
  //     errorMethod('😔 No drivers available at the moment. Please try again.');
  //     Logger.error('No drivers available.');
  //   }
  // }

  // bookNearestDriver() async {
  //   if (GeoFireAssistant.nearestDrivers.isEmpty) {
  //     errorMethod("No drivers available nearby. Please try again later.");
  //     Get.to(() => const ConfirmDeliveryScreen(fromPage: 0));
  //     return;
  //   }
  //
  //   double minDistance = double.infinity;
  //   CloseByDriverModel? selectedDriver;
  //
  //   for (CloseByDriverModel driver in GeoFireAssistant.nearestDrivers) {
  //     double distance = Geolocator.distanceBetween(
  //       confirmPackageState.pickupLatLng.latitude,
  //       confirmPackageState.pickupLatLng.longitude,
  //       driver.latitude!,
  //       driver.longitude!,
  //     );
  //     if (distance < minDistance) {
  //       minDistance = distance;
  //       selectedDriver = driver;
  //     }
  //   }
  //
  //   if (selectedDriver != null) {
  //     confirmPackageState.nearestDriver = selectedDriver;
  //     setSelectedDriver(false);
  //     locationController.addMark();
  //
  //     // Create delivery request first
  //     DocumentReference documentReference = await saveDeliveryRequest();
  //     await uploadSentImage(documentReference.id);
  //
  //     // Now get driver details for notification
  //     DriverModel? driverData = await GeoFireAssistant.getDriverDetails(
  //         selectedDriver.driversId!
  //     );
  //
  //     if (driverData != null) {
  //       confirmPackageState.driverDetails.value = driverData;
  //       log("Driver found: ${driverData.firstName} ${driverData.lastName}");
  //
  //       // Send notification to driver
  //       sendDriverNotification(
  //         driverID: selectedDriver.driversId,
  //         requestPath: documentReference.id,
  //       );
  //
  //       successMethod("Request sent to ${driverData.firstName}! Waiting for response...");
  //     } else {
  //       successMethod("Request sent to driver! Waiting for response...");
  //     }
  //
  //     // Start listening for status updates
  //     getRiderDriverStatus(documentReference);
  //
  //     log("Delivery request sent to driver: ${selectedDriver.driversId}");
  //   } else {
  //     errorMethod("No drivers available at the moment. Please try again.");
  //   }
  // }

  bookNearestDriver() async {
    // Prevent duplicate calls
    if (confirmPackageState.isRiderRequesting.value) {
      if (kDebugMode) {
        log("Already processing a driver request, ignoring duplicate call");
      }
      return;
    }

    if (GeoFireAssistant.nearestDrivers.isEmpty) {
      errorMethod("No drivers available nearby. Please try again later.");
      // Get.to(() => const ConfirmDeliveryScreen(fromPage: 0)); // REMOVED: This causes state loss loop
      return;
    }

    // Set flag to prevent duplicate processing
    confirmPackageState.isRiderRequesting.value = true;

    try {
      // All drivers in nearestDrivers are already online and approved (filtered by stream)
      // Just find the closest one
      CloseByDriverModel? selectedDriver =
          _findClosestDriver(GeoFireAssistant.nearestDrivers);
      String driverStatus = "Finding nearest driver";

      if (selectedDriver != null) {
        confirmPackageState.nearestDriver = selectedDriver;
        setSelectedDriver(false);
        locationController.addMark();

        // Create delivery request without driver assignment
        DocumentReference documentReference = await saveDeliveryRequest();
        await uploadSentImage(documentReference.id);

        // Get driver details and send notification
        DriverModel? driverData =
            await GeoFireAssistant.getDriverDetails(selectedDriver.driversId!);

        if (driverData != null) {
          confirmPackageState.driverDetails.value = driverData;

          if (kDebugMode) {
            log("📱 Driver Details:");
            log("- Driver Name: ${driverData.firstName} ${driverData.lastName}");
            log("- Driver ID: ${driverData.driversId}");
            log("- Driver Token: ${driverData.userToken?.substring(0, 20)}...");
            log("- Token is null: ${driverData.userToken == null}");
            log("- Token is empty: ${driverData.userToken?.isEmpty}");
          }

          // Send notification to selected driver only
          if (driverData.userToken != null &&
              driverData.userToken!.isNotEmpty) {
            if (kDebugMode) {
              log("🔔 Sending notification to driver...");
            }
            await Network.notifyDriver(
                driverToken: driverData.userToken!,
                requestID: documentReference.id,
                title: "New Delivery Request",
                message:
                    "You have a new delivery request. Tap to view details.",
                status: "new_request",
                type: "delivery_request");
            if (kDebugMode) {
              log("✅ Notification sent successfully");
            }
          } else {
            if (kDebugMode) {
              log("❌ Driver token is null or empty - notification NOT sent!");
            }
          }

          successMethod("Request sent! ($driverStatus)");
        } else {
          if (kDebugMode) {
            log("❌ Driver data is null!");
          }
        }

        // Clear any existing notifications for this request
        var homeController = Get.find<HomeController>();
        homeController.clearRequestNotifications(documentReference.id);

        // Start monitoring the request
        getRiderDriverStatus(documentReference);

        // Start timeout timer for driver acceptance (3 minutes)
        _startDriverAcceptanceTimeout(documentReference.id);
      } else {
        errorMethod("No drivers available at the moment. Please try again.");
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        log("Error in bookNearestDriver: $e");
        log("Stack trace: $stackTrace");
      }
      errorMethod("An error occurred while booking. Please try again.");
    } finally {
      // ALWAYS reset the flag, even if an error occurs
      confirmPackageState.isRiderRequesting.value = false;
    }
  }

// Helper method to find closest driver
  CloseByDriverModel? _findClosestDriver(List<CloseByDriverModel> drivers) {
    if (drivers.isEmpty) return null;

    double minDistance = double.infinity;
    CloseByDriverModel? closest;

    for (CloseByDriverModel driver in drivers) {
      double distance = Geolocator.distanceBetween(
        confirmPackageState.pickupLatLng.latitude,
        confirmPackageState.pickupLatLng.longitude,
        driver.latitude!,
        driver.longitude!,
      );

      if (distance < minDistance) {
        minDistance = distance;
        closest = driver;
      }
    }

    return closest;
  }

  void updateDriversFound(bool value) {
    // Mark search as complete
    confirmPackageState.isSearchingDrivers.value = false;
    
    if (value) {
      confirmPackageState.driversFound.value = true;
      confirmPackageState.isUpdated = true;
      log("✅ updateDriversFound: drivers found = true");
    } else {
      confirmPackageState.driversFound.value = false;
      confirmPackageState.isUpdated = false;
      log("❌ updateDriversFound: drivers found = false");
    }
  }

  // saveDeliveryRequest() async {
  //   UserModel profile = SessionController.to.userData;
  //   var deliveryRequest = DeliveryRequest(
  //     userID: currentUser!.uid,
  //     userName: "${profile.firstName} ${profile.lastName}",
  //     status: "waiting",
  //     userPhone: profile.phoneNumber,
  //     driverID: confirmPackageState.nearestDriver!.driversId!,
  //     vehicleType: confirmPackageState.vehicleType.value,
  //     pickupLocation: confirmPackageState.pickupLocation.value,
  //     dropOffLocation: confirmPackageState.dropOffLocation.value,
  //     itemType: confirmPackageState.itemType.value,
  //     recipientName: confirmPackageState.receipientname.value,
  //     recipientNumber: confirmPackageState.receipientContact.value,
  //     paymentMethod: confirmPackageState.paymentMethod.value,
  //     pickupLatLng: confirmPackageState.pickupLatLng,
  //     dropOffLatLng: confirmPackageState.dropOffLatLng,
  //     deliveryAmount: confirmPackageState.tripAmount.value,
  //     dateCreated: DateTime.now(),
  //     userToken: profile.userToken,
  //   );
  //
  //   final docRef = fDataBase.collection("DeliveryRequests").doc();
  //   await docRef.set(deliveryRequest.toJson());
  //   getRatingAndDeliveries(confirmPackageState.nearestDriver!.driversId!);
  //
  //   return docRef;
  // }

  saveDeliveryRequest() async {
    // Reset message flags for new request
    _hasShownAcceptedMessage = false;
    _hasShownArrivedMessage = false;
    _hasShownOnTripMessage = false;

    UserModel profile = SessionController.to.userData;

    // Get current user FCM token
    String? currentUserToken;
    try {
      currentUserToken = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      if (kDebugMode) {
        log("Failed to get FCM token: $e");
      }
      // Continue without token - better to send request without token than to fail completely
    }

    var deliveryRequest = DeliveryRequest(
      userID: currentUser!.uid,
      userName: "${profile.firstName} ${profile.lastName}",
      status: "waiting",
      userPhone: profile.phoneNumber,
      driverID: "",
      // Empty string until a driver accepts - this prevents type errors
      vehicleType: confirmPackageState.vehicleType.value,
      pickupLocation: confirmPackageState.pickupLocation.value,
      dropOffLocation: confirmPackageState.dropOffLocation.value,
      itemType: confirmPackageState.itemType.value,
      recipientName: confirmPackageState.receipientname.value,
      recipientNumber: confirmPackageState.receipientContact.value,
      paymentMethod: confirmPackageState.paymentMethod.value,
      pickupLatLng: confirmPackageState.pickupLatLng,
      dropOffLatLng: confirmPackageState.dropOffLatLng,
      deliveryAmount: confirmPackageState.tripAmount.value,
      dateCreated: DateTime.now(),
      userToken: currentUserToken ?? profile.userToken, // Use current token
    );

    final docRef = fDataBase.collection("DeliveryRequests").doc();
    await docRef.set(deliveryRequest.toJson());

    // Set the requestID after creating the document
    confirmPackageState.requestID!.value = docRef.id;

    getRatingAndDeliveries(confirmPackageState.nearestDriver!.driversId!);
    return docRef;
  }

  uploadSentImage(String docRef) async {
    ProgressDialogUtils.showProgressDialog();

    String fileName = DateTime.now().microsecondsSinceEpoch.toString();
    bool ishasNetwork = await NetworkUtils.hasNetwork();

    if (!ishasNetwork) {
      return;
    }

    fstorage.Reference reference = fstorage.FirebaseStorage.instance
        .ref()
        .child("vlogx/deliveries")
        .child(fileName);
    fstorage.UploadTask uploadTask =
        reference.putFile(File(confirmPackageState.imagePath));
    fstorage.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    ProgressDialogUtils.hideProgressDialog();
    await taskSnapshot.ref
        .getDownloadURL()
        .then((imageUrl) {
          Map<String, dynamic> data = {
            "imageSent": imageUrl,
            "orderID": Util.uniqueRefenece(),
          };
          fDataBase.collection("DeliveryRequests").doc(docRef).update(data);
        })
        .catchError((error) => errorMethod("Error: $error"))
        .onError((error, stackTrace) {
          if (kDebugMode) {
            Logger.error(error, stackTrace: stackTrace);
          }
        });
  }

  sendDriverNotification({
    required String? driverID,
    required String requestPath,
  }) async {
    DriverModel? driverModel =
        await GeoFireAssistant.getDriverDetails(driverID!);
    var token = driverModel?.userToken;

    await Network.notifyDriver(driverToken: token!, requestID: requestPath);
  }

  void getRiderDriverStatus(DocumentReference docRef) {
    GeoFireAssistant.tripStreamSubscription =
        docRef.snapshots().listen((event) async {
      try {
        if (event.exists) {
          final data = event.data() as Map<String, dynamic>;
          final resultData = DeliveryRequest.fromJson(data);

          UserRideRequestStatus? status =
              getUserRideRequestStatusFromString(resultData.status!);

          if (status != null) {
            confirmPackageState.userRideRequestStatus.value = status;

            LatLng latLng = LatLng(confirmPackageState.nearestDriver!.latitude!,
                confirmPackageState.nearestDriver!.longitude!);
            handleRideRequestStatus(latLng);

            if (status == UserRideRequestStatus.accepted) {
              // Cancel timeout since driver accepted
              _cancelDriverAcceptanceTimeout();

              // CRITICAL: Assign driver ID ONLY when they accept - this is the key fix!
              if (resultData.driverID != null &&
                  resultData.driverID!.isNotEmpty) {
                // Store the accepted driver ID in state for rating later
                confirmPackageState.acceptedDriverID.value =
                    resultData.driverID!;

                try {
                  await fDataBase
                      .collection("DeliveryRequests")
                      .doc(confirmPackageState.requestID!.value)
                      .update({
                    'driverID':
                        resultData.driverID, // NOW we assign the driver ID
                    'acceptedAt': FieldValue.serverTimestamp(),
                    'assignedDriver':
                        resultData.driverID, // Track who was assigned
                  });
                } catch (e) {
                  if (kDebugMode) {
                    log("❌ Error assigning driver ID to delivery request: $e");
                  }
                }
              }

              DriverModel? driverData =
                  await GeoFireAssistant.getDriverDetails(resultData.driverID!);
              if (driverData != null) {
                confirmPackageState.driverDetails.value = driverData;

                // Fetch the latest rating and delivery data for the accepted driver
                getRatingAndDeliveriesForceRefresh(resultData.driverID!);
              }

              // Note: No need to manually refresh HomeController - its persistent
              // Firestore listener will automatically detect the status change
            }

            if (status == UserRideRequestStatus.declined) {
              // Cancel timeout since driver declined
              _cancelDriverAcceptanceTimeout();

              // Remove the declined driver from the list to prevent re-assignment
              if (resultData.driverID != null &&
                  resultData.driverID!.isNotEmpty) {
                GeoFireAssistant.deleteOfflineDriverFromList(
                    resultData.driverID!);

                if (kDebugMode) {
                  log("❌ Driver ${resultData.driverID} declined - removing from list");
                }
              }

              // ✅ Reassign to next driver WITHOUT creating duplicate trip
              if (GeoFireAssistant.nearestDrivers.isNotEmpty) {
                await reassignToNextDriver(
                    confirmPackageState.requestID!.value);
              } else {
                errorMethod(
                    "No more drivers available. Please try again later.");
              }
            }

            if (status == UserRideRequestStatus.ended) {
              successMethod(
                  "📦 Package Delivered Successfully! Thank you for using SwiftRun.");

              // Use the driver ID from the delivery request (the one who accepted and completed)
              String completedDriverId = resultData.driverID ??
                  confirmPackageState.acceptedDriverID.value;

              Map<String, String?> data = {
                "driverId":
                    completedDriverId, // ✅ Use the driver who actually completed the trip
                "tripId":
                    confirmPackageState.requestID!.value, // ✅ Add the trip ID
              };

              Get.offAll(() => const RatingScreen(), arguments: data);
            }
          }
        }
      } catch (e, stackTrace) {
        if (kDebugMode) {
          log("Error in getRiderDriverStatus: $e");
          log("Stack Trace: $stackTrace");
        }
      }
    }, onError: (error) {
      if (kDebugMode) {
        log("❌ Firestore Stream Error: $error");
      }
      errorMethod(
          "Connection Error: We are not receiving updates. Please check your internet.");
    });
  }

  setSelectedDriver(bool newStatus) {
    confirmPackageState.fetchedDriver.value = newStatus;
    update();
  }

  setRiderRequest(bool status) {
    confirmPackageState.isRiderRequesting.value = status;
    update();
  }

  Timer? _driverAcceptanceTimer;
  Timer? _followUpNotification1Timer;
  Timer? _followUpNotification2Timer;

  void _startDriverAcceptanceTimeout(String requestID) {
    // Cancel any existing timers
    _driverAcceptanceTimer?.cancel();
    _followUpNotification1Timer?.cancel();
    _followUpNotification2Timer?.cancel();

    // Follow-up notification after 30 seconds (halfway through timeout)
    _followUpNotification1Timer = Timer(const Duration(seconds: 30), () async {
      try {
        DocumentSnapshot doc =
            await fDataBase.collection('DeliveryRequests').doc(requestID).get();

        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String status = data['status'] ?? '';

          // Only send follow-up if still waiting
          if (status == 'waiting') {
            DriverModel? driverData = await GeoFireAssistant.getDriverDetails(
                confirmPackageState.nearestDriver!.driversId!);

            if (driverData != null && driverData.userToken != null) {
              await Network.notifyDriver(
                  driverToken: driverData.userToken!,
                  requestID: requestID,
                  title: "⚠️ Delivery Request Pending",
                  message:
                      "Please respond to this delivery request within 30 seconds.",
                  status: "reminder",
                  type: "delivery_request");

              if (kDebugMode) {
                log("✅ 30-second reminder sent to driver");
              }
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          log("Error sending 30-second reminder: $e");
        }
      }
    });

    // Final timeout after 60 seconds - reassign to another driver
    _driverAcceptanceTimer = Timer(const Duration(seconds: 60), () async {
      // Check if request is still waiting for acceptance
      try {
        DocumentSnapshot doc =
            await fDataBase.collection('DeliveryRequests').doc(requestID).get();

        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String status = data['status'] ?? '';

          // Only reassign if still waiting for driver response
          if (status == 'waiting') {
            // Remove current driver from list to prevent re-assignment
            if (confirmPackageState.nearestDriver != null) {
              String driverId = confirmPackageState.nearestDriver!.driversId!;
              GeoFireAssistant.deleteOfflineDriverFromList(driverId);

              if (kDebugMode) {
                log("⏰ Driver $driverId timed out - removing from list");
              }
            }

            // Show friendly timeout message
            infoMethod(
                "Still looking for a driver. You can exit this page and we'll verify when a driver accepts.");

            // ✅ Reassign to next driver WITHOUT creating duplicate trip
            if (GeoFireAssistant.nearestDrivers.isNotEmpty) {
              await reassignToNextDriver(requestID);
            } else {
              infoMethod(
                  "All nearby drivers are busy. We'll keep looking for you.");
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          log("Error checking request status during timeout: $e");
        }
      }
    });
  }

  /// Reassign existing delivery to next available driver (without creating duplicate trip)
  Future<void> reassignToNextDriver(String requestID) async {
    if (kDebugMode) {
      log("🔄 Reassigning trip $requestID to next available driver");
    }

    if (GeoFireAssistant.nearestDrivers.isEmpty) {
      infoMethod(
          "No more drivers available nearby. We'll notify you when one becomes free.");
      return;
    }

    // All drivers in nearestDrivers are already online and approved
    // Just find the closest one
    CloseByDriverModel? selectedDriver =
        _findClosestDriver(GeoFireAssistant.nearestDrivers);
    String driverStatus = "Finding nearest driver";

    if (selectedDriver != null) {
      confirmPackageState.nearestDriver = selectedDriver;

      // ✅ UPDATE existing trip - DON'T create a new one
      try {
        await fDataBase.collection('DeliveryRequests').doc(requestID).update({
          'status': 'waiting', // Keep as waiting for new driver
          'reassignedAt': FieldValue.serverTimestamp(),
          'previousDrivers': FieldValue.arrayUnion([
            if (confirmPackageState.driverDetails.value.driversId != null)
              confirmPackageState.driverDetails.value.driversId
          ]),
        });

        if (kDebugMode) {
          log("✅ Trip updated (not duplicated)");
        }
      } catch (e) {
        if (kDebugMode) {
          log("❌ Error updating trip: $e");
        }
        return;
      }

      // Get new driver details and send notification
      DriverModel? driverData =
          await GeoFireAssistant.getDriverDetails(selectedDriver.driversId!);

      if (driverData != null) {
        confirmPackageState.driverDetails.value = driverData;

        if (kDebugMode) {
          log("📱 New Driver Details:");
          log("- Driver Name: ${driverData.firstName} ${driverData.lastName}");
          log("- Driver ID: ${driverData.driversId}");
        }

        // Send notification to new driver
        if (driverData.userToken != null && driverData.userToken!.isNotEmpty) {
          await Network.notifyDriver(
              driverToken: driverData.userToken!,
              requestID: requestID,
              title: "New Delivery Request",
              message: "You have a new delivery request. Tap to view details.",
              status: "new_request",
              type: "delivery_request");

          if (kDebugMode) {
            log("✅ Notification sent to new driver");
          }
        }

        successMethod("$driverStatus - Request reassigned!");

        // Start new timeout for this driver
        _startDriverAcceptanceTimeout(requestID);
      } else {
        errorMethod("Could not get driver details. Please try again.");
      }
    } else {
      errorMethod("⏰ No drivers available. Please try again later.");
    }
  }

  void _cancelDriverAcceptanceTimeout() {
    _driverAcceptanceTimer?.cancel();
    _driverAcceptanceTimer = null;
    _followUpNotification1Timer?.cancel();
    _followUpNotification1Timer = null;
    _followUpNotification2Timer?.cancel();
    _followUpNotification2Timer = null;
  }

  void updateDriversTimeToPickupLocation(LatLng driverLatLng) async {
    if (confirmPackageState.requestPositionInfo.value) {
      confirmPackageState.requestPositionInfo.value = false;

      DirectionModel directionInfo = await Network.getRiderDirection(
        driverLatLng,
        confirmPackageState.pickupLatLng,
      );

      confirmPackageState.driverRideStatus.value =
          "🚗 ${formatDuration(directionInfo.duration)} away from your pickup location";

      confirmPackageState.requestPositionInfo.value = true;
    }
  }

  void updateDriversTimeToDropOffLocation(LatLng driverLatLng) async {
    if (confirmPackageState.requestPositionInfo.value) {
      confirmPackageState.requestPositionInfo.value = false;

      try {
        DirectionModel directionInfo = await Network.getRiderDirection(
          driverLatLng,
          confirmPackageState.dropOffLatLng,
        );

        confirmPackageState.driverRideStatus.value =
            "📦 ${formatDuration(directionInfo.duration)} to delivery location";
      } catch (e) {
        if (kDebugMode) {
          Logger.i("Error in getting direction: $e");
        }
      } finally {
        confirmPackageState.requestPositionInfo.value = true;
      }
    }
  }

  void handleRideRequestStatus(LatLng driverCurrentPositionLatLng) {
    switch (confirmPackageState.userRideRequestStatus.value) {
      case UserRideRequestStatus.accepted:
        updateDriversTimeToPickupLocation(driverCurrentPositionLatLng);
        if (!_hasShownAcceptedMessage) {
          successMethod(
              "🎉 Great! ${confirmPackageState.driverDetails.value.firstName ?? 'Driver'} accepted your request!");
          _hasShownAcceptedMessage = true;
        }
        break;

      case UserRideRequestStatus.arrived:
        confirmPackageState.driverRideStatus.value =
            "🚗 Your driver has arrived at pickup location!";
        if (!_hasShownArrivedMessage) {
          successMethod(
              "📍 ${confirmPackageState.driverDetails.value.firstName ?? 'Your driver'} is here!");
          _hasShownArrivedMessage = true;
        }
        break;

      case UserRideRequestStatus.onTrip:
        updateDriversTimeToDropOffLocation(driverCurrentPositionLatLng);
        if (!_hasShownOnTripMessage) {
          successMethod(
              "🚚 Package picked up! On the way to delivery location.");
          _hasShownOnTripMessage = true;
        }
        break;

      case UserRideRequestStatus.declined:
        errorMethod(
            "😔 Driver declined your request. Finding another driver...");
        break;

      case UserRideRequestStatus.ended:
        break;

      default:
        // Handle unknown status
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

  Future<double> getTripAmount({required String vehicleTypeId}) async {
    try {
      if (LocationController.to.directionDetails != null) {
        double fareAmount = await FareCalculator.calculateFareAmount(
          distanceInKM: LocationController.to.directionDetails!,
          vehicleTypeId: vehicleTypeId,
        );

        confirmPackageState.tripAmount.value = fareAmount.toStringAsFixed(0);
        return fareAmount;
      } else {
        throw Exception("Direction details are not available");
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        Logger.error("Error calculating trip amount: $e",
            stackTrace: stackTrace);
      }
      throw Exception('Failed to calculate trip amount: $e');
    }
  }

  updatePaymentStatus(bool paymentStatus) {
    confirmPackageState.paymentStatus.value = paymentStatus;
    fDataBase
        .collection('DeliveryRequests')
        .doc(confirmPackageState.requestID!.value)
        .update({'paymentStatus': paymentStatus});

    Logger.i(
        "Payment Status: $paymentStatus ${confirmPackageState.paymentStatus.value}");
    update();
  }

  // void cancelTrip() {
  //   try {
  //     // Check if requestID exists and is not empty
  //     if (confirmPackageState.requestID?.value == null ||
  //         confirmPackageState.requestID!.value.isEmpty) {
  //       errorMethod("Cannot cancel: No active request found");
  //       return;
  //     }
  //
  //     Map<String, dynamic> data = {"status": "cancelled"};
  //     fDataBase
  //         .collection('DeliveryRequests')
  //         .doc(confirmPackageState.requestID!.value)
  //         .update(data);
  //
  //     // Clean up
  //     GeoFireAssistant.tripStreamSubscription?.cancel();
  //     confirmPackageState.userRideRequestStatus.value = UserRideRequestStatus.waiting;
  //
  //     successMethod("Request cancelled successfully");
  //     log("Trip cancelled: ${confirmPackageState.requestID!.value}");
  //   } catch (e) {
  //     log("Error cancelling trip: $e");
  //     errorMethod("Failed to cancel request");
  //   }
  // }

  // void cancelTrip() {
  //   try {
  //     if (confirmPackageState.requestID?.value == null ||
  //         confirmPackageState.requestID!.value.isEmpty) {
  //       errorMethod("Cannot cancel: No active request found");
  //       return;
  //     }
  //
  //     Map<String, dynamic> data = {"status": "cancelled"};
  //     fDataBase
  //         .collection('DeliveryRequests')
  //         .doc(confirmPackageState.requestID!.value)
  //         .update(data)
  //         .then((_) async {
  //
  //       // Send cancellation notification to the assigned driver
  //       if (confirmPackageState.driverDetails.value != null &&
  //           confirmPackageState.driverDetails.value!.userToken != null) {
  //
  //         await Network.notifyDriver(
  //           driverToken: confirmPackageState.driverDetails.value!.userToken!,
  //           requestID: confirmPackageState.requestID!.value,
  //         );
  //       }
  //     });
  //
  //     GeoFireAssistant.tripStreamSubscription?.cancel();
  //     confirmPackageState.userRideRequestStatus.value = UserRideRequestStatus.waiting;
  //
  //     successMethod("Request cancelled successfully");
  //     log("Trip cancelled: ${confirmPackageState.requestID!.value}");
  //   } catch (e) {
  //     log("Error cancelling trip: $e");
  //     errorMethod("Failed to cancel request");
  //   }
  // }

  void cancelTrip() {
    try {
      if (confirmPackageState.requestID?.value == null ||
          confirmPackageState.requestID!.value.isEmpty) {
        errorMethod("Cannot cancel: No active request found");
        return;
      }

      Map<String, dynamic> data = {"status": "cancelled"};
      fDataBase
          .collection('DeliveryRequests')
          .doc(confirmPackageState.requestID!.value)
          .update(data)
          .then((_) async {
        // Send cancellation notification with proper parameters
        if (confirmPackageState.driverDetails.value.userToken != null) {
          await Network.notifyDriver(
              driverToken: confirmPackageState.driverDetails.value.userToken!,
              requestID: confirmPackageState.requestID!.value,
              title: "Delivery Cancelled", // Add this
              message:
                  "The customer has cancelled this delivery request.", // Add this
              status: "cancelled", // Add this
              type: "delivery_cancelled" // Add this
              );
        }
      });

      GeoFireAssistant.tripStreamSubscription?.cancel();
      confirmPackageState.userRideRequestStatus.value =
          UserRideRequestStatus.waiting;

      successMethod("Request cancelled successfully");
    } catch (e) {
      if (kDebugMode) {
        log("Error cancelling trip: $e");
      }
      errorMethod("Failed to cancel request");
    }
  }

  /// Listen for payment verification from webhook
  void startPaymentVerificationListener(String deliveryId) {
    if (kDebugMode) {
      log('🔄 Starting payment verification listener for: $deliveryId');
    }

    bool isFirstSnapshot = true;
    Timer? timeoutTimer;

    // Set timeout for webhook verification (60 seconds)
    timeoutTimer = Timer(const Duration(seconds: 60), () {
      if (kDebugMode) {
        log('⏰ Payment verification timeout - webhook took too long');
      }
      errorMethod(
          'Payment verification timeout. Please contact support if money was deducted.');
    });

    // Listen to Firestore for payment verification
    fDataBase
        .collection('DeliveryRequests')
        .doc(deliveryId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) return;

      final data = snapshot.data();
      if (data == null) return;

      // Check if payment is verified by webhook
      final paymentVerified = data['paymentVerified'] as bool?;
      final paymentStatus = data['paymentStatus'] as bool?;

      if (kDebugMode) {
        log('Payment status update: verified=$paymentVerified, status=$paymentStatus, isFirstSnapshot=$isFirstSnapshot');
      }

      // Skip the initial snapshot (before webhook processes)
      if (isFirstSnapshot) {
        isFirstSnapshot = false;
        if (kDebugMode) {
          log('📸 Initial state captured, waiting for webhook update...');
        }
        return;
      }

      // Webhook has updated the document - cancel timeout
      timeoutTimer?.cancel();

      if (paymentVerified == true && paymentStatus == true) {
        // Payment confirmed by webhook!
        if (kDebugMode) {
          log('✅ Payment verified by webhook!');
        }
        // Reset processing state and update payment status
        log('🔄 Setting isPaymentProcessing to false');
        confirmPackageState.isPaymentProcessing.value = false;
        log('💳 Setting paymentStatus to true');
        updatePaymentStatus(true);
        // Force UI update
        confirmPackageState.paymentUIUpdateTrigger.value++;
        log('📱 Calling successMethod');
        successMethod('Payment confirmed! ✅');
      } else if (paymentVerified == false || paymentStatus == false) {
        // Payment failed
        if (kDebugMode) {
          log('❌ Payment verification failed by webhook');
        }
        // Reset processing state on failure
        log('🔄 Setting isPaymentProcessing to false (failed)');
        confirmPackageState.isPaymentProcessing.value = false;
        // Force UI update
        confirmPackageState.paymentUIUpdateTrigger.value++;
        errorMethod('Payment failed. Please try again.');
        // Note: We don't update payment status to false because user might retry
      }
    });
  }

  @override
  void onClose() {
    // Cancel any pending timeout timer
    _cancelDriverAcceptanceTimeout();

    GeoFireAssistant.nearestDrivers.clear();
    // Safely dispose googleMapController if it exists
    googleMapController?.dispose();
    super.onClose();
  }
}

enum UserRideRequestStatus {
  waiting,
  accepted,
  declined,
  arrived,
  onTrip,
  ended,
}

// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as fstorage;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:swiftrun/common/routes/route.dart';
import 'package:swiftrun/common/utils/fare_cal.dart';
import 'package:swiftrun/common/utils/geofire_assistant.dart';
import 'package:swiftrun/common/utils/utils.dart';
import 'package:swiftrun/core/controller/get_driver_near.dart';
import 'package:swiftrun/core/controller/location_controller.dart';
import 'package:swiftrun/core/controller/session_controller.dart';
import 'package:swiftrun/core/model/address_model.dart';
import 'package:swiftrun/core/model/driver_model.dart';
import 'package:swiftrun/features/auth/data/model/user_model.dart';
import 'package:swiftrun/features/booking/model/nearby_driver_model.dart';
import 'package:swiftrun/features/booking/model/schedule_model.dart';
import 'package:swiftrun/features/booking/presentation/atoms/schedule_delivery/state.dart';
import 'package:swiftrun/global/global.dart';
import 'package:swiftrun/services/network/network.dart';
import 'package:swiftrun/services/network/network_utils.dart';

class ScheducleDeliveryController extends GetxController {
  static ScheducleDeliveryController get to => Get.find();
  var locationController = Get.put(LocationController());
  var state = ScheduleState();

  final Completer<GoogleMapController> _mapControllerDriver = Completer();
  GoogleMapController? googleMapController;

  UserModel profile = SessionController.to.userData;

  // Timers for notifications and driver reassignment
  Timer? _driverAcceptanceTimer;
  Timer? _followUpNotification1Timer;
  Timer? _followUpNotification2Timer;
  Timer? _reminderNotification10MinTimer;
  Timer? _reminderNotification5MinTimer;

  // Track assigned driver
  CloseByDriverModel? assignedDriver;
  String? currentRequestID;

  @override
  void onInit() {
    super.onInit();

    state.requestData = Get.arguments;

    // state.pickupLatLng.value = state.requestData['pickupLocation'];

    // state.dropOffLatLng.value = state.requestData['dropOffLocation'];
    state.pickupLatLng.value = LatLng(
      double.parse(state.requestData['pickupLat'].toString()),
      double.parse(state.requestData['pickupLng'].toString()),
    );
    state.dropOffLatLng.value = LatLng(
      double.parse(state.requestData['dropOffLat'].toString()),
      double.parse(state.requestData['dropOffLat'].toString()),
    );
    state.itemType.value = state.requestData['items'];
    state.receipientname.value = state.requestData['receipientName'];
    state.receipientContact.value = state.requestData['receipientNumber'];
    state.vehicleType.value = state.requestData['vehicleType'];
    state.vehicleTypeId.value = state.requestData['vehicleTypeId'];
    state.dropOffLocation.value = state.requestData['dropOffAddress'];
    state.pickupLocation.value = state.requestData['pickupAddress'];
    state.pickupDate.value = state.requestData['dateScheduled'];
    state.pickupTime.value = state.requestData['timeScheduled'];
    state.imageUrl.value = state.requestData['imageUrl'];
    state.paymentMethod.value = state.requestData['paymentMethod'] ?? "Cash";
  }

  void onMapDetail(GoogleMapController controller) {
    _mapControllerDriver.complete(controller);
    googleMapController = controller;

    _addMarker();
  }

  Future<double> getTripAmount({
    required String vehicleTypeId,
  }) async {
    try {
      if (LocationController.to.directionDetails != null) {
        double fareAmount = await FareCalculator.calculateFareAmount(
          distanceInKM: LocationController.to.directionDetails!,
          vehicleTypeId: vehicleTypeId,
        );

        state.deliveryAmount.value = fareAmount.toStringAsFixed(0);
        return fareAmount;
      } else {
        throw Exception("Direction details are not available");
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        Logger.error("Error calculating trip amount: $e", stackTrace: stackTrace);
      }
      throw Exception('Failed to calculate trip amount: $e');
    }
  }

  void _addMarker() {
    state.markerSet.clear();
    state.markerSet.add(
      Marker(
        markerId: const MarkerId('Destination'),
        position: state.dropOffLatLng.value!,
        infoWindow:
            InfoWindow(title: '${state.requestData['dropOffLocation']}'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
    debugPrint("Destination.......${state.markerSet}");
    state.markerSet.add(
      Marker(
        markerId: const MarkerId('pickup'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        position: state.pickupLatLng.value!,
        infoWindow: const InfoWindow(title: 'Pickup Location'),
      ),
    );
    if (kDebugMode) {
      debugPrint("Markers added: pickup and destination");
    }
  }

  void saveToDataBase(BuildContext context) async {
    try {
      var dateFormat = DateFormat.yMMMd();
      var timeFormat = DateFormat('h:mm a');

      DateTime parsedDate = dateFormat.parse(state.pickupDate.value);
      DateTime parsedTime = timeFormat.parse(state.pickupTime.value);
      DateTime combinedDateTime = DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
        parsedTime.hour,
        parsedTime.minute,
      );

      var scheduleDeliveryData = ScheduleDeliveryModel(
        userID: profile.userID,
        pickupAddress: state.pickupLocation.value,
        pickupLatLng: state.pickupLatLng.value,
        dropOffAddress: state.dropOffLocation.value,
        dropOffLatLng: state.dropOffLatLng.value,
        vehicleType: state.vehicleType.value,
        deliveryAmount: state.deliveryAmount.value,
        status: "scheduled", // Changed from "waiting" to "scheduled" so it shows in dashboard
        recipientName: state.receipientname.value,
        recipientNumber: state.receipientContact.value,
        items: state.itemType.value,
        dateScheduled: combinedDateTime,
        dateCreated: DateTime.now(),
      );

      ProgressDialogUtils.showProgressDialog();

      if (!await NetworkUtils.hasNetwork()) {
        ProgressDialogUtils.hideProgressDialog();
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          title: 'No Network',
          desc: 'Please check your internet connection and try again.',
          btnOkOnPress: () => Navigator.of(context).pop(),
        ).show();
        return;
      }

      final docRef = fDataBase.collection("ScheduleRequest").doc();
      await docRef.set(scheduleDeliveryData.toMap());

      // Store delivery ID for payment metadata
      state.scheduledDeliveryId.value = docRef.id;

      if (state.imageUrl.value.isNotEmpty) {
        String fileName = DateTime.now().microsecondsSinceEpoch.toString();
        fstorage.Reference reference =
            fstorage.FirebaseStorage.instance.ref("vlogx/deliveries/$fileName");

        fstorage.UploadTask uploadTask =
            reference.putFile(File(state.imageUrl.value));

        fstorage.TaskSnapshot taskSnapshot = await uploadTask;

        String imageUrl = await taskSnapshot.ref.getDownloadURL();
        await docRef.update({"imageUrl": imageUrl});
      }

      // Search for nearby drivers first, then assign
      if (kDebugMode) {
        dev.log("📅 Searching for drivers near pickup location for: ${docRef.id}");
      }

      // Create AddressModel for driver search (required by GetNearByDriver)
      LocationController.to.pickupLocation = AddressModel(
        name: "Pickup Location",
        description: state.pickupLocation.value,
        latitude: state.pickupLatLng.value!.latitude,
        longitude: state.pickupLatLng.value!.longitude,
      );

      // Get active drivers near the pickup location
      GetNearByDriver.getActiveDriver();

      // Wait a bit for the driver search to complete
      await Future.delayed(const Duration(seconds: 3));

      if (kDebugMode) {
        dev.log("📊 Found ${GeoFireAssistant.nearestDrivers.length} nearby drivers");
      }

      // Now assign driver and setup notifications
      await _assignDriverToScheduledDelivery(docRef.id, combinedDateTime);

      ProgressDialogUtils.hideProgressDialog();
      AwesomeDialog(
        context: context,
        animType: AnimType.leftSlide,
        dialogType: DialogType.success,
        title: 'Success',
        desc: 'Your delivery has been scheduled successfully. A driver will be assigned shortly.',
        autoDismiss: false,
        onDismissCallback: (type) {
          if (kDebugMode) {
            debugPrint("Dialog dismissed: $type");
          }
        },
        btnOkOnPress: () => Get.offAllNamed(AppRoutes.dashboard),
      ).show();
    } catch (e, stackTrace) {
      ProgressDialogUtils.hideProgressDialog();
      if (kDebugMode) {
        Logger.error("Error in saveToDataBase: $e", stackTrace: stackTrace);
      }
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Error',
        desc:
            'An error occurred while scheduling your delivery. Please try again.',
        btnOkOnPress: () => Navigator.of(context).pop(),
      ).show();
    }
  }

  void updatePaymentStatus(bool paymentStatus) {
    fDataBase
        .collection('ScheduleRequest')
        .doc(state.docRef.id)
        .update({'paymentStatus': paymentStatus});

    if (kDebugMode) {
      Logger.i("Payment Status updated: $paymentStatus");
    }
  }

  // Find and assign a driver for scheduled delivery
  Future<void> _assignDriverToScheduledDelivery(String requestID, DateTime scheduledTime) async {
    try {
      if (GeoFireAssistant.nearestDrivers.isEmpty) {
        if (kDebugMode) {
          dev.log("❌ No drivers available for scheduled delivery");
        }
        return;
      }

      // Create a copy to avoid concurrent modification
      List<CloseByDriverModel> nearbyDriversCopy = List.from(GeoFireAssistant.nearestDrivers);

      // Separate available and busy drivers
      List<CloseByDriverModel> availableDrivers = [];
      List<CloseByDriverModel> busyDrivers = [];

      for (CloseByDriverModel driver in nearbyDriversCopy) {
        bool isAvailable = await GetNearByDriver.checkDriverAvailability(driver.driversId!);

        if (isAvailable) {
          availableDrivers.add(driver);
        } else {
          busyDrivers.add(driver);
        }
      }

      // Prefer available drivers first
      CloseByDriverModel? selectedDriver;
      if (availableDrivers.isNotEmpty) {
        selectedDriver = _findClosestDriver(availableDrivers);
      } else if (busyDrivers.isNotEmpty) {
        selectedDriver = _findClosestDriver(busyDrivers);
      }

      if (selectedDriver != null) {
        assignedDriver = selectedDriver;
        currentRequestID = requestID;

        // Get driver details and send notification
        DriverModel? driverData = await GeoFireAssistant.getDriverDetails(selectedDriver.driversId!);

        if (driverData != null && driverData.userToken != null) {
          // Send immediate notification
          await Network.notifyDriver(
            driverToken: driverData.userToken!,
            requestID: requestID,
            title: "📅 New Scheduled Delivery",
            message: "You have been assigned a scheduled delivery for ${DateFormat('MMM d, h:mm a').format(scheduledTime)}. Please accept.",
            status: "scheduled_request",
            type: "scheduled_delivery"
          );

          if (kDebugMode) {
            dev.log("✅ Notification sent to driver: ${driverData.firstName}");
          }

          // Start follow-up notifications and acceptance timeout
          _startScheduledDeliveryNotifications(requestID, scheduledTime, driverData);
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        Logger.error("Error assigning driver: $e", stackTrace: stackTrace);
      }
    }
  }

  // Find closest driver from a list
  CloseByDriverModel? _findClosestDriver(List<CloseByDriverModel> drivers) {
    if (drivers.isEmpty) return null;

    double minDistance = double.infinity;
    CloseByDriverModel? closest;

    for (CloseByDriverModel driver in drivers) {
      double distance = Geolocator.distanceBetween(
        state.pickupLatLng.value!.latitude,
        state.pickupLatLng.value!.longitude,
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

  // Start notification system for scheduled deliveries
  void _startScheduledDeliveryNotifications(String requestID, DateTime scheduledTime, DriverModel driverData) {
    _cancelAllTimers();

    // Follow-up notification after 30 seconds (halfway through timeout)
    _followUpNotification1Timer = Timer(const Duration(seconds: 30), () async {
      if (kDebugMode) {
        dev.log("30-second reminder for scheduled delivery: $requestID");
      }
      await _sendFollowUpIfNotAccepted(requestID, driverData, "⚠️ Scheduled Delivery Pending", "Please respond to this scheduled delivery request within 30 seconds.");
    });

    // Reassign if no acceptance after 60 seconds
    _driverAcceptanceTimer = Timer(const Duration(seconds: 60), () async {
      if (kDebugMode) {
        dev.log("Driver acceptance timeout (60s) for scheduled delivery: $requestID");
      }
      await _reassignScheduledDelivery(requestID, scheduledTime);
    });

    // Schedule reminder notifications (10 min and 5 min before scheduled time)
    _scheduleReminderNotifications(requestID, scheduledTime, driverData);
  }

  // Send follow-up notification if request is still waiting
  Future<void> _sendFollowUpIfNotAccepted(String requestID, DriverModel driverData, String title, String message) async {
    try {
      DocumentSnapshot doc = await fDataBase.collection('ScheduleRequest').doc(requestID).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String status = data['status'] ?? '';

        if (status == 'scheduled' || status == 'waiting') {
          await Network.notifyDriver(
            driverToken: driverData.userToken!,
            requestID: requestID,
            title: title,
            message: message,
            status: "reminder",
            type: "scheduled_delivery"
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        dev.log("Error sending follow-up: $e");
      }
    }
  }

  // Reassign scheduled delivery to another driver
  Future<void> _reassignScheduledDelivery(String requestID, DateTime scheduledTime) async {
    try {
      DocumentSnapshot doc = await fDataBase.collection('ScheduleRequest').doc(requestID).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String status = data['status'] ?? '';

        if (status == 'scheduled' || status == 'waiting') {
          if (kDebugMode) {
            dev.log("Reassigning scheduled delivery to another driver");
          }

          // Remove current driver from list
          if (assignedDriver != null) {
            GeoFireAssistant.deleteOfflineDriverFromList(assignedDriver!.driversId!);
          }

          // Find and assign another driver
          await _assignDriverToScheduledDelivery(requestID, scheduledTime);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        dev.log("Error reassigning scheduled delivery: $e");
      }
    }
  }

  // Schedule reminder notifications for accepted deliveries
  void _scheduleReminderNotifications(String requestID, DateTime scheduledTime, DriverModel driverData) {
    DateTime now = DateTime.now();
    Duration timeUntil30Min = scheduledTime.subtract(const Duration(minutes: 30)).difference(now);
    Duration timeUntil10Min = scheduledTime.subtract(const Duration(minutes: 10)).difference(now);

    // Only schedule if the time hasn't passed
    if (timeUntil30Min.isNegative == false && timeUntil30Min.inMinutes > 0) {
      _reminderNotification10MinTimer = Timer(timeUntil30Min, () async {
        if (kDebugMode) {
          dev.log("30-minute reminder for scheduled delivery: $requestID");
        }
        await _sendAcceptedDeliveryReminder(requestID, driverData, "🔔 Scheduled Delivery in 30 Minutes", "Your scheduled delivery starts in 30 minutes. Please prepare.");
      });
    }

    if (timeUntil10Min.isNegative == false && timeUntil10Min.inMinutes > 0) {
      _reminderNotification5MinTimer = Timer(timeUntil10Min, () async {
        if (kDebugMode) {
          dev.log("10-minute reminder for scheduled delivery: $requestID");
        }
        await _sendAcceptedDeliveryReminder(requestID, driverData, "⏰ Scheduled Delivery in 10 Minutes!", "Your scheduled delivery starts in 10 minutes. Get ready!");
      });
    }
  }

  // Send reminder for accepted scheduled delivery
  Future<void> _sendAcceptedDeliveryReminder(String requestID, DriverModel driverData, String title, String message) async {
    try {
      DocumentSnapshot doc = await fDataBase.collection('ScheduleRequest').doc(requestID).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String status = data['status'] ?? '';

        // Only send reminder if delivery is accepted and not yet completed
        if (status == 'accepted' || status == 'waiting') {
          await Network.notifyDriver(
            driverToken: driverData.userToken!,
            requestID: requestID,
            title: title,
            message: message,
            status: "scheduled_reminder",
            type: "scheduled_delivery"
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        dev.log("Error sending scheduled reminder: $e");
      }
    }
  }

  // Cancel all timers
  void _cancelAllTimers() {
    _driverAcceptanceTimer?.cancel();
    _followUpNotification1Timer?.cancel();
    _followUpNotification2Timer?.cancel();
    _reminderNotification10MinTimer?.cancel();
    _reminderNotification5MinTimer?.cancel();
  }

  // Cancel scheduled delivery
  Future<void> cancelScheduledDelivery(String requestID, BuildContext context) async {
    try {
      if (kDebugMode) {
        dev.log("🚫 Canceling scheduled delivery: $requestID");
      }

      // Get the delivery document
      DocumentSnapshot doc = await fDataBase.collection('ScheduleRequest').doc(requestID).get();

      if (!doc.exists) {
        errorMethod("Delivery not found");
        return;
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String status = data['status'] ?? '';

      // Check if delivery can be canceled
      if (status == 'ended' || status == 'cancelled') {
        errorMethod("This delivery cannot be cancelled");
        return;
      }

      // Cancel all notification timers
      _cancelAllTimers();

      // Update status to cancelled
      await fDataBase.collection('ScheduleRequest').doc(requestID).update({
        'status': 'cancelled',
        'dateCancelled': DateTime.now(),
        'cancelReason': 'Cancelled by user',
      });

      // Notify driver if one was assigned
      String? driverID = data['driverAssigned'];
      if (driverID != null && driverID.isNotEmpty) {
        DriverModel? driverData = await GeoFireAssistant.getDriverDetails(driverID);

        if (driverData != null && driverData.userToken != null) {
          await Network.notifyDriver(
            driverToken: driverData.userToken!,
            requestID: requestID,
            title: "🚫 Delivery Cancelled",
            message: "The scheduled delivery has been cancelled by the customer.",
            status: "cancelled",
            type: "scheduled_cancelled"
          );
        }
      }

      successMethod("Scheduled delivery cancelled successfully");

      // Navigate back to dashboard
      Get.offAllNamed(AppRoutes.dashboard);

    } catch (e, stackTrace) {
      if (kDebugMode) {
        Logger.error("Error cancelling scheduled delivery: $e", stackTrace: stackTrace);
      }
      errorMethod("Failed to cancel delivery");
    }
  }

  /// Listen for payment verification from webhook
  void startPaymentVerificationListener(String deliveryId) {
    if (kDebugMode) {
      dev.log('🔄 Starting payment verification listener for scheduled delivery: $deliveryId');
    }

    bool isFirstSnapshot = true;
    Timer? timeoutTimer;
    
    // Set timeout for webhook verification (60 seconds)
    timeoutTimer = Timer(const Duration(seconds: 60), () {
      if (kDebugMode) {
        dev.log('⏰ Payment verification timeout - webhook took too long');
      }
      errorMethod('Payment verification timeout. Please contact support if money was deducted.');
    });

    // Listen to Firestore for payment verification
    fDataBase
        .collection('ScheduleRequest')
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
        dev.log('Scheduled payment status update: verified=$paymentVerified, status=$paymentStatus, isFirstSnapshot=$isFirstSnapshot');
      }

      // Skip the initial snapshot (before webhook processes)
      if (isFirstSnapshot) {
        isFirstSnapshot = false;
        if (kDebugMode) {
          dev.log('📸 Initial state captured, waiting for webhook update...');
        }
        return;
      }

      // Webhook has updated the document - cancel timeout
      timeoutTimer?.cancel();

      if (paymentVerified == true && paymentStatus == true) {
        // Payment confirmed by webhook!
        if (kDebugMode) {
          dev.log('✅ Scheduled payment verified by webhook!');
        }
        updatePaymentStatus(true);
        successMethod('Payment confirmed! ✅');
      } else if (paymentVerified == false || paymentStatus == false) {
        // Payment failed
        if (kDebugMode) {
          dev.log('❌ Payment verification failed by webhook');
        }
        errorMethod('Payment failed. Please try again.');
        // Note: We don't update payment status to false because user might retry
      }
    });
  }

  @override
  void onClose() {
    _cancelAllTimers();
    super.onClose();
  }
}

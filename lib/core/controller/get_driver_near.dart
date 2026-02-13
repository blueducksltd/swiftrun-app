import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:get/get.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:swiftrun/common/utils/geofire_assistant.dart';
import 'package:swiftrun/common/utils/logger.dart';
import 'package:swiftrun/core/controller/location_controller.dart';
import 'package:swiftrun/features/booking/model/nearby_driver_model.dart';
import 'package:swiftrun/features/booking/presentation/atoms/confirm_details/confirmation.con.dart';
import 'package:swiftrun/global/global.dart';

class GetNearByDriver {
  static StreamSubscription<List<DocumentSnapshot>>? _streamSubscription;
  static bool _isLoading = false;
  
  // Cache the controller reference to avoid repeated lookups
  static ConfirmPackageController? _cachedController;
  
  // Method to manually set the controller instance (call this from onInit)
  static void setController(ConfirmPackageController c) {
    _cachedController = c;
    log("✅ ConfirmPackageController manually set in GetNearByDriver");
  }
  
  // Use Get.find() with proper registration check
  static ConfirmPackageController get controller {
    // Check if we already have a cached reference
    if (_cachedController != null) {
      return _cachedController!;
    }
    
    // Try to find existing controller
    if (Get.isRegistered<ConfirmPackageController>()) {
      _cachedController = Get.find<ConfirmPackageController>();
      return _cachedController!;
    }
    
    // Safety check: throw error instead of creating new instance to avoid infinite loops
    // If we get here, it means getActiveDriver was called before controller was initialized/registered
    throw Exception("CRITICAL: ConfirmPackageController not found! Ensure GetNearByDriver.setController(this) is called in onInit.");
  }
  
  // Clear cached controller when needed (e.g., on dispose)
  static void clearControllerCache() {
    _cachedController = null;
  }

  // static void getActiveDriver() async {
  //   // Initialize GeoFlutterFire2
  //   GeoFlutterFire geo = GeoFlutterFire();
  //
  //   // Create a GeoFirePoint based on the provided position
  //   GeoFirePoint center = geo.point(
  //     latitude: LocationController.to.pickupLocation!.latitude!,
  //     longitude: LocationController.to.pickupLocation!.longitude!,
  //   );
  //   log("center ${center.latitude} ${center.longitude}");
  //   // Reference to the Firestore collection
  //   //final Query<Map<String, dynamic>> collection = fDataBase
  //   Query collection = fDataBase
  //       .collection('Drivers')
  //       .where('isDriverOnline', isEqualTo: true);
  //   QuerySnapshot querySnapshot = await collection.get();
  //   final result = querySnapshot.docs;
  //
  //   final data = result.map((e) => e.data()).toList();
  //
  //   Logger.i("{Data:: $data}");
  //
  //   // Create a GeoFlutterFire stream
  //
  //   GeoFireAssistant.stream = geo.collection(collectionRef: collection).within(
  //         center: center,
  //         radius: 500,
  //         field: 'geoPosition',
  //       );
  //   log("Streams ${GeoFireAssistant.stream}");
  //   // Listen to the stream
  //   _streamSubscription =
  //       GeoFireAssistant.stream.listen((List<DocumentSnapshot> documentList) {
  //     Logger.error("Stream received data: ${documentList.length} documents");
  //
  //     if (documentList.isEmpty) {
  //       Logger.error("No documents found within the specified radius.");
  //       controller.updateDriversFound(false);
  //     } else {
  //       controller.updateDriversFound(true);
  //       log("Is Not Empty");
  //     }
  //
  //     GeoFireAssistant.nearestDrivers.clear();
  //
  //     for (var doc in documentList) {
  //       Logger.error("Processing document ID: ${doc.id}");
  //
  //       if (doc.data() != null) {
  //         Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  //
  //         if (data.containsKey('driversId') &&
  //             data.containsKey('geoPosition')) {
  //           // controller.updateDriversFound(true);
  //           // log("Is Not Empty");
  //           final GeoPoint position = data['geoPosition']['geopoint'];
  //           Logger.error('Lat ${position.latitude}');
  //           Logger.error('Lng ${position.longitude}');
  //           var result = CloseByDriverModel(
  //             driversId: data['driversId'].toString(),
  //             latitude: position.latitude,
  //             longitude: position.longitude,
  //           );
  //           Logger.error('LngR ${result.longitude}');
  //           Logger.error('LngR ${result.latitude}');
  //           GeoFireAssistant.nearestDrivers.add(result);
  //
  //           Logger.error(
  //               "Added driver: ${result.driversId}, at location: ${result.latitude}, ${result.longitude}");
  //           var con = Get.put(ConfirmPackageController());
  //           if (con.confirmPackageState.fetchedDriver.value == true) {
  //             for (var driver in GeoFireAssistant.nearestDrivers) {
  //               LatLng eachActiveDriverPosition =
  //                   LatLng(driver.latitude!, driver.longitude!);
  //
  //               LocationController.to.riderMaker.add(
  //                 Marker(
  //                   markerId: const MarkerId("Driver on Trip"),
  //                   position: eachActiveDriverPosition,
  //                   infoWindow: const InfoWindow(
  //                       title: "Active Driver", snippet: "Driver"),
  //                   icon: LocationController.to.carIcon!,
  //                   // BitmapDescriptor.defaultMarkerWithHue(
  //                   //     BitmapDescriptor.hueAzure),
  //                   rotation: 360,
  //                 ),
  //               );
  //
  //               Logger.error("Driver ID: ${driver.driversId}");
  //               Logger.error("Latitude: ${driver.latitude}");
  //               Logger.error("Longitude: ${driver.longitude}");
  //               Logger.error(
  //                 "Marker: ${LocationController.to.riderMaker}",
  //               );
  //             }
  //           }
  //         } else {
  //           Logger.error(
  //               "Document data is missing required fields: ${doc.data()}");
  //         }
  //       } else {
  //         Logger.error("Document data is null for document ID: ${doc.id}");
  //       }
  //     }
  //   }, onError: (error) {
  //     Logger.error("Stream error: $error");
  //   });
  // }

  static void getActiveDriver() async {
    // Cancel any existing subscription first to prevent memory leaks and duplicate listeners
    _streamSubscription?.cancel();
    
    // Set loading state
    _isLoading = true;
    controller.confirmPackageState.isSearchingDrivers.value = true; // Mark as searching
    controller.confirmPackageState.driversFound.value = false; // Reset while loading
    
    print("--------------------------------------------------");
    print("🚀 STARTING DRIVER SEARCH 🚀");
    
    if (LocationController.to.pickupLocation == null) {
      print("❌ ERROR: Pickup location is NULL!");
      _isLoading = false;
      controller.updateDriversFound(false);
      return;
    }
    
    print("📍 Pickup Location: ${LocationController.to.pickupLocation?.latitude}, ${LocationController.to.pickupLocation?.longitude}");
    print("--------------------------------------------------");

    GeoFlutterFire geo = GeoFlutterFire();

    GeoFirePoint center = geo.point(
      latitude: LocationController.to.pickupLocation!.latitude!,
      longitude: LocationController.to.pickupLocation!.longitude!,
    );

    // Query for all drivers - filter in memory to avoid index issues and debug clearly
    Query collection = fDataBase.collection('Drivers');
    
    log("🔍 Searching for ALL drivers within 50km radius (filtering in memory)...");

    log("🔍 Searching for drivers within 50km radius...");

    GeoFireAssistant.stream = geo.collection(collectionRef: collection).within(
          center: center,
          radius: 50,
          field: 'geoPosition',
        );

    _streamSubscription = GeoFireAssistant.stream
        .listen((List<DocumentSnapshot> documentList) async {
      log("📡 Stream callback started - processing ${documentList.length} documents");
      
      // Filter out documents with null data first
      final validDocs =
          documentList.where((doc) => doc.data() != null).toList();
      log("Stream received ${documentList.length} documents, ${validDocs.length} valid");

      if (validDocs.isEmpty) {
        log("❌ No valid driver documents found");
        _isLoading = false;
        controller.updateDriversFound(false);
        return;
      }

      GeoFireAssistant.nearestDrivers.clear();

      // Process ALL drivers in parallel using Future.wait to avoid sequential delays
      List<Future<CloseByDriverModel?>> driverChecks = [];
      
      for (var doc in validDocs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if (data.containsKey('driversId') && data.containsKey('geoPosition')) {
          String driverId = data['driversId'].toString();
          final GeoPoint position = data['geoPosition']['geopoint'];
          
          // Create async check for each driver
          driverChecks.add(_processDriver(driverId, position));
        }
      }
      
      // Wait for ALL driver checks to complete
      List<CloseByDriverModel?> results = await Future.wait(driverChecks);
      
      // Add all available drivers to the list
      for (var result in results) {
        if (result != null) {
          GeoFireAssistant.nearestDrivers.add(result);
        }
      }
      
      // Mark loading complete
      _isLoading = false;
      
      // Update UI with found drivers - this is the critical fix
      bool hasDrivers = GeoFireAssistant.nearestDrivers.isNotEmpty;
      log("✅ Driver search complete: found ${GeoFireAssistant.nearestDrivers.length} available drivers, driversFound=$hasDrivers");
      
      controller.updateDriversFound(hasDrivers);
      controller.update(); // Force GetX to refresh all listeners

      // Update map markers if needed
      if (controller.confirmPackageState.fetchedDriver.value) {
        _updateDriverMarkers();
      }
    }, onError: (error) {
      log("❌ Stream error: $error");
      _isLoading = false;
      controller.updateDriversFound(false);
    });
  }

  /// Helper method to process a single driver asynchronously
  /// Returns CloseByDriverModel if driver is available, null otherwise
  static Future<CloseByDriverModel?> _processDriver(String driverId, GeoPoint position) async {
    bool isAvailable = await checkDriverAvailability(driverId);
    
    if (isAvailable) {
      log("Driver $driverId: Available - added to list");
      return CloseByDriverModel(
        driversId: driverId,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } else {
      log("Driver $driverId: Busy - skipped");
      return null;
    }
  }

// Add this method to check driver availability
  static Future<bool> checkDriverAvailability(String driverId) async {
    try {
      // First check if driver is online and approved
      final driverDoc =
          await fDataBase.collection("Drivers").doc(driverId).get();

      if (!driverDoc.exists) {
        log("Driver $driverId not found in database");
        return false;
      }

      var driverData = driverDoc.data() as Map<String, dynamic>;
      
      log("🔍 Checking availability for Driver $driverId:");

      // Check approval status
      bool isApproved = driverData['isApproved'] ?? false;
      if (!isApproved) {
        log("❌ Driver $driverId rejected: isApproved is false/null");
        return false;
      }

      // Check online status - handle both new 'isOnline' and old 'isDriverOnline' fields
      bool isOnline = driverData['isOnline'] ?? false;
      bool isDriverOnline = driverData['isDriverOnline'] ?? false;
      
      log("   - isOnline: $isOnline");
      log("   - isDriverOnline: $isDriverOnline");
      log("   - isApproved: $isApproved");
      
      // Accept if either field is true
      if (!isOnline && !isDriverOnline) {
        log("❌ Driver $driverId rejected: Offline (both isOnline and isDriverOnline are false)");
        return false;
      }

      log("✅ Driver $driverId APPROVED for selection");
      return true; // Available if approved and (online OR driverOnline)
    } catch (e) {
      log("Error checking driver availability: $e");
      return false; // Assume unavailable if error
    }
  }

  static void _updateDriverMarkers() {
    Set<Marker> newMarkers = {};
    
    for (var driver in GeoFireAssistant.nearestDrivers) {
      LatLng eachActiveDriverPosition =
          LatLng(driver.latitude!, driver.longitude!);

      newMarkers.add(
        Marker(
          markerId: MarkerId("driver_${driver.driversId}"),
          position: eachActiveDriverPosition,
          infoWindow: InfoWindow(
              title: "Driver ${driver.driversId}", snippet: "Available Driver"),
          icon: LocationController.to.carIcon ?? BitmapDescriptor.defaultMarker,
          rotation: 360,
        ),
      );
    }
    
    // Batch update the observable set to trigger only ONE UI rebuild
    LocationController.to.riderMaker.assignAll(newMarkers);
    log("🚗 Updated ${newMarkers.length} driver markers on map");
  }

  static void disposeGetActiveDriver() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    Logger.error("Stream subscription cancelled.");
  }
}

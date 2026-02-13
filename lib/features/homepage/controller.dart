// // import 'dart:developer';
// //
// // import 'package:app_version_update/app_version_update.dart';
// // import 'package:get/get.dart';
// // import 'package:swiftrun/common/styles/style.dart';
// // import 'package:swiftrun/common/utils/utils.dart';
// // import 'package:swiftrun/features/auth/index.dart';
// // import 'package:swiftrun/features/homepage/state.dart';
// // import 'package:swiftrun/global/global.dart';
// //
// // class HomeController extends GetxController {
// //   var homeState = HomeState();
// //
// //   @override
// //   void onInit() {
// //     super.onInit();
// //     getRequests();
// //     AuthenticationController.onUserLogin();
// //   }
// //
// //   Future<void> getRequests({int? limit}) async {
// //     final currentUser = firebaseAuth.currentUser;
// //     try {
// //       if (currentUser == null) {
// //         homeState.requestData.clear();
// //         return;
// //       }
// //       homeState.isLoading.value = true;
// //
// //       homeState.requestSubscription = fDataBase
// //           .collection("DeliveryRequests")
// //           .where("userID", isEqualTo: currentUser.uid)
// //           .where("status", isNotEqualTo: "waiting")
// //           .limit(limit ?? 5)
// //           .orderBy("dateCreated", descending: true)
// //           .snapshots()
// //           .listen((event) {
// //         homeState.requestData.assignAll(event.docs);
// //         homeState.isLoading.value = false;
// //         Logger.i("Help ${homeState.requestData.toJson()}");
// //       }, onError: (error) {
// //         log("Error History $error");
// //         homeState.isLoading.value = false;
// //       });
// //     } catch (e) {
// //       log("Error Catch $e");
// //       homeState.isLoading.value = false;
// //     }
// //   }
// //
// //
// //
// //   Future<void> checkAppUpdate() async {
// //     Logger.error("Checking Update Here");
// //     await AppVersionUpdate.checkForUpdates(
// //             playStoreId: "com.vlogx", country: 'ng')
// //         .then((onValue) async {
// //       Logger.error("Checking Update");
// //       if (onValue.canUpdate!) {
// //         await AppVersionUpdate.showAlertUpdate(
// //           appVersionResult: onValue,
// //           backgroundColor: AppColor.disabledColor.withValues(alpha: 0.5),
// //           title: "New Update",
// //           content: 'Would you like to update your application?',
// //           updateButtonText: 'Update',
// //           cancelButtonText: 'Update Later',
// //         );
// //       }
// //     });
// //   }
// // }
//
//
// import 'dart:async';
// import 'dart:developer';
//
// import 'package:swiftrun/common/utils/app_update_checker.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';
// import 'package:swiftrun/common/styles/style.dart';
// import 'package:swiftrun/common/utils/utils.dart';
// import 'package:swiftrun/features/auth/index.dart';
// import 'package:swiftrun/features/homepage/state.dart';
// import 'package:swiftrun/features/rating/view.dart';
// import 'package:swiftrun/global/global.dart';
//
// class HomeController extends GetxController {
//   var homeState = HomeState();
//   StreamSubscription<QuerySnapshot>? _statusSubscription;
//   final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
//
//   @override
//   void onInit() {
//     super.onInit();
//     getRequests();
//     AuthenticationController.onUserLogin();
//
//     // Add new functionality
//     _initializeNotifications();
//     listenToDeliveryUpdates();
//     _checkAndRefreshToken();
//   }
//
//   Future<void> _initializeNotifications() async {
//     const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const iosSettings = DarwinInitializationSettings();
//     const initSettings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );
//
//     await _notificationsPlugin.initialize(initSettings);
//   }
//
//   // Future<void> getRequests({int? limit}) async {
//   //   final currentUser = firebaseAuth.currentUser;
//   //   try {
//   //     if (currentUser == null) {
//   //       homeState.requestData.clear();
//   //       return;
//   //     }
//   //     homeState.isLoading.value = true;
//   //
//   //     homeState.requestSubscription = fDataBase
//   //         .collection("DeliveryRequests")
//   //         .where("userID", isEqualTo: currentUser.uid)
//   //         .where("status", isNotEqualTo: "waiting")
//   //         .limit(limit ?? 5)
//   //         .orderBy("dateCreated", descending: true)
//   //         .snapshots()
//   //         .listen((event) {
//   //       homeState.requestData.assignAll(event.docs);
//   //       homeState.isLoading.value = false;
//   //       Logger.i("Help ${homeState.requestData.toJson()}");
//   //     }, onError: (error) {
//   //       log("Error History $error");
//   //       homeState.isLoading.value = false;
//   //     });
//   //   } catch (e) {
//   //     log("Error Catch $e");
//   //     homeState.isLoading.value = false;
//   //   }
//   // }
//
//   Future<void> getRequests({int? limit}) async {
//     final currentUser = firebaseAuth.currentUser;
//     try {
//       if (currentUser == null) {
//         homeState.requestData.clear();
//         return;
//       }
//       homeState.isLoading.value = true;
//
//       homeState.requestSubscription = fDataBase
//           .collection("DeliveryRequests")
//           .where("userID", isEqualTo: currentUser.uid)
//           .where("status", whereIn: ["accepted", "arrived", "onTrip", "ended"]) // Only show actual in-progress or completed
//           .orderBy("dateCreated", descending: true)
//           .limit(limit ?? 5)
//           .snapshots()
//           .listen((event) {
//         homeState.requestData.assignAll(event.docs);
//         homeState.isLoading.value = false;
//         Logger.i("History requests: ${event.docs.length}");
//       }, onError: (error) {
//         log("Error History $error");
//         homeState.isLoading.value = false;
//       });
//     } catch (e) {
//       log("Error Catch $e");
//       homeState.isLoading.value = false;
//     }
//   }
//
//
//   // Listen to delivery status changes in real-time
//   void listenToDeliveryUpdates() async {
//     final currentUser = firebaseAuth.currentUser;
//     if (currentUser == null) return;
//
//     try {
//       log("Starting delivery status listener for user: ${currentUser.uid}");
//
//       _statusSubscription = fDataBase
//           .collection("DeliveryRequests")
//           .where("userID", isEqualTo: currentUser.uid)
//           .where("status", whereIn: ["accepted", "arrived", "onTrip", "ended"])
//           .snapshots()
//           .listen((snapshot) {
//
//         log("Status listener triggered - ${snapshot.docChanges.length} changes");
//
//         for (var change in snapshot.docChanges) {
//           if (change.type == DocumentChangeType.modified) {
//             var data = change.doc.data() as Map<String, dynamic>;
//             String status = data['status'] ?? '';
//             String driverId = data['driverID'] ?? '';
//
//             log("Delivery status updated: $status for request: ${change.doc.id}");
//
//             // Handle status changes
//             switch (status) {
//               case 'accepted':
//                 _showStatusNotification("Request Accepted", "Your delivery has been accepted by a driver");
//                 break;
//               case 'arrived':
//                 _showStatusNotification("Driver Arrived", "Your driver has arrived at pickup location");
//                 break;
//               case 'onTrip':
//                 _showStatusNotification("Delivery Started", "Your package is being delivered");
//                 break;
//               case 'ended':
//                 _showStatusNotification("Delivery Completed", "Your package has been delivered");
//                 // Navigate to rating screen
//                 Future.delayed(Duration(seconds: 2), () {
//                   Get.to(() => const RatingScreen(), arguments: {"driverId": driverId});
//                 });
//                 break;
//             }
//           }
//         }
//       }, onError: (error) {
//         log("Error in delivery status listener: $error");
//       });
//     } catch (e) {
//       log("Error setting up delivery status listener: $e");
//     }
//   }
//
//   // Display local notifications for status updates
//   void _showStatusNotification(String title, String message) async {
//     try {
//       const notificationDetails = NotificationDetails(
//         android: AndroidNotificationDetails(
//           'delivery_status',
//           'Delivery Status Updates',
//           channelDescription: 'Notifications for delivery status changes',
//           importance: Importance.high,
//           priority: Priority.high,
//           showWhen: true,
//         ),
//         iOS: DarwinNotificationDetails(
//           presentAlert: true,
//           presentBadge: true,
//           presentSound: true,
//         ),
//       );
//
//       await _notificationsPlugin.show(
//         DateTime.now().millisecond,
//         title,
//         message,
//         notificationDetails,
//       );
//
//       log("Local notification shown: $title - $message");
//     } catch (e) {
//       log("Error showing notification: $e");
//     }
//   }
//
//   // Check and refresh FCM token if needed
//   Future<void> _checkAndRefreshToken() async {
//     try {
//       String? currentToken = await FirebaseMessaging.instance.getToken();
//       if (currentToken == null || currentToken.isEmpty) {
//         log("No FCM token found, requesting refresh");
//         await refreshFCMToken();
//       } else {
//         log("Current FCM token exists: ${currentToken.substring(0, 20)}...");
//       }
//     } catch (e) {
//       log("Error checking FCM token: $e");
//     }
//   }
//
//   // Refresh FCM token
//   Future<void> refreshFCMToken() async {
//     try {
//       final currentUser = firebaseAuth.currentUser;
//       if (currentUser == null) return;
//
//       log("Refreshing customer FCM token...");
//
//       // Delete old token
//       await FirebaseMessaging.instance.deleteToken();
//       await Future.delayed(Duration(seconds: 2));
//
//       // Get new token
//       String? newToken = await FirebaseMessaging.instance.getToken();
//
//       if (newToken != null) {
//         await fDataBase.collection("Customers").doc(currentUser.uid).update({
//           "userToken": newToken,
//           "tokenStatus": "active",
//           "lastTokenUpdate": FieldValue.serverTimestamp(),
//         });
//
//         log("Customer FCM token refreshed successfully");
//         successMethod("Notification settings updated");
//       }
//     } catch (e) {
//       log("Error refreshing customer FCM token: $e");
//     }
//   }
//
//   // Update current FCM token in user document
//   Future<void> updateFCMToken() async {
//     try {
//       final currentUser = firebaseAuth.currentUser;
//       if (currentUser == null) return;
//
//       String? token = await FirebaseMessaging.instance.getToken();
//
//       if (token != null) {
//         Map<String, dynamic> data = {
//           "userToken": token,
//           "tokenStatus": "active",
//           "lastTokenUpdate": FieldValue.serverTimestamp(),
//         };
//
//         await fDataBase.collection("Customers").doc(currentUser.uid).set(data, SetOptions(merge: true));
//
//         log("Customer token updated successfully: ${token.substring(0, 20)}...");
//       }
//     } catch (e) {
//       log("Error updating customer FCM token: $e");
//     }
//   }
//
//   // Debug method to check customer token
//   Future<void> debugCustomerToken() async {
//     try {
//       final currentUser = firebaseAuth.currentUser;
//       if (currentUser == null) {
//         log("No authenticated user");
//         return;
//       }
//
//       // Check current FCM token
//       String? fcmToken = await FirebaseMessaging.instance.getToken();
//       log("Current FCM Token: $fcmToken");
//
//       // Check customer document
//       final customerDoc = await fDataBase.collection("Customers").doc(currentUser.uid).get();
//       if (customerDoc.exists) {
//         final data = customerDoc.data() as Map<String, dynamic>;
//         log("Customer document token: ${data['userToken']}");
//         log("Token status: ${data['tokenStatus']}");
//       } else {
//         log("Customer document does not exist");
//       }
//
//       // Check recent delivery requests
//       final recentRequests = await fDataBase
//           .collection("DeliveryRequests")
//           .where("userID", isEqualTo: currentUser.uid)
//           .orderBy("dateCreated", descending: true)
//           .limit(1)
//           .get();
//
//       if (recentRequests.docs.isNotEmpty) {
//         final requestData = recentRequests.docs.first.data();
//         // final requestData = recentRequests.docs.first.data() as Map<String, dynamic>;
//         log("Recent request token: ${requestData['userToken']}");
//       }
//     } catch (e) {
//       log("Error in debug: $e");
//     }
//   }
//
//   Future<void> checkAppUpdate() async {
//     Logger.error("Checking Update Here");
//     await AppVersionUpdate.checkForUpdates(
//         playStoreId: "com.vlogx", country: 'ng')
//         .then((onValue) async {
//       Logger.error("Checking Update");
//       if (onValue.canUpdate!) {
//         await AppVersionUpdate.showAlertUpdate(
//           appVersionResult: onValue,
//           backgroundColor: AppColor.disabledColor.withValues(alpha: 0.5),
//           title: "New Update",
//           content: 'Would you like to update your application?',
//           updateButtonText: 'Update',
//           cancelButtonText: 'Update Later',
//         );
//       }
//     });
//   }
//
//   @override
//   void onClose() {
//     // Clean up subscriptions
//     homeState.requestSubscription?.cancel();
//     _statusSubscription?.cancel();
//     super.onClose();
//   }
// }

import 'dart:async';
import 'dart:developer';

import 'package:swiftrun/common/utils/app_update_checker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/utils/utils.dart';
import 'package:swiftrun/features/auth/index.dart';
import 'package:swiftrun/features/homepage/state.dart';
import 'package:swiftrun/features/rating/view.dart';
import 'package:swiftrun/global/global.dart';

class HomeController extends GetxController {
  var homeState = HomeState();
  StreamSubscription<QuerySnapshot>? _statusSubscription;
  StreamSubscription<QuerySnapshot>? _scheduleRequestSubscription;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Add notification deduplication
  final Set<String> _notifiedRequests = <String>{};
  final Map<String, String> _lastNotifiedStatus = <String, String>{};

  // Hold both instant and scheduled requests
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _instantRequests = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _scheduledRequests = [];

  // Track if both listeners have initialized to prevent race conditions
  bool _instantListenerInitialized = false;
  bool _scheduledListenerInitialized = false;

  @override
  void onInit() async {
    super.onInit();

    // Initialize auth and notifications BEFORE loading requests.
    // Previously, these were deferred via Future.microtask() which caused a race
    // condition: getRequests() would fire before auth was ready, find currentUser
    // as null, clear requestData, and never set up Firestore listeners.
    // After an app update this meant no recent activity until sign-out/sign-in.
    AuthenticationController.onUserLogin();
    _initializeNotifications();
    listenToDeliveryUpdates();
    _checkAndRefreshToken();
    checkAppUpdate();

    // Load requests AFTER auth is settled
    getRequests();
  }

  Future<void> _initializeNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
  }

  Future<void> getRequests({int? limit}) async {
    var currentUser = firebaseAuth.currentUser;

    // After an app update, Firebase Auth may not have restored the session yet.
    // Wait briefly for auth to settle before giving up.
    if (currentUser == null) {
      await Future.delayed(const Duration(seconds: 2));
      currentUser = firebaseAuth.currentUser;
    }

    try {
      if (currentUser == null) {
        homeState.requestData.clear();
        homeState.isLoading.value = false;
        return;
      }

      homeState.isLoading.value = true;

      // Reset initialization flags
      _instantListenerInitialized = false;
      _scheduledListenerInitialized = false;

      // Cancel existing subscriptions if any - with null check
      try {
        homeState.requestSubscription?.cancel();
        _scheduleRequestSubscription?.cancel();
      } catch (e) {
        if (kDebugMode) {
          log("Error cancelling existing subscriptions: $e");
        }
      }

      // Listen to instant delivery requests
      homeState.requestSubscription = fDataBase
          .collection("DeliveryRequests")
          .where("userID", isEqualTo: currentUser.uid)
          .orderBy("dateCreated", descending: true)
          .limit(limit ?? 10)
          .snapshots()
          .listen((event) {
        // Filter instant delivery requests - show ALL statuses including 'waiting'
        // This includes: waiting, accepted, arrived, onTrip, ended, cancelled, declined, etc.
        _instantRequests = event.docs.where((doc) {
          var data = doc.data();
          String status = data['status'] ?? '';
          // Show all statuses including 'waiting' (pending driver acceptance)
          return status.isNotEmpty;
        }).toList();

        // Mark as initialized
        _instantListenerInitialized = true;

        // Merge and update only if both listeners have initialized
        _mergeAndUpdateRequests(limit);
      }, onError: (error) {
        if (kDebugMode) {
          log("❌ Error loading instant deliveries: $error");
        }
        _instantListenerInitialized = true; // Mark as initialized even on error
        _mergeAndUpdateRequests(limit); // Still try to merge with what we have
        homeState.isLoading.value = false;
        Future.delayed(const Duration(seconds: 2), () {
          if (homeState.isLoading.value) {
            _retryGetRequests(limit);
          }
        });
      });

      // Listen to scheduled delivery requests
      _scheduleRequestSubscription = fDataBase
          .collection("ScheduleRequest")
          .where("userID", isEqualTo: currentUser.uid)
          .orderBy("dateCreated", descending: true)
          .limit(limit ?? 10)
          .snapshots()
          .listen((event) {
        // Filter scheduled requests - show ALL statuses (scheduled, accepted, arrived, onTrip, ended, cancelled, etc.)
        _scheduledRequests = event.docs.where((doc) {
          var data = doc.data();
          String status = data['status'] ?? '';
          // Show all scheduled deliveries with any status
          return status.isNotEmpty;
        }).toList();

        // Mark as initialized
        _scheduledListenerInitialized = true;

        // Merge and update only if both listeners have initialized
        _mergeAndUpdateRequests(limit);
      }, onError: (error) {
        if (kDebugMode) {
          log("❌ Error loading scheduled deliveries: $error");
        }
        _scheduledListenerInitialized =
            true; // Mark as initialized even on error
        _mergeAndUpdateRequests(limit); // Still try to merge with what we have
        homeState.isLoading.value = false;
      });
    } catch (e) {
      if (kDebugMode) {
        log("Error in getRequests: $e");
      }
      homeState.isLoading.value = false;

      // Retry after a delay if there's an error
      Future.delayed(const Duration(seconds: 3), () {
        _retryGetRequests(limit);
      });
    }
  }

  // Retry mechanism for failed requests
  void _retryGetRequests(int? limit, {int retryCount = 0}) {
    if (retryCount >= 3) {
      homeState.isLoading.value = false;
      return;
    }

    Future.delayed(Duration(seconds: 2 * (retryCount + 1)), () {
      if (homeState.isLoading.value) {
        try {
          getRequests(limit: limit);
        } catch (e) {
          _retryGetRequests(limit, retryCount: retryCount + 1);
        }
      }
    });
  }

  // Merge instant and scheduled requests and update the UI
  void _mergeAndUpdateRequests(int? limit) {
    // Only merge if both listeners have initialized (prevents race condition)
    if (!_instantListenerInitialized || !_scheduledListenerInitialized) {
      return;
    }

    // Combine both lists
    List<QueryDocumentSnapshot<Map<String, dynamic>>> allRequests = [
      ..._instantRequests,
      ..._scheduledRequests,
    ];

    // Sort by dateCreated (most recent first)
    allRequests.sort((a, b) {
      var aData = a.data();
      var bData = b.data();
      Timestamp aTime = aData['dateCreated'] ?? Timestamp.now();
      Timestamp bTime = bData['dateCreated'] ?? Timestamp.now();
      return bTime.compareTo(aTime); // Descending order
    });

    // Take only the limit we want
    var limitedRequests = allRequests.take(limit ?? 10).toList();

    // Update the UI
    homeState.requestData.assignAll(limitedRequests);
    homeState.isLoading.value = false;
  }

  // Alternative method using a simpler query approach
  Future<void> getRequestsAlternative({int? limit}) async {
    final currentUser = firebaseAuth.currentUser;
    try {
      if (currentUser == null) {
        homeState.requestData.clear();
        homeState.isLoading.value = false;
        return;
      }

      homeState.isLoading.value = true;

      // Cancel existing subscription
      homeState.requestSubscription?.cancel();

      // Use a simple query without complex where clauses
      homeState.requestSubscription = fDataBase
          .collection("DeliveryRequests")
          .where("userID", isEqualTo: currentUser.uid)
          .orderBy("dateCreated", descending: true)
          .snapshots()
          .listen((event) {
        // Filter and limit in memory
        var relevantDocs = event.docs
            .where((doc) {
              var data = doc.data();
              String status = data['status'] ?? '';

              // Include all statuses except waiting
              return status.isNotEmpty && status != 'waiting';
            })
            .take(limit ?? 10)
            .toList();

        homeState.requestData.assignAll(relevantDocs);
        homeState.isLoading.value = false;

        log("Alternative history loaded: ${relevantDocs.length} requests");
      }, onError: (error) {
        log("Error in alternative history query: $error");
        homeState.isLoading.value = false;
      });
    } catch (e) {
      log("Error in getRequestsAlternative: $e");
      homeState.isLoading.value = false;
    }
  }

  // Method to refresh history manually
  void refreshHistory() {
    log("Manually refreshing history");
    homeState.isLoading.value = true;
    homeState.requestSubscription?.cancel();

    // Small delay to ensure subscription is cancelled
    Future.delayed(const Duration(milliseconds: 500), () {
      getRequests();
    });
  }

  // Force refresh when request status changes
  void forceRefreshOnStatusChange() {
    log("Force refreshing due to status change");
    homeState.isLoading.value = true;

    // Cancel existing subscription
    homeState.requestSubscription?.cancel();

    // Immediate refresh
    getRequests();
  }

  // Clear notification history for a specific request
  void clearRequestNotifications(String requestId) {
    _notifiedRequests.removeWhere((key) => key.startsWith(requestId));
    _lastNotifiedStatus.remove(requestId);
    log("Cleared notification history for request: $requestId");
  }

  // Listen to delivery status changes in real-time
  void listenToDeliveryUpdates() async {
    final currentUser = firebaseAuth.currentUser;
    if (currentUser == null) return;

    try {
      log("Starting delivery status listener for user: ${currentUser.uid}");

      _statusSubscription?.cancel(); // Cancel existing subscription

      _statusSubscription = fDataBase
          .collection("DeliveryRequests")
          .where("userID", isEqualTo: currentUser.uid)
          .where("status", whereIn: ["accepted", "arrived", "onTrip", "ended"])
          .snapshots()
          .listen((snapshot) {
            log("Status listener triggered - ${snapshot.docChanges.length} changes");

            for (var change in snapshot.docChanges) {
              if (change.type == DocumentChangeType.modified) {
                var data = change.doc.data() as Map<String, dynamic>;
                String status = data['status'] ?? '';
                String driverId = data['driverID'] ?? '';
                String requestId = change.doc.id;

                log("Delivery status updated: $status for request: $requestId");

                // Check if we've already notified for this status change
                String notificationKey = "${requestId}_$status";
                if (_notifiedRequests.contains(notificationKey)) {
                  log("Already notified for $status on request $requestId, skipping");
                  continue;
                }

                // Check if this is a new status for this request
                String lastStatus = _lastNotifiedStatus[requestId] ?? '';
                if (lastStatus == status) {
                  log("Same status as last notification for $requestId, skipping");
                  continue;
                }

                // Additional check: Don't notify for the same status within 5 seconds
                String timeKey =
                    "${requestId}_${status}_${DateTime.now().millisecondsSinceEpoch ~/ 5000}";
                if (_notifiedRequests.contains(timeKey)) {
                  log("Recent notification for $status on request $requestId, skipping");
                  continue;
                }

                // Handle status changes
                switch (status) {
                  case 'accepted':
                    _showStatusNotification("Request Accepted",
                        "Your delivery has been accepted by a driver");
                    _notifiedRequests.add(notificationKey);
                    _notifiedRequests.add(timeKey);
                    _lastNotifiedStatus[requestId] = status;
                    break;
                  case 'arrived':
                    _showStatusNotification("Driver Arrived",
                        "Your driver has arrived at pickup location");
                    _notifiedRequests.add(notificationKey);
                    _notifiedRequests.add(timeKey);
                    _lastNotifiedStatus[requestId] = status;
                    break;
                  case 'onTrip':
                    _showStatusNotification(
                        "Delivery Started", "Your package is being delivered");
                    _notifiedRequests.add(notificationKey);
                    _notifiedRequests.add(timeKey);
                    _lastNotifiedStatus[requestId] = status;
                    break;
                  case 'ended':
                    _showStatusNotification("Delivery Completed",
                        "Your package has been delivered");
                    _notifiedRequests.add(notificationKey);
                    _notifiedRequests.add(timeKey);
                    _lastNotifiedStatus[requestId] = status;
                    // Navigate to rating screen
                    Future.delayed(const Duration(seconds: 2), () {
                      Get.to(() => const RatingScreen(), arguments: {
                        "driverId": driverId,
                        "tripId":
                            requestId, // ✅ Add trip ID - requestId is the document ID
                      });
                    });
                    break;
                }
              }
            }
          }, onError: (error) {
            if (kDebugMode) {
              log("Error in delivery status listener: $error");
            }
          });
    } catch (e) {
      if (kDebugMode) {
        log("Error setting up delivery status listener: $e");
      }
    }
  }

  // Clean up old notification records to prevent memory leaks
  void _cleanupOldNotifications() {
    // Keep only the last 50 notification records
    if (_notifiedRequests.length > 50) {
      var toRemove =
          _notifiedRequests.take(_notifiedRequests.length - 50).toList();
      for (var key in toRemove) {
        _notifiedRequests.remove(key);
      }
    }

    // Clean up old status records
    if (_lastNotifiedStatus.length > 50) {
      var keys = _lastNotifiedStatus.keys.toList();
      var toRemove = keys.take(keys.length - 50);
      for (var key in toRemove) {
        _lastNotifiedStatus.remove(key);
      }
    }
  }

  // Display local notifications for status updates
  void _showStatusNotification(String title, String message) async {
    try {
      const notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          'delivery_status',
          'Delivery Status Updates',
          channelDescription: 'Notifications for delivery status changes',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _notificationsPlugin.show(
        DateTime.now().millisecond,
        title,
        message,
        notificationDetails,
      );

      // Clean up old notifications periodically
      _cleanupOldNotifications();
    } catch (e) {
      if (kDebugMode) {
        log("Error showing notification: $e");
      }
    }
  }

  // Check and refresh FCM token if needed
  Future<void> _checkAndRefreshToken() async {
    try {
      String? currentToken = await FirebaseMessaging.instance.getToken();
      if (currentToken == null || currentToken.isEmpty) {
        await refreshFCMToken();
      }
    } catch (e) {
      if (kDebugMode) {
        log("Error checking FCM token: $e");
      }
    }
  }

  // Refresh FCM token
  Future<void> refreshFCMToken() async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) return;

      // Delete old token
      await FirebaseMessaging.instance.deleteToken();
      await Future.delayed(const Duration(seconds: 2));

      // Get new token
      String? newToken = await FirebaseMessaging.instance.getToken();

      if (newToken != null) {
        await fDataBase.collection("Customers").doc(currentUser.uid).update({
          "userToken": newToken,
          "tokenStatus": "active",
          "lastTokenUpdate": FieldValue.serverTimestamp(),
        });

        successMethod("Notification settings updated");
      }
    } catch (e) {
      if (kDebugMode) {
        log("Error refreshing customer FCM token: $e");
      }
    }
  }

  // Update current FCM token in user document
  Future<void> updateFCMToken() async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) return;

      String? token = await FirebaseMessaging.instance.getToken();

      if (token != null) {
        Map<String, dynamic> data = {
          "userToken": token,
          "tokenStatus": "active",
          "lastTokenUpdate": FieldValue.serverTimestamp(),
        };

        await fDataBase
            .collection("Customers")
            .doc(currentUser.uid)
            .set(data, SetOptions(merge: true));
      }
    } catch (e) {
      if (kDebugMode) {
        log("Error updating customer FCM token: $e");
      }
    }
  }

  // Debug method to check customer token
  Future<void> debugCustomerToken() async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        return;
      }

      // Check customer document
      final customerDoc =
          await fDataBase.collection("Customers").doc(currentUser.uid).get();
      if (customerDoc.exists) {
        final data = customerDoc.data() as Map<String, dynamic>;
        if (kDebugMode) {
          log("Customer document token: ${data['userToken']}");
          log("Token status: ${data['tokenStatus']}");
        }
      }

      // Check recent delivery requests
      final recentRequests = await fDataBase
          .collection("DeliveryRequests")
          .where("userID", isEqualTo: currentUser.uid)
          .orderBy("dateCreated", descending: true)
          .limit(1)
          .get();

      if (recentRequests.docs.isNotEmpty) {
        final requestData = recentRequests.docs.first.data();
        if (kDebugMode) {
          log("Recent request token: ${requestData['userToken']}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        log("Error in debug: $e");
      }
    }
  }

  Future<void> checkAppUpdate() async {
    // FIXED: Using AppUpdateChecker with in_app_update as requested
    AppUpdateChecker.checkForUpdate(Get.context!);
  }

  @override
  void onClose() {
    // Clean up subscriptions
    homeState.requestSubscription?.cancel();
    _scheduleRequestSubscription?.cancel();
    _statusSubscription?.cancel();
    super.onClose();
  }
}

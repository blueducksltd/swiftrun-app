// import 'package:flutter/cupertino.dart';

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
//import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:swiftrun/common/utils/logger.dart';

import 'package:swiftrun/common/utils/util.dart';
import 'package:swiftrun/core/model/driver_model.dart';
import 'package:swiftrun/features/rating/view.dart';
import 'package:swiftrun/global/global.dart';

class NotifyHelper {
  static final _messaging = FirebaseMessaging.instance;
  final notificationsPlugin = FlutterLocalNotificationsPlugin(); //
  static late Stream<List<DocumentSnapshot>> stream;
  initializeNotification() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        if (details.payload == 'chat_message' && details.payload != null) {
          // Extract driver ID from notification data if available
          // Note: payload might need to be JSON string with driverId
          log("Chat notification tapped");
        }
      },
    );

    // Request notification permissions explicitly
    await requestNotificationPermissions();

    //listenToStatusChnage();
    await initializeCloudMessaging();
  }

  // Request notification permissions explicitly
  Future<void> requestNotificationPermissions() async {
    try {
      // For Android 13+ (API level 33+), request notification permission
      if (defaultTargetPlatform == TargetPlatform.android) {
        final bool? result = await notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();

        if (result == true) {
          Logger.i("✅ Android notification permission granted");
        } else {
          Logger.i("❌ Android notification permission denied");
        }
      }

      // For iOS, permissions are handled by DarwinInitializationSettings
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final bool? result = await notificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );

        if (result == true) {
          Logger.i("✅ iOS notification permission granted");
        } else {
          Logger.i("❌ iOS notification permission denied");
        }
      }
    } catch (e) {
      Logger.error("Error requesting notification permissions: $e");
    }
  }

  // Check if notifications are enabled and show dialog if not
  Future<bool> checkNotificationPermissions() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final bool? areNotificationsEnabled = await notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.areNotificationsEnabled();

        if (areNotificationsEnabled == false) {
          Logger.i("📱 Notifications are disabled on Android");
          return false;
        }
        return true;
      }

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        // For iOS, we can't directly check if notifications are enabled
        // The permission request will handle this
        return true;
      }

      return true;
    } catch (e) {
      Logger.error("Error checking notification permissions: $e");
      return false;
    }
  }

  Future initializeCloudMessaging() async {
    //Terminated

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        Logger.i('${remoteMessage.data}');
        _handleNotification(remoteMessage.data);
        debugPrint(
            "Notification Request On Terminated:: ${remoteMessage.data["rideRequestId"] ?? remoteMessage.data["type"]}");
      }
    });

    NotificationDetails notificationDetails = const NotificationDetails(
      android: AndroidNotificationDetails(
        'Default',
        'Basic Notification',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      ),
      iOS: DarwinNotificationDetails(),
    );

    Future<void> displayNotification({
      required String title,
      required String body,
      String? payload,
    }) async {
      return notificationsPlugin.show(
        int.parse(Util.uniqueRefenece()),
        title,
        body,
        notificationDetails,
      );
    }

    // Foreground

    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      if (remoteMessage!.notification != null) {
        // Check if it's a chat message notification
        String? notificationType = remoteMessage.data['type'];
        String? payload = notificationType == 'chat_message' 
            ? 'chat_message' 
            : null;
            
        displayNotification(
          title: remoteMessage.notification!.title!,
          body: remoteMessage.notification!.body!,
          payload: payload,
        );
      }
      Logger.i('${remoteMessage.data}');
      
      // Handle notification data (for chat messages, this will navigate to chat)
      if (remoteMessage.data['type'] == 'chat_message') {
        _handleNotification(remoteMessage.data);
      }

      debugPrint(
          "Notification Request On Foreground:: ${remoteMessage.data["rideRequestId"] ?? remoteMessage.data["type"]}");
    });

    // Background
    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage? remoteMessage) {
        if (remoteMessage!.notification != null) {
          String? notificationType = remoteMessage.data['type'];
          String? payload = notificationType == 'chat_message' 
              ? 'chat_message' 
              : null;
          displayNotification(
            title: remoteMessage.notification!.title!,
            body: remoteMessage.notification!.body!,
            payload: payload,
          );
        }
        Logger.i(
            '${remoteMessage.data['status']}, ${remoteMessage.data['driverId']}, Type: ${remoteMessage.data['type']}');
        _handleNotification(remoteMessage.data);
        debugPrint(
            "Notification Request On Background:: ${remoteMessage.data["rideRequestId"] ?? remoteMessage.data["type"]}");
      },
    );
  }

  // Future getDeviceToken({int maxRetires = 3}) async {
  //   try {
  //     String? registrationToken;
  //
  //     User? currentUser = firebaseAuth.currentUser;
  //     if (currentUser == null) throw Exception("User not logged in");
  //     List<String> collectionName = ["Customers", "DeliveryRequests"];
  //
  //     registrationToken = await _messaging.getToken();
  //
  //     debugPrint("FCM token $registrationToken");
  //
  //     Map<String, dynamic> data = {
  //       "userToken": registrationToken,
  //     };
  //
  //     String userID = currentUser.uid;
  //
  //     for (var collection in collectionName) {
  //       CollectionReference collectionRef =
  //           FirebaseFirestore.instance.collection(collection);
  //       QuerySnapshot querySnapshot =
  //           await collectionRef.where('userID', isEqualTo: userID).get();
  //
  //       if (querySnapshot.docs.isNotEmpty) {
  //         for (var doc in querySnapshot.docs) {
  //           await collectionRef.doc(doc.id).update(data);
  //           Logger.i(
  //               "User token updated successfully in $collection for userID: $userID with token: $registrationToken");
  //         }
  //       } else {
  //         Logger.i(
  //             "No document found in $collection with userID: $userID. Skipping update.");
  //       }
  //     }
  //
  //     return registrationToken;
  //   } catch (e) {
  //     Logger.error("failed to get device token");
  //     if (maxRetires > 0) {
  //       await Future.delayed(const Duration(seconds: 10));
  //       return getDeviceToken(maxRetires: -1);
  //     }
  //   }
  // }

  Future getDeviceToken({int maxRetires = 3}) async {
    try {
      User? currentUser = firebaseAuth.currentUser;
      if (currentUser == null) throw Exception("User not logged in");

      String? registrationToken = await _messaging.getToken();
      debugPrint("FCM token: $registrationToken");

      if (registrationToken != null) {
        // Only update the user document, not delivery requests
        Map<String, dynamic> data = {
          "userToken": registrationToken,
          "tokenStatus": "active",
          "lastTokenUpdate": FieldValue.serverTimestamp(),
        };

        await fDataBase.collection("Customers").doc(currentUser.uid).set(data, SetOptions(merge: true));

        Logger.i("Customer token updated successfully: $registrationToken");
        return registrationToken;
      }
    } catch (e) {
      Logger.error("Failed to get device token: $e");
      if (maxRetires > 0) {
        await Future.delayed(const Duration(seconds: 10));
        return getDeviceToken(maxRetires: maxRetires - 1);
      }
    }
    return null;
  }

// Add token refresh method
  Future<void> refreshFCMToken() async {
    try {
      User? currentUser = firebaseAuth.currentUser;
      if (currentUser == null) return;

      debugPrint("Refreshing customer FCM token...");

      await _messaging.deleteToken();
      await Future.delayed(const Duration(seconds: 2));

      String? newToken = await _messaging.getToken();

      if (newToken != null) {
        await fDataBase.collection("Customers").doc(currentUser.uid).update({
          "userToken": newToken,
          "tokenStatus": "active",
          "lastTokenUpdate": FieldValue.serverTimestamp(),
        });

        debugPrint("Customer FCM token refreshed: $newToken");
      }
    } catch (e) {
      debugPrint("Error refreshing customer FCM token: $e");
    }
  }

  static void _handleNotification(Map<String, dynamic> data) {
    String type = data['type'] ?? '';
    String status = data['status'] ?? '';

    Logger.i("Notification - Type: $type, Status: $status, Data: $data");

    // Handle chat message notifications
    if (type == 'chat_message') {
      String driverId = data['driverId'] ?? '';
      String driverName = data['driverName'] ?? 'Driver';
      String chatId = data['chatId'] ?? '';
      
      log("💬 Chat Notification - Navigating to chat screen:");
      log("  - Driver ID: $driverId");
      log("  - Driver Name: $driverName");
      log("  - Chat ID: $chatId");
      
      // Fetch driver info from Firestore
      _navigateToChat(driverId);
      return;
    }

    // Handle delivery status notifications (existing logic)
    Map<String, String> arguments = {
      "driverId": data['driverId'] ?? '',
      "tripId": data['requestId'] ?? data['tripId'] ?? '',  // ✅ Add trip ID from notification payload
    };

    // Check if the status is "ended" or "completed"
    if (status == 'ended' || status == 'completed') {
      log("🔍 Push Notification - Navigating to rating screen:");
      log("  - Driver ID: ${arguments['driverId']}");
      log("  - Trip ID: ${arguments['tripId']}");
      Get.to(() => const RatingScreen(), arguments: arguments);
    }
  }

  /// Navigate to chat screen with driver info
  static Future<void> _navigateToChat(String driverId) async {
    try {
      // Fetch driver info from Firestore
      final driverDoc = await fDataBase
          .collection('Drivers')
          .doc(driverId)
          .get();

      if (!driverDoc.exists) {
        Logger.error("Driver document not found: $driverId");
        return;
      }

      final driverData = driverDoc.data();
      if (driverData == null) {
        Logger.error("Driver data is null for: $driverId");
        return;
      }

      // Parse driver model using fromJson
      final driverInfo = DriverModel.fromJson(driverData);
      driverInfo.driversId = driverId; // Ensure driverId is set
      
      // Navigate to chat screen
      Map data = {"driverInfo": driverInfo};
      Get.toNamed('/chat', arguments: data);
      
      Logger.i("✅ Navigated to chat screen with driver: ${driverInfo.firstName} ${driverInfo.lastName}");
    } catch (e, stackTrace) {
      Logger.error("❌ Error navigating to chat: $e", stackTrace: stackTrace);
    }
  }

  Future onDidReceiveLocalNotification(
      int? id, String? title, String? body, String? payload) async {}

  Future selectNotification(String? payload) async {
    if (payload != null) {
      if (kDebugMode) {
        print('notification payload: $payload');
      }
    } else {
      if (kDebugMode) {
        print("Notification Done");
      }
    }
    if (payload == "Notify") {
    } else {}
  }
}

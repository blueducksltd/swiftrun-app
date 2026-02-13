// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:get/get.dart';
// import 'package:swiftrun/core/controller/notification.dart';
// import 'package:swiftrun/core/controller/session_controller.dart';
// import 'package:swiftrun/firebase_options.dart';
// import 'package:swiftrun/services/shared/sessions.dart';
//
// class Global {
//   static Future init() async {
//     WidgetsFlutterBinding.ensureInitialized();
//     await dotenv.load(fileName: '.env');
//     await Firebase.initializeApp(
//         options: DefaultFirebaseOptions.currentPlatform);
//     await Get.putAsync<SessionManager>(() => SessionManager().init());
//
//     Get.put<SessionController>(SessionController());
//     // await FareCalculator.initializeFareMultipliers();
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//     await NotifyHelper().initializeNotification();
//   }
// }
//
// NotifyHelper notifyHelper = NotifyHelper();
// FirebaseAuth firebaseAuth = FirebaseAuth.instance;
// FirebaseFirestore fDataBase = FirebaseFirestore.instance;
// User? currentUser = firebaseAuth.currentUser;
// Map<int, dynamic> fetchedfareMultipliers = {};
// Map<String, double> vehicleMultipliers = {};
// double addOnFee = 0;
// double pricePerKM = 0;
//
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   // log('Handling a background message: ${message.messageId}');
// }
// // final navigatorKey = GlobalKey();


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:swiftrun/core/controller/notification.dart';
import 'package:swiftrun/core/controller/session_controller.dart';
import 'package:swiftrun/firebase_options.dart';
import 'package:swiftrun/services/shared/sessions.dart';

class Global {
  static Future init() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Load .env file (fast - no await needed, runs in parallel)
    dotenv.load(fileName: '.env');

    // Initialize session manager (required for cached user data)
    await Get.putAsync<SessionManager>(() => SessionManager().init());

    // Initialize session controller (loads cached user data - fast)
    // Initialize session controller and await profile loading
    final sessionController = Get.put(SessionController());
    await sessionController.loadUserInfo();
    
    // Set up background message handler (doesn't block)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Defer notification initialization to after UI shows (not critical for startup)
    Future.microtask(() async {
      await NotifyHelper().initializeNotification();
    });
  }
}

NotifyHelper notifyHelper = NotifyHelper();
FirebaseAuth firebaseAuth = FirebaseAuth.instance;
FirebaseFirestore fDataBase = FirebaseFirestore.instance;
User? get currentUser => firebaseAuth.currentUser;
Map<int, dynamic> fetchedfareMultipliers = {};
Map<String, double> vehicleMultipliers = {};
double addOnFee = 0;
double pricePerKM = 0;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Only initialize if not already initialized
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }
  // log('Handling a background message: ${message.messageId}');
}
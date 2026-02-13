import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:swiftrun/common/utils/utils.dart';
import 'package:swiftrun/features/auth/data/model/user_model.dart';
import 'package:swiftrun/global/global.dart';
import 'package:swiftrun/services/shared/sessions.dart';
import 'package:swiftrun/core/controller/notification.dart';
import 'package:swiftrun/services/firebase_session_service.dart';

class SessionController extends GetxController {
  static SessionController get to => Get.find();

  final _isLogin = false.obs;
  final _userData = UserModel().obs;

  bool get isLogin => _isLogin.value;
  UserModel get userData => _userData.value;

  @override
  Future<void> onInit() async {
    await loadUserInfo();
    super.onInit();
  }

  saveProfileData(UserModel profileInfo) {
    _isLogin.value = true;
    SessionManager.to
        .setString("UserProfile", jsonEncode(profileInfo.toJson()));
    _userData(profileInfo);
    
    // Start Firebase session tracking for admin monitoring
    FirebaseSessionService().startSession();
  }

  saveDataLocally(User info) async {
    await fDataBase
        .collection("Customers")
        .doc(info.uid)
        .get()
        .then((value) async {
      log(value.data().toString());
      UserModel userData =
          UserModel.fromJson(value.data() as Map<String, dynamic>);
      saveProfileData(userData);
    }).onError((error, stackTrace) {
      errorMethod("An Error Occured");
      Logger.error(error, stackTrace: stackTrace);
    });
  }

  Future<UserModel?> getUserData() async {
    final String jsonString = SessionManager.to.getString("UserProfile");
    try {
      if (jsonString.isEmpty) {
        log("No saved user data found.");
        return null;
      }

      final Map<String, dynamic> userDataMap = jsonDecode(jsonString);
      return UserModel.fromJson(userDataMap);
    } on FormatException catch (error) {
      log("Error decoding saved profile data: $error\nData: $jsonString");
      return null;
    } catch (e) {
      log("Unexpected error retrieving saved data $e");
      return null;
    }
  }

  Future<void> updatedProfilePic(String updatedProfilePic) async {
    final String userData = SessionManager.to.getString("UserProfile");

    final Map<String, dynamic> jsonData = jsonDecode(userData);
    final UserModel userInfo = UserModel.fromJson(jsonData);

    userInfo.profilePix = updatedProfilePic;

    await SessionManager.to
        .setString("UserProfile", jsonEncode(userInfo.toJson()));
    _userData.value = userInfo; // Update the reactive variable
    Logger.i(userInfo.toJson());
  }

  Future<void> refreshUserData() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user != null) {
        await fDataBase
            .collection("Customers")
            .doc(user.uid)
            .get()
            .then((value) async {
          if (value.exists) {
            UserModel userData = UserModel.fromJson(value.data() as Map<String, dynamic>);
            saveProfileData(userData);
            log('User data refreshed successfully');
          }
        }).onError((error, stackTrace) {
          log('Error refreshing user data: $error');
        });
      }
    } catch (e) {
      log('Error refreshing user data: $e');
    }
  }

  loadUserInfo() async {
    UserModel? savedData = await getUserData();
    if (savedData != null) {
      _isLogin.value = true;
      log("Loaded UI from cache: ${savedData.toJson()}");
      _userData.value = savedData;
      
      // CRITICAL: Refresh user data from Firestore in background
      // This ensures that trips/payments missing from cache after an update
      // are pulled down immediately on cold start.
      refreshUserData();
    }
  }

  getString(String key) => SessionManager.to.getString(key);

  bool getLoginStatus() {
    return SessionManager.to.getBool("isLoggedIn");
  }

  void signOut() async {
    // End Firebase session tracking
    await FirebaseSessionService().endSession();
    
    firebaseAuth.signOut();
    _isLogin.value = false;
    // _userData.close();
    SessionManager.to.removeAll();

    Get.offNamed("/sign_in");
  }

  /// Clears local session without navigation (used for account deletion)
  void signOutWithoutNavigation() async {
    // End Firebase session tracking
    await FirebaseSessionService().endSession();
    
    _isLogin.value = false;
    _userData.value = UserModel();
    SessionManager.to.removeAll();
  }
  
  // Check and request notification permissions
  Future<void> checkNotificationPermissions() async {
    try {
      final notifyHelper = NotifyHelper();
      bool hasPermission = await notifyHelper.checkNotificationPermissions();
      
      if (!hasPermission) {
        log("📱 Notification permissions not granted, requesting...");
        await notifyHelper.requestNotificationPermissions();
      } else {
        log("✅ Notification permissions already granted");
      }
    } catch (e) {
      log("Error checking notification permissions: $e");
    }
  }
}

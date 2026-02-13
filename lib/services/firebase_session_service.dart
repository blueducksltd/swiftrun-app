import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:swiftrun/global/global.dart';

/// Service to track user sessions in Firebase for admin monitoring
class FirebaseSessionService {
  static final FirebaseSessionService _instance = FirebaseSessionService._internal();
  factory FirebaseSessionService() => _instance;
  FirebaseSessionService._internal();

  Timer? _heartbeatTimer;
  String? _currentSessionId;
  bool _isInitialized = false;

  /// Initialize session tracking when user logs in
  Future<void> startSession({String? fcmToken}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        log('❌ Cannot start session: No authenticated user');
        return;
      }

      // Generate unique session ID
      _currentSessionId = '${user.uid}_${DateTime.now().millisecondsSinceEpoch}';

      // Get device info
      final deviceInfo = await _getDeviceInfo();
      final packageInfo = await PackageInfo.fromPlatform();

      // Create session document
      final sessionData = {
        'userId': user.uid,
        'userType': 'customer',
        'userName': user.displayName ?? '',
        'userEmail': user.email ?? '',
        'deviceInfo': deviceInfo['model'] ?? 'Unknown',
        'platform': Platform.isIOS ? 'ios' : 'android',
        'osVersion': deviceInfo['osVersion'] ?? '',
        'appVersion': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
        'loginTime': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
        'fcmToken': fcmToken ?? '',
        'isActive': true,
      };

      await fDataBase
          .collection('UserSessions')
          .doc(_currentSessionId)
          .set(sessionData);

      log('✅ Session started: $_currentSessionId');
      _isInitialized = true;

      // Start heartbeat to update lastActive periodically
      _startHeartbeat();
    } catch (e) {
      log('❌ Error starting session: $e');
    }
  }

  /// Update FCM token in current session
  Future<void> updateFcmToken(String token) async {
    if (_currentSessionId == null) return;

    try {
      await fDataBase
          .collection('UserSessions')
          .doc(_currentSessionId)
          .update({
        'fcmToken': token,
        'lastActive': FieldValue.serverTimestamp(),
      });
      log('✅ FCM token updated in session');
    } catch (e) {
      log('❌ Error updating FCM token: $e');
    }
  }

  /// Update lastActive timestamp periodically
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    
    // Update every 5 minutes
    _heartbeatTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      await _updateLastActive();
    });
  }

  Future<void> _updateLastActive() async {
    if (_currentSessionId == null || !_isInitialized) return;

    try {
      await fDataBase
          .collection('UserSessions')
          .doc(_currentSessionId)
          .update({
        'lastActive': FieldValue.serverTimestamp(),
      });
      log('💓 Session heartbeat: $_currentSessionId');
    } catch (e) {
      log('❌ Error updating session heartbeat: $e');
    }
  }

  /// End session when user logs out
  Future<void> endSession() async {
    _heartbeatTimer?.cancel();

    if (_currentSessionId == null) return;

    try {
      // Delete the session document
      await fDataBase
          .collection('UserSessions')
          .doc(_currentSessionId)
          .delete();

      log('✅ Session ended: $_currentSessionId');
      _currentSessionId = null;
      _isInitialized = false;
    } catch (e) {
      log('❌ Error ending session: $e');
    }
  }

  /// Check if this session was terminated by admin
  Future<bool> isSessionValid() async {
    if (_currentSessionId == null) return false;

    try {
      final doc = await fDataBase
          .collection('UserSessions')
          .doc(_currentSessionId)
          .get();

      return doc.exists && (doc.data()?['isActive'] ?? false);
    } catch (e) {
      log('❌ Error checking session validity: $e');
      return true; // Assume valid on error to not disrupt user
    }
  }

  /// Get device information
  Future<Map<String, String>> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return {
          'model': '${androidInfo.brand} ${androidInfo.model}',
          'osVersion': 'Android ${androidInfo.version.release}',
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return {
          'model': iosInfo.model,
          'osVersion': '${iosInfo.systemName} ${iosInfo.systemVersion}',
        };
      }
    } catch (e) {
      log('Error getting device info: $e');
    }
    
    return {'model': 'Unknown', 'osVersion': 'Unknown'};
  }

  /// Clean up on app dispose
  void dispose() {
    _heartbeatTimer?.cancel();
  }
}

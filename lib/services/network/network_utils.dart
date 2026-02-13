import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:swiftrun/common/utils/extension.dart';
import 'package:swiftrun/common/utils/logger.dart';

class NetworkUtils {
  static Map<String, String>? headers({String? token}) {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Future<bool> hasNetwork() async {
    const noInternetErrorMessage = 'No Internet Connection';

    try {
      final connectivityResult = await Connectivity().checkConnectivity();

      // bool isOffline = connectivityResult == ConnectivityResult.none;
      // ignore: unrelated_type_equality_checks
      if (connectivityResult == ConnectivityResult.none) {
        errorMethod('noInternetErrorMessage');
        return false;
      }
      return true;
    } on SocketException catch (e) {
      Logger.error('SocketException: $e');
      errorMethod('noInternetErrorMessage');
      return false;
    } catch (e) {
      // Handle other potential errors

      Logger.error('Unexpected error: $e');

      errorMethod(noInternetErrorMessage);
      return false;
    }
  }
}

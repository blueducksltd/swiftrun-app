import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:swiftrun/common/utils/toast.dart';

class NetworkErrors {
  static handleNetworkErrors(http.Response response) {
    final result = json.decode(response.body);
    if (response.statusCode == 404) {
      Toasts.showToast(Colors.red,
          result['message'] ?? 'Account not found, please create an account');
    } else if (response.statusCode == 400) {
      Toasts.showToast(
          Colors.red, result['message'] ?? 'Please provide all fields');
    } else if (response.statusCode == 401) {
      Toasts.showToast(Colors.red, result['message'] ?? 'Unauthenticated');
    } else if (response.statusCode == 310) {
      Toasts.showToast(Colors.green, result['message'] ?? 'Email not verified');
    } else if (response.statusCode == 500) {
      Toasts.showToast(Colors.red, result['message'] ?? 'Something went wrong');
    } else {
      Toasts.showToast(Colors.red, 'Something happened, try again');
    }
  }
}

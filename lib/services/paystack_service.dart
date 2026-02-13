import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:swiftrun/common/utils/api_keys.dart';
import 'package:swiftrun/core/model/api_respons.dart';
import 'package:swiftrun/core/model/paystack/payment_auth.dart';
import 'package:swiftrun/core/model/paystack/transcation.dart';
import 'package:swiftrun/services/location/location_service.dart';
import 'package:swiftrun/services/network/network.dart';
import 'package:swiftrun/services/network/network_utils.dart';

class PaystackService {
  Future<PaymentAuthorization> initTransaction({
    required String email,
    required double amount,
    String currency = "NGN",
    required String reference,
    String? callbackUrl,
    List<String> channels = const [
      "card",
      "bank",
      "ussd",
      "mobile_money",
      "bank_transfer"
    ],
    Object? metadata,
  }) async {
    ApiResponse apiResponse;
    try {
      apiResponse = await Network.post(
        uri: ApisAddress.initializeTransaction,
        data: jsonEncode({
          "email": email,
          "amount": amount,
          "reference": reference,
          "currency": currency,
          "callback_url": callbackUrl,
          "metadata": metadata,
          "channels": channels,
        }),
      );

      if (apiResponse.statusCode == 200) {
        return PaymentAuthorization.fromJson(
            apiResponse.data as Map<String, dynamic>);
      } else {
        throw Exception(apiResponse.error.toString());
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
      throw Exception("Error: $e");
    }
  }

  /// Returns a user-friendly error message based on gateway response
  String _getFriendlyErrorMessage(String? gatewayResponse, String? status) {
    if (gatewayResponse != null) {
      final response = gatewayResponse.toLowerCase();
      if (response.contains('declined')) {
        return 'Your payment was declined. Please try a different payment method.';
      } else if (response.contains('insufficient')) {
        return 'Insufficient funds. Please try a different card or payment method.';
      } else if (response.contains('expired')) {
        return 'Your card has expired. Please use a different card.';
      } else if (response.contains('invalid')) {
        return 'Invalid card details. Please check and try again.';
      } else if (response.contains('not completed')) {
        return 'Payment was not completed. Please try again.';
      } else if (response.contains('failed')) {
        return 'Payment failed. Please try again or use a different payment method.';
      }
    }
    return 'Payment could not be processed. Please try again.';
  }

  Future verifyTransaction(
    String reference,
    Function(Object) onSuccessfulTransaction,
    Function(Object) onFailedTransaction, {
    Function()? onCancelledTransaction,
  }) async {
    try {
      final url = Uri.parse(ApisAddress.verifyTransaction(reference));
      final response = await http.get(
        url,
        headers: NetworkUtils.headers(token: paystackSecret),
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw TimeoutException("Connection Timed Out"),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final transactionData = data['data'] as Map<String, dynamic>;
        final status = transactionData['status'] as String?;
        final gatewayResponse = transactionData['gateway_response'] as String?;
        
        // Check for successful transaction
        if (gatewayResponse == "Successful" || gatewayResponse == "Approved") {
          onSuccessfulTransaction(transactionData);
        } 
        // Check for abandoned/cancelled/pending transactions - don't treat as error
        else if (status == "abandoned" || status == "pending") {
          // User cancelled or didn't complete - silently handle
          debugPrint('Payment $status - not showing error to user');
          onCancelledTransaction?.call();
        }
        // Actual failed transaction - show friendly message
        else {
          final friendlyMessage = _getFriendlyErrorMessage(gatewayResponse, status);
          onFailedTransaction(friendlyMessage);
        }
      } else {
        onFailedTransaction('Unable to verify payment. Please try again.');
      }
    } on TimeoutException {
      onFailedTransaction('Connection timed out. Please check your internet and try again.');
    } on HttpException catch (e) {
      onFailedTransaction('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Payment verification error: $e');
      onFailedTransaction('An error occurred. Please try again.');
    }
  }

  // Get lists of transactions
  Future<List<Transaction>> listTransactions() async {
    ApiResponse response;
    try {
      response = await Network.get(url: ApisAddress.transactionList);
      if (response.statusCode == 200) {
        final data = response.data as List;
        if (data.isEmpty) return [];
        return data
            .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }
}

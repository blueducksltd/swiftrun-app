import 'package:flutter/material.dart';
import 'package:swiftrun/common/styles/colors.dart';
import 'package:swiftrun/features/paystack/payment_screen.dart';

class Payment {
  void makePayment({
    required BuildContext context,
    required double amount,
    required String secretKey,
    required String userEmail,
    Map<String, dynamic>? metadata, // Add metadata parameter
    Function()? onSuccess,
  }) {
    // Generate a unique reference for the transaction
    final String reference = 'TR-${DateTime.now().millisecondsSinceEpoch}';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PayStackPaymentScreen(
          reference: reference,
          currency: 'NGN',
          email: userEmail,
          amount: amount,
          metadata: metadata,
          onCompletedTransaction: (response) {
            // Screen pops itself automatically after verification.
            // We just trigger the success callback to update the UI (show "Paid").
            onSuccess?.call();
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Payment verification successful'),
                backgroundColor: AppColor.primaryColor,
              ),
            );
          },
          onFailedTransaction: (error) {
            // Extract message from error object or use as-is if string
            String errorMessage;
            if (error is String) {
              errorMessage = error;
            } else if (error is Map) {
              errorMessage = error['message']?.toString() ?? 'Payment failed. Please try again.';
            } else {
              errorMessage = 'Payment failed. Please try again.';
            }
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: AppColor.errorColor,
              ),
            );
          },
        ),
      ),
    );
  }
}

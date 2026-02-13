import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:swiftrun/common/utils/utils.dart';
import 'package:swiftrun/global/global.dart';

class ProfileController extends GetxController {
  Future<List> getFaq() async {
    try {
      CollectionReference collectionReference = fDataBase.collection('FAQs');
      QuerySnapshot querySnapshot = await collectionReference.get();

      final faqData = querySnapshot.docs.map((value) {
        final data = value.data() as Map<String, dynamic>;

        log(data.toString());
        return data;
      }).toList();
      Logger.i(faqData);
      return faqData;
    } catch (e, stackTrack) {
      Logger.error("Error: $e", stackTrace: stackTrack);
      errorMethod('An error occured');
      return [];
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> fetchPaymentHistory() async {
    try {
      log("Fetching payment history for user: ${currentUser?.uid}");

      if (currentUser == null) {
        log("Current user is null, cannot fetch payment history");
        return {};
      }

      // Fetch all user deliveries and filter for payments in code to avoid compound query index issues
      QuerySnapshot allUserDeliveries = await fDataBase
          .collection('DeliveryRequests')
          .where("userID", isEqualTo: currentUser!.uid)
          .orderBy('dateCreated', descending: true)
          .get();

      // Debug: Log a few sample documents to see their structure
      for (int i = 0; i < allUserDeliveries.docs.length && i < 3; i++) {
        var doc = allUserDeliveries.docs[i];
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        log("Sample doc ${doc.id}: paymentStatus=${data['paymentStatus']}, paymentVerified=${data['paymentVerified']}, status=${data['status']}");
      }

      // Filter for deliveries where payment was confirmed
      List<QueryDocumentSnapshot> allPayments = allUserDeliveries.docs.where((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        bool paymentStatus = data['paymentStatus'] == true;
        bool paymentVerified = data['paymentVerified'] == true;
        return paymentStatus || paymentVerified;
      }).toList();

      log("Total user deliveries: ${allUserDeliveries.docs.length}");
      log("Filtered payments: ${allPayments.length}");

      // Group the payments by month and year
      Map<String, List<Map<String, dynamic>>> groupedPayments = {};

      for (var payment in allPayments) {
        var date = (payment['dateCreated'] as Timestamp).toDate();
        var formattedDate = DateFormat.yMMMM().format(date); // "May 2023"

        Map<String, dynamic> paymentData = {
          ...(payment.data() as Map<String, dynamic>),
          'imageSent': payment['imageSent'] ?? '',
        };

        if (!groupedPayments.containsKey(formattedDate)) {
          groupedPayments[formattedDate] = [];
        }
        groupedPayments[formattedDate]!.add(paymentData);
      }
      log("Payment history fetch complete. Grouped payments: ${groupedPayments.length} months");
      for (var month in groupedPayments.keys) {
        log("Month $month: ${groupedPayments[month]!.length} payments");
      }
      return groupedPayments;
    } catch (error, stackTrace) {
      Logger.error("Payment history fetch error: $error", stackTrace: stackTrace);
      // Return empty map instead of throwing to prevent UI crashes
      return {};
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import 'common/utils/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:swiftrun/common/routes/route_name.dart';
import 'package:swiftrun/common/styles/colors.dart';
import 'package:swiftrun/common/utils/logger.dart';
import 'global/global.dart';




Future<void> setupPaymentSettings() async {
  final List<Map<String, dynamic>> settings = [
    {'vehicleTypeId': 'bike', 'addOnFee': 0.0, 'pricePerKM': 4000.0},
    {'vehicleTypeId': 'truck', 'addOnFee': 0.0, 'pricePerKM': 10000.0},
  ];
  for (var setting in settings) {
    await FirebaseFirestore.instance
        .collection('PaymentSettings')
        .doc(setting['vehicleTypeId'] as String)
        .set(setting);
  }
  Logger.i('PaymentSettings collection initialized');
}
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:swiftrun/common/utils/logger.dart';
// import 'package:swiftrun/core/model/direction_model.dart';
// import 'package:swiftrun/global/global.dart';
//
// class FareCalculator {
//   static Future<double> calculateFareAmount({
//     required DirectionModel distanceInKM,
//     required String vehicleTypeId,
//   }) async {
//     Logger.i("Calculate Fare Amount..");
//     double totalAmount = 0.0;
//     try {
//       QuerySnapshot snapshot = await fDataBase
//           .collection("PaymentSettings")
//           .where("vehicleTypeId", isEqualTo: vehicleTypeId)
//           .get();
//       for (var result in snapshot.docs) {
//         var resultData = result.data() as Map<String, dynamic>;
//         double addOnFee = (resultData['addOnFee'] ?? 0.0).toDouble();
//         Logger.i(result);
//         Logger.i(resultData);
//         double pricePerKM = (resultData['pricePerDistance'] ?? 0.0).toDouble();
//         double numberOfKM = (distanceInKM.distanceInMeter! / 1000);
//
//         totalAmount = (pricePerKM * numberOfKM) + addOnFee;
//         Logger.i("Here on Amount $totalAmount");
//         Logger.i("Here on KMeter $numberOfKM");
//       }
//     } catch (e, stackTrace) {
//       Logger.error(e, stackTrace: stackTrace);
//       return 0.0;
//     }
//     Logger.i(totalAmount);
//     return double.parse(totalAmount.toStringAsFixed(0));
//   }
//
//   static Future<List<Map<String, String>>> vehicleTypes() async {
//     Logger.i(" Get VehicleTypes:..");
//     List<Map<String, String>> vehicleTypes = [];
//     try {
//       QuerySnapshot snapshot = await fDataBase
//           .collection("VehicleTypes")
//           .where("status", isEqualTo: "Active")
//           .get();
//       for (var docResult in snapshot.docs) {
//         var docResults = docResult.data() as Map<String, dynamic>;
//
//         var vehicleType = docResults['type'] ?? "";
//         var vehicleIcon = docResults['vehicleIcon'] ?? '';
//         var vehicleRef = docResult.id;
//         vehicleTypes.add({
//           "type": vehicleType,
//           'vehicleIcon': vehicleIcon,
//           "vehicleRef": vehicleRef,
//         });
//         Logger.i(docResults);
//         Logger.i('SnapShots ${docResult.id}');
//       }
//     } catch (error, stackTrace) {
//       Logger.error("Error Occured $error, $stackTrace");
//       return [];
//     }
//     return vehicleTypes;
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swiftrun/common/utils/logger.dart';
import 'package:swiftrun/core/model/direction_model.dart';
import 'package:swiftrun/global/global.dart';

class FareCalculator {
  static Future<double> calculateFareAmount({
    required DirectionModel distanceInKM,
    required String vehicleTypeId,
  }) async {
    Logger.i("🔍 Calculate Fare Amount for vehicleTypeId: $vehicleTypeId");
    Logger.i("🔍 Distance in meters: ${distanceInKM.distanceInMeter}");

    double totalAmount = 0.0;
    try {
      // Debug the query
      Logger.i("🔍 Querying PaymentSettings collection...");

      QuerySnapshot snapshot = await fDataBase
          .collection("PaymentSettings")
          .where("vehicleTypeId", isEqualTo: vehicleTypeId)
          .get();

      Logger.i("🔍 Found ${snapshot.docs.length} payment settings documents");

      if (snapshot.docs.isEmpty) {
        Logger.error("❌ No payment settings found for vehicleTypeId: $vehicleTypeId");
        return 0.0;
      }

      for (var result in snapshot.docs) {
        var resultData = result.data() as Map<String, dynamic>;
        Logger.i("🔍 Payment Settings Data: $resultData");

        // Handle both string and number types safely
        double addOnFee = _parseToDouble(resultData['addOnFee'] ?? 0.0);
        double pricePerKM = _parseToDouble(resultData['pricePerDistance'] ?? 0.0);
        double numberOfKM = (distanceInKM.distanceInMeter! / 1000);

        Logger.i("🔍 Add-on Fee: $addOnFee");
        Logger.i("🔍 Price per KM: $pricePerKM");
        Logger.i("🔍 Distance in KM: $numberOfKM");

        totalAmount = (pricePerKM * numberOfKM) + addOnFee;

        Logger.i("✅ Calculated Total Amount: $totalAmount");
        Logger.i("💰 Calculation: ($pricePerKM × $numberOfKM) + $addOnFee = $totalAmount");
      }
    } catch (e, stackTrace) {
      Logger.error("❌ Error calculating fare: $e", stackTrace: stackTrace);
      return 0.0;
    }

    Logger.i("💰 Final Amount: $totalAmount");
    return double.parse(totalAmount.toStringAsFixed(0));
  }

  // Helper method to safely parse values to double
  static double _parseToDouble(dynamic value) {
    if (value == null) {
      Logger.i("⚠️ Null value found, returning 0.0");
      return 0.0;
    }

    if (value is double) {
      Logger.i("✅ Value is already double: $value");
      return value;
    }

    if (value is int) {
      Logger.i("✅ Converting int to double: $value");
      return value.toDouble();
    }

    if (value is String) {
      try {
        double parsed = double.parse(value);
        Logger.i("✅ Parsed string to double: '$value' → $parsed");
        return parsed;
      } catch (e) {
        Logger.error("❌ Failed to parse '$value' to double: $e");
        return 0.0;
      }
    }

    Logger.error("❌ Unknown type for value: $value (${value.runtimeType})");
    return 0.0;
  }

  static Future<List<Map<String, String>>> vehicleTypes() async {
    Logger.i("🚗 Get VehicleTypes...");
    List<Map<String, String>> vehicleTypes = [];
    try {
      QuerySnapshot snapshot = await fDataBase
          .collection("VehicleTypes")
          .where("status", isEqualTo: "Active")
          .get();

      Logger.i("🚗 Found ${snapshot.docs.length} active vehicle types");

      for (var docResult in snapshot.docs) {
        var docResults = docResult.data() as Map<String, dynamic>;

        var vehicleType = docResults['type'] ?? "";
        var vehicleIcon = docResults['vehicleIcon'] ?? '';
        var vehicleRef = docResult.id;

        vehicleTypes.add({
          "type": vehicleType,
          'vehicleIcon': vehicleIcon,
          "vehicleRef": vehicleRef,
        });

        Logger.i("🚗 Vehicle Type: $vehicleType, ID: $vehicleRef");
      }

      Logger.i("🚗 Total vehicle types loaded: ${vehicleTypes.length}");
    } catch (error, stackTrace) {
      Logger.error("❌ Error getting vehicle types: $error", stackTrace: stackTrace);
      return [];
    }
    return vehicleTypes;
  }
}
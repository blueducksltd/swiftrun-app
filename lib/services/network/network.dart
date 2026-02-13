import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:swiftrun/common/utils/utils.dart';
import 'package:swiftrun/core/controller/location_controller.dart';
import 'package:swiftrun/core/model/address_model.dart';
import 'package:swiftrun/core/model/api_respons.dart';
import 'package:swiftrun/core/model/auto_prediction.dart';
import 'package:swiftrun/core/model/direction_model.dart';
import 'package:swiftrun/services/location/get_service_key.dart';
import 'package:swiftrun/services/location/location_service.dart';
import 'package:swiftrun/services/network/errors.dart';
import 'package:swiftrun/services/network/network_utils.dart';

class Network {
  // static Future<void> notifyDriver({
  //   required String driverToken,
  //   required String requestID,
  // }) async {
  //   var fcmServerKey = await GetServiceKey.getServiceToken();
  //   Logger.i(fcmServerKey);
  //
  //   if (await NetworkUtils.hasNetwork()) {
  //     try {
  //       final url = Uri.parse(ApisAddress.sendNotification());
  //       var body = jsonEncode({
  //         "message": {
  //           "token": driverToken,
  //           "notification": {
  //             "title": "VLOGX",
  //             "body": "You have a new ride request"
  //           },
  //           "data": {
  //             "click_action": "FLUTTER_NOTIFICATION_CLICK",
  //             "id": "1",
  //             "status": "done",
  //             "rideRequestId": requestID
  //           }
  //         }
  //       });
  //
  //       var response = await http.post(
  //         url,
  //         headers: {
  //           'Content-Type': 'application/json',
  //           'Authorization': 'Bearer $fcmServerKey',
  //         },
  //         body: body,
  //       );
  //
  //       if (response.statusCode == 200) {
  //         Logger.i("✅ Request sent successfully: ${response.body}");
  //       } else {
  //         Logger.error("❌ Failed to send notification. Status code: ${response.statusCode}, Response: ${response.body}");
  //         // DON'T throw exception - let booking continue
  //       }
  //     } on TimeoutException catch (_) {
  //       Logger.error("⏰ Connection Time Out - but booking continues");
  //       // DON'T throw exception - let booking continue
  //     } catch (e, stackTrace) {
  //       Logger.error("❌ Notification error but booking continues: $e", stackTrace: stackTrace);
  //       // DON'T throw exception - let booking continue
  //     }
  //   } else {
  //     Logger.error("📶 No network connection for notification");
  //     // DON'T throw exception - let booking continue
  //   }
  // }



  // static Future<void> notifyDriver({
  //   required String driverToken,
  //   required String requestID,
  // }) async {
  //   var fcmServerKey = await GetServiceKey.getServiceToken();
  //   Logger.i(fcmServerKey);
  //
  //   if (await NetworkUtils.hasNetwork()) {
  //     try {
  //       final url = Uri.parse(ApisAddress.sendNotification());
  //       var body = jsonEncode({
  //         "message": {
  //           "token": driverToken,
  //           "notification": {
  //             "title": "New Delivery Request",
  //             "body": "You have a new delivery request. Tap to view details."
  //           },
  //           "data": {
  //             "click_action": "FLUTTER_NOTIFICATION_CLICK",
  //             "id": "1",
  //             "status": "done",
  //             "rideRequestId": requestID,
  //             "type": "delivery_request"
  //           },
  //           "android": {
  //             "priority": "high",
  //             "notification": {
  //               "channel_id": "delivery_requests",
  //               "priority": "high",
  //               "default_sound": true,
  //               "default_vibrate": true
  //             }
  //           },
  //           "apns": {
  //             "payload": {
  //               "aps": {
  //                 "sound": "default",
  //                 "badge": 1
  //               }
  //             }
  //           }
  //         }
  //       });
  //
  //       var response = await http.post(
  //         url,
  //         headers: {
  //           'Content-Type': 'application/json',
  //           'Authorization': 'Bearer $fcmServerKey',
  //         },
  //         body: body,
  //       ).timeout(const Duration(seconds: 30)); // Add timeout
  //
  //       if (response.statusCode == 200) {
  //         Logger.i("Driver notification sent successfully: ${response.body}");
  //       } else {
  //         Logger.error("Failed to send driver notification: ${response.statusCode} - ${response.body}");
  //       }
  //     } on TimeoutException catch (_) {
  //       Logger.error("Driver notification timeout - but booking continues");
  //     } catch (e, stackTrace) {
  //       Logger.error("Driver notification error: $e", stackTrace: stackTrace);
  //     }
  //   } else {
  //     Logger.error("No network connection for driver notification");
  //   }
  // }



  static Future<void> notifyDriver({
    required String driverToken,
    required String requestID,
    String? title,
    String? message, // Changed from 'body' to 'message' to avoid conflict
    String? status,
    String? type,
  }) async {
    var fcmServerKey = await GetServiceKey.getServiceToken();

    if (await NetworkUtils.hasNetwork()) {
      try {
        final url = Uri.parse(ApisAddress.sendNotification());
        var body = jsonEncode({
          "message": {
            "token": driverToken,
            "notification": {
              "title": title ?? "New Delivery Request",
              "body": message ?? "You have a new delivery request. Tap to view details." // Now using 'message' parameter
            },
            "data": {
              "click_action": "FLUTTER_NOTIFICATION_CLICK",
              "id": "1",
              "status": status ?? "new_request",
              "rideRequestId": requestID,
              "requestId": requestID,  // ✅ Add requestId for rating screen
              "tripId": requestID,     // ✅ Add tripId as alternative key
              "type": type ?? "delivery_request"
            },
            "android": {
              "priority": "high"
            },
            "apns": {
              "payload": {
                "aps": {
                  "sound": "default",
                  "badge": 1
                }
              }
            }
          }
        });

        var response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $fcmServerKey',
          },
          body: body,
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          Logger.i("Driver notification sent successfully: ${response.body}");
        } else {
          Logger.error("Failed to send driver notification: ${response.statusCode} - ${response.body}");
        }
      } catch (e, stackTrace) {
        Logger.error("Driver notification error: $e", stackTrace: stackTrace);
      }
    }
  }



  static Future<void> notifyDriversTopic({
    required String requestID,
  }) async {
    var fcmServerKey = await GetServiceKey.getServiceToken();

    if (await NetworkUtils.hasNetwork()) {
      try {
        final url = Uri.parse(ApisAddress.sendNotification());
        var body = jsonEncode({
          "message": {
            "topic": "AllDrivers",
            "notification": {
              "title": "New Delivery Request",
              "body": "A new delivery request is available. Tap to view details."
            },
            "data": {
              "click_action": "FLUTTER_NOTIFICATION_CLICK",
              "rideRequestId": requestID,
              "type": "delivery_request"
            },
            "android": {
              "priority": "high",
              // Remove the notification object - it causes conflicts
            },
            "apns": {
              "payload": {
                "aps": {
                  "sound": "default",
                  "badge": 1
                }
              }
            }
          }
        });

        var response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $fcmServerKey',
          },
          body: body,
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          Logger.i("Topic notification sent to all drivers: ${response.body}");
        } else {
          Logger.error("Failed to send topic notification: ${response.statusCode} - ${response.body}");
        }
      } catch (e) {
        Logger.error("Topic notification error: $e");
      }
    }
  }


  // Add this method right after notifyDriver
  static Future<void> testDriverToken(String driverToken) async {
    var fcmServerKey = await GetServiceKey.getServiceToken();

    final url = Uri.parse(ApisAddress.sendNotification());
    var body = jsonEncode({
      "message": {
        "token": driverToken,
        "notification": {
          "title": "Test Notification",
          "body": "This is a test notification"
        },
        "data": {
          "rideRequestId": "test_123"
        }
      }
    });

    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $fcmServerKey',
      },
      body: body,
    );

    Logger.i("Test notification response: ${response.statusCode} - ${response.body}");
  }


  static Future<List<Map<String, dynamic>>> getLocationPlace(
      {required String placeName, String? countryCode}) async {
    if (await NetworkUtils.hasNetwork()) {
      var url = Uri.parse(ApisAddress.placesAPI(placeName, countryCode: countryCode));
      try {
        var response = await http
            .get(url, headers: NetworkUtils.headers())
            .timeout(const Duration(seconds: 60), onTimeout: () {
          throw TimeoutException("Connection Timed Out");
        });
        // .onError((error, stackTrace) => throw Exception(error));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final jsonData = json.decode(response.body);
          final List<dynamic> predictionList = jsonData['predictions'];
          debugPrint(response.body);
          return predictionList.cast<Map<String, dynamic>>();
        } else {
          NetworkErrors.handleNetworkErrors(response);
          throw Exception(
              'Failed to load place predictions: ${response.statusCode}');
        }
      } catch (e, stackTrace) {
        Logger.error(e, stackTrace: stackTrace);
        throw Exception(
            'An error occurred while fetching place predictions: $e');
      }
    } else {
      Toasts.showToast(Colors.black, "No Internet Connection");
      throw Exception('Failed to load place predictions');
    }
  }

  static getLatLngFromPlaceID(
      AutocompletePrediction address, LocationType locationTpye) async {
    if (await NetworkUtils.hasNetwork()) {
      final url = Uri.parse(
          ApisAddress.getLatLngFromPlaceIDAPI(address.placeId.toString()));
      try {
        var response = await http
            .get(url, headers: NetworkUtils.headers())
            .timeout(const Duration(seconds: 60), onTimeout: () {
          throw TimeoutException("Connection Timed Out");
        }).onError((error, stackTrace) => throw Exception(error));
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final jsonData = json.decode(response.body);
          var latlngResult = jsonData['result']['geometry']['location'];

          var addressModelResult = AddressModel(
              name: address.description,
              description: address.description,
              placeID: address.placeId,
              latitude: latlngResult['lat'],
              longitude: latlngResult['lng']);
          final locationCont = Get.put(LocationController());
          if (locationTpye == LocationType.pickupAddress) {
            locationCont.updatePickupAddress(addressModelResult);
          } else {
            locationCont.updateDropoffAddress(addressModelResult);
          }
          log('LatLng $addressModelResult');
          log("LatLng.....$latlngResult");

          return latlngResult;
        } else {
          NetworkErrors.handleNetworkErrors(response);
        }
      } catch (e, stackTrace) {
        if (kDebugMode) {
          print(stackTrace);
        }
      }
    } else {
      Toasts.showToast(Colors.black, "No Internet Connection");
    }
    throw Exception('Failed to load place predictions');
  }

  static getRiderDirection(LatLng pickupPoint, LatLng dropOffPoint) async {
    // ProgressDialogUtils.showProgressDialog();
    DirectionModel directionResult = DirectionModel();
    if (await NetworkUtils.hasNetwork()) {
      final url =
          Uri.parse(ApisAddress.directionAPI(pickupPoint, dropOffPoint));
      try {
        var response = await http
            .get(url, headers: NetworkUtils.headers())
            .timeout(const Duration(seconds: 60), onTimeout: () {
          throw TimeoutException("Connection Timed Out");
        }).onError((error, stackTrace) => throw Exception(error));
        if (response.statusCode == 200) {
          // ProgressDialogUtils.hideProgressDialog();
          var decodeResponse = jsonDecode(response.body);
          log("Decode $decodeResponse");
          final locationCont = Get.put(LocationController());
          var directionModel = DirectionModel(
            distanceInKM: decodeResponse['routes'][0]['legs'][0]['distance']
                ['text'],
            distanceInMeter: decodeResponse['routes'][0]['legs'][0]['distance']
                ['value'],
            durationInHour: decodeResponse['routes'][0]['legs'][0]['duration']
                ['text'],
            duration: decodeResponse['routes'][0]['legs'][0]['duration']
                ['value'],
            polylinePoints: decodeResponse['routes'][0]['overview_polyline']
                ['points'],
          );
          log("Direction ${directionModel.toMap().toString()}");
          directionResult = directionModel;
          locationCont.updateDirection(directionModel);
        }
      } catch (e, stackTrack) {
        errorMethod("Error fetching the data");
        Logger.error(e, stackTrace: stackTrack);
        throw Exception(e);
      }
    }
    return directionResult;
  }

  static Future<ApiResponse> post({
    required String uri,
    Map<String, dynamic>? formData,
    String? data,
  }) async {
    final ApiResponse apiResponse = ApiResponse();
    final url = Uri.parse(uri);
    try {
      final response = await http
          .post(
            url,
            headers: NetworkUtils.headers(token: paystackSecret),
            body: formData ?? data,
          )
          .timeout(const Duration(seconds: 60),
              onTimeout: () => throw TimeoutException("Connection Timed Out"));
      log("Response: $response");
      // if (response.statusCode >= 200 && response.statusCode < 300) {
      final raw = jsonDecode(response.body);

      apiResponse
        ..data = raw["data"] ?? raw
        ..statusCode = response.statusCode;
      // } else {
      //   apiResponse.error = NetworkErrors.handleNetworkErrors(response);
      // }
    } on TimeoutException {
      apiResponse.error = {"message": "Request timed out. Please try again."};
    } on HttpException catch (e, stackTrace) {
      Logger.error(e, stackTrace: stackTrace);
      apiResponse.error = {"message": e.message};
    } on FormatException {
      apiResponse.error = {"message": "Invalid response format."};
    } catch (e, stackTrace) {
      Logger.error(e, stackTrace: stackTrace);
      apiResponse.error = {"message": "An unknown error occurred!"};
    }

    return apiResponse;
  }

  static Future<ApiResponse> put({
    required String uri,
    Map<String, dynamic>? formData,
    String? data,
  }) async {
    final ApiResponse apiResponse = ApiResponse();
    final url = Uri.parse(uri);
    try {
      final response = await http
          .put(
            url,
            headers: NetworkUtils.headers(token: paystackSecret),
            body: formData ?? data,
          )
          .timeout(const Duration(seconds: 60),
              onTimeout: () => throw TimeoutException("Connection Timed Out"));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final raw = jsonDecode(response.body);

        apiResponse
          ..data = raw["data"] ?? raw
          ..statusCode = response.statusCode;
      } else {
        apiResponse.error = NetworkErrors.handleNetworkErrors(response);
      }
    } on TimeoutException {
      apiResponse.error = {"message": "Request timed out. Please try again."};
    } on HttpException catch (e) {
      apiResponse.error = {"message": e.message};
    } on FormatException {
      apiResponse.error = {"message": "Invalid response format."};
    } catch (e) {
      apiResponse.error = {"message": "An unknown error occurred!"};
    }

    return apiResponse;
  }

  static Future<ApiResponse> get({
    required String url,
    String? path,
    Map<String, dynamic>? options,
    // Map<String, dynamic>? data = const <String, dynamic>{},
  }) async {
    final ApiResponse apiResponse = ApiResponse();
    var uri = Uri.https(url, path!, options);
    try {
      final response = await http
          .get(
            uri,
            headers: NetworkUtils.headers(token: paystackSecret),
          )
          .timeout(const Duration(seconds: 60),
              onTimeout: () => throw TimeoutException("Connection Timed Out"));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final raw = jsonDecode(response.body);

        raw is List
            ? apiResponse.data = raw
            : apiResponse.data = raw['data'] ?? raw;

        apiResponse.statusCode = response.statusCode;
      } else {
        apiResponse.error = NetworkErrors.handleNetworkErrors(response);
      }
    } on TimeoutException {
      apiResponse.error = {"message": "Request timed out. Please try again."};
    } on HttpException catch (e) {
      apiResponse.error = {"message": e.message};
    } on FormatException {
      apiResponse.error = {"message": "Invalid response format."};
    } catch (e) {
      apiResponse.error = {"message": "An unknown error occurred!"};
    }

    return apiResponse;
  }
}

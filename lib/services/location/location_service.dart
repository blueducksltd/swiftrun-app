import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:swiftrun/common/utils/utils.dart';

class ApisAddress {
  static String placesAPI(String placeName, {String? countryCode}) {
    String apiKey = Uri.encodeQueryComponent(googleMapApiKey);
    String encodedPlaceName = Uri.encodeQueryComponent(placeName);
    
    // Use provided country code or default to global search
    String countryFilter = countryCode != null ? '&components=country:$countryCode' : '';
    
    return 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$encodedPlaceName&key=$apiKey$countryFilter';
  }

  static getLatLngFromPlaceIDAPI(String placeID) {
    String apiKey = Uri.encodeQueryComponent(googleMapApiKey);
    String encodedPlaceID = Uri.encodeQueryComponent(placeID);
    return 'https://maps.googleapis.com/maps/api/place/details/json?placeid=$encodedPlaceID&key=$apiKey';
  }

  static geoCoadingAPI(LatLng position) {
    String apiKey = Uri.encodeQueryComponent(googleMapApiKey);
    return 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey';
  }

  static directionAPI(LatLng pickup, LatLng drop) {
    String apiKey = Uri.encodeQueryComponent(googleMapApiKey);
    return 'https://maps.googleapis.com/maps/api/directions/json?origin=${pickup.latitude},${pickup.longitude}&destination=${drop.latitude},${drop.longitude}&mode=driving&key=$apiKey';
  }

  static sendNotification() =>
      'https://fcm.googleapis.com/v1/projects/vlogx-f4c1f/messages:send';

  static const String initializeTransaction =
      "https://api.paystack.co/transaction/initialize";
  static String verifyTransaction(String reference) =>
      "https://api.paystack.co/transaction/verify/$reference";

  static const transactionList = "https://api.paystack.co/transaction";

  static const customerList = "https://api.paystack.co/customer";
  static const createCustomer = "https://api.paystack.co/customer";

  static fetchCustomer(String emailORcode) =>
      "https://api.paystack.co/customer/$emailORcode";
  static updateCustomer(String code) =>
      "https://api.paystack.co/customer/$code";
}

String get baseURl => "api.paystack.co";

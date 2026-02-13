import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/utils/logger.dart';
import 'package:swiftrun/common/utils/toast.dart';
import 'package:swiftrun/core/model/address_model.dart';
import 'package:swiftrun/core/model/auto_prediction.dart';
import 'package:swiftrun/core/model/direction_model.dart';
import 'package:swiftrun/services/network/network.dart';
import 'package:swiftrun/common/utils/location_utils.dart';
import 'package:swiftrun/core/controller/session_controller.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

enum LocationType {
  pickupAddress,
  dropoffAddres,
}

class LocationController extends GetxController {
  static LocationController get to => Get.find();
  var riderMaker = <Marker>{}.obs;
  var circleMarker = <Circle>{}.obs;
  var polylineSet = <Polyline>{}.obs;
  RxList<LatLng> polylineCoordinatesList = <LatLng>[].obs;
  DirectionModel? directionDetails;
  BitmapDescriptor? carIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? pickupIcon;
  RxBool updateMarkerBool = false.obs;
  Position? position;
  AddressModel? pickupLocation;
  AddressModel? dropLocation;

  List<Placemark>? placeMarks;

  RxList<AutocompletePrediction> pickupPredictionList =
      <AutocompletePrediction>[].obs;
  RxList<AutocompletePrediction> dropOffpredictionList =
      <AutocompletePrediction>[].obs;

  Rx<LatLng?> selectedLocation = Rx<LatLng?>(null);
  String completeAddress = "";

  var pickupText = TextEditingController();
  var dropOffText = TextEditingController();

  late GoogleMapController googleMapController;
  Completer<GoogleMapController> mapControllerDriver = Completer();

  // DEFAULT FALLBACK - Enugu coordinates
  CameraPosition initalLocation = const CameraPosition(
    zoom: 12,
    target: LatLng(
      6.5244, // Enugu coordinates
      7.4989,
    ),
  );

  // Track if we've set the initial location and loading state
  RxBool hasSetCurrentLocation = false.obs;
  RxBool isGettingLocation = false.obs;
  
  // Track user's jurisdiction for filtering
  RxString userCountry = "".obs;
  RxString userState = "".obs;
  
  // Current country detection
  RxString currentCountryCode = 'NG'.obs;
  RxString currentCountryName = 'Nigeria'.obs;
  
  // Get current country for external use
  String getCurrentCountryCode() => currentCountryCode.value;
  String getCurrentCountryName() => currentCountryName.value;
  
  // Manual country override for testing
  void setCurrentCountry(String countryCode) {
    currentCountryCode.value = countryCode;
    currentCountryName.value = _getCountryNameFromCode(countryCode);
    Logger.i("🌍 Manually set country to: ${currentCountryName.value} ($countryCode)");
  }
  
  // Test method to manually set country for different locations
  void testCountryDetection() {
    Logger.i("🧪 Testing country detection...");
    Logger.i("Current country: ${currentCountryName.value} (${currentCountryCode.value})");
    Logger.i("Available countries: NG, US, CA, MT");
    Logger.i("Use setCurrentCountry('US') to test US locations");
    Logger.i("Use setCurrentCountry('MT') to test Malta locations");
  }

  @override
  void onInit() {
    super.onInit();
    // Get current location immediately when controller initializes
    _initializeCurrentLocation();
  }

  void _initializeCurrentLocation() async {
    await getCurrentLocation();
    if (position != null) {
      // Update the initial camera position with current location
      initalLocation = CameraPosition(
        zoom: 15,
        target: LatLng(position!.latitude, position!.longitude),
      );
      hasSetCurrentLocation.value = true;

      // Detect current country from location
      await _detectCurrentCountry();

      // If map is already created, animate to current location
      if (mapControllerDriver.isCompleted) {
        try {
          googleMapController.animateCamera(
            CameraUpdate.newLatLng(
              LatLng(position!.latitude, position!.longitude),
            ),
          );
        } catch (e) {
          log("Error animating camera: $e");
        }
      }
    }
  }

  // Detect country from current location coordinates
  Future<void> _detectCurrentCountry() async {
    try {
      Logger.i("Starting country detection...");
      Logger.i("Position: ${position?.latitude}, ${position?.longitude}");
      
      if (position != null) {
        Logger.i("Getting placemarks for coordinates...");
        final placemarks = await placemarkFromCoordinates(
          position!.latitude,
          position!.longitude,
        );
        
        Logger.i("Found ${placemarks.length} placemarks");
        
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          final country = placemark.country ?? 'Nigeria';
          final countryCode = _getCountryCodeFromName(country);
          
          currentCountryName.value = country;
          currentCountryCode.value = countryCode;
          
          Logger.i("✅ Detected current country: $country ($countryCode)");
          Logger.i("Current country code set to: ${currentCountryCode.value}");
        } else {
          Logger.i("No placemarks found, using fallback");
          _setFallbackCountry();
        }
      } else {
        Logger.i("No position available, using fallback");
        _setFallbackCountry();
      }
    } catch (e) {
      Logger.error("Error detecting current country: $e");
      _setFallbackCountry();
    }
  }
  
  void _setFallbackCountry() {
    // Fallback to user's registered country
    final userCountry = SessionController.to.userData.countryCode ?? '+234';
    currentCountryCode.value = LocationUtils.getCountryFromCode(userCountry);
    currentCountryName.value = _getCountryNameFromCode(currentCountryCode.value);
    Logger.i("Using fallback country: ${currentCountryName.value} (${currentCountryCode.value})");
  }
  
  // Helper method to get country code from country name
  String _getCountryCodeFromName(String countryName) {
    switch (countryName.toLowerCase()) {
      case 'nigeria':
        return 'NG';
      case 'united states':
      case 'usa':
      case 'united states of america':
        return 'US';
      case 'canada':
        return 'CA';
      case 'malta':
        return 'MT';
      default:
        return 'NG'; // Default fallback
    }
  }
  
  // Helper method to get country name from country code
  String _getCountryNameFromCode(String countryCode) {
    switch (countryCode) {
      case 'NG':
        return 'Nigeria';
      case 'US':
        return 'United States';
      case 'CA':
        return 'Canada';
      case 'MT':
        return 'Malta';
      default:
        return 'Nigeria';
    }
  }

  void getPlaceAutoComplete(String placeName, bool isPickup) async {
    if (placeName.trim().isEmpty) return;

    try {
      Logger.i("🔍 Getting autocomplete for: '$placeName'");
      
      // Use current location country instead of user's registered country
      final countryCode = currentCountryCode.value;
      Logger.i("📍 Using country code: $countryCode");
      
      // Get country-specific suggestions based on current location
      final countrySuggestions = LocationUtils.getLocationSuggestions(countryCode);
      Logger.i("🏙️ Country suggestions: ${countrySuggestions.length} cities");
      
      // Create local suggestions based on current location country
      final localSuggestions = countrySuggestions
          .where((location) => location.toLowerCase().contains(placeName.toLowerCase()))
          .take(5)
          .map((location) => {
                'place_id': location,
                'description': location,
                'structured_formatting': {
                  'main_text': location.split(',')[0],
                  'secondary_text': location.split(',')[1].trim(),
                }
              })
          .toList();

      Logger.i("🎯 Local suggestions found: ${localSuggestions.length}");
      for (var suggestion in localSuggestions) {
        Logger.i("  - ${suggestion['description']}");
      }

      // Get API suggestions with country filter
      Logger.i("🌐 Getting API suggestions for country: $countryCode");
      final response = await Network.getLocationPlace(placeName: placeName, countryCode: countryCode);
      Logger.i("🌐 API suggestions found: ${response.length}");
      
      // Combine local and API suggestions
      final allSuggestions = [...localSuggestions, ...response];
      Logger.i("📋 Total suggestions: ${allSuggestions.length}");

      if (isPickup) {
        pickupPredictionList.value =
            allSuggestions.map((e) => AutocompletePrediction.fromJson(e)).toList();
        Logger.i("✅ Updated pickup predictions: ${pickupPredictionList.length}");
      } else {
        dropOffpredictionList.value =
            allSuggestions.map((e) => AutocompletePrediction.fromJson(e)).toList();
        Logger.i("✅ Updated dropoff predictions: ${dropOffpredictionList.length}");
      }
      
    } catch (e) {
      Logger.error("❌ Error getting place autocomplete: $e");
      // Clear the lists on error
      if (isPickup) {
        pickupPredictionList.clear();
      } else {
        dropOffpredictionList.clear();
      }
    }
  }

  void onMapCreated(GoogleMapController controller) async {
    if (!mapControllerDriver.isCompleted) {
      mapControllerDriver.complete(controller);
    }
    googleMapController = controller;

    // If we have current location, immediately move camera there
    if (position != null) {
      try {
        googleMapController.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position!.latitude, position!.longitude),
          ),
        );
      } catch (e) {
        log("Error animating camera on map created: $e");
      }
    } else {
      // If we don't have location yet, get it now
      _initializeCurrentLocation();
    }
  }

  // Enhanced getCurrentLocation with proper geocoding priority
  getCurrentLocation({bool isForDelivery = false}) async {
    // Prevent multiple concurrent requests
    if (isGettingLocation.value) {
      Toasts.showToast(AppColor.primaryColor, "Location request already in progress...");
      return;
    }

    isGettingLocation.value = true;

    try {
      final hasPermission = await _permissionHandler();
      if (!hasPermission) {
        isGettingLocation.value = false;
        return;
      }

      // Show loading toast
      Toasts.showToast(AppColor.primaryColor, "Getting current location...");

      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      position = currentPosition;
      LatLng currentLocation = LatLng(
        currentPosition.latitude,
        currentPosition.longitude,
      );

      // IMPORTANT: Try to get placemarks with shorter timeout
      try {
        placeMarks = await placemarkFromCoordinates(
          currentPosition.latitude,
          currentPosition.longitude,
        ).timeout(const Duration(seconds: 3)); // Reduced timeout
        log("Placemarks retrieved successfully: ${placeMarks?.length ?? 0} results");
      } catch (e) {
        log("Error getting placemarks: $e");
        placeMarks = null;
      }

      // Get formatted address using improved method (Flutter geocoding first)
      completeAddress = await _getAddressFromLatLng(
        currentPosition.latitude,
        currentPosition.longitude,
      );

      var getCurrentLocationModel = AddressModel(
        description: completeAddress,
        name: "Current Location",
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude,
      );

      // Set to either pickup or delivery based on parameter
      if (isForDelivery) {
        dropOffText.text = completeAddress;
        updateDropoffAddress(getCurrentLocationModel);
        // Clear prediction list when setting location
        dropOffpredictionList.clear();
        Toasts.showToast(AppColor.primaryColor, "Delivery location set");
      } else {
        pickupText.text = completeAddress;
        updatePickupAddress(getCurrentLocationModel);
        // Clear prediction list when setting location
        pickupPredictionList.clear();
        Toasts.showToast(AppColor.primaryColor, "Pickup location set");
      }

      // Move camera to current location if map is ready
      if (mapControllerDriver.isCompleted) {
        try {
          googleMapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: currentLocation,
                zoom: 15,
              ),
            ),
          );
        } catch (e) {
          log("Error animating camera to location: $e");
        }
      }

      log("Current location set: ${currentPosition.latitude}, ${currentPosition.longitude}");
      log("Address: $completeAddress");

      // Always fetch structural placemark data for Country/State filtering
      // This is crucial for the "Smart Location" limiting (Malta vs Nigeria)
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
            currentPosition.latitude, 
            currentPosition.longitude
        );
        
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          userCountry.value = place.country ?? "";
          userState.value = place.administrativeArea ?? "";
          
          log("📍 Smart Location Detected: Country=${userCountry.value}, State=${userState.value}");
        }
      } catch (e) {
        log("Error fetching placemarks for filtering: $e");
      }

    } catch (e) {
      log("Error getting current location: $e");
      String errorMessage = "Unable to get current location";

      if (e.toString().contains('TimeoutException') || e.toString().contains('timeout')) {
        errorMessage = "Location request timed out. Please check your GPS and internet connection.";
      } else if (e.toString().contains('PERMISSION_DENIED')) {
        errorMessage = "Location permission denied. Please enable location access.";
      } else if (e.toString().contains('PERMISSION_DISABLED')) {
        errorMessage = "Location services disabled. Please enable GPS.";
      }

      Toasts.showToast(AppColor.errorColor, errorMessage);
    } finally {
      isGettingLocation.value = false;
    }
  }

  // IMPROVED METHOD: Shorter timeouts and better offline handling
  Future<String> _getAddressFromLatLng(double latitude, double longitude) async {
    log("Starting geocoding for: $latitude, $longitude");

    // METHOD 1: Quick Flutter geocoding attempt with shorter timeout
    try {
      log("Trying Flutter geocoding with short timeout...");
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      ).timeout(const Duration(seconds: 3)); // Reduced timeout

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Debug what we got
        _debugPlacemarkData(place);

        String formattedAddress = _buildAddressFromPlacemark(place);

        if (formattedAddress.isNotEmpty && formattedAddress.length > 10) {
          log("✅ Flutter geocoding SUCCESS: $formattedAddress");
          return formattedAddress;
        } else {
          log("⚠️ Flutter geocoding returned empty/short address");
        }
      } else {
        log("⚠️ Flutter geocoding returned no placemarks");
      }
    } catch (e) {
      log("❌ Flutter geocoding FAILED: $e");
    }

    // METHOD 2: Try with existing placeMarks (from earlier successful call)
    if (placeMarks != null && placeMarks!.isNotEmpty) {
      try {
        log("Trying cached placemarks from earlier call...");
        String cachedAddress = _buildAddressFromPlacemark(placeMarks![0]);
        if (cachedAddress.isNotEmpty && cachedAddress.length > 10) {
          log("✅ Cached placemarks SUCCESS: $cachedAddress");
          return cachedAddress;
        }
      } catch (e) {
        log("❌ Cached placemarks FAILED: $e");
      }
    }

    // METHOD 3: Quick Google API attempt with shorter timeout
    try {
      log("Trying Google geocoding with short timeout...");
      String googleAddress = await _getGoogleGeocodingAddress(latitude, longitude);
      if (googleAddress.isNotEmpty && !googleAddress.contains("Current Location (")) {
        log("✅ Google geocoding SUCCESS: $googleAddress");
        return googleAddress;
      }
    } catch (e) {
      log("❌ Google geocoding FAILED: $e");
    }

    // METHOD 4: Enhanced offline fallback with known Enugu areas
    log("Using enhanced offline fallback...");
    return _getEnhancedOfflineFallback(latitude, longitude);
  }

  // Helper method to build address from Flutter's Placemark
  String _buildAddressFromPlacemark(Placemark place) {
    List<String> addressParts = [];

    log("Building address from placemark...");

    // Build street address (most specific first)
    if (place.subThoroughfare?.isNotEmpty == true &&
        place.thoroughfare?.isNotEmpty == true) {
      addressParts.add('${place.subThoroughfare} ${place.thoroughfare}');
      log("Added street: ${place.subThoroughfare} ${place.thoroughfare}");
    } else if (place.thoroughfare?.isNotEmpty == true) {
      addressParts.add(place.thoroughfare!);
      log("Added thoroughfare: ${place.thoroughfare}");
    } else if (place.name?.isNotEmpty == true &&
        !place.name!.contains('+') &&
        place.name!.length < 50) {
      addressParts.add(place.name!);
      log("Added name: ${place.name}");
    }

    // Sub-locality (neighborhood/area)
    if (place.subLocality?.isNotEmpty == true) {
      addressParts.add(place.subLocality!);
      log("Added subLocality: ${place.subLocality}");
    }

    // Main locality (city/town)
    if (place.locality?.isNotEmpty == true) {
      addressParts.add(place.locality!);
      log("Added locality: ${place.locality}");
    }

    // Sub-administrative area (LGA)
    if (place.subAdministrativeArea?.isNotEmpty == true) {
      addressParts.add(place.subAdministrativeArea!);
      log("Added LGA: ${place.subAdministrativeArea}");
    }

    // Administrative area (state) - should be Enugu for you
    if (place.administrativeArea?.isNotEmpty == true) {
      addressParts.add(place.administrativeArea!);
      log("Added state: ${place.administrativeArea}");
    }

    String result = addressParts.join(', ');

    // Clean up the address
    result = result.replaceAll(RegExp(r',\s*,'), ','); // Remove double commas
    result = result.replaceAll(RegExp(r'^,\s*'), ''); // Remove leading comma
    result = result.replaceAll(RegExp(r',\s*$'), ''); // Remove trailing comma
    result = result.trim();

    log("Final built address: '$result'");
    return result;
  }

  // Debug method to see what data we're getting
  void _debugPlacemarkData(Placemark place) {
    log("=== PLACEMARK DEBUG DATA ===");
    log("Name: '${place.name ?? 'NULL'}'");
    log("Street: '${place.street ?? 'NULL'}'");
    log("SubThoroughfare: '${place.subThoroughfare ?? 'NULL'}'");
    log("Thoroughfare: '${place.thoroughfare ?? 'NULL'}'");
    log("SubLocality: '${place.subLocality ?? 'NULL'}'");
    log("Locality: '${place.locality ?? 'NULL'}'");
    log("SubAdminArea: '${place.subAdministrativeArea ?? 'NULL'}'");
    log("AdminArea: '${place.administrativeArea ?? 'NULL'}'");
    log("PostalCode: '${place.postalCode ?? 'NULL'}'");
    log("Country: '${place.country ?? 'NULL'}'");
    log("IsoCountryCode: '${place.isoCountryCode ?? 'NULL'}'");
    log("===============================");
  }

  // Separate method for Google's REST API with shorter timeout
  Future<String> _getGoogleGeocodingAddress(double latitude, double longitude) async {
    const String apiKey = "AIzaSyAbfduz030HMKN9BAFcTd0r9Xh1Bsuuplc";
    final String url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey&result_type=street_address|premise|subpremise|route&language=en';

    final response = await http.get(
      Uri.parse(url),
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 5)); // Reduced timeout

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        // Try to get the best result
        for (var result in data['results']) {
          String formattedAddress = result['formatted_address'] ?? '';

          if (formattedAddress.isNotEmpty &&
              !formattedAddress.toLowerCase().startsWith('unnamed') &&
              formattedAddress.length > 15) {

            // Try to build custom address from components
            String customAddress = _formatAddressFromComponents(
                result['address_components'] ?? []
            );

            return customAddress.isNotEmpty ? customAddress : formattedAddress;
          }
        }

        // Use first result if available
        if (data['results'][0]['formatted_address'] != null) {
          return data['results'][0]['formatted_address'];
        }
      } else {
        log("Google geocoding API error: ${data['status']} - ${data['error_message'] ?? 'No details'}");
      }
    } else {
      log("Google geocoding HTTP error: ${response.statusCode}");
    }

    return '';
  }

  // Enhanced address formatting from Google's components
  String _formatAddressFromComponents(List<dynamic> addressComponents) {
    if (addressComponents.isEmpty) return '';

    Map<String, String> components = {};

    for (var component in addressComponents) {
      List<dynamic> types = component['types'] ?? [];
      String longName = component['long_name'] ?? '';
      String shortName = component['short_name'] ?? '';

      if (types.contains('street_number')) {
        components['street_number'] = longName;
      } else if (types.contains('route')) {
        components['route'] = longName;
      } else if (types.contains('sublocality') || types.contains('sublocality_level_1')) {
        components['sublocality'] = longName;
      } else if (types.contains('locality')) {
        components['locality'] = longName;
      } else if (types.contains('administrative_area_level_1')) {
        components['state'] = shortName.isNotEmpty ? shortName : longName;
      } else if (types.contains('administrative_area_level_2')) {
        components['lga'] = longName;
      }
    }

    List<String> addressParts = [];

    // Build street address
    if (components['street_number']?.isNotEmpty == true &&
        components['route']?.isNotEmpty == true) {
      addressParts.add('${components['street_number']} ${components['route']}');
    } else if (components['route']?.isNotEmpty == true) {
      addressParts.add(components['route']!);
    }

    if (components['sublocality']?.isNotEmpty == true) {
      addressParts.add(components['sublocality']!);
    }

    if (components['locality']?.isNotEmpty == true) {
      addressParts.add(components['locality']!);
    }

    if (components['lga']?.isNotEmpty == true) {
      addressParts.add(components['lga']!);
    }

    if (components['state']?.isNotEmpty == true) {
      addressParts.add(components['state']!);
    }

    String result = addressParts.join(', ');
    return result.isNotEmpty ? result : '';
  }

  // Enhanced offline fallback with known Enugu areas
  String _getEnhancedOfflineFallback(double latitude, double longitude) {
    // Known Enugu areas and landmarks (you can expand this list)
    Map<String, Map<String, dynamic>> enuguAreas = {
      'Independence Layout': {
        'lat_range': [6.430, 6.460],
        'lng_range': [7.520, 7.550],
        'description': 'Independence Layout, Enugu'
      },
      'Trans Ekulu': {
        'lat_range': [6.440, 6.470],
        'lng_range': [7.500, 7.530],
        'description': 'Trans Ekulu, Enugu'
      },
      'New Haven': {
        'lat_range': [6.420, 6.450],
        'lng_range': [7.480, 7.510],
        'description': 'New Haven, Enugu'
      },
      'GRA': {
        'lat_range': [6.440, 6.470],
        'lng_range': [7.480, 7.510],
        'description': 'Government Reserved Area (GRA), Enugu'
      },
      'Coal Camp': {
        'lat_range': [6.450, 6.480],
        'lng_range': [7.500, 7.530],
        'description': 'Coal Camp, Enugu'
      },
      'Abakpa Nike': {
        'lat_range': [6.450, 6.480],
        'lng_range': [7.530, 7.560],
        'description': 'Abakpa Nike, Enugu'
      },
      'Uwani': {
        'lat_range': [6.420, 6.450],
        'lng_range': [7.480, 7.510],
        'description': 'Uwani, Enugu'
      },
      'Achara Layout': {
        'lat_range': [6.410, 6.440],
        'lng_range': [7.490, 7.520],
        'description': 'Achara Layout, Enugu'
      },
      'Emene': {
        'lat_range': [6.460, 6.490],
        'lng_range': [7.550, 7.590],
        'description': 'Emene, Enugu'
      }
    };

    // Find if coordinates are within any known area
    for (var areaName in enuguAreas.keys) {
      var area = enuguAreas[areaName]!;
      List<double> latRange = area['lat_range'];
      List<double> lngRange = area['lng_range'];

      if (latitude >= latRange[0] && latitude <= latRange[1] &&
          longitude >= lngRange[0] && longitude <= lngRange[1]) {
        return area['description'];
      }
    }

    // Default static fallback if no match found
    return "Enugu, Nigeria";
  }

  // Update pickup address and notify listeners
  void updatePickupAddress(AddressModel address) {
    pickupLocation = address;
    pickupText.text = address.description ?? "";
    update();
  }

  // Update dropoff address and notify listeners
  void updateDropoffAddress(AddressModel address) {
    dropLocation = address;
    dropOffText.text = address.description ?? "";
    update();
  }

  // Update direction details and notify listeners
  void updateDirection(DirectionModel details) {
    directionDetails = details;
    update();
  }

  Future<bool> _permissionHandler() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      log('Location services are disabled.');
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        log('Location permissions are denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      log('Location permissions are permanently denied');
      return false;
    }

    return true;
  }

  void animateToLocation(LatLng target) {
    if (mapControllerDriver.isCompleted) {
      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: target,
            zoom: 15,
          ),
        ),
      );
    }
  }

  void addMarker(String id, LatLng position, BitmapDescriptor icon, {String? title}) {
    riderMaker.add(
      Marker(
        markerId: MarkerId(id),
        position: position,
        icon: icon,
        infoWindow: title != null ? InfoWindow(title: title) : InfoWindow.noText,
      ),
    );
  }

  void addMark() {
    if (pickupIcon != null && destinationIcon != null) {
      log("Adding markers");
      riderMaker.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: LatLng(pickupLocation!.latitude!, pickupLocation!.longitude!),
          icon: pickupIcon!,
        ),
      );
      riderMaker.add(
        Marker(
          markerId: const MarkerId('Dropoff'),
          position: LatLng(dropLocation!.latitude!, dropLocation!.longitude!),
          icon: destinationIcon!,
        ),
      );
    }
  }

  void decodePolylineAndUpdatePolylineField() async {
    if (pickupLocation != null && dropLocation != null) {
      try {
        var details = await Network.getRiderDirection(
          LatLng(pickupLocation!.latitude!, pickupLocation!.longitude!),
          LatLng(dropLocation!.latitude!, dropLocation!.longitude!),
        );
        directionDetails = details;

        PolylinePoints polylinePoints = PolylinePoints();
        List<PointLatLng> result =
            polylinePoints.decodePolyline(details.polylinePoints!);

        polylineCoordinatesList.clear();
        if (result.isNotEmpty) {
          for (var point in result) {
            polylineCoordinatesList.add(LatLng(point.latitude, point.longitude));
          }
        }

        polylineSet.clear();
        Polyline polyline = Polyline(
          polylineId: const PolylineId("poly"),
          color: AppColor.primaryColor,
          points: polylineCoordinatesList,
          width: 5,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true,
        );
        polylineSet.add(polyline);
        update();
      } catch (e) {
        log("Error decoding polyline: $e");
      }
    }
  }

  Future<void> createActiveNearByDriverIconMarker(BuildContext context) async {
    if (pickupIcon == null) {
      pickupIcon = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(2, 2)),
          "assets/icons/car.png"); // Using available car icon as fallback if specific ones missing
    }
    if (destinationIcon == null) {
      destinationIcon = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(2, 2)),
          "assets/icons/deliveryCar.png");
    }
    if (carIcon == null) {
      carIcon = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(2, 2)), "assets/icons/mapCar.png");
    }
  }

  void clearMarkers() {
    riderMaker.clear();
  }

  @override
  void onClose() {
    pickupText.dispose();
    dropOffText.dispose();
    super.onClose();
  }
}
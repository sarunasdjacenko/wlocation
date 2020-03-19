// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';

import '../services/services.dart';
import 'models.dart';

class WifiScanner {
  /// [MethodChannel] on which to invoke native methods.
  static const _platform = const MethodChannel('sarunasdjacenko.com/wlocation');

  // Asks the user to enable the location permission, and location service.
  static Future<void> _enableLocation() async {
    final location = Location();
    location.requestService();
    location.requestPermission();
  }

  /// Returns the current location estimated with GPS.
  static Future<GeoPoint> getCurrentLocation() async {
    _enableLocation();
    final location = await Location().getLocation();
    return GeoPoint(location.latitude, location.longitude);
  }

  /// Invokes native method to scan for WiFi using, and returns the results.
  /// This is only implemented in Android (Kotlin) due to iOS limitations.
  static Future<Map> getWifiResults() async {
    await _enableLocation();
    final wifiResults = await _platform.invokeListMethod('getWifiResults');
    return Map.fromEntries(wifiResults
        // .where((result) => result['ssid'] == 'eduroam')
        .map((result) => ScanData.fromMap(result)));
  }
}

import 'package:flutter/services.dart';
import 'package:wlocation/models/scan_result.dart';

class WifiScanner {
  /// [MethodChannel] on which to invoke native methods.
  static const _platform = const MethodChannel('sarunasdjacenko.com/wifi_scan');

  /// Invokes native method to scan for WiFi using, and returns the results.
  /// This is only implemented in Android (Kotlin) due to iOS limitations.
  static Future<List<ScanResult>> getWifiResults() async {
    List<Map<dynamic, dynamic>> wifiResults = [];
    wifiResults = await _platform.invokeListMethod('getWifiResults');
    return wifiResults.map((result) => ScanResult(result: result)).toList();
  }
}

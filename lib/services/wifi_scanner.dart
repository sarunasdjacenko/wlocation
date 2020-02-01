import 'package:flutter/services.dart';
import 'package:wlocation/models/scan_result.dart';

class WifiScanner {
  /// [MethodChannel] on which to invoke native methods.
  static const _platform = const MethodChannel('sarunasdjacenko.com/wifi_scan');

  /// Invokes native method to scan for WiFi using, and returns the results.
  /// This is only implemented in Android (Kotlin) due to iOS limitations.
  static Future<Map> getWifiResults() async {
    final wifiResults = await _platform.invokeListMethod('getWifiResults');
    return Map.fromEntries(wifiResults
        // .where((result) => result['ssid'] == 'eduroam')
        .map((result) => ScanResult(result: result)));
  }
}

import 'package:flutter/foundation.dart';

/// Scan Result object, containing relevant information from the scan.
class ScanResult {
  final String ssid;
  final String bssid;
  final int level;
  final int timestamp;

  ScanResult({@required Map<dynamic, dynamic> result})
      : this.ssid = result["ssid"],
        this.bssid = result["bssid"],
        this.level = result["level"],
        this.timestamp = result["timestamp"];
}

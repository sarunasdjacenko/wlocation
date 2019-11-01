import 'package:flutter/foundation.dart';
import 'dart:math';

/// Scan Result object, containing relevant information from the scan.
class ScanResult {
  final String ssid;
  final String bssid;
  final int frequency;
  final int level;
  final int levelpct;
  double distance;

  ScanResult({@required Map<dynamic, dynamic> result})
      : this.ssid = result["ssid"],
        this.bssid = result["bssid"],
        this.frequency = result["frequency"],
        this.level = result["level"],
        this.levelpct = result["levelpct"] + 1 {
    this.distance = pow(10, ((-40) - this.level) / 20);
  }
}

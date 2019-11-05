import 'package:flutter/foundation.dart';
import 'dart:math';

/// Scan Result object, containing relevant information from the scan.
class ScanResult {
  final String ssid;
  final String bssid;
  final int frequency;
  final int level;
  final int levelpct;

  /// The speed of light in a vacuum.
  static const int _kSpeedOfLight = 299792458;
  /// 4π/c. Convert GHz to Hz (* 1000), and km to m (* 1000).
  static const double _kConstant = (4*pi/_kSpeedOfLight) * 1000 * 1000;
  /// The estimated distance to the access point.
  double distance;

  ScanResult({@required Map<dynamic, dynamic> result})
      : this.ssid = result["ssid"],
        this.bssid = result["bssid"],
        this.frequency = result["frequency"],
        this.level = result["level"],
        this.levelpct = result["levelpct"] + 1 {
    /// Set the distance, using a rearranged form of the Free-Space Path Loss.
    distance = pow(10, -level/20) / (frequency * _kConstant);
  }
}

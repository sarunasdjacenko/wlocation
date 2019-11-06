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
  /// 4π/c. Convert [frequency] measurement from MHz to Hz.
  static const double _kConstant = (4*pi/_kSpeedOfLight) * 1000000;
  /// The estimated [distance] to the access point.
  double distance;

  /// Store the result of the scan.
  /// Calculate [distance], with ideas from Friis' transmission equation.
  /// Derivation to this form is shown in the report.
  ScanResult({@required Map<dynamic, dynamic> result})
      : this.ssid = result["ssid"],
        this.bssid = result["bssid"],
        this.frequency = result["frequency"],
        this.level = result["level"],
        this.levelpct = result["levelpct"] + 1 {
    distance = pow(10, -level/20) / (frequency * _kConstant);
  }
}

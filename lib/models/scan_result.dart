import 'dart:math';
import 'package:flutter/foundation.dart';

/// Scan Result object, containing relevant information from the scan
class ScanResult {
  /// The identifier of the access point
  final String bssid;

  /// The estimated distance to the access point
  double distance;

  /// The speed of light in a vacuum, in m/s
  static const int _kSpeedOfLight = 299792458;

  /// "4π/c" and convert frequency from MHz to Hz
  static const double _kMultiplier = _kSpeedOfLight / (4 * pi * 1000000);

  /// Calculate [distance] if it is not given
  /// Derivation from Friis' transmission equation is shown in the report
  ScanResult({@required Map<dynamic, dynamic> result})
      : this.bssid = result['bssid'] {
    distance = result['distance'] ??
        pow(10, -result['level'] / 20) * _kMultiplier / result['frequency'];
  }
}

import 'dart:math';
import 'package:flutter/foundation.dart';

/// Scan Result object, containing relevant information from the scan
class ScanResult implements MapEntry {
  final String key;
  final double value;

  /// The bssid of the access point
  String get bssid => key;

  /// The estimated distance to the access point
  double get distance => value;

  /// The speed of light in a vacuum, in m/s
  static const int _kSpeedOfLight = 299792458;

  /// c / 4π,  and convert frequency from MHz to Hz
  static const double _kMultiplier = _kSpeedOfLight / (4 * pi * 1000000);

  /// Calculate the distance if it is not given
  /// Derivation from Friis' transmission equation is shown in the report
  ScanResult({@required Map<dynamic, dynamic> result})
      : this.key = result['bssid'],
        this.value = result['distance'] ??
            pow(10, -result['level'] / 20) * _kMultiplier / result['frequency'];
}

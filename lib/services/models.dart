import 'dart:math';

import 'package:flutter/material.dart';

class PositionData implements MapEntry<Offset, double> {
  final Offset key;
  final double value;

  /// The position to be evaluated.
  Offset get position => key;

  /// The evaluation of the position.
  double get evaluation => value;

  /// Constructor for [PositionData].
  PositionData(this.key, this.value);
}

class ScanData implements MapEntry<String, double> {
  /// The speed of light in a vacuum, in m/s.
  static const int _kSpeedOfLight = 299792458;

  /// c / 4π,  and convert frequency from MHz to Hz.
  static const double _kMultiplier = _kSpeedOfLight / (4 * pi * 1000000);

  final String key;
  final double value;

  /// The bssid of the access point.
  String get bssid => key;

  /// The estimated distance to the access point.
  double get distance => value;

  /// Constructor for [ScanData].
  ScanData(this.key, this.value);

  /// Creates a [ScanData] object from a [Map].
  /// Distance is derived from Friis' transmission equation.
  factory ScanData.fromMap(Map data) {
    return ScanData(
        data['bssid'],
        data['distance'] ??
            pow(10, -data['level'] / 20) * _kMultiplier / data['frequency']);
  }
}

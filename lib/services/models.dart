import 'dart:math';

import 'package:flutter/material.dart';

extension Position on Offset {
  /// Creates an [Offset] from a [Map].
  static Offset fromMap(Map data) {
    return Offset(data['x'], data['y']);
  }
}

extension PositionEvaluation on MapEntry<Offset, double> {
  /// The position to be evaluated.
  Offset get position => key;

  /// The evaluation of the position.
  double get evaluation => value;
}

extension ScanResult on MapEntry<String, double> {
  /// The speed of light in a vacuum, in m/s.
  static const int _kSpeedOfLight = 299792458;

  /// c / 4π,  and convert frequency from MHz to Hz.
  static const double _kMultiplier =
      ScanResult._kSpeedOfLight / (4 * pi * 1000000);

  /// The bssid of the access point.
  String get bssid => key;

  /// The estimated distance to the access point.
  double get distance => value;

  /// Creates a [MapEntry] with key bssid, value distance.
  /// Distance is derived from Friis' transmission equation.
  static MapEntry<String, double> fromMap(Map data) => MapEntry(data['bssid'],
      pow(10, -data['level'] / 20) * _kMultiplier / data['frequency']);
}

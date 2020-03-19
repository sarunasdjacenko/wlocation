import 'package:flutter/material.dart';

import 'math_functions.dart';

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
  final String key;
  final double value;

  /// The bssid of the access point.
  String get bssid => key;

  /// The estimated distance to the access point.
  double get distance => value;

  /// Constructor for [ScanData].
  ScanData(this.key, this.value);

  /// Creates a [ScanData] object from a [Map].
  factory ScanData.fromMap(Map data) {
    return ScanData(
      data['bssid'],
      data['distance'] ??
          MathFunctions.friisDistance(data['level'], data['frequency']),
    );
  }
}

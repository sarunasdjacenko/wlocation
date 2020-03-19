import 'dart:math';

import 'package:flutter/material.dart';

class MathFunctions {
  /// The speed of light in a vacuum, in m/s.
  static const int speedOfLight = 299792458;

  /// The radius of earth, in m.
  static const radiusOfEarth = 6371000;

  /// Finds the line of best fit, using the method of least squares.
  static Map<String, double> lineOfBestFit(List<Offset> data) {
    final means =
        data.reduce((sum, pair) => sum + pair) / data.length.toDouble();

    // Calculates Sxx and Sxy.
    final sumOfDifferences = data.fold(Offset.zero, (sum, pair) {
      final x = pair.dx - means.dx;
      final y = pair.dy - means.dy;
      return sum + Offset(pow(x, 2), x * y);
    });

    final gradient = sumOfDifferences.dy / sumOfDifferences.dx;
    final intercept = means.dy - gradient * means.dx;
    return {'gradient': gradient, 'intercept': intercept};
  }

  /// Takes [Offset] objects, in the form Offset(longitude, latitude).
  /// Returns the haversine distance in metres.
  static double haversineDistance(Offset locationOne, Offset locationTwo) {
    Offset degreesToRadians(Offset offset) => offset * pi / 180;

    final locOne = degreesToRadians(locationOne);
    final locTwo = degreesToRadians(locationTwo);
    final delta = locOne - locTwo;
    // Haversine function.
    final a = pow(sin(delta.dy / 2), 2) +
        cos(locOne.dx) * cos(locTwo.dx) * pow(sin(delta.dx / 2), 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return radiusOfEarth * c;
  }

  /// Distance is derived from Friis' transmission equation.
  static double friisDistance(int rssi, int frequency) =>
      pow(10, -rssi / 20) * speedOfLight / (4 * pi * frequency * 1000000);
}

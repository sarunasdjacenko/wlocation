import 'dart:math';
import 'package:flutter/material.dart';

class LocationFinder {
  /// Find user location using best mean square difference
  /// between the scan results and the fingerprints.
  static Offset bestMeanSquareDifference({
    @required Map wifiResults,
    @required Map fingerprints,
  }) {
    var bestLocationMatch, bestLocationMatchScore = double.infinity;
    fingerprints?.forEach((location, results) {
      var score = 0.0;
      results.forEach((result) =>
          score += pow(wifiResults[result.bssid] - result.distance, 2));
      score /= results.length;
      if (score < bestLocationMatchScore) {
        bestLocationMatchScore = score;
        bestLocationMatch = location;
      }
    });
    return bestLocationMatch;
  }
}

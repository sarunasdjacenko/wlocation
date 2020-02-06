import 'dart:math';
import 'package:flutter/material.dart';

class LocationFinder {
  /// Evaluation for k-nearest neighbours regression, using Euclidean distance.
  static double _meanSquaredError(Map wifiResults, List data) {
    var sumSquaredError = 0.0;
    data.forEach((result) =>
        sumSquaredError += pow(wifiResults[result.bssid] - result.distance, 2));
    return sumSquaredError /= data.length;
  }

  /// Algorithm for weighted k-nearest neighbours algorithm.
  /// Equivalent to k-nearest neighbours when weightFunction is constant.
  static Offset _wknnRegressionAlgorithm(
    Map wifiResults,
    Map fingerprints,
    int k, {
    @required Function weightFunction,
  }) {
    final dataset = fingerprints?.map((position, data) =>
        MapEntry(position, _meanSquaredError(wifiResults, data)));
    // Sort dataset with evaluation function, and take the k-nearest neighbours.
    final neighbours = (dataset.entries.toList(growable: false)
          ..sort((curr, next) => curr.value.compareTo(next.value)))
        .take(k);
    if (neighbours.isNotEmpty) {
      // Find the sum of weighted positions, and the sum of weights.
      var sumOfWeightedPositions = Offset.zero, sumOfWeights = 0.0;
      neighbours.forEach((neighbour) {
        final weight = weightFunction(neighbour.value);
        sumOfWeightedPositions += neighbour.key * weight;
        sumOfWeights += weight;
      });
      // Return the mean weighted position.
      return sumOfWeightedPositions / sumOfWeights;
    }
    return null;
  }

  /// Find user position using k-nearest neighbours regression.
  static Offset knnRegression({
    @required Map wifiResults,
    @required Map fingerprints,
    @required int k,
  }) =>
      _wknnRegressionAlgorithm(wifiResults, fingerprints, k,
          weightFunction: (evaluation) => 1.0);

  /// Find user position using weighted k-nearest neighbours regression.
  static Offset wknnRegression({
    @required Map wifiResults,
    @required Map fingerprints,
    @required int k,
  }) =>
      _wknnRegressionAlgorithm(wifiResults, fingerprints, k,
          weightFunction: (evaluation) => 1.0 / evaluation);
}

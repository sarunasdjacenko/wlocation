import 'dart:math';

import 'package:flutter/material.dart';

class MachineLearning {
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

  /// Evaluation for k-nearest neighbours regression, using Euclidean distance.
  static double meanSquaredError(Map wifiResults, List data) {
    var sumSquaredError = 0.0;
    data.forEach((result) =>
        sumSquaredError += pow(wifiResults[result.bssid] - result.distance, 2));
    return sumSquaredError /= data.length;
  }

  /// Algorithm for weighted k-nearest neighbours algorithm.
  /// Equivalent to k-nearest neighbours when weightFunction is constant.
  static Offset _wknnRegressionAlgorithm(
    Map dataset,
    int kNeighbours, {
    Function weightFunction,
  }) {
    // Sort dataset with evaluation function, and take the k-nearest neighbours.
    final neighbours = (dataset.entries.toList(growable: false)
          ..sort((curr, next) => curr.value.compareTo(next.value)))
        .take(kNeighbours);
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
  static Offset knnRegression({Map dataset, int kNeighbours}) =>
      _wknnRegressionAlgorithm(dataset, kNeighbours,
          weightFunction: (evaluation) => 1.0);

  /// Find user position using weighted k-nearest neighbours regression.
  static Offset wknnRegression({Map dataset, int kNeighbours}) =>
      _wknnRegressionAlgorithm(dataset, kNeighbours,
          weightFunction: (evaluation) => 1.0 / evaluation);
}

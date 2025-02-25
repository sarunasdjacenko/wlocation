import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/services.dart';
import 'map_screen_admin.dart';
import 'map_screen_user.dart';

class MapScreen extends StatelessWidget {
  final String venueId;
  final String locationId;
  final String locationName;

  /// Constructor for the [MapScreen] class.
  MapScreen({
    @required this.venueId,
    @required this.locationId,
    @required this.locationName,
  });

  /// Returns the [MapMarkerData] from the widget tree.
  static MapMarkerData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MapMarkerData>();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return user.isAdmin
        ? AdminMapScreen(venueId, locationId, locationName)
        : UserMapScreen(venueId, locationId, locationName);
  }
}

abstract class BaseMapScreen extends StatefulWidget {
  final String venueId;
  final String locationId;
  final String locationName;

  /// Constructor for the [BaseMapScreen] class.
  BaseMapScreen(this.venueId, this.locationId, this.locationName);
}

abstract class BaseMapScreenState extends State<BaseMapScreen> {
  /// The k to use in k-nearest neighbours.
  static const _kNearestNeighbours = 3;

  // URL of the map image.
  Future<String> mapImageUrl;

  /// [Map] of (bssid => distance) for each access point scanned.
  Map wifiResults = {};

  /// [Offset] of a marker on the image, chosen by the user.
  Offset chosenMarkerOffset;

  /// [Offset] of a marker on the image, predicted with Machine Learning.
  Offset predictedMarkerOffset;

  /// Abstract method used to set a marker offset. Activated on tap.
  void setMarkerOffset(Offset newMarkerOffset);

  /// Scans Wi-Fi. Gets the fingerprints from the database,
  /// which match the scanned access points.
  Future<Map> _getFingerprints() async {
    var fingerprints;
    final newWifiResults = await WifiScanner.getWifiResults();
    if (!mapEquals(wifiResults, newWifiResults)) {
      wifiResults = newWifiResults;
      fingerprints = await Database.getFingerprints(
        venueId: widget.venueId,
        locationId: widget.locationId,
        bssids: wifiResults.keys,
      );
    }
    return fingerprints;
  }

  /// Finds the user's location using Weighted K-Nearest Neighbours.
  Future<Offset> findUserGeolocation() async {
    var bestLocationMatch;
    final fingerprints = await _getFingerprints();
    final dataset = fingerprints?.map((position, data) => MapEntry(
        position, MachineLearning.meanSquaredError(wifiResults, data)));
    if (dataset != null) {
      bestLocationMatch = MachineLearning.wknnRegression(
        dataset: dataset,
        kNeighbours: _kNearestNeighbours,
      );
    }
    return bestLocationMatch;
  }

  /// Converts an image offset to a geo offset.
  Future<Offset> imageOffsetToGeoOffset(Offset offset) async {
    double calculate(double coordinate, Map equation) {
      final gradient = equation['gradient'];
      final intercept = equation['intercept'];
      return coordinate * gradient + intercept;
    }

    var geoOffset;
    final calibration = await Database.getMapCalibration(
      venueId: widget.venueId,
      locationId: widget.locationId,
    );
    if (calibration != null) {
      final longitude = calculate(offset.dx, calibration['longitude']);
      final latitude = calculate(offset.dy, calibration['latitude']);
      geoOffset = Offset(longitude, latitude);
    }
    return geoOffset;
  }

  /// Converts a geo offset to an image offset.
  Future<Offset> geoOffsetToImageOffset(Offset geopoint) async {
    double calculate(double coordinate, Map equation) {
      final gradient = equation['gradient'];
      final intercept = equation['intercept'];
      return (coordinate - intercept) / gradient;
    }

    var imageOffset;
    final calibration = await Database.getMapCalibration(
      venueId: widget.venueId,
      locationId: widget.locationId,
    );
    if (calibration != null) {
      final x = calculate(geopoint.dx, calibration['longitude']);
      final y = calculate(geopoint.dy, calibration['latitude']);
      imageOffset = Offset(x, y);
    }
    return imageOffset;
  }

  /// Initialises the state, and retrieves the map image from [FirebaseStorage].
  @override
  void initState() {
    super.initState();
    mapImageUrl = Database.getMapUrl(
      widget.venueId,
      widget.locationId,
    );
  }
}

class MapMarkerData extends InheritedWidget {
  /// [Offset] of a marker on the image, chosen by the admin.
  final Offset chosenMarkerOffset;

  /// [Offset] of a marker on the image, predicted with Machine Learning.
  final Offset predictedMarkerOffset;

  /// Callback used to set [chosenMarkerOffset] or [predictedMarkerOffset].
  final ValueChanged<Offset> setMarkerOffset;

  /// Constructor for the [MapMarkerData] class.
  MapMarkerData({
    @required Widget child,
    @required this.predictedMarkerOffset,
    this.chosenMarkerOffset,
    this.setMarkerOffset,
  }) : super(child: child);

  @override
  bool updateShouldNotify(MapMarkerData old) =>
      chosenMarkerOffset != old.chosenMarkerOffset ||
      predictedMarkerOffset != old.predictedMarkerOffset;
}

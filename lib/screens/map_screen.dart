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

  MapScreen({
    @required this.venueId,
    @required this.locationId,
    @required this.locationName,
  });

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

  BaseMapScreen(this.venueId, this.locationId, this.locationName);
}

abstract class BaseMapScreenState extends State<BaseMapScreen> {
  /// The k to use in k-nearest neighbours.
  static const _kNearestNeighbours = 3;

  // URL of the map image.
  Future<String> mapImageUrl;

  /// [Map] of (bssid => distance) for each access point scanned.
  Map wifiResults = {};

  /// [Offset] of the marker on the image.
  Offset markerOffsetOnImage;

  void setMarkerOffsetOnImage(Offset newMarkerOffsetOnImage) =>
      setState(() => markerOffsetOnImage = newMarkerOffsetOnImage);

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

  Future<Offset> offsetOnImageToGeoOffset(Offset offset) async {
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

  Future<Offset> geoOffsetToOffsetOnImage(Offset geopoint) async {
    double calculate(double coordinate, Map equation) {
      final gradient = equation['gradient'];
      final intercept = equation['intercept'];
      return (coordinate - intercept) / gradient;
    }

    var offsetOnImage;
    final calibration = await Database.getMapCalibration(
      venueId: widget.venueId,
      locationId: widget.locationId,
    );
    if (calibration != null) {
      final x = calculate(geopoint.dx, calibration['longitude']);
      final y = calculate(geopoint.dy, calibration['latitude']);
      offsetOnImage = Offset(x, y);
    }
    return offsetOnImage;
  }

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
  /// [Offset] of the marker on the image.
  final Offset markerOffsetOnImage;
  final ValueChanged<Offset> setMarkerOffsetOnImage;

  MapMarkerData({
    @required Widget child,
    @required this.markerOffsetOnImage,
    this.setMarkerOffsetOnImage,
  }) : super(child: child);

  @override
  bool updateShouldNotify(MapMarkerData old) =>
      markerOffsetOnImage != old.markerOffsetOnImage;
}

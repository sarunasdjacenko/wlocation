import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/components.dart';
import '../services/services.dart';

class MapScreen extends StatefulWidget {
  final String venueId;
  final String locationId;
  final String locationName;

  MapScreen({
    @required this.venueId,
    @required this.locationId,
    @required this.locationName,
  });

  factory MapScreen.fromMap(String venueId, Map location) {
    return MapScreen(
      venueId: venueId,
      locationId: location['id'],
      locationName: location['name'],
    );
  }

  static _MarkerData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_MarkerData>();

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  /// The k to use in k-nearest neighbours.
  final int _kNearestNeighbours = 3;

  /// [Map] of (bssid => distance) for each access point scanned.
  Map _wifiResults = {};

  /// [Offset] of the marker on the image.
  Offset _markerOffsetOnImage;

  void _setMarkerOffsetOnImage(Offset markerOffsetOnImage) =>
      setState(() => _markerOffsetOnImage = markerOffsetOnImage);

  void _addFingerprints() async {
    if (_markerOffsetOnImage != null) {
      final wifiResults = await WifiScanner.getWifiResults();
      if (!mapEquals(wifiResults, _wifiResults)) {
        _wifiResults = wifiResults;
        Database.addFingerprints(
          venue: widget.venueId,
          location: widget.locationId,
          scanResults: _wifiResults,
          markerOffsetOnImage: _markerOffsetOnImage,
        );
      }
    }
  }

  Future<Map> _getFingerprints() async {
    var fingerprints;
    final wifiResults = await WifiScanner.getWifiResults();
    if (!mapEquals(wifiResults, _wifiResults)) {
      _wifiResults = wifiResults;
      fingerprints = await Database.getFingerprints(
        venue: widget.venueId,
        location: widget.locationId,
        bssids: _wifiResults.keys,
      );
    }
    return fingerprints;
  }

  void _findUserLocation() async {
    final fingerprints = await _getFingerprints();
    final dataset = fingerprints?.map((position, data) => MapEntry(
        position, LocationFinder.meanSquaredError(_wifiResults, data)));
    final bestLocationMatch = LocationFinder.wknnRegression(
      dataset: dataset,
      kNeighbours: _kNearestNeighbours,
    );
    _setMarkerOffsetOnImage(bestLocationMatch);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.locationName)),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Container(height: 34),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 3.0,
        child: const Icon(Icons.wifi, size: 35),
        onPressed: () =>
            user.isSignedIn ? _addFingerprints() : _findUserLocation(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _MarkerData(
          markerOffsetOnImage: _markerOffsetOnImage,
          setMarkerOffsetOnImage: _setMarkerOffsetOnImage,
          child: MapView(image: AssetImage('assets/BH7.jpg')),
        ),
      ),
    );
  }
}

class _MarkerData extends InheritedWidget {
  /// [Offset] of the marker on the image.
  final Offset markerOffsetOnImage;
  final ValueChanged<Offset> setMarkerOffsetOnImage;

  _MarkerData({
    @required Widget child,
    @required this.markerOffsetOnImage,
    this.setMarkerOffsetOnImage,
  }) : super(child: child);

  @override
  bool updateShouldNotify(_MarkerData old) =>
      markerOffsetOnImage != old.markerOffsetOnImage;
}

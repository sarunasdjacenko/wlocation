import 'package:flutter/material.dart';
import 'package:wlocation/components/custom_floating_action_button.dart';
import 'package:wlocation/components/custom_scaffold.dart';
import 'package:wlocation/components/map_view.dart';
import 'package:wlocation/components/user_provider.dart';
import 'package:wlocation/models/location_finder.dart';
import 'package:wlocation/services/database.dart';
import 'package:wlocation/services/wifi_scanner.dart';

class MapScreen extends StatefulWidget {
  final String venue;
  final String location;

  MapScreen({@required this.venue, @required this.location});

  static _MarkerData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_MarkerData>();

  @override
  State<StatefulWidget> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
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
      if (wifiResults != _wifiResults) {
        _wifiResults = wifiResults;
        Database.addFingerprints(
          venue: widget.venue,
          location: widget.location,
          scanResults: _wifiResults,
          markerOffsetOnImage: _markerOffsetOnImage,
        );
      }
    }
  }

  Future<Map> _getFingerprints() async {
    var fingerprints;
    final wifiResults = await WifiScanner.getWifiResults();
    if (_wifiResults != wifiResults) {
      _wifiResults = wifiResults;
      fingerprints = await Database.getFingerprints(
        venue: widget.venue,
        location: widget.location,
        bssids: _wifiResults.keys,
      );
    }
    return fingerprints;
  }

  void _findUserLocation() async {
    final fingerprints = await _getFingerprints();
    final bestLocationMatch = LocationFinder.wknnRegression(
      wifiResults: _wifiResults,
      fingerprints: fingerprints,
      k: _kNearestNeighbours,
    );
    _setMarkerOffsetOnImage(bestLocationMatch);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backEnabled: true,
      scanButton: CustomFloatingActionButton(
        onPressed: UserProvider.of(context).isSignedIn()
            ? _addFingerprints
            : _findUserLocation,
      ),
      body: _MarkerData(
        markerOffsetOnImage: _markerOffsetOnImage,
        setMarkerOffsetOnImage: _setMarkerOffsetOnImage,
        child: MapView(image: AssetImage('assets/BH7.jpg')),
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

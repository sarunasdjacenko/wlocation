import 'package:flutter/material.dart';
import 'package:wlocation/components/custom_floating_action_button.dart';
import 'package:wlocation/components/custom_scaffold.dart';
import 'package:wlocation/components/map_view.dart';
import 'package:wlocation/components/user_provider.dart';
import 'package:wlocation/models/location_finder.dart';
import 'package:wlocation/services/database.dart';
import 'package:wlocation/services/wifi_scanner.dart';

class MapScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
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
        Database.addFingerprints(_wifiResults, _markerOffsetOnImage);
      }
    }
  }

  Future<Map> _getFingerprints() async {
    var fingerprints;
    final wifiResults = await WifiScanner.getWifiResults();
    if (_wifiResults != wifiResults) {
      _wifiResults = wifiResults;
      fingerprints = await Database.getFingerprints(_wifiResults.keys);
    }
    return fingerprints;
  }

  void _findUserLocation() async {
    final fingerprints = await _getFingerprints();
    final bestLocationMatch = LocationFinder.bestMeanSquaredError(
      wifiResults: _wifiResults,
      fingerprints: fingerprints,
    );
    setState(() => _markerOffsetOnImage = bestLocationMatch);
  }

  @override
  Widget build(BuildContext context) {
    // if (!UserProvider.of(context).isSignedIn()) {
    //   _markerOffsetOnImage = null;
    // }
    return CustomScaffold(
      backEnabled: true,
      scanButton: CustomFloatingActionButton(
        onPressed: UserProvider.of(context).isSignedIn()
            ? _addFingerprints
            : _findUserLocation,
      ),
      body: MapView(
        image: AssetImage('assets/BH7.jpg'),
        markerOffsetOnImage: _markerOffsetOnImage,
        setMarkerOffsetOnImage: _setMarkerOffsetOnImage,
      ),
    );
  }
}

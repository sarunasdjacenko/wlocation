import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/components.dart';
import '../services/services.dart';
import 'map_screen.dart';

class UserMapScreen extends BaseMapScreen {
  UserMapScreen(String venueId, String locationId, String locationName)
      : super(venueId, locationId, locationName);

  @override
  State<StatefulWidget> createState() => _UserMapScreenState();
}

class _UserMapScreenState extends BaseMapScreenState {
  /// The k to use in k-nearest neighbours.
  static const _kNearestNeighbours = 3;

  RestartableTimer _scanTimer;

  @override
  void initState() {
    super.initState();
    final scanFrequency =
        Provider.of<ScanFrequency>(context, listen: false).frequency;
    _scanTimer = RestartableTimer(scanFrequency, _updateUserLocation);
    _updateUserLocation();
  }

  @override
  void dispose() {
    _scanTimer.cancel();
    super.dispose();
  }

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

  void _updateUserLocation() async {
    _scanTimer.reset();
    final fingerprints = await _getFingerprints();
    final dataset = fingerprints?.map((position, data) => MapEntry(
        position, MachineLearning.meanSquaredError(wifiResults, data)));
    if (dataset != null) {
      final bestLocationMatch = MachineLearning.wknnRegression(
        dataset: dataset,
        kNeighbours: _kNearestNeighbours,
      );
      if (_scanTimer.isActive) setMarkerOffsetOnImage(bestLocationMatch);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.locationName),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: mapImageUrl,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(child: CircularProgressIndicator());

            if (!snapshot.hasData)
              return Center(
                child: Text(
                  'Map not available.\nPlease try again later.',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              );

            return MapMarkerData(
              markerOffsetOnImage: markerOffsetOnImage,
              setMarkerOffsetOnImage: setMarkerOffsetOnImage,
              child: MapView(image: NetworkImage(snapshot.data)),
            );
          },
        ),
      ),
    );
  }
}

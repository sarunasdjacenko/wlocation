import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:wlocation/components/map_view.dart';
import 'package:wlocation/models/scan_result.dart';
import 'package:wlocation/services/database.dart';
import 'package:wlocation/services/wifi_scanner.dart';

class MapScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  /// Set [Duration] between each WiFi scan.
  // static const _scanWaitTime = const Duration(seconds: 30);

  /// [RestartableTimer] used to scan for Wifi every [_scanWaitTime] seconds.
  // RestartableTimer _scanTimer;

  /// [List] of [ScanResult] obtained with each WiFi scan.
  List<ScanResult> _wifiResults = [];

  /// Offset of the marker on the image
  Offset _markerOffsetOnImage;

  // @override
  // void initState() {
  // super.initState();
  //   _scanTimer = RestartableTimer(_scanWaitTime, () => _scanWifi());
  // }

  /// Scan WiFi, and restart the timer.
  void _scanWifi() async {
    // _scanTimer.reset();
    List<ScanResult> wifiResults = await WifiScanner.getWifiResults();
    setState(() => _wifiResults = wifiResults);
    Database.addFingerprints(_wifiResults, _markerOffsetOnImage);
  }

  void markerCallback(Offset markerOffsetOnImage) =>
      _markerOffsetOnImage = markerOffsetOnImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.wifi),
            onPressed: _scanWifi,
          )
        ],
      ),
      body: MapView(
        image: AssetImage('assets/BH7.jpg'),
        callback: markerCallback,
      ),
    );
  }
}

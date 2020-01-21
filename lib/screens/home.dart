import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:wlocation/components/map_view.dart';
import 'package:wlocation/models/scan_result.dart';
import 'package:wlocation/services/wifi_scanner.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Set [Duration] between each WiFi scan.
  static const _scanWaitTime = const Duration(seconds: 30);

  /// [RestartableTimer] used to scan for Wifi every [_scanWaitTime] seconds.
  RestartableTimer _scanTimer;

  /// [List] of [ScanResult] obtained with each WiFi scan.
  List<ScanResult> _wifiResults = [];

  @override
  void initState() {
    super.initState();
    _scanTimer = RestartableTimer(_scanWaitTime, () => _scanWifi());
  }

  /// Scan WiFi, and restart the timer.
  void _scanWifi() async {
    _scanTimer.reset();
    List<ScanResult> wifiResults = await WifiScanner.getWifiResults();
    setState(() => _wifiResults = wifiResults);
  }

  /// Create text widget for each part of a result in a wifi scan.
  Widget _textItem(String str) {
    return Text(str, style: Theme.of(context).textTheme.subhead);
  }

  /// Create expanded text widget for larger text.
  Widget _expandedTextItem(String str) {
    return Expanded(child: _textItem(str));
  }

  /// Create widget for each result in a wifi scan.
  Widget _rowItem(ScanResult result) {
    return Row(
      children: <Widget>[
        _expandedTextItem(
            '${result.level}, ${result.frequency}, ${result.bssid}, ${result.ssid}'),
        _textItem('distance: ${result.distance.toStringAsFixed(3)}m'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: MapView(),
    );
  }
}

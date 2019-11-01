import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wifi_location/models/scan_result.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Make app full screen for presentation screenshots.
    // SystemChrome.setEnabledSystemUIOverlays([]);

    return MaterialApp(
      // Hide debug banner for presentation screenshots.
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// [MethodChannel] on which to invoke native methods.
  static const _platform = const MethodChannel('sarunasdjacenko.com/wifi_scan');

  /// [List] of [ScanResult] obtained with each WiFi scan.
  List<ScanResult> _wifiResults = [];

  /// Set [Duration] between each WiFi scan.
  static const _scanWaitTime = const Duration(seconds: 30);

  /// [RestartableTimer] used to scan for Wifi every [_scanWaitTime] seconds.
  RestartableTimer _scanTimer;

  @override
  void initState() {
    super.initState();
    _scanTimer = RestartableTimer(_scanWaitTime, () => _getWifiResults());
    _getWifiResults();
  }

  /// Invokes native method to scan for WiFi using, and adds results to a list.
  /// This is only implemented in Android (Kotlin) due to iOS limitations.
  Future<void> _getWifiResults() async {
    _scanTimer.reset();
    List<Map<dynamic, dynamic>> wifiResults;
    try {
      wifiResults = await _platform.invokeListMethod('getWifiResults');
    } on PlatformException {
      wifiResults = [];
    }

    setState(() {
      _wifiResults =
          wifiResults.map((result) => ScanResult(result: result)).toList();
    });
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
    if (result.ssid != 'eduroam') return Container();
    return Row(
      children: <Widget>[
        _expandedTextItem(
            '${result.ssid}, ${result.frequency}Hz, ${result.level}dB, ${result.levelpct}%'),
        _textItem('distance: ${result.distance.toStringAsFixed(3)}m'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: _wifiResults.length,
          itemBuilder: (BuildContext context, int index) {
            return _rowItem(_wifiResults[index]);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getWifiResults,
        tooltip: 'Increment',
        child: Icon(Icons.search),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

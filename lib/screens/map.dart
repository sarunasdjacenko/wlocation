import 'package:flutter/material.dart';
import 'package:wlocation/components/custom_floating_action_button.dart';
import 'package:wlocation/components/custom_scaffold.dart';
import 'package:wlocation/components/map_view.dart';

class MapScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  /// [Offset] of the marker on the image
  Offset _markerOffsetOnImage;

  void _markerCallback(Offset markerOffsetOnImage) {
      _markerOffsetOnImage = markerOffsetOnImage;
      print(_markerOffsetOnImage);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backEnabled: true,
      scanButton: CustomFloatingActionButton(
        onPressed: () => print('CustomFloatingActionButton'),
      ),
      body: MapView(
        image: AssetImage('assets/BH7.jpg'),
        callback: _markerCallback,
      ),
    );
  }
}

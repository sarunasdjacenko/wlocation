import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/components.dart';
import 'map_screen.dart';

class UserMapScreen extends BaseMapScreen {
  UserMapScreen(String venueId, String locationId, String locationName)
      : super(venueId, locationId, locationName);

  @override
  State<StatefulWidget> createState() => _UserMapScreenState();
}

class _UserMapScreenState extends BaseMapScreenState {
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

  void _updateUserLocation() async {
    _scanTimer.reset();
    final bestLocationMatch = await findUserGeolocation();
    final offsetOnImage = await geoOffsetToOffsetOnImage(bestLocationMatch);
    if (_scanTimer.isActive) setMarkerOffsetOnImage(offsetOnImage);
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

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/components.dart';
import 'map_screen.dart';

class UserMapScreen extends BaseMapScreen {
  /// Constructor for the [UserMapScreen] class.
  UserMapScreen(String venueId, String locationId, String locationName)
      : super(venueId, locationId, locationName);

  @override
  State<StatefulWidget> createState() => _UserMapScreenState();
}

class _UserMapScreenState extends BaseMapScreenState {
  /// Timer, used to scan every X duration.
  RestartableTimer _scanTimer;

  /// Updates the user location on the map.
  void _updateUserLocation() async {
    _scanTimer.reset();
    final bestLocationMatch = await findUserGeolocation();
    if (bestLocationMatch != null) {
      final imageOffset = await geoOffsetToImageOffset(bestLocationMatch);
      if (_scanTimer.isActive) setMarkerOffset(imageOffset);
    }
  }

  @override
  void setMarkerOffset(Offset newMarkerOffset) =>
      setState(() => predictedMarkerOffset = newMarkerOffset);

  /// Initialises the state, and starts the scan timer.
  @override
  void initState() {
    super.initState();
    final scanFrequency =
        Provider.of<ScanFrequency>(context, listen: false).frequency;
    _scanTimer = RestartableTimer(scanFrequency, _updateUserLocation);
    _updateUserLocation();
  }

  /// Disposes the state when it is no longer needed.
  @override
  void dispose() {
    _scanTimer.cancel();
    super.dispose();
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
              predictedMarkerOffset: predictedMarkerOffset,
              setMarkerOffset: setMarkerOffset,
              child: MapView(image: NetworkImage(snapshot.data)),
            );
          },
        ),
      ),
    );
  }
}

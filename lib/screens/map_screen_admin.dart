import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../components/components.dart';
import '../services/services.dart';
import 'map_screen.dart';

class AdminMapScreen extends BaseMapScreen {
  AdminMapScreen(String venueId, String locationId, String locationName)
      : super(venueId, locationId, locationName);

  @override
  State<StatefulWidget> createState() => _AdminMapScreenState();
}

class _AdminMapScreenState extends BaseMapScreenState {
  bool _calibrationEnabled = false;
  final List<Map> _calibrationList = [];

  void _toggleCalibration(BuildContext context, {bool isComplete = false}) {
    _calibrationList.clear();
    setState(() => _calibrationEnabled = !_calibrationEnabled);
    showSnackBar(
      context,
      isComplete
          ? 'Calibration Complete'
          : _calibrationEnabled
              ? 'Calibration Enabled. Add 3 Calibration Points.'
              : 'Calibration Disabled',
    );
  }

  void _addCalibrationPoint(BuildContext context) async {
    final marker = markerOffsetOnImage;
    if (marker == null)
      showSnackBar(context, 'Select Your Location');
    else {
      final geopoint = await WifiScanner.getCurrentLocation();
      if (geopoint == null)
        showSnackBar(context, 'Please Try Again');
      else {
        _calibrationList.add({'marker': marker, 'geopoint': geopoint});
        showSnackBar(context, 'Calibration Point Added');
        setState(() {});
      }
    }
  }

  void _calibrateGeolocation(BuildContext context) async {
    var longitudes = <Offset>[], latitudes = <Offset>[];
    _calibrationList.forEach((entry) {
      longitudes.add(Offset(entry['marker'].dx, entry['geopoint'].longitude));
      latitudes.add(Offset(entry['marker'].dy, entry['geopoint'].latitude));
    });
    final lineLongitude = MachineLearning.lineOfBestFit(longitudes);
    final lineLatitude = MachineLearning.lineOfBestFit(latitudes);
    final line = {'latitude': lineLatitude, 'longitude': lineLongitude};
    Database.setCalibration(
      venueId: widget.venueId,
      locationId: widget.locationId,
      lineOfBestFit: line,
    );
    _toggleCalibration(context, isComplete: true);
  }

  void _addFingerprints() async {
    if (markerOffsetOnImage != null) {
      final newWifiResults = await WifiScanner.getWifiResults();
      if (!mapEquals(wifiResults, newWifiResults)) {
        wifiResults = newWifiResults;
        Database.addFingerprints(
          venueId: widget.venueId,
          locationId: widget.locationId,
          scanResults: wifiResults,
          markerOffsetOnImage: markerOffsetOnImage,
        );
      }
    }
  }

  void _uploadMapImage() async {
    final image = await ImagePicker.pickImage(source: ImageSource.gallery);
    Database.addMapImage(widget.venueId, widget.locationId, image).listen(
      (event) {
        if (event.type == StorageTaskEventType.success) {
          // Image uploaded, so get the URL, and trigger rebuild.
          mapImageUrl = Database.getMapUrl(
            widget.venueId,
            widget.locationId,
          );
          setState(() {});
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.locationName),
        actions: <Widget>[
          IconButton(
            tooltip: 'Calculate Error',
            icon: Icon(Icons.error_outline),
            onPressed: () => print('error'),
          ),
          Builder(
            builder: (context) => IconButton(
              tooltip: 'Calibrate GeoLocation',
              icon: Icon(Icons.gps_fixed),
              onPressed: () => _toggleCalibration(context),
            ),
          ),
          IconButton(
            tooltip: 'Add a Map Image',
            icon: Icon(Icons.add),
            onPressed: _uploadMapImage,
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Container(height: 34),
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
            elevation: 3.0,
            // child: Icon(Icons.wifi, size: 35),
            child: Icon(
              (_calibrationEnabled)
                  ? (_calibrationList.length < 3) ? Icons.add : Icons.done
                  : Icons.wifi,
              size: 35,
            ),
            onPressed: () {
              // if (_calibrationEnabled) {
              //   if (_calibrationList.length < 3) {
              //     _addCalibrationPoint();
              //   } else {
              //     _calibrateGeolocation(context);
              //     _toggleCalibration(context);
              //   }
              // } else {
              //   _addFingerprints();
              // }
              (_calibrationEnabled)
                  ? (_calibrationList.length < 3)
                      ? _addCalibrationPoint(context)
                      : _calibrateGeolocation(context)
                  : _addFingerprints();
            }),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SafeArea(
        child: FutureBuilder(
          future: mapImageUrl,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(child: CircularProgressIndicator());

            if (!snapshot.hasData)
              return Center(
                child: Text(
                  'Upload an image.',
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

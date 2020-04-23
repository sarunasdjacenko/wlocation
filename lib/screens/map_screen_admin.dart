import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../components/components.dart';
import '../services/services.dart';
import 'map_screen.dart';

class AdminMapScreen extends BaseMapScreen {
  /// Constructor for the [AdminMapScreen] class.
  AdminMapScreen(String venueId, String locationId, String locationName)
      : super(venueId, locationId, locationName);

  @override
  State<StatefulWidget> createState() => _AdminMapScreenState();
}

class _AdminMapScreenState extends BaseMapScreenState {
  /// True if the error calculation mode is enabled.
  bool _errorCalculationEnabled = false;

  /// True if the calibration mode is enabled.
  bool _calibrationEnabled = false;

  /// List of points to use in calibration.
  final List<Map> _calibrationList = [];

  /// Toggles the error calculation mode.
  void _toggleErrorCalculation(BuildContext context) {
    setState(() {
      if (_calibrationEnabled) _calibrationEnabled = false;
      chosenMarkerOffset = null;
      predictedMarkerOffset = null;
      _errorCalculationEnabled = !_errorCalculationEnabled;
    });
    showSnackBar(
      context,
      _errorCalculationEnabled
          ? 'Error calculation enabled. Select your location.'
          : 'Error calculation disabled.',
    );
  }

  /// Calculates the error.
  void _calculateError(BuildContext context) async {
    final marker = chosenMarkerOffset;
    if (marker == null)
      showSnackBar(context, 'Select your location');
    else {
      final chosenLocation = await imageOffsetToGeoOffset(marker);
      final predictedLocation = await findUserGeolocation();
      if (predictedLocation == null)
        showSnackBar(context, 'Failed to scan Wi-Fi. Try again later.');
      else {
        final bestImageOffset = await geoOffsetToImageOffset(predictedLocation);
        setState(() => predictedMarkerOffset = bestImageOffset);
        final errorDistance =
            MathFunctions.haversineDistance(chosenLocation, predictedLocation);
        showSnackBar(
          context,
          'The error is approximately ${errorDistance.toStringAsFixed(2)} m.',
        );
      }
    }
  }

  /// Toggles the calibration mode.
  void _toggleCalibration(BuildContext context, {bool isComplete = false}) {
    _calibrationList.clear();
    setState(() {
      if (_errorCalculationEnabled) _errorCalculationEnabled = false;
      chosenMarkerOffset = null;
      predictedMarkerOffset = null;
      _calibrationEnabled = !_calibrationEnabled;
    });
    showSnackBar(
      context,
      isComplete
          ? 'Calibration complete.'
          : _calibrationEnabled
              ? 'Calibration enabled. Add 3 calibration points.'
              : 'Calibration disabled.',
    );
  }

  /// Adds a calibration point.
  void _addCalibrationPoint(BuildContext context) async {
    final marker = chosenMarkerOffset;
    if (marker == null)
      showSnackBar(context, 'Select Your Location');
    else {
      final geopoint = await WifiScanner.getCurrentLocation();
      if (geopoint == null)
        showSnackBar(context, 'Failed to get location. Try again later.');
      else {
        _calibrationList.add({'marker': marker, 'geopoint': geopoint});
        showSnackBar(context, 'Calibration point added.');
        setState(() {});
      }
    }
  }

  /// Calibrates the map with GPS.
  void _calibrateGeolocation(BuildContext context) async {
    var longitudes = <Offset>[], latitudes = <Offset>[];
    _calibrationList.forEach((entry) {
      longitudes.add(Offset(entry['marker'].dx, entry['geopoint'].longitude));
      latitudes.add(Offset(entry['marker'].dy, entry['geopoint'].latitude));
    });
    final lineLongitude = MathFunctions.lineOfBestFit(longitudes);
    final lineLatitude = MathFunctions.lineOfBestFit(latitudes);
    if (lineLongitude['gradient'] == null || lineLatitude['gradient'] == null) {
      _calibrationList.clear();
      showSnackBar(context, 'Calibration failed. Try again later.');
    } else {
      final line = {'latitude': lineLatitude, 'longitude': lineLongitude};
      Database.setMapCalibration(
        venueId: widget.venueId,
        locationId: widget.locationId,
        lineOfBestFit: line,
      );
      _toggleCalibration(context, isComplete: true);
    }
  }

  /// Uploads a map image to [FirebaseStorage].
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

  /// Adds fingerprints to the database.
  void _addFingerprints(BuildContext context) async {
    final marker = chosenMarkerOffset;
    if (marker == null)
      showSnackBar(context, 'Select your location.');
    else {
      final geoOffset = await imageOffsetToGeoOffset(marker);
      if (geoOffset == null)
        showSnackBar(context, 'Calibrate the geolocation.');
      else {
        final newWifiResults = await WifiScanner.getWifiResults();
        if (mapEquals(wifiResults, newWifiResults))
          showSnackBar(context, 'Failed to scan Wi-Fi. Try again later.');
        else {
          wifiResults = newWifiResults;
          Database.addFingerprints(
            venueId: widget.venueId,
            locationId: widget.locationId,
            scanResults: wifiResults,
            geoOffset: geoOffset,
          );
          showSnackBar(context, 'Added fingerprints.');
        }
      }
    }
  }

  @override
  void setMarkerOffset(Offset newMarkerOffset) {
    chosenMarkerOffset = newMarkerOffset;
    predictedMarkerOffset = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.locationName),
        actions: <Widget>[
          Builder(
            builder: (context) => IconButton(
              tooltip: 'Calculate Error',
              icon: Icon(
                _errorCalculationEnabled ? Icons.error : Icons.error_outline,
              ),
              onPressed: () => _toggleErrorCalculation(context),
            ),
          ),
          Builder(
            builder: (context) => IconButton(
              tooltip: 'Calibrate Geolocation',
              icon: Icon(
                _calibrationEnabled ? Icons.gps_fixed : Icons.gps_off,
              ),
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
        builder: (context) {
          var icon, onPressed;
          if (_errorCalculationEnabled) {
            icon = Icons.error_outline;
            onPressed = () => _calculateError(context);
          } else if (_calibrationEnabled) {
            if (_calibrationList.length < 3) {
              icon = Icons.add;
              onPressed = () => _addCalibrationPoint(context);
            } else {
              icon = Icons.done;
              onPressed = () => _calibrateGeolocation(context);
            }
          } else {
            icon = Icons.wifi;
            onPressed = () => _addFingerprints(context);
          }

          return FloatingActionButton(
            elevation: 3.0,
            child: Icon(icon, size: 35),
            onPressed: onPressed,
          );
        },
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
              chosenMarkerOffset: chosenMarkerOffset,
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

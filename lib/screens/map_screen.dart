import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/services.dart';
import 'map_screen_admin.dart';
import 'map_screen_user.dart';

class MapScreen extends StatelessWidget {
  final String venueId;
  final String locationId;
  final String locationName;

  MapScreen({
    @required this.venueId,
    @required this.locationId,
    @required this.locationName,
  });

  static MapMarkerData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MapMarkerData>();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return user.isAdmin
        ? AdminMapScreen(venueId, locationId, locationName)
        : UserMapScreen(venueId, locationId, locationName);
  }
}

abstract class BaseMapScreen extends StatefulWidget {
  final String venueId;
  final String locationId;
  final String locationName;

  BaseMapScreen(this.venueId, this.locationId, this.locationName);
}

abstract class BaseMapScreenState extends State<BaseMapScreen> {
  // URL of the map image.
  Future<String> mapImageUrl;

  /// [Map] of (bssid => distance) for each access point scanned.
  Map wifiResults = {};

  /// [Offset] of the marker on the image.
  Offset markerOffsetOnImage;

  void setMarkerOffsetOnImage(Offset newMarkerOffsetOnImage) =>
      setState(() => markerOffsetOnImage = newMarkerOffsetOnImage);

  @override
  void initState() {
    super.initState();
    mapImageUrl = Database.getMapUrl(
      widget.venueId,
      widget.locationId,
    );
  }
}

class MapMarkerData extends InheritedWidget {
  /// [Offset] of the marker on the image.
  final Offset markerOffsetOnImage;
  final ValueChanged<Offset> setMarkerOffsetOnImage;

  MapMarkerData({
    @required Widget child,
    @required this.markerOffsetOnImage,
    this.setMarkerOffsetOnImage,
  }) : super(child: child);

  @override
  bool updateShouldNotify(MapMarkerData old) =>
      markerOffsetOnImage != old.markerOffsetOnImage;
}

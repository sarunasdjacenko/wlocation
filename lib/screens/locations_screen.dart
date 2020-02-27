import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '../components/components.dart';
import '../services/services.dart';
import 'map_screen.dart';

class LocationsScreen extends StatefulWidget {
  final String venueId;
  final String venueName;

  LocationsScreen({
    @required this.venueId,
    @required this.venueName,
  });

  factory LocationsScreen.fromMap(Map venue) {
    return LocationsScreen(
      venueId: venue['id'],
      venueName: venue['name'],
    );
  }

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  List<Map> _locations = [];

  void _getLocations() => Database.getLocations(venue: widget.venueId)
      .then((locationsList) => setState(() => _locations = locationsList));

  @override
  void initState() {
    super.initState();
    _getLocations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.venueName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      drawer: CustomDrawer(),
      body: SafeArea(
        child: GridView.count(
          padding: const EdgeInsets.all(10),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: <Widget>[
            ..._locations.map(
              (location) => OpenContainer(
                closedColor: Theme.of(context).cardColor,
                closedBuilder: (context, action) => ListTile(
                  title: Text(
                    location['name'],
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
                openBuilder: (context, action) =>
                    MapScreen.fromMap(widget.venueId, location),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

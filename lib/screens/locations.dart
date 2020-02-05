import 'package:flutter/material.dart';
import 'package:wlocation/components/custom_scaffold.dart';
import 'package:wlocation/components/list_item.dart';
import 'package:wlocation/screens/map.dart';
import 'package:wlocation/services/database.dart';

class LocationsScreen extends StatefulWidget {
  final String venue;

  LocationsScreen({this.venue});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  List<Map> _locations = [];

  Future<void> _getLocations() => Database.getLocations(venue: widget.venue)
      .then((locationsList) => setState(() => _locations = locationsList));

  @override
  void initState() {
    super.initState();
    _getLocations();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backEnabled: true,
      body: ListView.builder(
        itemCount: _locations.length,
        itemBuilder: (BuildContext context, int index) => ListItem(
          title: _locations[index]['name'],
          child: MapScreen(
            venue: widget.venue,
            location: _locations[index]['id'],
          ),
        ),
      ),
    );
  }
}

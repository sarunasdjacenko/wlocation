import 'package:flutter/material.dart';
import 'package:wlocation/components/custom_scaffold.dart';
import 'package:wlocation/components/list_item.dart';
import 'package:wlocation/screens/map.dart';
import 'package:wlocation/services/database.dart';

class LocationsScreen extends StatefulWidget {
  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  List<Map> _locations = [];

  Future<void> _getLocations() => Database.getLocations()
      .then((locationsList) => setState(() => _locations = locationsList));

  @override
  void initState() {
    super.initState();
    Database.setLocation(null);
    _getLocations();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backEnabled: true,
      body: ListView.builder(
        itemCount: _locations.length,
        itemBuilder: (BuildContext context, int index) {
          final location = _locations[index];
          return ListItem(
            title: location['name'],
            page: MapScreen(),
            beforePageCreate: () => Database.setLocation(location['id']),
          );
        },
      ),
    );
  }
}

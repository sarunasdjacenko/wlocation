import 'package:flutter/material.dart';
import 'package:wlocation/components/custom_scaffold.dart';
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

  Widget _listItem(Map location) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(
            location['name'],
            style: const TextStyle(fontSize: 100),
          ),
          onTap: () {
            Database.setVenue(location['id']);
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    MapScreen(),
              ),
            );
          },
        ),
        Divider(height: 0.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backEnabled: true,
      body: ListView.builder(
        itemCount: _locations.length,
        itemBuilder: (BuildContext context, int index) =>
            _listItem(_locations[index]),
      ),
    );
  }
}

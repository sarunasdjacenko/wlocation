import 'package:flutter/material.dart';

import '../components/components.dart';
import '../services/services.dart';
import 'locations.dart';

class VenuesScreen extends StatefulWidget {
  @override
  State<VenuesScreen> createState() => _VenuesScreenState();
}

class _VenuesScreenState extends State<VenuesScreen> {
  List<Map> _venues = [];

  Future<void> _getVenues() => Database.getVenues()
      .then((venuesList) => setState(() => _venues = venuesList));

  @override
  void initState() {
    super.initState();
    _getVenues();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backEnabled: false,
      body: ListView.builder(
        itemCount: _venues.length,
        itemBuilder: (BuildContext context, int index) => ListItem(
          title: _venues[index]['name'],
          child: LocationsScreen(
            venue: _venues[index]['id'],
          ),
        ),
      ),
    );
  }
}

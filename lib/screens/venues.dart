import 'package:flutter/material.dart';
import 'package:wlocation/components/custom_scaffold.dart';
import 'package:wlocation/screens/locations.dart';
import 'package:wlocation/services/database.dart';

class VenuesScreen extends StatefulWidget {
  @override
  State<VenuesScreen> createState() => _VenuesScreenState();
}

class _VenuesScreenState extends State<VenuesScreen> {
  List<Map> _venues = [];

  // Future<void> _getVenues() async {
  //   final venues = await Database.getVenues();
  //   setState(() => _venues = venues);
  // }
  Future<void> _getVenues() => Database.getVenues()
      .then((venuesList) => setState(() => _venues = venuesList));

  @override
  void initState() {
    super.initState();
    _getVenues();
  }

  Widget _listItem(Map venue) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(
            venue['name'],
            style: const TextStyle(fontSize: 100),
          ),
          onTap: () {
            Database.setVenue(venue['id']);
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    LocationsScreen(),
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
      backEnabled: false,
      body: ListView.builder(
        itemCount: _venues.length,
        itemBuilder: (BuildContext context, int index) =>
            _listItem(_venues[index]),
      ),
    );
  }
}

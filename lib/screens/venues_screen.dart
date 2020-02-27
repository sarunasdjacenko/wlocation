import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '../components/components.dart';
import '../services/services.dart';
import 'locations_screen.dart';

class VenuesScreen extends StatefulWidget {
  @override
  State<VenuesScreen> createState() => _VenuesScreenState();
}

class _VenuesScreenState extends State<VenuesScreen> {
  List<Map> _venues = [];

  void _getVenues() => Database.getVenues()
      .then((venuesList) => setState(() => _venues = venuesList));

  @override
  void initState() {
    super.initState();
    _getVenues();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(),
        drawer: CustomDrawer(),
        body: SafeArea(
          child: ListView.separated(
            itemCount: _venues.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (BuildContext context, int index) {
              final venue = _venues[index];
              return OpenContainer(
                closedColor: Theme.of(context).cardColor,
                closedBuilder: (context, action) => Column(
                  children: <Widget>[
                    ListTile(
                      contentPadding: const EdgeInsets.all(15),
                      title: Text(
                        venue['name'],
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ],
                ),
                openBuilder: (context, action) =>
                    LocationsScreen.fromMap(venue),
              );
            },
            separatorBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(top: 10),
            ),
          ),
        ),
      ),
    );
  }
}

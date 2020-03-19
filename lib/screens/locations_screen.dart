import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.venueName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: <Widget>[
          if (user.isAdmin)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => showDialog(
                context: context,
                child: TextFieldDialog(
                  titleText: 'Add a location',
                  labelText: 'Location',
                  onSubmit: (locationName) =>
                      Database.addLocation(widget.venueId, locationName),
                ),
              ),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      drawer: CustomDrawer(),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: Database.locations(widget.venueId),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());

            final locations = snapshot.data.documents;
            return GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: locations.length,
              itemBuilder: (context, index) {
                final location = locations[index];
                return OpenContainer(
                  closedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  closedColor: Theme.of(context).cardColor,
                  closedBuilder: (context, action) => _LocationCard(
                    venueId: widget.venueId,
                    locationId: location.documentID,
                    locationName: location.data['name'],
                  ),
                  openBuilder: (context, action) => MapScreen(
                    venueId: widget.venueId,
                    locationId: location.documentID,
                    locationName: location.data['name'],
                  ),
                );
              },
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final String locationName;
  final String venueId;
  final String locationId;

  _LocationCard({
    @required this.locationName,
    this.venueId,
    this.locationId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          Expanded(
            child: FutureBuilder(
              future: Database.getMapThumbnailUrl(venueId, locationId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    !snapshot.hasData) return Container();

                return Image.network(snapshot.data);
              },
            ),
          ),
          const Padding(padding: EdgeInsets.only(top: 10)),
          Text(locationName, style: const TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
}

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/components.dart';
import '../services/services.dart';
import 'locations_screen.dart';

class VenuesScreen extends StatefulWidget {
  @override
  State<VenuesScreen> createState() => _VenuesScreenState();
}

class _VenuesScreenState extends State<VenuesScreen> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            if (user.isAdmin)
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => showDialog(
                  context: context,
                  child: TextFieldDialog(
                    titleText: 'Add a venue',
                    labelText: 'Venue',
                    onSubmit: (venueName) => Database.addVenue(venueName),
                  ),
                ),
              ),
          ],
        ),
        drawer: CustomDrawer(),
        body: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: Database.venues(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(child: CircularProgressIndicator());

              final venues = snapshot.data.documents;
              return ListView.separated(
                padding: const EdgeInsets.all(10),
                itemCount: venues.length,
                itemBuilder: (context, index) {
                  final venue = venues[index];
                  return OpenContainer(
                    closedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    closedColor: Theme.of(context).cardColor,
                    closedBuilder: (context, action) => _VenueCard(
                      venueName: venue.data['name'],
                    ),
                    openBuilder: (context, action) => LocationsScreen(
                      venueId: venue.documentID,
                      venueName: venue.data['name'],
                    ),
                  );
                },
                separatorBuilder: (context, index) => const Padding(
                  padding: EdgeInsets.only(top: 10),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _VenueCard extends StatelessWidget {
  final String venueName;

  /// Constructor for the [_VenueCard] class.
  _VenueCard({@required this.venueName});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(15),
      title: Text(venueName, style: const TextStyle(fontSize: 34)),
    );
  }
}

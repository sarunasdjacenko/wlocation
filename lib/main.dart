import 'package:flutter/material.dart';
import 'package:wlocation/components/user_provider.dart';
import 'package:wlocation/screens/venues.dart';
import 'package:wlocation/services/backend.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialise Firebase services
  await Backend.initFirebase();
  // Launch the app
  runApp(
    UserProvider(
      child: MaterialApp(
        title: 'wlocation',
        theme: ThemeData(
          primarySwatch: Colors.pink,
        ),
        home: VenuesScreen(),
      ),
    ),
  );
}

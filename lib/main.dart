import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wlocation/screens/venues.dart';

import 'services/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        StreamProvider<UserInfo>.value(value: Auth.currentUser)
      ],
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.pink,
        ),
        home: VenuesScreen(),
      ),
    ),
  );
}

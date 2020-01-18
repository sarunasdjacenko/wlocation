import 'package:flutter/material.dart';
import 'package:wlocation/services/backend.dart';
import 'package:wlocation/screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialise Firebase services
  await Backend.initFirebase();
  // Launch the app
  runApp(
    MaterialApp(
      title: 'wlocation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    ),
  );
}

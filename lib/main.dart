import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/components.dart';
import 'screens/screens.dart';
import 'services/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final brightnessMode = await ThemeBrightness.getStoredBrightnessMode();
  final scanFrequency = await ScanFrequency.getStoredScanFrequency();
  runApp(
    MultiProvider(
      providers: [
        StreamProvider<User>.value(
          initialData: User(null),
          value: Auth.currentUser,
        ),
        ChangeNotifierProvider<ThemeBrightness>(
          create: (context) => ThemeBrightness(brightnessMode),
        ),
        ChangeNotifierProvider<ScanFrequency>(
          create: (context) => ScanFrequency(scanFrequency),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  ThemeData _buildTheme(BuildContext context, {Brightness fallback}) {
    return ThemeData(
      brightness: Provider.of<ThemeBrightness>(context).brightness ?? fallback,
      primarySwatch: Colors.pink,
      accentColor: Colors.pink,
      textSelectionHandleColor: Colors.pinkAccent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _buildTheme(context, fallback: Brightness.light),
      darkTheme: _buildTheme(context, fallback: Brightness.dark),
      home: VenuesScreen(),
    );
  }
}

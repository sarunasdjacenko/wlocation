import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/components.dart';
import 'screens/screens.dart';
import 'services/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final brightnessMode = await ThemeBrightnessMode.getStoredBrightnessMode();
  runApp(
    MyApp(
      storedBrightnessMode: brightnessMode,
    ),
  );
}

class MyApp extends StatelessWidget {
  final BrightnessModeOptions storedBrightnessMode;

  MyApp({@required this.storedBrightnessMode});

  ThemeData _buildTheme(BuildContext context, {Brightness fallback}) {
    return ThemeData(
      brightness:
          Provider.of<ThemeBrightnessMode>(context).brightnessMode ?? fallback,
      primarySwatch: Colors.pink,
      accentColor: Colors.pink,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<UserInfo>.value(value: Auth.currentUser),
        ChangeNotifierProvider<ThemeBrightnessMode>(
          create: (context) => ThemeBrightnessMode(storedBrightnessMode),
        ),
      ],
      child: Builder(
        builder: (context) => MaterialApp(
          theme: _buildTheme(context, fallback: Brightness.light),
          darkTheme: _buildTheme(context, fallback: Brightness.dark),
          home: VenuesScreen(),
        ),
      ),
    );
  }
}

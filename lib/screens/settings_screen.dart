import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/components.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Column(
        children: <Widget>[
          DropdownButton(
            isExpanded: true,
            onChanged: (option) =>
                Provider.of<ThemeBrightness>(context, listen: false)
                    .setBrightnessMode(option),
            items: [
              ...BrightnessModeOptions.values.map((option) => DropdownMenuItem(
                    value: option,
                    child: Text(option.toDisplayString()),
                  )),
            ],
            underline: Container(),
            hint: ListTile(
              title: const Text('Brightness Mode'),
              subtitle: Text(
                Provider.of<ThemeBrightness>(context).toString(),
              ),
              contentPadding: EdgeInsets.zero,
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: const Icon(Icons.brightness_4),
                  ),
                ],
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.only(top: 20)),
          DropdownButton(
            isExpanded: true,
            onChanged: (option) =>
                Provider.of<ScanFrequency>(context, listen: false)
                    .setScanFrequency(option),
            items: [
              ...ScanFrequencyOptions.values.map((option) => DropdownMenuItem(
                    value: option,
                    child: Text(option.toDisplayString()),
                  )),
            ],
            underline: Container(),
            hint: ListTile(
              // isThreeLine: true,
              title: const Text('Scan Frequency'),
              subtitle: Text(
                'Note: High frequency requires Android 10. Wi-Fi scan ' +
                    'throttling must also be disabled in Developer Options.\n' +
                    Provider.of<ScanFrequency>(context).toString(),
              ),
              contentPadding: EdgeInsets.zero,
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: const Icon(Icons.wifi),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

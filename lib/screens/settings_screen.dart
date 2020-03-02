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
        ],
      ),
    );
  }
}

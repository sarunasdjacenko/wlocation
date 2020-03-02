import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum BrightnessModeOptions { light, dark, system }

extension BrightnessModeOptionsExtension on BrightnessModeOptions {
  String toDisplayString() {
    final str = describeEnum(this);
    return str[0].toUpperCase() + str.substring(1);
  }
}

class ThemeBrightness extends ChangeNotifier {
  static const _key = 'brightness_mode';
  BrightnessModeOptions _option;

  ThemeBrightness(this._option);

  Brightness get brightness {
    if (_option == BrightnessModeOptions.light) return Brightness.light;
    if (_option == BrightnessModeOptions.dark) return Brightness.dark;
    return null;
  }

  void setBrightnessMode(BrightnessModeOptions newOption) {
    _option = newOption;
    _storeBrightnessMode();
    notifyListeners();
  }

  void _storeBrightnessMode() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_key, describeEnum(_option));
  }

  static Future<BrightnessModeOptions> getStoredBrightnessMode() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(_key);
    if (mode == describeEnum(BrightnessModeOptions.light))
      return BrightnessModeOptions.light;
    if (mode == describeEnum(BrightnessModeOptions.dark))
      return BrightnessModeOptions.dark;
    // Use System brightness mode as fallback.
    return BrightnessModeOptions.system;
  }

  @override
  String toString() => _option.toDisplayString();
}

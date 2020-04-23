import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enum which contains the brightness mode options.
enum BrightnessModeOptions { light, dark, system }

extension BrightnessModeOptionsExtension on BrightnessModeOptions {
  /// Adds a display string method to the above enum.
  String toDisplayString() {
    final str = describeEnum(this);
    return str[0].toUpperCase() + str.substring(1);
  }
}

class ThemeBrightness extends ChangeNotifier {
  /// The key used to store brightness mode on the device.
  static const _key = 'brightness_mode';

  /// The current brightness mode option.
  BrightnessModeOptions _option;

  /// Constructor for the [ThemeBrightness] class.
  ThemeBrightness(this._option);

  /// Returns a [Brightness] object based on the current brightness mode option.
  Brightness get brightness {
    if (_option == BrightnessModeOptions.light) return Brightness.light;
    if (_option == BrightnessModeOptions.dark) return Brightness.dark;
    return null;
  }

  /// Sets the brightness mode option.
  void setBrightnessMode(BrightnessModeOptions newOption) {
    _option = newOption;
    _storeBrightnessMode();
    notifyListeners();
  }

  /// Stores the brightness mode option on the device.
  void _storeBrightnessMode() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_key, describeEnum(_option));
  }

  /// Gets the brightness mode option stored on the device.
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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enum which contains the options for scan frequency.
enum ScanFrequencyOptions { high, low }

extension ScanFrequencyOptionsExtension on ScanFrequencyOptions {
  /// Adds a display string method to the above enum.
  String toDisplayString() {
    final str = describeEnum(this);
    return str[0].toUpperCase() + str.substring(1);
  }
}

class ScanFrequency extends ChangeNotifier {
  /// The key used to store scan frequency on the device.
  static const _key = 'scan_frequency';

  /// The current scan frequency option.
  ScanFrequencyOptions _option;

  /// Constructor for the [ScanFrequency] class.
  ScanFrequency(this._option);

  /// Returns a [Duration] object based on the current scan frequency option.
  Duration get frequency {
    if (_option == ScanFrequencyOptions.high) return const Duration(seconds: 5);
    if (_option == ScanFrequencyOptions.low) return const Duration(seconds: 30);
    return null;
  }

  /// Sets the scan frequency option.
  void setScanFrequency(ScanFrequencyOptions newOption) {
    _option = newOption;
    _storeScanFrequency();
    notifyListeners();
  }

  /// Stores the scan frequency option on the device.
  void _storeScanFrequency() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_key, describeEnum(_option));
  }

  /// Gets the scan frequency option stored on the device.
  static Future<ScanFrequencyOptions> getStoredScanFrequency() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(_key);
    if (mode == describeEnum(ScanFrequencyOptions.high))
      return ScanFrequencyOptions.high;
    if (mode == describeEnum(ScanFrequencyOptions.low))
      return ScanFrequencyOptions.low;
    // Use low scan frequency as fallback.
    return ScanFrequencyOptions.low;
  }

  @override
  String toString() => _option.toDisplayString();
}

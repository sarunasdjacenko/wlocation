import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ScanFrequencyOptions { high, low }

extension ScanFrequencyOptionsExtension on ScanFrequencyOptions {
  String toDisplayString() {
    final str = describeEnum(this);
    return str[0].toUpperCase() + str.substring(1);
  }
}

class ScanFrequency extends ChangeNotifier {
  static const _key = 'scan_frequency';
  ScanFrequencyOptions _option;

  ScanFrequency(this._option);

  Duration get frequency {
    if (_option == ScanFrequencyOptions.high) return const Duration(seconds: 5);
    if (_option == ScanFrequencyOptions.low) return const Duration(seconds: 30);
    return null;
  }

  void setScanFrequency(ScanFrequencyOptions newOption) {
    _option = newOption;
    _storeScanFrequency();
    notifyListeners();
  }

  void _storeScanFrequency() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_key, describeEnum(_option));
  }

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

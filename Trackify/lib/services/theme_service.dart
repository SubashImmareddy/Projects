import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeService extends ChangeNotifier {
  static const _boxName = 'settings';
  static const _darkKey = 'darkMode';
  static const _fontSizeKey = 'fontSize';

  bool _isDarkMode = false;
  String _fontSize = 'Medium';

  bool get isDarkMode => _isDarkMode;
  String get fontSize => _fontSize;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  double get fontScaleFactor {
    switch (_fontSize) {
      case 'Small':
        return 0.85;
      case 'Large':
        return 1.2;
      default:
        return 1.0;
    }
  }

  void loadTheme() {
    final box = Hive.box(_boxName);
    _isDarkMode = box.get(_darkKey, defaultValue: false);
    _fontSize = box.get(_fontSizeKey, defaultValue: 'Medium');
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final box = Hive.box(_boxName);
    await box.put(_darkKey, _isDarkMode);
    notifyListeners();
  }

  Future<void> setFontSize(String size) async {
    _fontSize = size;
    final box = Hive.box(_boxName);
    await box.put(_fontSizeKey, size);
    notifyListeners();
  }
}
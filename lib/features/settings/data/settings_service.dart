import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _keyCc = 'user_cc_motor';
  static const String _keyWeight = 'user_weight_kg';

  Future<void> saveSettings(int cc, int weight) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCc, cc);
    await prefs.setInt(_keyWeight, weight);
  }

  Future<Map<String, int>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    // Default values if not set: 150cc, 65kg
    final cc = prefs.getInt(_keyCc) ?? 150;
    final weight = prefs.getInt(_keyWeight) ?? 65;
    return {'cc': cc, 'weight': weight};
  }
}

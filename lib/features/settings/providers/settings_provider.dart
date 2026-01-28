import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/settings_service.dart';

class SettingsState {
  final int ccMotor;
  final int weightKg;
  final bool isLoading;

  SettingsState({
    required this.ccMotor,
    required this.weightKg,
    this.isLoading = false,
  });

  SettingsState copyWith({int? ccMotor, int? weightKg, bool? isLoading}) {
    return SettingsState(
      ccMotor: ccMotor ?? this.ccMotor,
      weightKg: weightKg ?? this.weightKg,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final _service = SettingsService();

  SettingsNotifier() : super(SettingsState(ccMotor: 150, weightKg: 65)) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true);
    final data = await _service.loadSettings();
    state = state.copyWith(
      ccMotor: data['cc'],
      weightKg: data['weight'],
      isLoading: false,
    );
  }

  Future<void> updateSettings(int cc, int weight) async {
    state = state.copyWith(isLoading: true);
    await _service.saveSettings(cc, weight);
    state = state.copyWith(ccMotor: cc, weightKg: weight, isLoading: false);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    return SettingsNotifier();
  },
);

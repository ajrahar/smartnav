import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../data/services/osrm_service.dart';
import '../data/services/fuel_prediction_service.dart';

// 1. State Class (Data apa yang disimpan?)
class NavigationState {
  final bool isLoading;
  final List<LatLng> routePoints; // Garis biru di peta
  final double distanceKm;
  final double predictedFuel; // Hasil AI
  final String? error;

  NavigationState({
    this.isLoading = false,
    this.routePoints = const [],
    this.distanceKm = 0,
    this.predictedFuel = 0,
    this.error,
  });

  // CopyWith untuk update state sebagian
  NavigationState copyWith({
    bool? isLoading,
    List<LatLng>? routePoints,
    double? distanceKm,
    double? predictedFuel,
    String? error,
  }) {
    return NavigationState(
      isLoading: isLoading ?? this.isLoading,
      routePoints: routePoints ?? this.routePoints,
      distanceKm: distanceKm ?? this.distanceKm,
      predictedFuel: predictedFuel ?? this.predictedFuel,
      error: error,
    );
  }
}

// 2. Provider Definition
final navigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
      return NavigationNotifier();
    });

// 3. Notifier Logic (Controller)
class NavigationNotifier extends StateNotifier<NavigationState> {
  final _osrmService = OSRMService(); // Service Peta
  final _aiService = FuelPredictionService(); // Service AI

  NavigationNotifier() : super(NavigationState());

  Future<void> calculateTrip(
    LatLng start,
    LatLng end,
    int userCC,
    int userWeight,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Langkah 1: Minta Rute ke OSRM
      final routeData = await _osrmService.getRoute(start, end);
      final double distKm = routeData['distance_km']; // Pastikan OSRM return KM

      // Langkah 2: Minta Prediksi ke AI (TFLite)
      final fuelNeeded = await _aiService.predict(
        distanceKm: distKm,
        ccMotor: userCC,
        weightKg: userWeight,
      );

      // Langkah 3: Update UI
      state = state.copyWith(
        isLoading: false,
        routePoints: routeData['geometry'], // List<LatLng>
        distanceKm: distKm,
        predictedFuel: fuelNeeded,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  @override
  void dispose() {
    _aiService.dispose();
    super.dispose();
  }
}

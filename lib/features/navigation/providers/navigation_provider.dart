import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../data/services/osrm_service.dart';
import '../data/services/fuel_prediction_service.dart';
import '../data/services/geocoding_service.dart';

// 1. State Class
class NavigationState {
  final bool isLoading;
  // Route Data
  final List<LatLng> routePoints;
  final double distanceKm;
  final double predictedFuel;
  final String? error;

  // Search & Navigation Data
  final LatLng? selectedStart;
  final LatLng? selectedDestination;
  final String? startAddress;
  final String? destinationAddress;
  final List<Map<String, dynamic>> searchResults;
  final bool
  isSearchingStart; // True if searching for Start, False if for Destination

  // Navigation Steps
  final List<Map<String, dynamic>> routeSteps;
  final int currentStepIndex;
  final bool isNavigationActive;

  NavigationState({
    this.isLoading = false,
    this.routePoints = const [],
    this.distanceKm = 0,
    this.predictedFuel = 0,
    this.error,
    this.selectedStart,
    this.selectedDestination,
    this.startAddress,
    this.destinationAddress,
    this.searchResults = const [],
    this.isSearchingStart = false,
    this.routeSteps = const [],
    this.currentStepIndex = 0,
    this.isNavigationActive = false,
  });

  NavigationState copyWith({
    bool? isLoading,
    List<LatLng>? routePoints,
    double? distanceKm,
    double? predictedFuel,
    String? error,
    LatLng? selectedStart,
    LatLng? selectedDestination,
    String? startAddress,
    String? destinationAddress,
    List<Map<String, dynamic>>? searchResults,
    bool? isSearchingStart,
    List<Map<String, dynamic>>? routeSteps,
    int? currentStepIndex,
    bool? isNavigationActive,
  }) {
    return NavigationState(
      isLoading: isLoading ?? this.isLoading,
      routePoints: routePoints ?? this.routePoints,
      distanceKm: distanceKm ?? this.distanceKm,
      predictedFuel: predictedFuel ?? this.predictedFuel,
      error: error,
      selectedStart: selectedStart ?? this.selectedStart,
      selectedDestination: selectedDestination ?? this.selectedDestination,
      startAddress: startAddress ?? this.startAddress,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      searchResults: searchResults ?? this.searchResults,
      isSearchingStart: isSearchingStart ?? this.isSearchingStart,
      routeSteps: routeSteps ?? this.routeSteps,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      isNavigationActive: isNavigationActive ?? this.isNavigationActive,
    );
  }
}

// 2. Provider Definition
final navigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
      return NavigationNotifier();
    });

// 3. Notifier Logic
class NavigationNotifier extends StateNotifier<NavigationState> {
  final _osrmService = OSRMService();
  final _aiService = FuelPredictionService();
  final _geocodingService = GeocodingService();

  NavigationNotifier() : super(NavigationState());

  /// Set which field is being searched (Start or Destination)
  void setSearchType({required bool isStart}) {
    state = state.copyWith(isSearchingStart: isStart, searchResults: []);
  }

  /// Search places properly
  Future<void> searchPlaces(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(searchResults: []);
      return;
    }

    // We don't set isLoading here to avoid flickering the UI too much,
    // or we could add a separate isSearching flag
    try {
      final results = await _geocodingService.searchPlace(query);
      state = state.copyWith(searchResults: results);
    } catch (e) {
      // Create a silent failure for search or show a snackbar in UI
      state = state.copyWith(searchResults: []);
    }
  }

  /// Select a location from search results or map tap
  void selectLocation(LatLng point, String address, {required bool isStart}) {
    if (isStart) {
      state = state.copyWith(
        selectedStart: point,
        startAddress: address,
        searchResults: [], // Clear search results after selection
      );
    } else {
      state = state.copyWith(
        selectedDestination: point,
        destinationAddress: address,
        searchResults: [],
      );
    }
  }

  /// Use current location as start point
  Future<void> useCurrentLocation() async {
    state = state.copyWith(isLoading: true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      final position = await Geolocator.getCurrentPosition();
      final point = LatLng(position.latitude, position.longitude);
      final address = await _geocodingService.reverseGeocode(point);

      state = state.copyWith(
        isLoading: false,
        selectedStart: point,
        startAddress: "Lokasi Saya ($address)", // Or just "Lokasi Saya"
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> calculateTrip(int userCC, int userWeight) async {
    if (state.selectedStart == null || state.selectedDestination == null) {
      state = state.copyWith(error: "Harap pilih posisi awal dan tujuan");
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final start = state.selectedStart!;
      final end = state.selectedDestination!;

      final routeData = await _osrmService.getRoute(start, end);
      final double distKm = routeData['distance_km'];
      final List<Map<String, dynamic>> stepsRaw = routeData['steps'] ?? [];

      final fuelNeeded = await _aiService.predict(
        distanceKm: distKm,
        ccMotor: userCC,
        weightKg: userWeight,
      );

      state = state.copyWith(
        isLoading: false,
        routePoints: routeData['geometry'],
        distanceKm: distKm,
        predictedFuel: fuelNeeded,
        routeSteps: stepsRaw,
        currentStepIndex: 0,
        isNavigationActive:
            true, // Start navigation mode automatically? Or maybe wait for user
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Stop navigation mode but keep the route preview
  void stopNavigation() {
    state = state.copyWith(isNavigationActive: false, currentStepIndex: 0);
  }

  /// Clear entire route and reset to initial state
  void clearRoute() {
    state = state.copyWith(
      routePoints: [],
      routeSteps: [],
      distanceKm: 0,
      predictedFuel: 0,
      isNavigationActive: false,
      currentStepIndex: 0,
      selectedStart: null,
      selectedDestination: null,
      startAddress: null,
      destinationAddress: null,
    );
  }
}

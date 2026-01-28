import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async'; // For Debounce
import '../providers/navigation_provider.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../settings/providers/settings_provider.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _destController = TextEditingController();
  Timer? _debounce;

  // Handle text changes with debounce
  void _onSearchChanged(String query, bool isStart) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(navigationProvider.notifier).setSearchType(isStart: isStart);
      ref.read(navigationProvider.notifier).searchPlaces(query);
    });
  }

  @override
  void dispose() {
    _startController.dispose();
    _destController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navState = ref.watch(navigationProvider);

    // Sync controllers with state if needed (optional, depends on UX preference)
    // Here we update text only if empty or explicitly selected to avoid fighting user input
    if (navState.startAddress != null &&
        _startController.text != navState.startAddress) {
      // Only update if not currently editing? For now, we update on selection.
      // A proper implementation might need a focus check.
    }

    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Prevent map from resizing when keyboard opens
      appBar: AppBar(
        title: const Text("Smart MotoNav"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // LAYER 1: MAP
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(-7.76, 110.37), // Jogja
              initialZoom: 13.0,
              onTap: (tapPosition, point) {
                // Determine which field is prioritized for map picking?
                // For now, let's say if we are "searching start", picking sets start.
                // If "searching destination" (or default), picking sets dest.
                final isStart = navState.isSearchingStart;
                ref
                    .read(navigationProvider.notifier)
                    .selectLocation(
                      point,
                      "${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}",
                      isStart: isStart,
                    );

                // Update text controllers
                if (isStart) {
                  _startController.text =
                      "${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}";
                } else {
                  _destController.text =
                      "${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}";
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.skripsi.motonav',
              ),
              // Route Line
              if (navState.routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: navState.routePoints,
                      strokeWidth: 5.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
              // Markers for Start and End
              MarkerLayer(
                markers: [
                  if (navState.selectedStart != null)
                    Marker(
                      point: navState.selectedStart!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.green,
                        size: 40,
                      ),
                    ),
                  if (navState.selectedDestination != null)
                    Marker(
                      point: navState.selectedDestination!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                ],
              ),
            ],
          ),

          // LAYER 2: SEARCH PANEL (Top)
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        // Start Location Input
                        TextField(
                          controller: _startController,
                          decoration: InputDecoration(
                            hintText: "Lokasi Awal",
                            prefixIcon: const Icon(
                              Icons.my_location,
                              color: Colors.green,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.gps_fixed),
                              onPressed: () async {
                                await ref
                                    .read(navigationProvider.notifier)
                                    .useCurrentLocation();
                                if (ref.read(navigationProvider).startAddress !=
                                    null) {
                                  _startController.text = ref
                                      .read(navigationProvider)
                                      .startAddress!;
                                  // Move map to center
                                  if (ref
                                          .read(navigationProvider)
                                          .selectedStart !=
                                      null) {
                                    _mapController.move(
                                      ref
                                          .read(navigationProvider)
                                          .selectedStart!,
                                      15,
                                    );
                                  }
                                }
                              },
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15,
                            ),
                          ),
                          onChanged: (val) => _onSearchChanged(val, true),
                          onTap: () {
                            ref
                                .read(navigationProvider.notifier)
                                .setSearchType(isStart: true);
                          },
                        ),
                        const Divider(height: 1),
                        // Destination Input
                        TextField(
                          controller: _destController,
                          decoration: const InputDecoration(
                            hintText: "Tujuan",
                            prefixIcon: Icon(
                              Icons.location_on,
                              color: Colors.red,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 15),
                          ),
                          onChanged: (val) => _onSearchChanged(val, false),
                          onTap: () {
                            ref
                                .read(navigationProvider.notifier)
                                .setSearchType(isStart: false);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Search Suggestions List
                if (navState.searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(blurRadius: 4, color: Colors.black26),
                      ],
                    ),
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: navState.searchResults.length,
                      separatorBuilder: (ctx, i) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final place = navState.searchResults[index];
                        return ListTile(
                          title: Text(
                            place['display_name'] ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          leading: const Icon(Icons.place, color: Colors.grey),
                          onTap: () {
                            final point = LatLng(place['lat'], place['lon']);
                            final name = place['display_name'];

                            ref
                                .read(navigationProvider.notifier)
                                .selectLocation(
                                  point,
                                  name,
                                  isStart: navState.isSearchingStart,
                                );

                            if (navState.isSearchingStart) {
                              _startController.text = name;
                            } else {
                              _destController.text = name;
                            }

                            _mapController.move(point, 15);

                            // Close keyboard
                            FocusScope.of(context).unfocus();
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // LAYER 3: MY LOCATION FAB
          Positioned(
            bottom: 240, // Above the bottom card
            right: 20,
            child: FloatingActionButton(
              heroTag: "my_location",
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () async {
                await ref
                    .read(navigationProvider.notifier)
                    .useCurrentLocation();
                final start = ref.read(navigationProvider).selectedStart;
                if (start != null) {
                  _startController.text =
                      ref.read(navigationProvider).startAddress ?? "";
                  _mapController.move(start, 15);
                }
              },
              child: const Icon(Icons.my_location, color: Colors.black87),
            ),
          ),

          // LAYER 4: INFO PANEL (Bottom)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (navState.isLoading)
                      const CircularProgressIndicator()
                    else if (navState.error != null)
                      Column(
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 30),
                          const SizedBox(height: 8),
                          Text(
                            'Error: ${navState.error}',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    // NAVIGATION MODE UI
                    else if (navState.isNavigationActive &&
                        navState.routeSteps.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Petunjuk Arah",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  ref
                                      .read(navigationProvider.notifier)
                                      .stopNavigation();
                                },
                              ),
                            ],
                          ),
                          const Divider(),
                          // Current Step
                          if (navState.routeSteps.isNotEmpty) ...[
                            ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Icon(
                                  Icons.turn_right,
                                  color: Colors.white,
                                ), // Dynamic icon todo
                              ),
                              title: Text(
                                _getInstructionText(
                                  navState.routeSteps[navState
                                      .currentStepIndex],
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                "${navState.routeSteps[navState.currentStepIndex]['name'] ?? 'Jalan tanpa nama'}\n${navState.routeSteps[navState.currentStepIndex]['distance']} m",
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total: ${navState.distanceKm.toStringAsFixed(1)} km",
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                "Bensin: ${navState.predictedFuel.toStringAsFixed(2)} L",
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    // PRE-NAVIGATION INFO
                    else if (navState.routePoints.isNotEmpty)
                      Column(
                        children: [
                          const Text(
                            "Estimasi Perjalanan",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Jarak: ${navState.distanceKm.toStringAsFixed(1)} km",
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                "Bensin: ${navState.predictedFuel.toStringAsFixed(2)} L",
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  (navState.isLoading ||
                                      navState.selectedStart == null ||
                                      navState.selectedDestination == null)
                                  ? null
                                  : () {
                                      final settings = ref.read(
                                        settingsProvider,
                                      );
                                      ref
                                          .read(navigationProvider.notifier)
                                          .calculateTrip(
                                            settings.ccMotor,
                                            settings.weightKg,
                                          );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "Mulai Navigasi",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      )
                    // READY TO CALCULATE
                    else if (navState.selectedStart != null &&
                        navState.selectedDestination != null)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: navState.isLoading
                              ? null
                              : () {
                                  final settings = ref.read(settingsProvider);
                                  ref
                                      .read(navigationProvider.notifier)
                                      .calculateTrip(
                                        settings.ccMotor,
                                        settings.weightKg,
                                      );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Hitung Rute & Estimasi",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      )
                    // EMPTY STATE
                    else
                      const Text(
                        "Silakan pilih lokasi awal dan tujuan.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInstructionText(Map<String, dynamic> step) {
    final type = step['instruction']; // 'turn', 'new name', 'arrive', etc
    final modifier = step['modifier']; // 'left', 'right', 'sharp right', etc

    String text = "";

    if (type == 'turn') {
      if (modifier == 'left') {
        text = "Belok Kiri";
      } else if (modifier == 'right') {
        text = "Belok Kanan";
      } else if (modifier == 'sharp left') {
        text = "Belok Tajam ke Kiri";
      } else if (modifier == 'sharp right') {
        text = "Belok Tajam ke Kanan";
      } else if (modifier == 'slight left') {
        text = "Serong Kiri";
      } else if (modifier == 'slight right') {
        text = "Serong Kanan";
      } else if (modifier == 'uturn') {
        text = "Putar Balik";
      } else {
        text = "Belok";
      }
    } else if (type == 'new name') {
      text = "Lanjut";
    } else if (type == 'depart') {
      text = "Mulai Perjalanan";
    } else if (type == 'arrive') {
      text = "Tiba di Tujuan";
    } else if (type == 'roundabout') {
      text = "Masuk Bundaran";
    } else {
      text = "Lanjut";
    }

    return text;
  }
}

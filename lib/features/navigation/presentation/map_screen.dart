import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../providers/navigation_provider.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Dengarkan perubahan state
    final navState = ref.watch(navigationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart MotoNav"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // LAYER 1: PETA
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(-7.76, 110.37), // Jogja
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.skripsi.motonav',
              ),
              // Gambar Garis Rute (Polyline)
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
            ],
          ),

          // LAYER 2: PANEL INFO (Bawah)
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
                          const Icon(Icons.error, color: Colors.red, size: 40),
                          const SizedBox(height: 8),
                          Text(
                            'Error: ${navState.error}',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
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
                              // HITUNG BAR BENSIN (UX) DISINI
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
                    else
                      const Text(
                        "Silakan pilih tujuan untuk mulai navigasi.",
                        textAlign: TextAlign.center,
                      ),

                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: navState.isLoading
                          ? null
                          : () {
                              // Simulasi User klik tombol cari rute
                              // Data CC & Berat nanti diambil dari User Settings
                              ref
                                  .read(navigationProvider.notifier)
                                  .calculateTrip(
                                    const LatLng(
                                      -7.76,
                                      110.37,
                                    ), // Asal (Amikom)
                                    const LatLng(
                                      -7.79,
                                      110.36,
                                    ), // Tujuan (Malioboro)
                                    150, // CC Motor
                                    65, // Berat Badan
                                  );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        "Cari Rute & Hitung Bensin",
                        style: TextStyle(fontSize: 16),
                      ),
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
}

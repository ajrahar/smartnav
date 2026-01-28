import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class OSRMService {
  static const String _baseUrl = 'https://router.project-osrm.org';

  /// Get route from OSRM API
  /// Returns Map with 'geometry' (List of LatLng) and 'distance_km' (double)
  Future<Map<String, dynamic>> getRoute(LatLng start, LatLng end) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson&steps=true',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['code'] != 'Ok') {
          throw Exception('OSRM Error: ${data['code']}');
        }

        final route = data['routes'][0];
        final coordinates = route['geometry']['coordinates'] as List;

        // Parse Steps
        final List<dynamic> legs = route['legs'];
        final List<Map<String, dynamic>> steps = [];

        if (legs.isNotEmpty) {
          final stepsRaw = legs[0]['steps'] as List;
          for (var step in stepsRaw) {
            steps.add({
              'instruction': step['maneuver']['type'], // e.g. "turn"
              'modifier': step['maneuver']['modifier'], // e.g. "left"
              'distance': step['distance'],
              'location': LatLng(
                step['maneuver']['location'][1],
                step['maneuver']['location'][0],
              ),
              'name': step['name'],
            });
          }
        }

        // Convert GeoJSON coordinates to LatLng
        final List<LatLng> routePoints = coordinates.map((coord) {
          return LatLng(coord[1], coord[0]); // GeoJSON is [lng, lat]
        }).toList();

        // Distance in meters, convert to km
        final double distanceKm = route['distance'] / 1000.0;

        return {
          'geometry': routePoints,
          'distance_km': distanceKm,
          'steps': steps,
        };
      } else {
        throw Exception('Failed to fetch route: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('OSRM Service Error: $e');
      rethrow;
    }
  }
}

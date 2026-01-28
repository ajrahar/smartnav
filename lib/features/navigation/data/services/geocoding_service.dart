import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GeocodingService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';

  // Nominatim requires a User-Agent to identify the application
  final Map<String, String> _headers = {'User-Agent': 'com.skripsi.motonav'};

  /// Search for a place by name/query
  Future<List<Map<String, dynamic>>> searchPlace(String query) async {
    if (query.isEmpty) return [];

    try {
      final url = Uri.parse(
        '$_baseUrl/search?q=$query&format=json&limit=5&addressdetails=1',
      );

      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map(
              (item) => {
                'display_name': item['display_name'],
                'lat': double.parse(item['lat']),
                'lon': double.parse(item['lon']),
              },
            )
            .toList();
      } else {
        throw Exception('Failed to search place: ${response.statusCode}');
      }
    } catch (e) {
      // In a real app, you might want to log this error
      rethrow;
    }
  }

  /// Get address from coordinates (Reverse Geocoding)
  Future<String> reverseGeocode(LatLng point) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/reverse?lat=${point.latitude}&lon=${point.longitude}&format=json',
      );

      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'] ?? 'Unknown Location';
      } else {
        return 'Location found (${point.latitude}, ${point.longitude})';
      }
    } catch (e) {
      return '${point.latitude}, ${point.longitude}';
    }
  }
}

/// Location Service
/// Handles geolocation for prayer time calculations
/// Uses geolocator package (mobile-only)

import 'package:geolocator/geolocator.dart' if (dart.library.html) 'location_service_stub.dart' as geolocator_platform;
import 'package:hive/hive.dart';

import '../models/user_settings_model.dart';

class LocationService {
  static const String _boxName = 'user_settings';
  
  /// Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission status
  static Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  static Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get current position
  static Future<Position?> getCurrentPosition() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationException('Location services are disabled');
      }

      // Check permission
      var permission = await checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          throw LocationException('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw LocationException('Location permission permanently denied');
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      throw LocationException('Failed to get location: $e');
    }
  }

  /// Get last known position
  static Future<Position?> getLastKnownPosition() async {
    return await Geolocator.getLastKnownPosition();
  }

  /// Get position stream for real-time updates
  static Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10, // meters
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    );
  }

  /// Get address from coordinates (simplified)
  /// In production, you might want to use geocoding package
  static Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    // For now, return coordinates as string
    // In production, use geocoding to get actual address
    return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
  }

  /// Save location to settings
  static Future<void> saveLocation({
    required double latitude,
    required double longitude,
    String? locationName,
  }) async {
    final box = Hive.box<UserSettings>(_boxName);
    final settings = box.get('settings') ?? UserSettings.defaultSettings();
    
    settings.latitude = latitude;
    settings.longitude = longitude;
    if (locationName != null) {
      settings.locationName = locationName;
    }
    
    await box.put('settings', settings);
  }

  /// Get saved location
  static Future<Map<String, dynamic>?> getSavedLocation() async {
    final box = Hive.box<UserSettings>(_boxName);
    final settings = box.get('settings');
    
    if (settings == null) return null;
    
    return {
      'latitude': settings.latitude,
      'longitude': settings.longitude,
      'locationName': settings.locationName,
    };
  }

  /// Calculate distance between two coordinates
  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Check if location is in Bangladesh
  static bool isInBangladesh(double latitude, double longitude) {
    // Bangladesh approximate bounds
    const minLat = 20.5;
    const maxLat = 26.7;
    const minLon = 88.0;
    const maxLon = 92.7;
    
    return latitude >= minLat &&
           latitude <= maxLat &&
           longitude >= minLon &&
           longitude <= maxLon;
  }

  /// Get nearest Bangladesh city
  static Map<String, dynamic>? getNearestBangladeshCity(
    double latitude,
    double longitude,
  ) {
    Map<String, dynamic>? nearestCity;
    double minDistance = double.infinity;

    for (final city in LocationPresets.bangladeshCities) {
      final distance = calculateDistance(
        latitude,
        longitude,
        city['latitude'] as double,
        city['longitude'] as double,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestCity = city;
      }
    }

    return nearestCity;
  }

  /// Set location to a preset city
  static Future<void> setPresetCity(String cityName) async {
    final city = LocationPresets.findCity(cityName);
    if (city == null) {
      throw LocationException('City not found: $cityName');
    }

    await saveLocation(
      latitude: city['latitude'] as double,
      longitude: city['longitude'] as double,
      locationName: '${city['name']}, Bangladesh',
    );
  }

  /// Get timezone from coordinates
  /// Returns timezone offset in hours
  static double getTimezoneOffset() {
    final now = DateTime.now();
    return now.timeZoneOffset.inHours.toDouble();
  }

  /// Format coordinates for display
  static String formatCoordinates(double latitude, double longitude) {
    final latDir = latitude >= 0 ? 'N' : 'S';
    final lonDir = longitude >= 0 ? 'E' : 'W';
    
    return '${latitude.abs().toStringAsFixed(4)}° $latDir, '
           '${longitude.abs().toStringAsFixed(4)}° $lonDir';
  }

  /// Get location accuracy description
  static String getAccuracyDescription(LocationAccuracy accuracy) {
    switch (accuracy) {
      case LocationAccuracy.lowest:
        return 'Lowest (3km)';
      case LocationAccuracy.low:
        return 'Low (1km)';
      case LocationAccuracy.medium:
        return 'Medium (100m)';
      case LocationAccuracy.high:
        return 'High (10m)';
      case LocationAccuracy.best:
        return 'Best (1m)';
      case LocationAccuracy.bestForNavigation:
        return 'Best for Navigation';
      default:
        return 'Unknown';
    }
  }
}

/// Location exception
class LocationException implements Exception {
  final String message;
  
  LocationException(this.message);
  
  @override
  String toString() => 'LocationException: $message';
}

/// Location result
class LocationResult {
  final bool success;
  final Position? position;
  final String? errorMessage;
  final String? address;

  LocationResult({
    required this.success,
    this.position,
    this.errorMessage,
    this.address,
  });

  factory LocationResult.success(Position position, String? address) {
    return LocationResult(
      success: true,
      position: position,
      address: address,
    );
  }

  factory LocationResult.error(String message) {
    return LocationResult(
      success: false,
      errorMessage: message,
    );
  }

  double? get latitude => position?.latitude;
  double? get longitude => position?.longitude;
}

/// Location change listener
class LocationChangeListener {
  Stream<Position>? _positionStream;
  
  void startListening({
    required Function(Position) onLocationChanged,
    Function(Object)? onError,
  }) {
    _positionStream = LocationService.getPositionStream();
    
    _positionStream?.listen(
      onLocationChanged,
      onError: onError,
    );
  }
  
  void stopListening() {
    // Stream will be cancelled when no longer listened to
    _positionStream = null;
  }
}

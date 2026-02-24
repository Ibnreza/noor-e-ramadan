/// Location Service Stub for Web
/// Mock implementation that returns null on web platform

class Position {
  final double latitude;
  final double longitude;
  
  Position({required this.latitude, required this.longitude});
}

class LocationException implements Exception {
  final String message;
  LocationException(this.message);
  
  @override
  String toString() => message;
}

class LocationService {
  static const String _boxName = 'user_settings';
  
  /// Check if location services are enabled (false on web)
  static Future<bool> isLocationServiceEnabled() async {
    return false;
  }

  /// Check location permission status
  static Future<Object> checkPermission() async {
    return null;
  }

  /// Request location permission
  static Future<Object> requestPermission() async {
    return null;
  }

  /// Get current position (returns null on web)
  static Future<Position?> getCurrentPosition() async {
    return null;
  }

  /// Get last known position (returns null on web)
  static Future<Position?> getLastKnownPosition() async {
    return null;
  }

  /// Get position stream for real-time updates (empty on web)
  static Stream<Position> getPositionStream({
    Object accuracy = 0,
    int distanceFilter = 10,
  }) {
    return Stream.empty();
  }

  /// Get address from coordinates (returns null on web)
  static Future<String?> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    return null;
  }

  /// Get coordinates from address (returns null on web)
  static Future<Position?> getCoordinatesFromAddress(String address) async {
    return null;
  }

  /// Open location settings
  static Future<bool> openLocationSettings() async {
    return false;
  }

  /// Get distance in meters between two coordinates
  static double getDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return 0.0;
  }

  /// Batch geocode addresses
  static Future<List<Position>> batchGeocode(List<String> addresses) async {
    return [];
  }
}

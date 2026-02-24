/// Flutter Qiblah Stub for Web
/// Mock implementation that provides empty streams on web platform

class FlutterQiblah {
  static Stream<QiblaDirection> qiblahStream() {
    return Stream.empty();
  }
}

class QiblaDirection {
  final double qibla;
  final double direction;
  final double offset;

  QiblaDirection({
    required this.qibla,
    required this.direction,
    required this.offset,
  });
}

// Geolocator stubs
class LocationAccuracy {
  static const dynamic high = 'high';
  static const dynamic low = 'low';
}

class LocationSettings {
  final dynamic accuracy;
  final int distanceFilter;
  
  const LocationSettings({
    this.accuracy,
    this.distanceFilter = 10,
  });
}

class Position {
  final double latitude;
  final double longitude;
  
  Position({required this.latitude, required this.longitude});
}

class Geolocator {
  static Future<bool> isLocationServiceEnabled() async => false;
  static Future<dynamic> checkPermission() async => null;
  static Future<dynamic> requestPermission() async => null;
  static Future<Position?> getCurrentPosition({dynamic desiredAccuracy}) async => null;
  static Future<Position?> getLastKnownPosition() async => null;
  static Stream<Position> getPositionStream({dynamic locationSettings}) => Stream.empty();
}

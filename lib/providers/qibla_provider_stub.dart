/// Flutter Qiblah Stub for Web
/// Mock implementation that provides empty streams on web platform

class FlutterQiblah {
  static Stream<QiblahDirection> get qiblahStream {
    return Stream.empty();
  }
  
  static Future<bool?> androidDeviceSensorSupport() async => false;
}

class QiblahDirection {
  final double qibla;
  final double direction;
  final double offset;

  QiblahDirection({
    required this.qibla,
    required this.direction,
    required this.offset,
  });
}

// Location Permission enum
class LocationPermission {
  static const int denied = 0;
  static const int deniedForever = 1;
  static const int granted = 2;
  static const int unknown = 3;
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
  static Future<int> checkPermission() async => LocationPermission.denied;
  static Future<int> requestPermission() async => LocationPermission.denied;
  static Future<Position?> getCurrentPosition({dynamic desiredAccuracy}) async => null;
  static Future<Position?> getLastKnownPosition() async => null;
  static Stream<Position> getPositionStream({dynamic locationSettings}) => Stream.empty();
}

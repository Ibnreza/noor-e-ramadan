// Stub implementation of LocationService for web
// This file is used when compiling for web to avoid native dependencies.

import 'package:geolocator/geolocator.dart';

class LocationService {
  static const LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  const LocationService._internal();

  // Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    // On web, we can check browser permissions
    return false; // Default stub value
  }

  // Check location permission
  static Future<LocationPermission> checkPermission() async {
    return LocationPermission.denied;
  }

  // Request location permission
  static Future<LocationPermission> requestPermission() async {
    return LocationPermission.denied;
  }

  // Get last known position
  static Future<Position?> getLastKnownPosition() async {
    return null;
  }

  // Get current position
  static Future<Position?> getCurrentPosition() async {
    return null;
  }
}

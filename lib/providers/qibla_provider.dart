/// Qibla Provider
/// Manages Qibla direction state using flutter_qiblah

import 'dart:async';
import 'dart:math' show pi, atan2, cos, sin;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart' if (dart.library.html) 'qibla_provider_stub.dart';
import 'package:geolocator/geolocator.dart' if (dart.library.html) '../services/location_service_stub.dart' as geolocator_platform;

import '../services/prayer_calculation_service.dart';
import 'settings_provider.dart';

/// Qibla state
class QiblaState {
  final bool isLoading;
  final bool hasPermission;
  final bool isSupported;
  final double? qiblaDirection; // Direction to Qibla from North (0-360)
  final double? deviceDirection; // Device heading from North (0-360)
  final double? offset; // Difference between device and Qibla
  final String? error;
  final Position? position;

  QiblaState({
    this.isLoading = true,
    this.hasPermission = false,
    this.isSupported = true,
    this.qiblaDirection,
    this.deviceDirection,
    this.offset,
    this.error,
    this.position,
  });

  QiblaState copyWith({
    bool? isLoading,
    bool? hasPermission,
    bool? isSupported,
    double? qiblaDirection,
    double? deviceDirection,
    double? offset,
    String? error,
    Position? position,
  }) {
    return QiblaState(
      isLoading: isLoading ?? this.isLoading,
      hasPermission: hasPermission ?? this.hasPermission,
      isSupported: isSupported ?? this.isSupported,
      qiblaDirection: qiblaDirection ?? this.qiblaDirection,
      deviceDirection: deviceDirection ?? this.deviceDirection,
      offset: offset ?? this.offset,
      error: error ?? this.error,
      position: position ?? this.position,
    );
  }

  /// Check if Qibla is aligned (within 5 degrees)
  bool get isAligned {
    if (offset == null) return false;
    final normalizedOffset = (offset! + 180) % 360 - 180;
    return normalizedOffset.abs() < 5;
  }

  /// Get alignment accuracy (0-100)
  double get alignmentAccuracy {
    if (offset == null) return 0;
    final normalizedOffset = (offset! + 180) % 360 - 180;
    final accuracy = (1 - (normalizedOffset.abs() / 180)) * 100;
    return accuracy.clamp(0, 100);
  }

  /// Get direction text
  String get directionText {
    if (qiblaDirection == null) return '';
    
    final direction = qiblaDirection!;
    if (direction >= 337.5 || direction < 22.5) return 'N';
    if (direction >= 22.5 && direction < 67.5) return 'NE';
    if (direction >= 67.5 && direction < 112.5) return 'E';
    if (direction >= 112.5 && direction < 157.5) return 'SE';
    if (direction >= 157.5 && direction < 202.5) return 'S';
    if (direction >= 202.5 && direction < 247.5) return 'SW';
    if (direction >= 247.5 && direction < 292.5) return 'W';
    if (direction >= 292.5 && direction < 337.5) return 'NW';
    return '';
  }

  /// Get formatted Qibla direction
  String get formattedQiblaDirection {
    if (qiblaDirection == null) return '--°';
    return '${qiblaDirection!.toStringAsFixed(1)}°';
  }

  /// Get formatted device direction
  String get formattedDeviceDirection {
    if (deviceDirection == null) return '--°';
    return '${deviceDirection!.toStringAsFixed(1)}°';
  }
}

/// Qibla notifier
class QiblaNotifier extends StateNotifier<QiblaState> {
  final Ref _ref;
  StreamSubscription<QiblahDirection>? _qiblaSubscription;
  StreamSubscription<Position>? _locationSubscription;

  QiblaNotifier(this._ref) : super(QiblaState()) {
    _initialize();
  }

  /// Initialize Qibla
  Future<void> _initialize() async {
    await checkDeviceSupport();
    await checkPermissions();
  }

  /// Check if device supports compass
  Future<void> checkDeviceSupport() async {
    final isSupported = await FlutterQiblah.androidDeviceSensorSupport();
    state = state.copyWith(isSupported: isSupported ?? false);
  }

  /// Check location permissions
  Future<void> checkPermissions() async {
    final permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      final requested = await Geolocator.requestPermission();
      if (requested == LocationPermission.denied ||
          requested == LocationPermission.deniedForever) {
        state = state.copyWith(
          isLoading: false,
          hasPermission: false,
          error: 'Location permission required for Qibla direction',
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      state = state.copyWith(
        isLoading: false,
        hasPermission: false,
        error: 'Location permission permanently denied. Please enable in settings.',
      );
      return;
    }

    state = state.copyWith(hasPermission: true);
    await _startListening();
  }

  /// Start listening to Qibla direction
  Future<void> _startListening() async {
    try {
      // Get current position
      final position = await Geolocator.getCurrentPosition();
      state = state.copyWith(position: position);

      // Calculate Qibla direction if position available
      if (position != null) {
        final qiblaDirection = PrayerCalculationService.getQiblaDirection(
          position.latitude,
          position.longitude,
        );
        state = state.copyWith(qiblaDirection: qiblaDirection);
      }

      // Listen to Qibla direction updates
      _qiblaSubscription = FlutterQiblah.qiblahStream.listen(
        (qiblahDirection) {
          final deviceDirection = qiblahDirection.direction;
          final offset = qiblahDirection.qiblah;

          state = state.copyWith(
            isLoading: false,
            deviceDirection: deviceDirection,
            offset: offset,
            error: null,
          );
        },
        onError: (error) {
          state = state.copyWith(
            isLoading: false,
            error: 'Error getting Qibla direction: $error',
          );
        },
      );

      // Also listen to location updates
      try {
        _locationSubscription = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 100,
          ),
        ).listen((position) {
          state = state.copyWith(position: position);
          
          // Recalculate Qibla direction if position not null
          if (position != null) {
            final qiblaDirection = PrayerCalculationService.getQiblaDirection(
              position.latitude,
              position.longitude,
            );
            state = state.copyWith(qiblaDirection: qiblaDirection);
          }
        });
      } catch (e) {
        // Geolocator not available on web, location updates not supported
        print('Location updates not available: $e');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to start Qibla: $e',
      );
    }
  }

  /// Stop listening
  void stopListening() {
    _qiblaSubscription?.cancel();
    _qiblaSubscription = null;
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  /// Restart listening
  Future<void> restart() async {
    stopListening();
    state = QiblaState();
    await _initialize();
  }

  /// Calibrate compass
  Future<void> calibrate() async {
    state = state.copyWith(isLoading: true);
    await restart();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}

/// Qibla provider
final qiblaProvider = StateNotifierProvider<QiblaNotifier, QiblaState>((ref) {
  return QiblaNotifier(ref);
});

/// Qibla direction provider
final qiblaDirectionProvider = Provider<double?>((ref) {
  return ref.watch(qiblaProvider).qiblaDirection;
});

/// Device direction provider
final deviceDirectionProvider = Provider<double?>((ref) {
  return ref.watch(qiblaProvider).deviceDirection;
});

/// Qibla offset provider
final qiblaOffsetProvider = Provider<double?>((ref) {
  return ref.watch(qiblaProvider).offset;
});

/// Is Qibla aligned provider
final isQiblaAlignedProvider = Provider<bool>((ref) {
  return ref.watch(qiblaProvider).isAligned;
});

/// Qibla alignment accuracy provider
final qiblaAccuracyProvider = Provider<double>((ref) {
  return ref.watch(qiblaProvider).alignmentAccuracy;
});

/// Qibla loading provider
final qiblaLoadingProvider = Provider<bool>((ref) {
  return ref.watch(qiblaProvider).isLoading;
});

/// Qibla error provider
final qiblaErrorProvider = Provider<String?>((ref) {
  return ref.watch(qiblaProvider).error;
});

/// Qibla has permission provider
final qiblaHasPermissionProvider = Provider<bool>((ref) {
  return ref.watch(qiblaProvider).hasPermission;
});

/// Compass rotation provider (for animation)
final compassRotationProvider = StreamProvider<double>((ref) async* {
  final offset = ref.watch(qiblaOffsetProvider);
  if (offset != null) {
    yield offset;
  }
  yield 0;
});

/// Qibla info provider
final qiblaInfoProvider = Provider<Map<String, dynamic>>((ref) {
  final state = ref.watch(qiblaProvider);
  final settings = ref.watch(settingsProvider);

  return {
    'qiblaDirection': state.qiblaDirection,
    'deviceDirection': state.deviceDirection,
    'offset': state.offset,
    'isAligned': state.isAligned,
    'accuracy': state.alignmentAccuracy,
    'directionText': state.directionText,
    'latitude': settings.latitude,
    'longitude': settings.longitude,
    'locationName': settings.locationName,
  };
});

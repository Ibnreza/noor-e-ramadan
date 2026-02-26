/// Prayer Times Provider
/// Manages prayer times state and calculations using Riverpod

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/prayer_times_model.dart';
import '../models/user_settings_model.dart';
import '../services/prayer_calculation_service.dart';
import 'settings_provider.dart';

final Object _unset = Object();

/// Prayer times state
class PrayerTimesState {
  final PrayerTimesModel? todayPrayerTimes;
  final PrayerTimesModel? tomorrowPrayerTimes;
  final List<PrayerTimesModel>? monthPrayerTimes;
  final bool isLoading;
  final String? error;
  final DateTime lastUpdated;

  PrayerTimesState({
    this.todayPrayerTimes,
    this.tomorrowPrayerTimes,
    this.monthPrayerTimes,
    this.isLoading = false,
    this.error,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  PrayerTimesState copyWith({
    Object? todayPrayerTimes = _unset,
    Object? tomorrowPrayerTimes = _unset,
    Object? monthPrayerTimes = _unset,
    bool? isLoading,
    Object? error = _unset,
    DateTime? lastUpdated,
  }) {
    return PrayerTimesState(
      todayPrayerTimes: identical(todayPrayerTimes, _unset)
          ? this.todayPrayerTimes
          : todayPrayerTimes as PrayerTimesModel?,
      tomorrowPrayerTimes: identical(tomorrowPrayerTimes, _unset)
          ? this.tomorrowPrayerTimes
          : tomorrowPrayerTimes as PrayerTimesModel?,
      monthPrayerTimes: identical(monthPrayerTimes, _unset)
          ? this.monthPrayerTimes
          : monthPrayerTimes as List<PrayerTimesModel>?,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _unset) ? this.error : error as String?,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Prayer times notifier
class PrayerTimesNotifier extends StateNotifier<PrayerTimesState> {
  final Ref _ref;
  Timer? _refreshTimer;

  PrayerTimesNotifier(this._ref) : super(PrayerTimesState()) {
    _initialize();
  }

  /// Initialize prayer times
  Future<void> _initialize() async {
    await loadPrayerTimes();
    _startRefreshTimer();
  }

  /// Start refresh timer (refresh every hour)
  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(hours: 1), (_) {
      loadPrayerTimes();
    });
  }

  /// Load prayer times
  Future<void> loadPrayerTimes() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final settings = _ref.read(settingsProvider);
      
      // Load today's prayer times
      final todayTimes = await PrayerCalculationService.getTodayPrayerTimes(settings);
      
      // Load tomorrow's prayer times
      final tomorrowTimes = await PrayerCalculationService.getTomorrowPrayerTimes(settings);
      
      state = state.copyWith(
        todayPrayerTimes: todayTimes,
        tomorrowPrayerTimes: tomorrowTimes,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load prayer times: $e',
      );
    }
  }

  /// Load month prayer times
  Future<void> loadMonthPrayerTimes(int year, int month) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final settings = _ref.read(settingsProvider);
      
      final monthTimes = PrayerCalculationService.calculateMonthPrayerTimes(
        year: year,
        month: month,
        latitude: settings.latitude,
        longitude: settings.longitude,
        calculationMethod: settings.calculationMethod,
        madhab: settings.madhab,
      );

      state = state.copyWith(
        monthPrayerTimes: monthTimes,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load month prayer times: $e',
      );
    }
  }

  /// Get prayer times for specific date
  Future<PrayerTimesModel?> getPrayerTimesForDate(DateTime date) async {
    try {
      final settings = _ref.read(settingsProvider);
      return await PrayerCalculationService.getOrCalculatePrayerTimes(
        date: date,
        settings: settings,
      );
    } catch (e) {
      return null;
    }
  }

  /// Refresh prayer times
  Future<void> refresh() async {
    await loadPrayerTimes();
  }

  /// Get current prayer
  String getCurrentPrayer() {
    final todayTimes = state.todayPrayerTimes;
    if (todayTimes == null) return '';
    
    return todayTimes.getCurrentPrayer(DateTime.now());
  }

  /// Get next prayer
  String getNextPrayer() {
    final todayTimes = state.todayPrayerTimes;
    if (todayTimes == null) return '';
    
    return todayTimes.getNextPrayerName(DateTime.now());
  }

  /// Get time until next prayer
  Duration? getTimeUntilNextPrayer() {
    final todayTimes = state.todayPrayerTimes;
    if (todayTimes == null) return null;
    
    return todayTimes.getTimeUntilNextPrayer(DateTime.now());
  }

  /// Get time until Iftar
  Duration? getTimeUntilIftar() {
    final todayTimes = state.todayPrayerTimes;
    if (todayTimes == null) return null;
    
    return todayTimes.getTimeUntilIftar(DateTime.now());
  }

  /// Get time until Suhoor
  Duration? getTimeUntilSuhoor() {
    final todayTimes = state.todayPrayerTimes;
    if (todayTimes == null) return null;
    
    return todayTimes.getTimeUntilSuhoor(DateTime.now());
  }

  /// Check if currently fasting
  bool isFastingTime() {
    final todayTimes = state.todayPrayerTimes;
    if (todayTimes == null) return false;
    
    return todayTimes.isFastingTime(DateTime.now());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

/// Prayer times provider
final prayerTimesProvider = StateNotifierProvider<PrayerTimesNotifier, PrayerTimesState>((ref) {
  return PrayerTimesNotifier(ref);
});

/// Today's prayer times provider
final todayPrayerTimesProvider = Provider<PrayerTimesModel?>((ref) {
  return ref.watch(prayerTimesProvider).todayPrayerTimes;
});

/// Tomorrow's prayer times provider
final tomorrowPrayerTimesProvider = Provider<PrayerTimesModel?>((ref) {
  return ref.watch(prayerTimesProvider).tomorrowPrayerTimes;
});

/// Current prayer provider
final currentPrayerProvider = Provider<String>((ref) {
  final notifier = ref.read(prayerTimesProvider.notifier);
  return notifier.getCurrentPrayer();
});

/// Next prayer provider
final nextPrayerProvider = Provider<String>((ref) {
  final notifier = ref.read(prayerTimesProvider.notifier);
  return notifier.getNextPrayer();
});

/// Time until next prayer provider
final timeUntilNextPrayerProvider = Provider<Duration?>((ref) {
  final notifier = ref.read(prayerTimesProvider.notifier);
  return notifier.getTimeUntilNextPrayer();
});

/// Time until Iftar provider
final timeUntilIftarProvider = Provider<Duration?>((ref) {
  final notifier = ref.read(prayerTimesProvider.notifier);
  return notifier.getTimeUntilIftar();
});

/// Time until Suhoor provider
final timeUntilSuhoorProvider = Provider<Duration?>((ref) {
  final notifier = ref.read(prayerTimesProvider.notifier);
  return notifier.getTimeUntilSuhoor();
});

/// Is fasting time provider
final isFastingTimeProvider = Provider<bool>((ref) {
  final notifier = ref.read(prayerTimesProvider.notifier);
  return notifier.isFastingTime();
});

/// Prayer times loading provider
final prayerTimesLoadingProvider = Provider<bool>((ref) {
  return ref.watch(prayerTimesProvider).isLoading;
});

/// Prayer times error provider
final prayerTimesErrorProvider = Provider<String?>((ref) {
  return ref.watch(prayerTimesProvider).error;
});

/// Current prayer info provider (comprehensive)
final currentPrayerInfoProvider = Provider<Map<String, dynamic>>((ref) {
  final prayerTimes = ref.watch(todayPrayerTimesProvider);
  if (prayerTimes == null) {
    return {
      'current': '',
      'next': '',
      'timeUntilNext': Duration.zero,
      'progress': 0.0,
    };
  }

  final now = DateTime.now();
  final current = prayerTimes.getCurrentPrayer(now);
  final next = prayerTimes.getNextPrayerName(now);
  final timeUntilNext = prayerTimes.getTimeUntilNextPrayer(now);
  
  // Calculate progress to next prayer
  final nextPrayerTime = prayerTimes.getNextPrayerTime(now);
  final currentPrayerTime = prayerTimes.getPrayerTime(current);
  double progress = 0.0;
  
  if (currentPrayerTime != null) {
    final totalDuration = nextPrayerTime.difference(currentPrayerTime);
    final elapsed = now.difference(currentPrayerTime);
    progress = elapsed.inSeconds / totalDuration.inSeconds;
    progress = progress.clamp(0.0, 1.0);
  }

  return {
    'current': current,
    'next': next,
    'timeUntilNext': timeUntilNext,
    'progress': progress,
  };
});

/// Iftar countdown provider (for home screen)
final iftarCountdownProvider = StreamProvider<Duration>((ref) async* {
  while (true) {
    final prayerTimes = ref.read(todayPrayerTimesProvider);
    if (prayerTimes != null) {
      final timeUntilIftar = prayerTimes.getTimeUntilIftar(DateTime.now());
      yield timeUntilIftar ?? Duration.zero;
    } else {
      yield Duration.zero;
    }
    await Future.delayed(const Duration(seconds: 1));
  }
});

/// Suhoor countdown provider
final suhoorCountdownProvider = StreamProvider<Duration>((ref) async* {
  while (true) {
    final prayerTimes = ref.read(todayPrayerTimesProvider);
    if (prayerTimes != null) {
      final timeUntilSuhoor = prayerTimes.getTimeUntilSuhoor(DateTime.now());
      yield timeUntilSuhoor ?? Duration.zero;
    } else {
      yield Duration.zero;
    }
    await Future.delayed(const Duration(seconds: 1));
  }
});

/// Tasbih Provider
/// Manages tasbih/dhikr counter state using Riverpod

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';
import 'package:hive/hive.dart';

import '../models/tasbih_model.dart';
import 'settings_provider.dart';

final Object _unset = Object();

/// Tasbih state
class TasbihState {
  final TasbihSession? currentSession;
  final DhikrType selectedDhikr;
  final int count;
  final int targetCount;
  final bool isActive;
  final bool showConfetti;
  final List<TasbihSession> todaySessions;
  final DailyTasbihSummary? todaySummary;

  TasbihState({
    this.currentSession,
    this.selectedDhikr = DhikrType.subhanAllah,
    this.count = 0,
    this.targetCount = 33,
    this.isActive = false,
    this.showConfetti = false,
    this.todaySessions = const [],
    this.todaySummary,
  });

  TasbihState copyWith({
    Object? currentSession = _unset,
    DhikrType? selectedDhikr,
    int? count,
    int? targetCount,
    bool? isActive,
    bool? showConfetti,
    List<TasbihSession>? todaySessions,
    Object? todaySummary = _unset,
  }) {
    return TasbihState(
      currentSession: identical(currentSession, _unset)
          ? this.currentSession
          : currentSession as TasbihSession?,
      selectedDhikr: selectedDhikr ?? this.selectedDhikr,
      count: count ?? this.count,
      targetCount: targetCount ?? this.targetCount,
      isActive: isActive ?? this.isActive,
      showConfetti: showConfetti ?? this.showConfetti,
      todaySessions: todaySessions ?? this.todaySessions,
      todaySummary: identical(todaySummary, _unset)
          ? this.todaySummary
          : todaySummary as DailyTasbihSummary?,
    );
  }

  /// Get progress percentage
  double get progress => targetCount > 0 ? count / targetCount : 0.0;

  /// Check if target reached
  bool get isTargetReached => count >= targetCount;

  /// Get remaining count
  int get remainingCount => (targetCount - count).clamp(0, targetCount);
}

/// Tasbih notifier
class TasbihNotifier extends StateNotifier<TasbihState> {
  final Ref _ref;
  final Box<TasbihSession> _box;
  Timer? _confettiTimer;

  TasbihNotifier(this._ref, this._box) : super(TasbihState()) {
    _loadTodaySessions();
  }

  /// Load today's sessions
  void _loadTodaySessions() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final sessions = _box.values.where((session) {
      return session.startTime.isAfter(startOfDay) &&
             session.startTime.isBefore(endOfDay);
    }).toList();

    final summary = _calculateDailySummary(sessions);

    state = state.copyWith(
      todaySessions: sessions,
      todaySummary: summary,
    );
  }

  /// Calculate daily summary
  DailyTasbihSummary _calculateDailySummary(List<TasbihSession> sessions) {
    if (sessions.isEmpty) {
      return DailyTasbihSummary.empty(DateTime.now());
    }

    final Map<DhikrType, int> dhikrCounts = {};
    int totalCount = 0;
    int goalsReached = 0;

    for (final session in sessions) {
      dhikrCounts[session.dhikrType] = 
          (dhikrCounts[session.dhikrType] ?? 0) + session.count;
      totalCount += session.count;
      if (session.isTargetReached) goalsReached++;
    }

    return DailyTasbihSummary(
      date: DateTime.now(),
      dhikrCounts: dhikrCounts,
      totalCount: totalCount,
      sessionsCompleted: sessions.length,
      goalsReached: goalsReached,
    );
  }

  /// Select dhikr type
  void selectDhikr(DhikrType dhikrType) {
    // Save current session if active
    if (state.isActive && state.count > 0) {
      _saveCurrentSession();
    }

    state = state.copyWith(
      selectedDhikr: dhikrType,
      count: 0,
      targetCount: dhikrType.recommendedCount,
      isActive: false,
      currentSession: null,
      showConfetti: false,
    );
  }

  /// Set custom target count
  void setTargetCount(int target) {
    state = state.copyWith(targetCount: target);
  }

  /// Start new session
  void startSession() {
    final session = TasbihSession.create(
      dhikrType: state.selectedDhikr,
      targetCount: state.targetCount,
    );

    state = state.copyWith(
      currentSession: session,
      isActive: true,
      count: 0,
      showConfetti: false,
    );
  }

  /// Increment counter
  Future<void> increment() async {
    if (!state.isActive) {
      startSession();
    }

    final newCount = state.count + 1;
    final isTargetReached = newCount >= state.targetCount;

    // Trigger haptic feedback
    await _triggerHaptic();

    state = state.copyWith(
      count: newCount,
      showConfetti: isTargetReached && !state.showConfetti,
    );

    // Show confetti and complete session if target reached
    if (isTargetReached && !state.showConfetti) {
      _completeSession();
    }
  }

  /// Trigger haptic feedback
  Future<void> _triggerHaptic() async {
    final settings = _ref.read(settingsProvider);
    if (!settings.enableTasbihHaptics) return;

    final hasVibrator = await Vibration.hasVibrator() ?? false;
    if (!hasVibrator) return;

    // Different vibration patterns based on count
    if (state.count % 33 == 0 && state.count > 0) {
      // Strong vibration at multiples of 33
      await Vibration.vibrate(pattern: [0, 100, 50, 100, 50, 200]);
    } else if (state.count % 10 == 0) {
      // Medium vibration at multiples of 10
      await Vibration.vibrate(pattern: [0, 50, 50, 100]);
    } else {
      // Light vibration for each count
      await Vibration.vibrate(duration: 20);
    }
  }

  /// Complete session
  void _completeSession() {
    if (state.currentSession != null) {
      state.currentSession!.count = state.count;
      state.currentSession!.complete();
      _saveCurrentSession();

      // Hide confetti after 3 seconds
      _confettiTimer?.cancel();
      _confettiTimer = Timer(const Duration(seconds: 3), () {
        state = state.copyWith(showConfetti: false);
      });

      // Reload today's sessions
      _loadTodaySessions();
    }
  }

  /// Save current session
  Future<void> _saveCurrentSession() async {
    if (state.currentSession != null) {
      await _box.put(state.currentSession!.id, state.currentSession!);
    }
  }

  /// Reset counter
  void reset() {
    if (state.isActive && state.count > 0) {
      _saveCurrentSession();
    }

    state = state.copyWith(
      count: 0,
      isActive: false,
      currentSession: null,
      showConfetti: false,
    );
  }

  /// Undo last increment
  void undo() {
    if (state.count > 0) {
      state = state.copyWith(count: state.count - 1);
    }
  }

  /// Get total count for dhikr type (all time)
  int getTotalCountForDhikr(DhikrType type) {
    return _box.values
        .where((session) => session.dhikrType == type)
        .fold(0, (sum, session) => sum + session.count);
  }

  /// Get all-time total count
  int getAllTimeTotalCount() {
    return _box.values.fold(0, (sum, session) => sum + session.count);
  }

  /// Get sessions for date range
  List<TasbihSession> getSessionsForRange(DateTime start, DateTime end) {
    return _box.values.where((session) {
      return session.startTime.isAfter(start) &&
             session.startTime.isBefore(end);
    }).toList();
  }

  /// Hide confetti
  void hideConfetti() {
    state = state.copyWith(showConfetti: false);
  }

  @override
  void dispose() {
    _confettiTimer?.cancel();
    if (state.isActive && state.count > 0) {
      _saveCurrentSession();
    }
    super.dispose();
  }
}

/// Tasbih provider
final tasbihProvider = StateNotifierProvider<TasbihNotifier, TasbihState>((ref) {
  final box = Hive.box<TasbihSession>('tasbih_sessions');
  return TasbihNotifier(ref, box);
});

/// Selected dhikr provider
final selectedDhikrProvider = Provider<DhikrType>((ref) {
  return ref.watch(tasbihProvider).selectedDhikr;
});

/// Tasbih count provider
final tasbihCountProvider = Provider<int>((ref) {
  return ref.watch(tasbihProvider).count;
});

/// Tasbih target provider
final tasbihTargetProvider = Provider<int>((ref) {
  return ref.watch(tasbihProvider).targetCount;
});

/// Tasbih progress provider
final tasbihProgressProvider = Provider<double>((ref) {
  return ref.watch(tasbihProvider).progress;
});

/// Tasbih is target reached provider
final tasbihTargetReachedProvider = Provider<bool>((ref) {
  return ref.watch(tasbihProvider).isTargetReached;
});

/// Tasbih show confetti provider
final tasbihConfettiProvider = Provider<bool>((ref) {
  return ref.watch(tasbihProvider).showConfetti;
});

/// Today's tasbih sessions provider
final todayTasbihSessionsProvider = Provider<List<TasbihSession>>((ref) {
  return ref.watch(tasbihProvider).todaySessions;
});

/// Today's tasbih summary provider
final todayTasbihSummaryProvider = Provider<DailyTasbihSummary?>((ref) {
  return ref.watch(tasbihProvider).todaySummary;
});

/// All dhikr types provider
final allDhikrTypesProvider = Provider<List<DhikrType>>((ref) {
  return DhikrTypeExtension.all;
});

/// Dhikr info provider
final dhikrInfoProvider = Provider.family<Map<String, String>, DhikrType>((ref, type) {
  return {
    'arabic': type.arabic,
    'transliteration': type.transliteration,
    'translation': type.translation,
    'bangla': type.bangla,
    'recommendedCount': type.recommendedCount.toString(),
  };
});

/// Tasbih stats provider
final tasbihStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final notifier = ref.read(tasbihProvider.notifier);
  final todaySummary = ref.watch(todayTasbihSummaryProvider);

  return {
    'todayTotal': todaySummary?.totalCount ?? 0,
    'todaySessions': todaySummary?.sessionsCompleted ?? 0,
    'todayGoalsReached': todaySummary?.goalsReached ?? 0,
    'allTimeTotal': notifier.getAllTimeTotalCount(),
  };
});

/// Weekly tasbih data provider (for charts)
final weeklyTasbihDataProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final notifier = ref.read(tasbihProvider.notifier);
  final now = DateTime.now();
  final weekAgo = now.subtract(const Duration(days: 7));

  final sessions = notifier.getSessionsForRange(weekAgo, now);
  
  // Group by day
  final Map<String, int> dailyCounts = {};
  for (int i = 0; i < 7; i++) {
    final date = now.subtract(Duration(days: i));
    final key = '${date.year}-${date.month}-${date.day}';
    dailyCounts[key] = 0;
  }

  for (final session in sessions) {
    final key = '${session.startTime.year}-${session.startTime.month}-${session.startTime.day}';
    dailyCounts[key] = (dailyCounts[key] ?? 0) + session.count;
  }

  return dailyCounts.entries.map((e) {
    final parts = e.key.split('-');
    final date = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
    return {
      'date': date,
      'count': e.value,
    };
  }).toList()
    ..sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
});

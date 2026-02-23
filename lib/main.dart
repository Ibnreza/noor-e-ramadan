/// NOOR RAMADAN 2026 - The #1 Islamic App
/// Built for Bangladesh (Chandpur) with offline-first architecture
/// Features: Prayer Times, Qibla Compass, Tasbih 2.0, Gamified Dashboard
/// 
/// Architecture: Clean Architecture with Riverpod State Management
/// Storage: Hive for local persistence
/// Prayer Calculation: Adhan Dart with Karachi method
/// 
/// Author: Senior Flutter Architect
/// Version: 2.0.0+2026

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'models/prayer_times_model.dart';
import 'models/tasbih_model.dart';
import 'models/user_settings_model.dart';
import 'models/badge_model.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(PrayerTimesModelAdapter());
  Hive.registerAdapter(TasbihSessionAdapter());
  Hive.registerAdapter(UserSettingsAdapter());
  Hive.registerAdapter(BadgeModelAdapter());
  Hive.registerAdapter(DhikrTypeAdapter());
  
  // Open Hive boxes
  await Hive.openBox<PrayerTimesModel>('prayer_times');
  await Hive.openBox<TasbihSession>('tasbih_sessions');
  await Hive.openBox<UserSettings>('user_settings');
  await Hive.openBox<BadgeModel>('badges');
  await Hive.openBox('fasting_streak');
  
  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style for dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0F1E),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(
    ProviderScope(
      overrides: [
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const NoorRamadanApp(),
    ),
  );
}

/// Global notification service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw UnimplementedError('Should be overridden in main');
});

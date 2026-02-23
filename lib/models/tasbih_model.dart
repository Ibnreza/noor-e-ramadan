/// Tasbih Model - Dhikr Counter and Session Tracking
/// Supports 15+ dhikr presets with daily history

import 'package:hive/hive.dart';

part 'tasbih_model.g.dart';

/// Dhikr Types - 15+ presets
@HiveType(typeId: 4)
enum DhikrType {
  @HiveField(0)
  allah,           // الله
  
  @HiveField(1)
  subhanAllah,     // سبحان الله
  
  @HiveField(2)
  alhamdulillah,   // الحمد لله
  
  @HiveField(3)
  allahuAkbar,     // الله أكبر
  
  @HiveField(4)
  astaghfirullah,  // أستغفر الله
  
  @HiveField(5)
  laIlahaIllallah, // لا إله إلا الله
  
  @HiveField(6)
  salawat,         // اللهم صل على محمد
  
  @HiveField(7)
  hasbunallahu,    // حسبي الله ونعم الوكيل
  
  @HiveField(8)
  bismillah,       // بسم الله
  
  @HiveField(9)
  laHawla,         // لا حول ولا قوة إلا بالله
  
  @HiveField(10)
  subhanAllahi,    // سبحان الله وبحمده
  
  @HiveField(11)
  rabbanaghfirli,  // رب اغفر لي
  
  @HiveField(12)
  allahummaAmin,   // اللهم آمين
  
  @HiveField(13)
  tahmid,          // الحمد لله رب العالمين
  
  @HiveField(14)
  takbir,          // الله أكبر كبيرا
  
  @HiveField(15)
  tasbih,          // سبحان الله العظيم
  
  @HiveField(16)
  custom,          // User custom dhikr
}

/// Extension for DhikrType to get display properties
extension DhikrTypeExtension on DhikrType {
  /// Arabic text
  String get arabic {
    switch (this) {
      case DhikrType.allah:
        return 'الله';
      case DhikrType.subhanAllah:
        return 'سبحان الله';
      case DhikrType.alhamdulillah:
        return 'الحمد لله';
      case DhikrType.allahuAkbar:
        return 'الله أكبر';
      case DhikrType.astaghfirullah:
        return 'أستغفر الله';
      case DhikrType.laIlahaIllallah:
        return 'لا إله إلا الله';
      case DhikrType.salawat:
        return 'اللهم صل على محمد';
      case DhikrType.hasbunallahu:
        return 'حسبي الله ونعم الوكيل';
      case DhikrType.bismillah:
        return 'بسم الله';
      case DhikrType.laHawla:
        return 'لا حول ولا قوة إلا بالله';
      case DhikrType.subhanAllahi:
        return 'سبحان الله وبحمده';
      case DhikrType.rabbanaghfirli:
        return 'رب اغفر لي';
      case DhikrType.allahummaAmin:
        return 'اللهم آمين';
      case DhikrType.tahmid:
        return 'الحمد لله رب العالمين';
      case DhikrType.takbir:
        return 'الله أكبر كبيرا';
      case DhikrType.tasbih:
        return 'سبحان الله العظيم';
      case DhikrType.custom:
        return 'Custom';
    }
  }

  /// Transliteration
  String get transliteration {
    switch (this) {
      case DhikrType.allah:
        return 'Allah';
      case DhikrType.subhanAllah:
        return 'SubhanAllah';
      case DhikrType.alhamdulillah:
        return 'Alhamdulillah';
      case DhikrType.allahuAkbar:
        return 'Allahu Akbar';
      case DhikrType.astaghfirullah:
        return 'Astaghfirullah';
      case DhikrType.laIlahaIllallah:
        return 'La ilaha illallah';
      case DhikrType.salawat:
        return 'Allahumma salli ala Muhammad';
      case DhikrType.hasbunallahu:
        return 'Hasbunallahu wa ni\'mal wakeel';
      case DhikrType.bismillah:
        return 'Bismillah';
      case DhikrType.laHawla:
        return 'La hawla wa la quwwata illa billah';
      case DhikrType.subhanAllahi:
        return 'SubhanAllahi wa bihamdihi';
      case DhikrType.rabbanaghfirli:
        return 'Rabbanaghfir li';
      case DhikrType.allahummaAmin:
        return 'Allahumma Amin';
      case DhikrType.tahmid:
        return 'Alhamdulillahi Rabbil Alamin';
      case DhikrType.takbir:
        return 'Allahu Akbar Kabira';
      case DhikrType.tasbih:
        return 'SubhanAllahil Adheem';
      case DhikrType.custom:
        return 'Custom Dhikr';
    }
  }

  /// English translation
  String get translation {
    switch (this) {
      case DhikrType.allah:
        return 'God';
      case DhikrType.subhanAllah:
        return 'Glory be to Allah';
      case DhikrType.alhamdulillah:
        return 'Praise be to Allah';
      case DhikrType.allahuAkbar:
        return 'Allah is the Greatest';
      case DhikrType.astaghfirullah:
        return 'I seek forgiveness from Allah';
      case DhikrType.laIlahaIllallah:
        return 'There is no god but Allah';
      case DhikrType.salawat:
        return 'O Allah, send blessings upon Muhammad';
      case DhikrType.hasbunallahu:
        return 'Allah is sufficient for us';
      case DhikrType.bismillah:
        return 'In the name of Allah';
      case DhikrType.laHawla:
        return 'There is no power except with Allah';
      case DhikrType.subhanAllahi:
        return 'Glory be to Allah and praise Him';
      case DhikrType.rabbanaghfirli:
        return 'My Lord, forgive me';
      case DhikrType.allahummaAmin:
        return 'O Allah, accept';
      case DhikrType.tahmid:
        return 'Praise be to Allah, Lord of the Worlds';
      case DhikrType.takbir:
        return 'Allah is the Greatest, the Most Great';
      case DhikrType.tasbih:
        return 'Glory be to Allah, the Magnificent';
      case DhikrType.custom:
        return 'Custom';
    }
  }

  /// Bangla translation
  String get bangla {
    switch (this) {
      case DhikrType.allah:
        return 'আল্লাহ';
      case DhikrType.subhanAllah:
        return 'সুবহানআল্লাহ';
      case DhikrType.alhamdulillah:
        return 'আলহামদুলিল্লাহ';
      case DhikrType.allahuAkbar:
        return 'আল্লাহু আকবর';
      case DhikrType.astaghfirullah:
        return 'আস্তাগফিরুল্লাহ';
      case DhikrType.laIlahaIllallah:
        return 'লা ইলাহা ইল্লাল্লাহ';
      case DhikrType.salawat:
        return 'আল্লাহুম্মা সাল্লি আলা মুহাম্মাদ';
      case DhikrType.hasbunallahu:
        return 'হাসবুনাল্লাহু ওয়া নি'মাল ওয়াকীল';
      case DhikrType.bismillah:
        return 'বিসমিল্লাহ';
      case DhikrType.laHawla:
        return 'লা হাওলা ওয়ালা কুওয়াতা ইল্লা বিল্লাহ';
      case DhikrType.subhanAllahi:
        return 'সুবহানাল্লাহি ওয়া বিহামদিহি';
      case DhikrType.rabbanaghfirli:
        return 'রাব্বনাগফির লি';
      case DhikrType.allahummaAmin:
        return 'আল্লাহুম্মা আমিন';
      case DhikrType.tahmid:
        return 'আলহামদুলিল্লাহি রাব্বিল আলামিন';
      case DhikrType.takbir:
        return 'আল্লাহু আকবার কাবিরা';
      case DhikrType.tasbih:
        return 'সুবহানাল্লাহিল আজিম';
      case DhikrType.custom:
        return 'কাস্টম';
    }
  }

  /// Recommended count (traditional)
  int get recommendedCount {
    switch (this) {
      case DhikrType.subhanAllah:
      case DhikrType.alhamdulillah:
      case DhikrType.allahuAkbar:
        return 33;
      case DhikrType.allah:
      case DhikrType.astaghfirullah:
        return 100;
      case DhikrType.laIlahaIllallah:
        return 100;
      case DhikrType.salawat:
        return 10;
      default:
        return 33;
    }
  }

  /// Get all available dhikr types
  static List<DhikrType> get all => [
    DhikrType.allah,
    DhikrType.subhanAllah,
    DhikrType.alhamdulillah,
    DhikrType.allahuAkbar,
    DhikrType.astaghfirullah,
    DhikrType.laIlahaIllallah,
    DhikrType.salawat,
    DhikrType.hasbunallahu,
    DhikrType.bismillah,
    DhikrType.laHawla,
    DhikrType.subhanAllahi,
    DhikrType.rabbanaghfirli,
    DhikrType.allahummaAmin,
    DhikrType.tahmid,
    DhikrType.takbir,
    DhikrType.tasbih,
  ];
}

/// Tasbih Session - Tracks a single dhikr session
@HiveType(typeId: 2)
class TasbihSession extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final DhikrType dhikrType;
  
  @HiveField(2)
  final DateTime startTime;
  
  @HiveField(3)
  DateTime? endTime;
  
  @HiveField(4)
  int count;
  
  @HiveField(5)
  final int targetCount;
  
  @HiveField(6)
  final String? customDhikrText;

  TasbihSession({
    required this.id,
    required this.dhikrType,
    required this.startTime,
    this.endTime,
    this.count = 0,
    required this.targetCount,
    this.customDhikrText,
  });

  /// Create new session
  factory TasbihSession.create({
    required DhikrType dhikrType,
    int? targetCount,
    String? customDhikrText,
  }) {
    return TasbihSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      dhikrType: dhikrType,
      startTime: DateTime.now(),
      count: 0,
      targetCount: targetCount ?? dhikrType.recommendedCount,
      customDhikrText: customDhikrText,
    );
  }

  /// Increment counter
  void increment() {
    count++;
  }

  /// Check if target reached
  bool get isTargetReached => count >= targetCount;

  /// Get progress percentage
  double get progress => (count / targetCount).clamp(0.0, 1.0);

  /// Complete the session
  void complete() {
    endTime = DateTime.now();
  }

  /// Get duration
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// Format duration for display
  String get formattedDuration {
    final d = duration;
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  @override
  String toString() {
    return 'TasbihSession(dhikr: ${dhikrType.arabic}, count: $count/$targetCount)';
  }
}

/// Daily Tasbih Summary
@HiveType(typeId: 5)
class DailyTasbihSummary extends HiveObject {
  @HiveField(0)
  final DateTime date;
  
  @HiveField(1)
  final Map<DhikrType, int> dhikrCounts;
  
  @HiveField(2)
  final int totalCount;
  
  @HiveField(3)
  final int sessionsCompleted;
  
  @HiveField(4)
  final int goalsReached;

  DailyTasbihSummary({
    required this.date,
    required this.dhikrCounts,
    required this.totalCount,
    required this.sessionsCompleted,
    required this.goalsReached,
  });

  /// Create empty summary for date
  factory DailyTasbihSummary.empty(DateTime date) {
    return DailyTasbihSummary(
      date: date,
      dhikrCounts: {},
      totalCount: 0,
      sessionsCompleted: 0,
      goalsReached: 0,
    );
  }

  /// Add session to summary
  DailyTasbihSummary addSession(TasbihSession session) {
    final newCounts = Map<DhikrType, int>.from(dhikrCounts);
    newCounts[session.dhikrType] = (newCounts[session.dhikrType] ?? 0) + session.count;
    
    return DailyTasbihSummary(
      date: date,
      dhikrCounts: newCounts,
      totalCount: totalCount + session.count,
      sessionsCompleted: sessionsCompleted + 1,
      goalsReached: goalsReached + (session.isTargetReached ? 1 : 0),
    );
  }
}

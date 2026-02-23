/// Next Prayer Card Widget
/// Shows the next prayer time with countdown

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/prayer_times_model.dart';
import '../../../providers/prayer_times_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../widgets/countdown_timer.dart';

class NextPrayerCard extends ConsumerWidget {
  const NextPrayerCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isBangla = settings.languageCode == 'bn';
    final prayerTimes = ref.watch(todayPrayerTimesProvider);
    final nextPrayer = ref.watch(nextPrayerProvider);
    final timeUntilNext = ref.watch(timeUntilNextPrayerProvider);

    if (prayerTimes == null) {
      return const SizedBox.shrink();
    }

    final nextPrayerTime = prayerTimes.getNextPrayerTime(DateTime.now());
    final prayerName = _getPrayerName(nextPrayer, isBangla);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1629),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1A2342),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isBangla ? 'পরবর্তী নামাজ' : 'Next Prayer',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5C0).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  prayerName,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00E5C0),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              // Prayer time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      PrayerTimesModel.formatTime(nextPrayerTime),
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (settings.showArabicInPrayerTimes)
                      Text(
                        _getPrayerNameArabic(nextPrayer),
                        style: GoogleFonts.amiri(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Countdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2342),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      isBangla ? 'বাকি' : 'In',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.white60,
                      ),
                    ),
                    const SizedBox(height: 4),
                    CountdownTimer(
                      targetTime: DateTime.now().add(timeUntilNext ?? Duration.zero),
                      compact: true,
                      fontSize: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getPrayerName(String prayer, bool isBangla) {
    if (isBangla) {
      switch (prayer.toLowerCase()) {
        case 'fajr':
          return 'ফজর';
        case 'sunrise':
          return 'সূর্যোদয়';
        case 'dhuhr':
          return 'যোহর';
        case 'asr':
          return 'আসর';
        case 'maghrib':
          return 'মাগরিব';
        case 'isha':
          return 'এশা';
        default:
          return prayer;
      }
    }
    return prayer.substring(0, 1).toUpperCase() + prayer.substring(1);
  }

  String _getPrayerNameArabic(String prayer) {
    switch (prayer.toLowerCase()) {
      case 'fajr':
        return 'الفجر';
      case 'sunrise':
        return 'الشروق';
      case 'dhuhr':
        return 'الظهر';
      case 'asr':
        return 'العصر';
      case 'maghrib':
        return 'المغرب';
      case 'isha':
        return 'العشاء';
      default:
        return prayer;
    }
  }
}

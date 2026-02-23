/// Prayer Times Screen
/// Shows all prayer times with notifications toggle

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../models/prayer_times_model.dart';
import '../../providers/prayer_times_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/notification_service_provider.dart';

class PrayerTimesScreen extends ConsumerWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isBangla = settings.languageCode == 'bn';
    final prayerTimes = ref.watch(todayPrayerTimesProvider);
    final isLoading = ref.watch(prayerTimesLoadingProvider);
    final error = ref.watch(prayerTimesErrorProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0F1E),
        elevation: 0,
        title: Text(
          isBangla ? 'নামাজের সময়' : 'Prayer Times',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(prayerTimesProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00E5C0),
              ),
            )
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        error,
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : prayerTimes == null
                  ? const Center(
                      child: Text(
                        'No prayer times available',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              // Date Header
                              _buildDateHeader(context, ref, prayerTimes),
                              
                              const SizedBox(height: 24),
                              
                              // Prayer Times List
                              _buildPrayerTimesList(context, ref, prayerTimes),
                              
                              const SizedBox(height: 24),
                              
                              // Notification Settings
                              _buildNotificationSettings(context, ref),
                              
                              const SizedBox(height: 24),
                              
                              // Location Info
                              _buildLocationInfo(context, ref),
                              
                              const SizedBox(height: 32),
                            ]),
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildDateHeader(BuildContext context, WidgetRef ref, PrayerTimesModel prayerTimes) {
    final settings = ref.watch(settingsProvider);
    final isBangla = settings.languageCode == 'bn';
    final now = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF00E5C0),
            Color(0xFF00BFA5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            isBangla ? 'আজ' : 'Today',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF0A0F1E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('EEEE, d MMMM yyyy').format(now),
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0A0F1E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            HijriDateConverter.toHijri(now),
            style: GoogleFonts.amiri(
              fontSize: 16,
              color: const Color(0xFF0A0F1E),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildPrayerTimesList(BuildContext context, WidgetRef ref, PrayerTimesModel prayerTimes) {
    final settings = ref.watch(settingsProvider);
    final isBangla = settings.languageCode == 'bn';
    final currentPrayer = ref.watch(currentPrayerProvider);

    final prayers = [
      ('imsak', prayerTimes.imsak, isBangla ? 'ইমসাক' : 'Imsak', false),
      ('fajr', prayerTimes.fajr, isBangla ? 'ফজর' : 'Fajr', true),
      ('sunrise', prayerTimes.sunrise, isBangla ? 'সূর্যোদয়' : 'Sunrise', false),
      ('dhuhr', prayerTimes.dhuhr, isBangla ? 'যোহর' : 'Dhuhr', true),
      ('asr', prayerTimes.asr, isBangla ? 'আসর' : 'Asr', true),
      ('maghrib', prayerTimes.maghrib, isBangla ? 'মাগরিব' : 'Maghrib', true),
      ('isha', prayerTimes.isha, isBangla ? 'এশা' : 'Isha', true),
    ];

    return Column(
      children: prayers.asMap().entries.map((entry) {
        final index = entry.key;
        final (name, time, label, hasNotification) = entry.value;
        final isCurrent = currentPrayer == name;
        final isPast = time.isBefore(DateTime.now());

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCurrent 
                ? const Color(0xFF00E5C0).withOpacity(0.1)
                : const Color(0xFF0F1629),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCurrent 
                  ? const Color(0xFF00E5C0)
                  : const Color(0xFF1A2342),
              width: isCurrent ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Prayer icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCurrent
                      ? const Color(0xFF00E5C0).withOpacity(0.2)
                      : const Color(0xFF1A2342),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    _getPrayerIcon(name),
                    color: isCurrent 
                        ? const Color(0xFF00E5C0)
                        : (isPast ? Colors.white38 : Colors.white70),
                    size: 24,
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Prayer name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isPast ? Colors.white38 : Colors.white,
                      ),
                    ),
                    if (settings.showArabicInPrayerTimes)
                      Text(
                        _getArabicName(name),
                        style: GoogleFonts.amiri(
                          fontSize: 14,
                          color: isPast ? Colors.white24 : Colors.white60,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Time
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    settings.use24HourFormat
                        ? PrayerTimesModel.formatTime24(time)
                        : PrayerTimesModel.formatTime(time),
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isPast ? Colors.white38 : Colors.white,
                    ),
                  ),
                  if (isCurrent)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E5C0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isBangla ? 'বর্তমান' : 'Current',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0A0F1E),
                        ),
                      ),
                    ),
                ],
              ),
              
              // Notification toggle
              if (hasNotification)
                IconButton(
                  icon: Icon(
                    settings.enablePrayerNotifications
                        ? Icons.notifications
                        : Icons.notifications_off,
                    color: settings.enablePrayerNotifications
                        ? const Color(0xFF00E5C0)
                        : Colors.white38,
                    size: 20,
                  ),
                  onPressed: () {
                    ref.read(settingsProvider.notifier).togglePrayerNotifications();
                  },
                ),
            ],
          ),
        ).animate(
          delay: (index * 100).ms,
        ).fadeIn(duration: 500.ms).slideX(begin: -0.2, end: 0);
      }).toList(),
    );
  }

  IconData _getPrayerIcon(String prayer) {
    switch (prayer) {
      case 'fajr':
        return Icons.wb_twilight;
      case 'sunrise':
        return Icons.wb_sunny;
      case 'dhuhr':
        return Icons.sunny;
      case 'asr':
        return Icons.wb_cloudy;
      case 'maghrib':
        return Icons.nights_stay;
      case 'isha':
        return Icons.bedtime;
      case 'imsak':
        return Icons.no_food;
      default:
        return Icons.access_time;
    }
  }

  String _getArabicName(String prayer) {
    switch (prayer) {
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
      case 'imsak':
        return 'الإمساك';
      default:
        return '';
    }
  }

  Widget _buildNotificationSettings(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isBangla = settings.languageCode == 'bn';

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
          Text(
            isBangla ? 'নোটিফিকেশন সেটিংস' : 'Notification Settings',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Prayer notifications
          _buildSwitchTile(
            title: isBangla ? 'নামাজের নোটিফিকেশন' : 'Prayer Notifications',
            subtitle: isBangla 
                ? 'প্রতিটি নামাজের সময় নোটিফিকেশন পান'
                : 'Get notified at prayer times',
            value: settings.enablePrayerNotifications,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).togglePrayerNotifications();
            },
          ),
          
          // Pre-prayer notifications
          _buildSwitchTile(
            title: isBangla ? 'পূর্ব নোটিফিকেশন' : 'Pre-Prayer Reminders',
            subtitle: isBangla
                ? '${settings.prePrayerNotificationMinutes} মিনিট আগে রিমাইন্ডার'
                : '${settings.prePrayerNotificationMinutes} minutes before',
            value: settings.enablePrePrayerNotifications,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).togglePrePrayerNotifications();
            },
          ),
          
          // Fasting notifications
          _buildSwitchTile(
            title: isBangla ? 'রোজার নোটিফিকেশন' : 'Fasting Notifications',
            subtitle: isBangla
                ? 'সেহরি ও ইফতারের নোটিফিকেশন'
                : 'Suhoor and Iftar notifications',
            value: settings.enableFastingNotifications,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleFastingNotifications();
            },
          ),
          
          // Vibration
          _buildSwitchTile(
            title: isBangla ? 'ভাইব্রেশন' : 'Vibration',
            subtitle: isBangla
                ? 'নোটিফিকেশনের সময় ভাইব্রেট করুন'
                : 'Vibrate on notifications',
            value: settings.enableVibration,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleVibration();
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms, duration: 500.ms);
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF00E5C0),
            activeTrackColor: const Color(0xFF00E5C0).withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isBangla = settings.languageCode == 'bn';

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
          Text(
            isBangla ? 'অবস্থান' : 'Location',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Color(0xFF00E5C0),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      settings.locationName,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${settings.latitude.toStringAsFixed(4)}, ${settings.longitude.toStringAsFixed(4)}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Calculation method
          Row(
            children: [
              const Icon(
                Icons.calculate,
                color: Color(0xFF00E5C0),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBangla ? 'গণনা পদ্ধতি' : 'Calculation Method',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white60,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      settings.calculationMethodDisplay,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms, duration: 500.ms);
  }
}

/// Simple Hijri date converter
class HijriDateConverter {
  static String toHijri(DateTime gregorianDate) {
    // Approximate conversion for display purposes
    // In production, use a proper Hijri calendar library
    final hijriYear = gregorianDate.year - 579;
    final hijriMonth = ((gregorianDate.month + 1) % 12) + 1;
    final hijriDay = gregorianDate.day;
    
    final monthNames = [
      'Muharram', 'Safar', 'Rabi\' al-awwal', 'Rabi\' al-thani',
      'Jumada al-awwal', 'Jumada al-thani', 'Rajab', 'Sha\'ban',
      'Ramadan', 'Shawwal', 'Dhu al-Qi\'dah', 'Dhu al-Hijjah'
    ];
    
    return '$hijriDay ${monthNames[hijriMonth - 1]} $hijriYear AH';
  }
}

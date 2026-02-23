/// Ramadan Calendar Screen
/// Shows full month prayer times in a table format

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../models/prayer_times_model.dart';
import '../../providers/prayer_times_provider.dart';
import '../../providers/settings_provider.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isBangla = settings.languageCode == 'bn';
    final prayerTimes = ref.watch(todayPrayerTimesProvider);

    // Generate Ramadan calendar for 2026
    final ramadanStart = DateTime(2026, 2, 18);
    final ramadanDays = List.generate(30, (index) {
      return ramadanStart.add(Duration(days: index));
    });

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0F1E),
        elevation: 0,
        title: Text(
          isBangla ? 'রমজান ক্যালেন্ডার' : 'Ramadan Calendar',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Month header
            Container(
              margin: const EdgeInsets.all(16),
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
                    isBangla ? 'রমজান ১৪৪৭ হিজরি' : 'Ramadan 1447 AH',
                    style: GoogleFonts.amiri(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0A0F1E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'February - March 2026',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF0A0F1E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildHeaderStat(
                        label: isBangla ? 'মোট দিন' : 'Total Days',
                        value: '30',
                      ),
                      _buildHeaderStat(
                        label: isBangla ? 'আজ' : 'Today',
                        value: isBangla 
                            ? 'দিন ${today.difference(ramadanStart).inDays + 1}'
                            : 'Day ${today.difference(ramadanStart).inDays + 1}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Calendar table header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1629),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      isBangla ? 'দিন' : 'Day',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      isBangla ? 'তারিখ' : 'Date',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      isBangla ? 'সেহরি' : 'Sahari',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      isBangla ? 'ইফতার' : 'Iftar',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Calendar list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: ramadanDays.length,
                itemBuilder: (context, index) {
                  final date = ramadanDays[index];
                  final day = index + 1;
                  final isToday = date.year == today.year &&
                      date.month == today.month &&
                      date.day == today.day;
                  final isPast = date.isBefore(today);

                  // Calculate prayer times for this date
                  // In production, this should be fetched from the provider
                  final sahariTime = DateTime(date.year, date.month, date.day, 4, 45);
                  final iftarTime = DateTime(date.year, date.month, date.day, 17, 57);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isToday
                          ? const Color(0xFF00E5C0).withOpacity(0.1)
                          : const Color(0xFF0F1629),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isToday
                            ? const Color(0xFF00E5C0)
                            : Colors.transparent,
                        width: isToday ? 2 : 0,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Day number
                        Expanded(
                          flex: 1,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isToday
                                  ? const Color(0xFF00E5C0)
                                  : isPast
                                      ? const Color(0xFF1A2342)
                                      : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$day',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isToday
                                      ? const Color(0xFF0A0F1E)
                                      : isPast
                                          ? Colors.white38
                                          : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        // Date
                        Expanded(
                          flex: 2,
                          child: Text(
                            DateFormat('d MMM').format(date),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isPast ? Colors.white38 : Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        // Sahari time
                        Expanded(
                          flex: 2,
                          child: Text(
                            PrayerTimesModel.formatTime(sahariTime),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: isPast ? Colors.white38 : Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        // Iftar time
                        Expanded(
                          flex: 2,
                          child: Text(
                            PrayerTimesModel.formatTime(iftarTime),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                              color: isToday
                                  ? const Color(0xFF00E5C0)
                                  : isPast
                                      ? Colors.white38
                                      : Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ).animate(
                    delay: (index * 30).ms,
                  ).fadeIn(duration: 300.ms);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat({required String label, required String value}) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0A0F1E),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF0A0F1E).withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}

/// Greeting Header Widget
/// Shows Ramadan greeting, date, and day number

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../providers/settings_provider.dart';

class GreetingHeader extends ConsumerWidget {
  const GreetingHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isBangla = settings.languageCode == 'bn';
    final now = DateTime.now();
    
    // Calculate Ramadan day (for 2026, Ramadan starts around Feb 18)
    final ramadanStart2026 = DateTime(2026, 2, 18);
    int? ramadanDay;
    if (now.isAfter(ramadanStart2026) && 
        now.isBefore(ramadanStart2026.add(const Duration(days: 30)))) {
      ramadanDay = now.difference(ramadanStart2026).inDays + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ramadan Mubarak
        Row(
          children: [
            Text(
              isBangla ? 'রমজান মুবারক' : 'Ramadan Mubarak',
              style: GoogleFonts.amiri(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E5C0), Color(0xFF00BFA5)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isBangla 
                    ? 'দিন ${ramadanDay ?? '--'}'
                    : 'Day ${ramadanDay ?? '--'}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0A0F1E),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Date
        Text(
          isBangla
              ? _formatDateBangla(now)
              : DateFormat('EEEE, d MMMM yyyy').format(now),
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        
        if (ramadanDay != null) ...[
          const SizedBox(height: 12),
          
          // Progress indicator
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ramadanDay / 30,
              backgroundColor: const Color(0xFF1A2342),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E5C0)),
              minHeight: 6,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            isBangla
                ? 'রমজানের ${(ramadanDay / 30 * 100).toStringAsFixed(0)}% সম্পন্ন'
                : '${(ramadanDay / 30 * 100).toStringAsFixed(0)}% of Ramadan completed',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white60,
            ),
          ),
        ],
      ],
    );
  }

  String _formatDateBangla(DateTime date) {
    final banglaDays = [
      'রবিবার', 'সোমবার', 'মঙ্গলবার', 'বুধবার', 
      'বৃহস্পতিবার', 'শুক্রবার', 'শনিবার'
    ];
    final banglaMonths = [
      'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
      'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'
    ];
    
    final day = banglaDays[date.weekday % 7];
    final month = banglaMonths[date.month - 1];
    
    return '$day, ${date.day} $month ${date.year}';
  }
}

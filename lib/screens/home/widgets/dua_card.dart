/// Dua Card Widget
/// Shows daily dua with Arabic, transliteration, and translation

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../providers/settings_provider.dart';

class DuaCard extends ConsumerWidget {
  const DuaCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isBangla = settings.languageCode == 'bn';

    // Suhoor/Iftar Dua
    const arabic = 'اللَّهُمَّ لَكَ صُمْتُ وَعَلَى رِزْقِكَ أَفْطَرْتُ';
    const transliteration = 'Allahumma laka sumtu wa ala rizqika aftartu';
    final translation = isBangla
        ? 'হে আল্লাহ! আমি তোমারই জন্য রোজা রেখেছি এবং তোমারই রিজিক দ্বারা ইফতার করছি'
        : 'O Allah! I fasted for You and I break my fast with Your sustenance';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A2342),
            const Color(0xFF0F1629),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00E5C0).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5C0).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.menu_book,
                  color: Color(0xFF00E5C0),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isBangla ? 'দৈনিক দোয়া' : 'Daily Dua',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Arabic
          Center(
            child: Text(
              arabic,
              style: GoogleFonts.amiri(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Divider
          Divider(
            color: const Color(0xFF1A2342),
            height: 1,
          ),
          
          const SizedBox(height: 16),
          
          // Transliteration
          if (settings.showTransliteration) ...[
            Text(
              transliteration,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.white70,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
          ],
          
          // Translation
          Text(
            translation,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white60,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Copy button
          Center(
            child: TextButton.icon(
              onPressed: () {
                // Copy dua to clipboard
              },
              icon: const Icon(
                Icons.copy,
                size: 16,
                color: Color(0xFF00E5C0),
              ),
              label: Text(
                isBangla ? 'কপি করুন' : 'Copy',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF00E5C0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

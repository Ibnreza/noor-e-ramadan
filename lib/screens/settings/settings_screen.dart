/// Settings Screen
/// App settings, location selection, and preferences

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../models/user_settings_model.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isBangla = settings.languageCode == 'bn';

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0F1E),
        elevation: 0,
        title: Text(
          isBangla ? 'সেটিংস' : 'Settings',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Language Section
            _buildSectionTitle(context, ref, isBangla ? 'ভাষা' : 'Language'),
            
            const SizedBox(height: 12),
            
            _buildLanguageSelector(context, ref),
            
            const SizedBox(height: 24),
            
            // Location Section
            _buildSectionTitle(context, ref, isBangla ? 'অবস্থান' : 'Location'),
            
            const SizedBox(height: 12),
            
            _buildLocationCard(context, ref),
            
            const SizedBox(height: 24),
            
            // Calculation Method Section
            _buildSectionTitle(context, ref, isBangla ? 'গণনা পদ্ধতি' : 'Calculation Method'),
            
            const SizedBox(height: 12),
            
            _buildCalculationMethodSelector(context, ref),
            
            const SizedBox(height: 24),
            
            // Display Section
            _buildSectionTitle(context, ref, isBangla ? 'ডিসপ্লে' : 'Display'),
            
            const SizedBox(height: 12),
            
            _buildDisplaySettings(context, ref),
            
            const SizedBox(height: 24),
            
            // About Section
            _buildSectionTitle(context, ref, isBangla ? 'অ্যাপ সম্পর্কে' : 'About'),
            
            const SizedBox(height: 12),
            
            _buildAboutCard(context, ref),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, WidgetRef ref, String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF00E5C0),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1629),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildLanguageOption(
              context,
              ref,
              label: 'English',
              code: 'en',
              isSelected: settings.languageCode == 'en',
            ),
          ),
          Expanded(
            child: _buildLanguageOption(
              context,
              ref,
              label: 'বাংলা',
              code: 'bn',
              isSelected: settings.languageCode == 'bn',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required String code,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        ref.read(settingsProvider.notifier).setLanguage(code);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00E5C0) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? const Color(0xFF0A0F1E) : Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isBangla = settings.languageCode == 'bn';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1629),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1A2342),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5C0).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Color(0xFF00E5C0),
                  size: 20,
                ),
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
                        fontWeight: FontWeight.w600,
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
          
          // Quick location selector for Bangladesh cities
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: LocationPresets.bangladeshCities.take(6).map((city) {
              final isSelected = settings.locationName.contains(city['name'] as String);
              return ActionChip(
                label: Text(
                  isBangla ? city['nameBn'] as String : city['name'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isSelected ? const Color(0xFF0A0F1E) : Colors.white70,
                  ),
                ),
                onPressed: () {
                  ref.read(settingsProvider.notifier).setLocation(
                    latitude: city['latitude'] as double,
                    longitude: city['longitude'] as double,
                    locationName: '${city['name']}, Bangladesh',
                  );
                },
                backgroundColor: isSelected ? const Color(0xFF00E5C0) : const Color(0xFF1A2342),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationMethodSelector(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isBangla = settings.languageCode == 'bn';

    final methods = [
      {'code': 'karachi', 'name': 'Karachi (Hanafi)', 'nameBn': 'করাচি (হানাফি)'},
      {'code': 'makkah', 'name': 'Makkah', 'nameBn': 'মক্কা'},
      {'code': 'egypt', 'name': 'Egypt', 'nameBn': 'মিশর'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1629),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1A2342),
          width: 1,
        ),
      ),
      child: Column(
        children: methods.map((method) {
          final isSelected = settings.calculationMethod == method['code'];
          return RadioListTile<String>(
            title: Text(
              isBangla ? method['nameBn']! : method['name']!,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            value: method['code']!,
            groupValue: settings.calculationMethod,
            onChanged: (value) {
              if (value != null) {
                ref.read(settingsProvider.notifier).setCalculationMethod(value);
              }
            },
            activeColor: const Color(0xFF00E5C0),
            tileColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDisplaySettings(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isBangla = settings.languageCode == 'bn';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1629),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1A2342),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: Text(
              isBangla ? '২৪ ঘণ্টা ফরম্যাট' : '24-Hour Format',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            value: settings.use24HourFormat,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggle24HourFormat();
            },
            activeColor: const Color(0xFF00E5C0),
          ),
          const Divider(color: Color(0xFF1A2342), height: 1),
          SwitchListTile(
            title: Text(
              isBangla ? 'আরবি দেখান' : 'Show Arabic',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              isBangla ? 'নামাজের সময়ে আরবি টেক্সট' : 'Arabic text in prayer times',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white60,
              ),
            ),
            value: settings.showArabicInPrayerTimes,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleArabicInPrayerTimes();
            },
            activeColor: const Color(0xFF00E5C0),
          ),
          const Divider(color: Color(0xFF1A2342), height: 1),
          SwitchListTile(
            title: Text(
              isBangla ? 'উচ্চারণ দেখান' : 'Show Transliteration',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            value: settings.showTransliteration,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleTransliteration();
            },
            activeColor: const Color(0xFF00E5C0),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isBangla = settings.languageCode == 'bn';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1629),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1A2342),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // App logo
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00E5C0), Color(0xFF00BFA5)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(
                Icons.mosque,
                color: Color(0xFF0A0F1E),
                size: 32,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Noor Ramadan',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            isBangla ? 'সংস্করণ ২.০.০' : 'Version 2.0.0',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white60,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            isBangla
                ? 'বাংলাদেশের জন্য তৈরি একটি অফলাইন রমজান কমপ্যানিয়ন অ্যাপ'
                : 'An offline Ramadan companion app made for Bangladesh',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white60,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 20),
          
          // Features
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildFeatureChip(isBangla ? 'অফলাইন' : 'Offline'),
              _buildFeatureChip(isBangla ? 'বিজ্ঞাপন মুক্ত' : 'Ad-Free'),
              _buildFeatureChip(isBangla ? 'গোপনীয়তা-কেন্দ্রিক' : 'Privacy-First'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2342),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          color: Colors.white70,
        ),
      ),
    );
  }
}

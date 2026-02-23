/// Tasbih Screen 2.0
/// Advanced dhikr counter with haptics, confetti, and 15+ presets

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/tasbih_model.dart';
import '../../providers/settings_provider.dart';
import '../../providers/tasbih_provider.dart';

class TasbihScreen extends ConsumerStatefulWidget {
  const TasbihScreen({super.key});

  @override
  ConsumerState<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends ConsumerState<TasbihScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isBangla = settings.languageCode == 'bn';
    final tasbihState = ref.watch(tasbihProvider);
    final selectedDhikr = tasbihState.selectedDhikr;
    final count = tasbihState.count;
    final target = tasbihState.targetCount;
    final progress = tasbihState.progress;
    final showConfetti = tasbihState.showConfetti;
    final todaySummary = ref.watch(todayTasbihSummaryProvider);

    // Trigger confetti when target reached
    if (showConfetti && !_confettiController.state.name.contains('playing')) {
      _confettiController.play();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0F1E),
        elevation: 0,
        title: Text(
          isBangla ? 'তাসবিহ' : 'Tasbih',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Stats button
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => _showStatsDialog(context, ref),
          ),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(context, ref),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Dhikr selector
                _buildDhikrSelector(context, ref),
                
                const SizedBox(height: 24),
                
                // Main counter area
                Expanded(
                  child: _buildCounterArea(context, ref),
                ),
                
                // Progress indicator
                _buildProgressIndicator(context, ref, progress),
                
                const SizedBox(height: 24),
                
                // Control buttons
                _buildControlButtons(context, ref),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
          
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.2,
              shouldLoop: false,
              colors: const [
                Color(0xFF00E5C0),
                Color(0xFFFFD700),
                Color(0xFFFF6B35),
                Colors.white,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDhikrSelector(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isBangla = settings.languageCode == 'bn';
    final selectedDhikr = ref.watch(selectedDhikrProvider);
    final allDhikr = ref.watch(allDhikrTypesProvider);

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: allDhikr.length,
        itemBuilder: (context, index) {
          final dhikr = allDhikr[index];
          final isSelected = dhikr == selectedDhikr;
          final info = ref.read(dhikrInfoProvider(dhikr));

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                isBangla ? info['bangla']! : info['transliteration']!,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected 
                      ? const Color(0xFF0A0F1E)
                      : Colors.white70,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  ref.read(tasbihProvider.notifier).selectDhikr(dhikr);
                }
              },
              selectedColor: const Color(0xFF00E5C0),
              backgroundColor: const Color(0xFF0F1629),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
                side: BorderSide(
                  color: isSelected 
                      ? const Color(0xFF00E5C0)
                      : const Color(0xFF1A2342),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCounterArea(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isBangla = settings.languageCode == 'bn';
    final selectedDhikr = ref.watch(selectedDhikrProvider);
    final count = ref.watch(tasbihCountProvider);
    final target = ref.watch(tasbihTargetProvider);
    final info = ref.watch(dhikrInfoProvider(selectedDhikr));

    return GestureDetector(
      onTap: () {
        ref.read(tasbihProvider.notifier).increment();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Arabic text
            Text(
              info['arabic']!,
              style: GoogleFonts.amiri(
                fontSize: 36,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
            
            const SizedBox(height: 12),
            
            // Transliteration
            if (settings.showTransliteration)
              Text(
                info['transliteration']!,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            
            const SizedBox(height: 8),
            
            // Translation
            Text(
              isBangla ? info['bangla']! : info['translation']!,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white60,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 48),
            
            // Counter circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF00E5C0).withOpacity(0.3),
                    const Color(0xFF00E5C0).withOpacity(0.1),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFF00E5C0),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5C0).withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$count',
                      style: GoogleFonts.inter(
                        fontSize: 64,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '/ $target',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
            )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.02, 1.02),
                  duration: 1.seconds,
                  curve: Curves.easeInOut,
                ),
            
            const SizedBox(height: 24),
            
            // Tap hint
            Text(
              isBangla ? 'গণনা করতে ট্যাপ করুন' : 'Tap to count',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context, WidgetRef ref, double progress) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFF1A2342),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E5C0)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toStringAsFixed(0)}%',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isBangla = settings.languageCode == 'bn';
    final count = ref.watch(tasbihCountProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Undo button
          _buildControlButton(
            icon: Icons.undo,
            onPressed: count > 0
                ? () => ref.read(tasbihProvider.notifier).undo()
                : null,
          ),
          
          const SizedBox(width: 24),
          
          // Reset button
          _buildControlButton(
            icon: Icons.refresh,
            label: isBangla ? 'রিসেট' : 'Reset',
            onPressed: count > 0
                ? () => _showResetConfirmation(context, ref)
                : null,
            isLarge: true,
          ),
          
          const SizedBox(width: 24),
          
          // Target button
          _buildControlButton(
            icon: Icons.edit,
            onPressed: () => _showTargetDialog(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    String? label,
    VoidCallback? onPressed,
    bool isLarge = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: onPressed != null
            ? const Color(0xFF0F1629)
            : const Color(0xFF1A2342),
        foregroundColor: onPressed != null
            ? const Color(0xFF00E5C0)
            : Colors.white38,
        padding: isLarge
            ? const EdgeInsets.symmetric(horizontal: 32, vertical: 16)
            : const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: onPressed != null
                ? const Color(0xFF00E5C0)
                : Colors.transparent,
          ),
        ),
      ),
      child: label != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(label),
              ],
            )
          : Icon(icon, size: 24),
    );
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsProvider);
    final isBangla = settings.languageCode == 'bn';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F1629),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          isBangla ? 'রিসেট করবেন?' : 'Reset Counter?',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          isBangla
              ? 'আপনার বর্তমান গণনা সংরক্ষণ করা হবে।'
              : 'Your current count will be saved.',
          style: GoogleFonts.inter(
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              isBangla ? 'বাতিল' : 'Cancel',
              style: GoogleFonts.inter(
                color: Colors.white70,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(tasbihProvider.notifier).reset();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E5C0),
              foregroundColor: const Color(0xFF0A0F1E),
            ),
            child: Text(
              isBangla ? 'রিসেট' : 'Reset',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTargetDialog(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsProvider);
    final isBangla = settings.languageCode == 'bn';
    final currentTarget = ref.read(tasbihTargetProvider);

    final targets = [11, 33, 66, 99, 100, 1000];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F1629),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          isBangla ? 'লক্ষ্য নির্বাচন করুন' : 'Select Target',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: targets.map((target) {
            final isSelected = target == currentTarget;
            return ChoiceChip(
              label: Text(
                '$target',
                style: GoogleFonts.inter(
                  color: isSelected
                      ? const Color(0xFF0A0F1E)
                      : Colors.white,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  ref.read(tasbihProvider.notifier).setTargetCount(target);
                  Navigator.pop(context);
                }
              },
              selectedColor: const Color(0xFF00E5C0),
              backgroundColor: const Color(0xFF1A2342),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showStatsDialog(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsProvider);
    final isBangla = settings.languageCode == 'bn';
    final stats = ref.read(tasbihStatsProvider);
    final todaySummary = ref.read(todayTasbihSummaryProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F1629),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          isBangla ? 'পরিসংখ্যান' : 'Statistics',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow(
              isBangla ? 'আজকের জিকির' : 'Today\'s Dhikr',
              '${stats['todayTotal']}',
            ),
            _buildStatRow(
              isBangla ? 'আজকের সেশন' : 'Today\'s Sessions',
              '${stats['todaySessions']}',
            ),
            _buildStatRow(
              isBangla ? 'লক্ষ্য পূরণ' : 'Goals Reached',
              '${stats['todayGoalsReached']}',
            ),
            const Divider(color: Color(0xFF1A2342)),
            _buildStatRow(
              isBangla ? 'সর্বমোট জিকির' : 'All Time Total',
              '${stats['allTimeTotal']}',
              isHighlighted: true,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E5C0),
              foregroundColor: const Color(0xFF0A0F1E),
            ),
            child: Text(
              isBangla ? 'ঠিক আছে' : 'OK',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: isHighlighted ? Colors.white : Colors.white70,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              color: isHighlighted ? const Color(0xFF00E5C0) : Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: isHighlighted ? 18 : 16,
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsProvider);
    final isBangla = settings.languageCode == 'bn';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F1629),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          isBangla ? 'সেটিংস' : 'Settings',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text(
                isBangla ? 'ভাইব্রেশন' : 'Vibration',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              subtitle: Text(
                isBangla ? 'গণনার সময় ভাইব্রেট করুন' : 'Vibrate on count',
                style: GoogleFonts.inter(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
              value: settings.enableTasbihHaptics,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).toggleTasbihHaptics();
              },
              activeColor: const Color(0xFF00E5C0),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              isBangla ? 'বন্ধ করুন' : 'Close',
              style: GoogleFonts.inter(
                color: const Color(0xFF00E5C0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

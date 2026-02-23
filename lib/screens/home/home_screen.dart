/// Home Screen - Gamified Dashboard
/// Main dashboard with fasting streak, badges, Iftar countdown, and progress rings

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/badge_model.dart';
import '../../providers/badge_provider.dart';
import '../../providers/prayer_times_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/tasbih_provider.dart';
import '../../widgets/countdown_timer.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/badge_card.dart';
import 'widgets/greeting_header.dart';
import 'widgets/streak_card.dart';
import 'widgets/next_prayer_card.dart';
import 'widgets/dua_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final userProgress = ref.watch(userProgressProvider);
    final prayerTimes = ref.watch(todayPrayerTimesProvider);
    final timeUntilIftar = ref.watch(timeUntilIftarProvider);
    final isFasting = ref.watch(isFastingTimeProvider);
    final newlyUnlocked = ref.watch(newlyUnlockedBadgeProvider);

    // Show badge unlock dialog if there's a newly unlocked badge
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (newlyUnlocked != null) {
        _showBadgeUnlockDialog(context, newlyUnlocked);
        ref.read(badgeProvider.notifier).clearNewlyUnlocked();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: _buildAppBar(context, ref),
            ),
            
            // Main Content
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Greeting Header
                  const GreetingHeader()
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: -0.2, end: 0),
                  
                  const SizedBox(height: 24),
                  
                  // Iftar/Suhoor Countdown
                  if (prayerTimes != null)
                    _buildCountdownCard(context, ref, prayerTimes, isFasting)
                        .animate()
                        .fadeIn(delay: 100.ms, duration: 500.ms)
                        .slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 24),
                  
                  // Streak & Progress Row
                  Row(
                    children: [
                      Expanded(
                        child: StreakCard(
                          streak: userProgress['currentStreak'] as int,
                          longestStreak: userProgress['longestStreak'] as int,
                        )
                            .animate()
                            .fadeIn(delay: 200.ms, duration: 500.ms)
                            .slideX(begin: -0.2, end: 0),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildLevelCard(context, ref, userProgress)
                            .animate()
                            .fadeIn(delay: 300.ms, duration: 500.ms)
                            .slideX(begin: 0.2, end: 0),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Next Prayer Card
                  const NextPrayerCard()
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 500.ms)
                      .slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 24),
                  
                  // Daily Dua Card
                  const DuaCard()
                      .animate()
                      .fadeIn(delay: 500.ms, duration: 500.ms)
                      .slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 24),
                  
                  // Quick Stats
                  _buildQuickStats(context, ref)
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 500.ms),
                  
                  const SizedBox(height: 24),
                  
                  // Recent Badges
                  _buildRecentBadges(context, ref)
                      .animate()
                      .fadeIn(delay: 700.ms, duration: 500.ms),
                  
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final userProgress = ref.watch(userProgressProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Location
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Color(0xFF00E5C0),
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                settings.locationName.split(',').first,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          
          // Level Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00E5C0), Color(0xFF00BFA5)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star,
                  color: Color(0xFF0A0F1E),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'Lvl ${userProgress['level']}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0A0F1E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownCard(
    BuildContext context,
    WidgetRef ref,
    prayerTimes,
    bool isFasting,
  ) {
    final settings = ref.watch(settingsProvider);
    final isBangla = settings.languageCode == 'bn';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF00E5C0),
            Color(0xFF00BFA5),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5C0).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isFasting ? Icons.nights_stay : Icons.wb_sunny,
                color: const Color(0xFF0A0F1E),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isFasting
                    ? (isBangla ? 'ইফতারের সময় বাকি' : 'Time until Iftar')
                    : (isBangla ? 'সেহরির সময় বাকি' : 'Time until Suhoor'),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0A0F1E),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Countdown
          CountdownTimer(
            targetTime: isFasting
                ? prayerTimes.maghrib
                : prayerTimes.imsak,
            textColor: const Color(0xFF0A0F1E),
            fontSize: 48,
          ),
          
          const SizedBox(height: 16),
          
          // Prayer Time
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0F1E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isFasting
                  ? '${isBangla ? 'ইফতার' : 'Iftar'}: ${PrayerTimesModel.formatTime(prayerTimes.maghrib)}'
                  : '${isBangla ? 'ইমসাক' : 'Imsak'}: ${PrayerTimesModel.formatTime(prayerTimes.imsak)}',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF0A0F1E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(BuildContext context, WidgetRef ref, Map<String, dynamic> userProgress) {
    final level = userProgress['level'] as int;
    final totalPoints = userProgress['totalPoints'] as int;
    final levelInfo = ref.watch(levelInfoProvider(level));
    final nextLevelPoints = levelInfo['nextLevelPoints'] as int?;
    final progress = nextLevelPoints != null
        ? (totalPoints - (levelInfo['pointsNeeded'] as int)) /
            (nextLevelPoints - (levelInfo['pointsNeeded'] as int))
        : 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Color(0xFFFFD700),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level $level',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      levelInfo['titleEn'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: const Color(0xFF1A2342),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
              minHeight: 6,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '$totalPoints pts',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isBangla = settings.languageCode == 'bn';
    final userProgress = ref.watch(userProgressProvider);
    final todaySummary = ref.watch(todayTasbihSummaryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isBangla ? 'আজকের পরিসংখ্যান' : 'Today\'s Stats',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            _buildStatCard(
              icon: Icons.local_fire_department,
              color: const Color(0xFFFF6B35),
              value: '${userProgress['currentStreak']}',
              label: isBangla ? 'দিনের ধারা' : 'Day Streak',
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              icon: Icons.calendar_today,
              color: const Color(0xFF00E5C0),
              value: '${userProgress['totalFastDays']}',
              label: isBangla ? 'মোট রোজা' : 'Total Fasts',
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              icon: Icons.fingerprint,
              color: const Color(0xFFFFD700),
              value: '${todaySummary?.totalCount ?? 0}',
              label: isBangla ? 'জিকির' : 'Dhikr',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
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
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentBadges(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isBangla = settings.languageCode == 'bn';
    final recentBadges = ref.watch(recentlyUnlockedBadgesProvider);

    if (recentBadges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isBangla ? 'সাম্প্রতিক ব্যাজ' : 'Recent Badges',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to badges screen
              },
              child: Text(
                isBangla ? 'সব দেখুন' : 'See All',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF00E5C0),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recentBadges.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: BadgeCard(
                  badge: recentBadges[index],
                  compact: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showBadgeUnlockDialog(BuildContext context, BadgeModel badge) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F1629),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(int.parse('0xFF${badge.rarityColor.substring(1)}')),
                    Color(int.parse('0xFF${badge.rarityColor.substring(1)}'))
                        .withOpacity(0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  badge.categoryIcon,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title
            Text(
              'Badge Unlocked!',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Badge Name
            Text(
              badge.name,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(int.parse('0xFF${badge.rarityColor.substring(1)}')),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Description
            Text(
              badge.description,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Points
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star,
                    color: Color(0xFFFFD700),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '+${badge.points} points',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFFD700),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Button
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5C0),
                foregroundColor: const Color(0xFF0A0F1E),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Awesome!',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

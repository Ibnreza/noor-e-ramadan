/// Badge Card Widget
/// Displays badge information in card format

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/badge_model.dart';

class BadgeCard extends StatelessWidget {
  final BadgeModel badge;
  final bool compact;
  final VoidCallback? onTap;

  const BadgeCard({
    super.key,
    required this.badge,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rarityColor = Color(int.parse('0xFF${badge.rarityColor.substring(1)}'));

    if (compact) {
      return Container(
        width: 80,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              rarityColor.withOpacity(0.3),
              rarityColor.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: rarityColor.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              badge.categoryIcon,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 8),
            Text(
              badge.name,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              rarityColor.withOpacity(0.2),
              rarityColor.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: rarityColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Badge icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    rarityColor,
                    rarityColor.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  badge.categoryIcon,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Badge info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: rarityColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badge.rarity.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: rarityColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Color(0xFFFFD700),
                              size: 10,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${badge.points}',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFFFD700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    badge.name,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    badge.description,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  if (badge.unlockedAt != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Unlocked on ${_formatDate(badge.unlockedAt!)}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Locked badge card (shows requirements)
class LockedBadgeCard extends StatelessWidget {
  final BadgeModel badge;
  final double progress;

  const LockedBadgeCard({
    super.key,
    required this.badge,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.6,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1629),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF1A2342),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Locked icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF1A2342),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  Icons.lock,
                  color: Colors.white38,
                  size: 28,
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Badge info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    badge.name,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    badge.description,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white38,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: const Color(0xFF1A2342),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF00E5C0),
                      ),
                      minHeight: 6,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}% complete',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

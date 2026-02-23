/// Custom Bottom Navigation Bar
/// Elegant bottom navigation with teal accent

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1629),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.access_time_rounded,
                label: 'Prayer',
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.fingerprint_rounded,
                label: 'Tasbih',
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.explore_rounded,
                label: 'Qibla',
                index: 3,
              ),
              _buildNavItem(
                icon: Icons.calendar_month_rounded,
                label: 'Calendar',
                index: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00E5C0).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF00E5C0)
                  : Colors.white54,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF00E5C0)
                    : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Floating bottom navigation (alternative design)
class FloatingBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FloatingBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFF0F1629),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildFloatingNavItem(
              icon: Icons.home_rounded,
              index: 0,
            ),
            _buildFloatingNavItem(
              icon: Icons.access_time_rounded,
              index: 1,
            ),
            _buildFloatingNavItem(
              icon: Icons.fingerprint_rounded,
              index: 2,
            ),
            _buildFloatingNavItem(
              icon: Icons.explore_rounded,
              index: 3,
            ),
            _buildFloatingNavItem(
              icon: Icons.calendar_month_rounded,
              index: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingNavItem({
    required IconData icon,
    required int index,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isSelected ? 48 : 40,
        height: isSelected ? 48 : 40,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00E5C0)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected
              ? const Color(0xFF0A0F1E)
              : Colors.white54,
          size: isSelected ? 24 : 20,
        ),
      ),
    );
  }
}

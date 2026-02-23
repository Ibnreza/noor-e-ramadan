/// Qibla Compass Screen
/// Animated Qibla direction compass using flutter_qiblah

import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/qibla_provider.dart';
import '../../providers/settings_provider.dart';

class QiblaScreen extends ConsumerWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isBangla = settings.languageCode == 'bn';
    final qiblaState = ref.watch(qiblaProvider);
    final isLoading = qiblaState.isLoading;
    final hasPermission = qiblaState.hasPermission;
    final error = qiblaState.error;
    final offset = qiblaState.offset;
    final qiblaDirection = qiblaState.qiblaDirection;
    final isAligned = qiblaState.isAligned;
    final accuracy = qiblaState.alignmentAccuracy;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0F1E),
        elevation: 0,
        title: Text(
          isBangla ? 'কিবলা কম্পাস' : 'Qibla Compass',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(qiblaProvider.notifier).restart();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFF00E5C0),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Calibrating compass...',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              )
            : error != null
                ? _buildErrorState(context, ref, error)
                : !hasPermission
                    ? _buildPermissionState(context, ref)
                    : _buildCompass(context, ref, offset, qiblaDirection, isAligned, accuracy),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
    final settings = ref.watch(settingsProvider);
    final isBangla = settings.languageCode == 'bn';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 24),
            Text(
              error,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(qiblaProvider.notifier).restart();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5C0),
                foregroundColor: const Color(0xFF0A0F1E),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(
                isBangla ? 'আবার চেষ্টা করুন' : 'Try Again',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionState(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isBangla = settings.languageCode == 'bn';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_off,
              color: Colors.white38,
              size: 64,
            ),
            const SizedBox(height: 24),
            Text(
              isBangla
                  ? 'অবস্থান অনুমতি প্রয়োজন'
                  : 'Location Permission Required',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isBangla
                  ? 'কিবলা দিকনির্ণয় করতে আমাদের আপনার অবস্থান জানতে হবে।'
                  : 'We need your location to determine the Qibla direction.',
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(qiblaProvider.notifier).checkPermissions();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5C0),
                foregroundColor: const Color(0xFF0A0F1E),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(
                isBangla ? 'অনুমতি দিন' : 'Grant Permission',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompass(
    BuildContext context,
    WidgetRef ref,
    double? offset,
    double? qiblaDirection,
    bool isAligned,
    double accuracy,
  ) {
    final settings = ref.watch(settingsProvider);
    final isBangla = settings.languageCode == 'bn';

    return Column(
      children: [
        const SizedBox(height: 24),
        
        // Alignment indicator
        if (isAligned)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00E5C0), Color(0xFF00BFA5)],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF0A0F1E),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isBangla ? 'কিবলার দিকে আছেন' : 'Facing Qibla',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0A0F1E),
                  ),
                ),
              ],
            ),
          )
              .animate()
              .scale(duration: 300.ms)
              .then()
              .shake(duration: 500.ms),
        
        const SizedBox(height: 32),
        
        // Compass
        Expanded(
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF1A2342),
                      width: 2,
                    ),
                  ),
                ),
                
                // Direction markers
                ..._buildDirectionMarkers(),
                
                // Rotating compass
                if (offset != null)
                  AnimatedRotation(
                    turns: -offset / 360,
                    duration: const Duration(milliseconds: 100),
                    child: SizedBox(
                      width: 280,
                      height: 280,
                      child: CustomPaint(
                        painter: CompassPainter(
                          isAligned: isAligned,
                        ),
                      ),
                    ),
                  ),
                
                // Center indicator
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isAligned ? const Color(0xFF00E5C0) : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: isAligned
                            ? const Color(0xFF00E5C0).withOpacity(0.5)
                            : Colors.white.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                
                // Kaaba icon at top
                Positioned(
                  top: 20,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1629),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF00E5C0),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.mosque,
                      color: Color(0xFF00E5C0),
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Direction info
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDirectionInfo(
                    label: isBangla ? 'কিবলা' : 'Qibla',
                    value: qiblaDirection != null
                        ? '${qiblaDirection.toStringAsFixed(1)}°'
                        : '--°',
                    icon: Icons.explore,
                  ),
                  _buildDirectionInfo(
                    label: isBangla ? 'নির্ভুলতা' : 'Accuracy',
                    value: '${accuracy.toStringAsFixed(0)}%',
                    icon: Icons.gps_fixed,
                    valueColor: accuracy > 90
                        ? const Color(0xFF00E5C0)
                        : accuracy > 70
                            ? Colors.yellow
                            : Colors.orange,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Location info
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Color(0xFF00E5C0),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    settings.locationName,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Instructions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            isBangla
                ? 'ফোনটি ধীরে ধীরে ঘোরান যতক্ষণ না সবুজ তীর কালো তীরের সাথে মিলে যায়'
                : 'Rotate your phone slowly until the green arrow aligns with the black arrow',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white60,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        const SizedBox(height: 32),
      ],
    );
  }

  List<Widget> _buildDirectionMarkers() {
    final directions = [
      ('N', 0),
      ('E', 90),
      ('S', 180),
      ('W', 270),
    ];

    return directions.map((dir) {
      final (label, angle) = dir;
      return Transform.rotate(
        angle: angle * pi / 180,
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: label == 'N' ? const Color(0xFF00E5C0) : Colors.white70,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildDirectionInfo({
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFF00E5C0),
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: valueColor ?? Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

/// Custom compass painter
class CompassPainter extends CustomPainter {
  final bool isAligned;

  CompassPainter({this.isAligned = false});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw compass needle
    final needlePaint = Paint()
      ..color = isAligned ? const Color(0xFF00E5C0) : Colors.white
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // North (Qibla) indicator
    canvas.drawLine(
      center,
      Offset(center.dx, center.dy - radius + 20),
      needlePaint..color = const Color(0xFF00E5C0),
    );

    // South indicator
    canvas.drawLine(
      center,
      Offset(center.dx, center.dy + radius - 20),
      needlePaint..color = Colors.white38,
    );

    // Draw tick marks
    final tickPaint = Paint()
      ..color = const Color(0xFF1A2342)
      ..strokeWidth = 1;

    for (int i = 0; i < 360; i += 10) {
      final angle = i * pi / 180;
      final startRadius = i % 90 == 0 ? radius - 15 : radius - 8;
      final start = Offset(
        center.dx + startRadius * cos(angle),
        center.dy + startRadius * sin(angle),
      );
      final end = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawLine(start, end, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

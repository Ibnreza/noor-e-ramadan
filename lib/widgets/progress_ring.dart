/// Progress Ring Widget
/// Circular progress indicator with center content

import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProgressRing extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;
  final Widget? centerChild;
  final String? centerText;
  final String? centerSubtext;

  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 120,
    this.strokeWidth = 8,
    this.backgroundColor = const Color(0xFF1A2342),
    this.progressColor = const Color(0xFF00E5C0),
    this.centerChild,
    this.centerText,
    this.centerSubtext,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          CustomPaint(
            size: Size(size, size),
            painter: _ProgressRingPainter(
              progress: 1.0,
              strokeWidth: strokeWidth,
              color: backgroundColor,
            ),
          ),
          
          // Progress ring
          CustomPaint(
            size: Size(size, size),
            painter: _ProgressRingPainter(
              progress: progress.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              color: progressColor,
            ),
          ),
          
          // Center content
          if (centerChild != null)
            centerChild!
          else if (centerText != null)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  centerText!,
                  style: GoogleFonts.inter(
                    fontSize: size * 0.25,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (centerSubtext != null)
                  Text(
                    centerSubtext!,
                    style: GoogleFonts.inter(
                      fontSize: size * 0.1,
                      color: Colors.white60,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;

  _ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Animated progress ring
class AnimatedProgressRing extends StatefulWidget {
  final double targetProgress;
  final Duration duration;
  final double size;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;
  final String? centerText;
  final String? centerSubtext;

  const AnimatedProgressRing({
    super.key,
    required this.targetProgress,
    this.duration = const Duration(milliseconds: 1000),
    this.size = 120,
    this.strokeWidth = 8,
    this.backgroundColor = const Color(0xFF1A2342),
    this.progressColor = const Color(0xFF00E5C0),
    this.centerText,
    this.centerSubtext,
  });

  @override
  State<AnimatedProgressRing> createState() => _AnimatedProgressRingState();
}

class _AnimatedProgressRingState extends State<AnimatedProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(begin: 0, end: widget.targetProgress).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetProgress != widget.targetProgress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.targetProgress,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        ),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ProgressRing(
          progress: _animation.value,
          size: widget.size,
          strokeWidth: widget.strokeWidth,
          backgroundColor: widget.backgroundColor,
          progressColor: widget.progressColor,
          centerText: widget.centerText,
          centerSubtext: widget.centerSubtext,
        );
      },
    );
  }
}

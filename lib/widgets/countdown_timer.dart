/// Countdown Timer Widget
/// Animated countdown display for Iftar/Suhoor

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime targetTime;
  final Color textColor;
  final double fontSize;
  final bool compact;

  const CountdownTimer({
    super.key,
    required this.targetTime,
    this.textColor = Colors.white,
    this.fontSize = 48,
    this.compact = false,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.targetTime.difference(DateTime.now());
    _startTimer();
  }

  @override
  void didUpdateWidget(CountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetTime != widget.targetTime) {
      _remaining = widget.targetTime.difference(DateTime.now());
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remaining = widget.targetTime.difference(DateTime.now());
        if (_remaining.isNegative) {
          _remaining = Duration.zero;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hours = _remaining.inHours;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    if (widget.compact) {
      return Text(
        '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
        style: GoogleFonts.inter(
          fontSize: widget.fontSize,
          fontWeight: FontWeight.w700,
          color: widget.textColor,
          fontFeatures: const [
            FontFeature.tabularFigures(),
          ],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimeUnit(hours, 'HRS'),
        _buildSeparator(),
        _buildTimeUnit(minutes, 'MIN'),
        _buildSeparator(),
        _buildTimeUnit(seconds, 'SEC'),
      ],
    );
  }

  Widget _buildTimeUnit(int value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0F1E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: GoogleFonts.inter(
              fontSize: widget.fontSize,
              fontWeight: FontWeight.w700,
              color: widget.textColor,
              fontFeatures: const [
                FontFeature.tabularFigures(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: widget.textColor.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        ':',
        style: GoogleFonts.inter(
          fontSize: widget.fontSize,
          fontWeight: FontWeight.w700,
          color: widget.textColor,
        ),
      ),
    );
  }
}

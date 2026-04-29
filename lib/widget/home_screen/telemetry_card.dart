import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TelemetryCard extends StatelessWidget {
  final String title;
  final double value;
  final String valueSuffix;
  final int fractionDigits;
  final String unit;
  final String iconPath;
  final double progress;

  static const Duration _animDuration = Duration(milliseconds: 250);

  const TelemetryCard({
    super.key,
    required this.title,
    required this.value,
    this.valueSuffix = '',
    this.fractionDigits = 0,
    required this.unit,
    required this.iconPath,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildIcon(colorScheme),

              const SizedBox(width: 4),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),

          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: value),
                duration: _animDuration,
                curve: Curves.easeOut,
                builder: (context, animValue, child) {
                  return Text(
                    "${animValue.toStringAsFixed(fractionDigits)}$valueSuffix",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 50,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  );
                },
              ),
              Text(
                unit.toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Spacer(),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: progress),
            duration: _animDuration,
            curve: Curves.easeOut,
            builder: (context, animProgress, child) {
              return _buildSegmentedIndicator(animProgress);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color.fromARGB(0, 26, 26, 31),
      ),
      child: SvgPicture.asset(
        iconPath,
        width: 16,
        height: 16,
        colorFilter: const ColorFilter.mode(Color(0xFFBDF343), BlendMode.srcIn),
      ),
    );
  }

  Widget _buildSegmentedIndicator(double currentProgress) {
    const int totalSegments = 18;
    int filledSegments = (currentProgress * totalSegments).round();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(totalSegments, (index) {
        bool isFilled = index < filledSegments;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 6,
          height: 14,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: isFilled
                ? const Color(0xFFBDF343)
                : Colors.white.withValues(alpha: 0.1),
          ),
        );
      }),
    );
  }
}

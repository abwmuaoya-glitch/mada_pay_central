import 'dart:math' as math;
import 'package:flutter/material.dart';

class SparklingBackground extends StatefulWidget {
  const SparklingBackground({super.key});

  @override
  State<SparklingBackground> createState() =>
      _SparklingBackgroundState();
}

class _SparklingBackgroundState extends State<SparklingBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Sparkle> _sparkles;

  @override
  void initState() {
    super.initState();

    final random = math.Random(27);

    _sparkles = List.generate(180, (index) {
      return _Sparkle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        radius: 0.5 + random.nextDouble() * 1.5,
        phase: random.nextDouble() * 2 * math.pi,
        speed: 0.5 + random.nextDouble() * 1.8,
        gold: random.nextDouble() > 0.38,
      );
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _SparklePainter(
                  progress: _controller.value,
                  sparkles: _sparkles,
                ),
                size: Size.infinite,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Sparkle {
  final double x;
  final double y;
  final double radius;
  final double phase;
  final double speed;
  final bool gold;

  const _Sparkle({
    required this.x,
    required this.y,
    required this.radius,
    required this.phase,
    required this.speed,
    required this.gold,
  });
}

class _SparklePainter extends CustomPainter {
  final double progress;
  final List<_Sparkle> sparkles;

  _SparklePainter({
    required this.progress,
    required this.sparkles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final sparkle in sparkles) {
      final angle =
          progress * 2 * math.pi * sparkle.speed + sparkle.phase;

      // تتغير شدة الضوء بصورة دورية ومستمرة.
      final glow = (math.sin(angle) + 1) / 2;

      // بعض النقاط تخفت كثيرًا ثم تعود إلى اللمعان.
      final opacity = 0.04 + 0.92 * math.pow(glow, 5).toDouble();

      final color = sparkle.gold
          ? const Color(0xFFFFD76A)
          : const Color(0xFF42CFFF);

      final center = Offset(
        sparkle.x * size.width,
        sparkle.y * size.height,
      );

      // هالة ضوئية ناعمة.
      final haloPaint = Paint()
        ..color = color.withOpacity(opacity * 0.28)
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          3,
        );

      canvas.drawCircle(
        center,
        sparkle.radius * (1.5 + glow),
        haloPaint,
      );

      // قلب الوميض اللامع.
      final corePaint = Paint()
        ..color = Colors.white.withOpacity(opacity);

      canvas.drawCircle(
        center,
        sparkle.radius * 0.55,
        corePaint,
      );

      // ومضات صغيرة على شكل ألماسة تظهر عند ذروة اللمعان.
      if (glow > 0.88 && sparkle.radius > 1.25) {
        final diamondPaint = Paint()
          ..color = color.withOpacity(opacity)
          ..strokeWidth = 0.6
          ..strokeCap = StrokeCap.round;

        final length = sparkle.radius * 2.8;

        canvas.drawLine(
          Offset(center.dx - length, center.dy),
          Offset(center.dx + length, center.dy),
          diamondPaint,
        );

        canvas.drawLine(
          Offset(center.dx, center.dy - length),
          Offset(center.dx, center.dy + length),
          diamondPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

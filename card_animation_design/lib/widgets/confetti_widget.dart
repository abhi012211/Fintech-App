import 'dart:math' as math;
import 'package:flutter/material.dart';

class ConfettiWidget extends StatefulWidget {
  final bool isPlaying;
  final Duration duration;

  const ConfettiWidget({
    super.key,
    required this.isPlaying,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _controller.addListener(() {
      setState(() {});
    });

    if (widget.isPlaying) {
      _initParticles();
      _controller.forward(from: 0.0);
    }
  }

  @override
  void didUpdateWidget(covariant ConfettiWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _initParticles();
      _controller.forward(from: 0.0);
    }
  }

  void _initParticles() {
    _particles.clear();
    const colors = [
      Color(0xFF10B981), // Emerald
      Color(0xFF6366F1), // Violet
      Color(0xFFF59E0B), // Gold
      Color(0xFF0EA5E9), // Sky Blue
      Color(0xFFEC4899), // Pink
      Color(0xFF34D399), // Mint
    ];

    for (int i = 0; i < 75; i++) {
      _particles.add(
        ConfettiParticle(
          x: _random.nextDouble(),
          y: -0.1 - _random.nextDouble() * 0.2,
          vx: (_random.nextDouble() - 0.5) * 0.8,
          vy: _random.nextDouble() * 0.8 + 0.5,
          color: colors[_random.nextInt(colors.length)],
          size: _random.nextDouble() * 8 + 6,
          rotation: _random.nextDouble() * 2 * math.pi,
          rotationSpeed: (_random.nextDouble() - 0.5) * 10,
          isCircle: _random.nextBool(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPlaying && _controller.isDismissed) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: ConfettiPainter(
          particles: _particles,
          progress: _controller.value,
        ),
      ),
    );
  }
}

class ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  double size;
  double rotation;
  double rotationSpeed;
  bool isCircle;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.isCircle,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final currentX = (particle.x + particle.vx * progress) * size.width;
      final currentY = (particle.y + particle.vy * progress) * size.height;
      final opacity = (1.0 - progress * 0.9).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(particle.rotation + particle.rotationSpeed * progress);

      if (particle.isCircle) {
        canvas.drawCircle(Offset.zero, particle.size / 2, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size * 0.6,
          ),
          paint,
        );
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) => true;
}

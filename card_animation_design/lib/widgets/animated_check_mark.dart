import 'package:flutter/material.dart';

class AnimatedCheckMark extends StatefulWidget {
  final double size;
  final Color color;
  final Color strokeColor;
  final Duration duration;

  const AnimatedCheckMark({
    super.key,
    this.size = 80,
    this.color = const Color(0xFF10B981),
    this.strokeColor = Colors.white,
    this.duration = const Duration(milliseconds: 700),
  });

  @override
  State<AnimatedCheckMark> createState() => _AnimatedCheckMarkState();
}

class _AnimatedCheckMarkState extends State<AnimatedCheckMark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkProgressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    );

    _checkProgressAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value.clamp(0.0, 1.2),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.45),
                  blurRadius: 24,
                  spreadRadius: 4,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CustomPaint(
              painter: CheckMarkPainter(
                progress: _checkProgressAnimation.value,
                color: widget.strokeColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

class CheckMarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  CheckMarkPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.085
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    // Checkmark points
    final start = Offset(size.width * 0.28, size.height * 0.52);
    final mid = Offset(size.width * 0.45, size.height * 0.68);
    final end = Offset(size.width * 0.72, size.height * 0.36);

    final path1Length = (mid - start).distance;
    final path2Length = (end - mid).distance;
    final totalLength = path1Length + path2Length;

    final currentDrawLength = totalLength * progress;

    path.moveTo(start.dx, start.dy);

    if (currentDrawLength <= path1Length) {
      final t = currentDrawLength / path1Length;
      final currentX = start.dx + (mid.dx - start.dx) * t;
      final currentY = start.dy + (mid.dy - start.dy) * t;
      path.lineTo(currentX, currentY);
    } else {
      path.lineTo(mid.dx, mid.dy);
      final remaining = currentDrawLength - path1Length;
      final t = (remaining / path2Length).clamp(0.0, 1.0);
      final currentX = mid.dx + (end.dx - mid.dx) * t;
      final currentY = mid.dy + (end.dy - mid.dy) * t;
      path.lineTo(currentX, currentY);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CheckMarkPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

import 'dart:math' as math;
import 'package:flutter/material.dart';

class CustomQRCodeWidget extends StatelessWidget {
  final String data;
  final double size;
  final Color color;

  const CustomQRCodeWidget({
    super.key,
    required this.data,
    this.size = 100,
    this.color = const Color(0xFF0F172A),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: CustomPaint(
        painter: QRCodePainter(data: data, color: color),
      ),
    );
  }
}

class QRCodePainter extends CustomPainter {
  final String data;
  final Color color;

  QRCodePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cellWidth = size.width / 12;
    final cellHeight = size.height / 12;

    // Corner finder patterns (Top-left, Top-right, Bottom-left)
    _drawFinderPattern(canvas, paint, 0, 0, cellWidth, cellHeight);
    _drawFinderPattern(canvas, paint, 8, 0, cellWidth, cellHeight);
    _drawFinderPattern(canvas, paint, 0, 8, cellWidth, cellHeight);

    // Pseudo-random data modules based on data hash string
    final random = math.Random(data.hashCode);
    for (int r = 0; r < 12; r++) {
      for (int c = 0; c < 12; c++) {
        // Skip finder pattern zones
        if ((r < 4 && c < 4) || (r < 4 && c > 7) || (r > 7 && c < 4)) {
          continue;
        }

        if (random.nextBool()) {
          final rect = Rect.fromLTWH(
            c * cellWidth + 0.5,
            r * cellHeight + 0.5,
            cellWidth - 1,
            cellHeight - 1,
          );
          canvas.drawRect(rect, paint);
        }
      }
    }
  }

  void _drawFinderPattern(Canvas canvas, Paint paint, int startCol, int startRow, double w, double h) {
    // 4x4 outer square
    canvas.drawRect(
      Rect.fromLTWH(startCol * w, startRow * h, 4 * w, 4 * h),
      paint,
    );
    // 2x2 inner cutout white
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH((startCol + 0.8) * w, (startRow + 0.8) * h, 2.4 * w, 2.4 * h),
      whitePaint,
    );
    // 1x1 center core square
    canvas.drawRect(
      Rect.fromLTWH((startCol + 1.4) * w, (startRow + 1.4) * h, 1.2 * w, 1.2 * h),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CustomBarcodeWidget extends StatelessWidget {
  final String code;
  final double height;

  const CustomBarcodeWidget({
    super.key,
    required this.code,
    this.height = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: BarcodePainter(code: code),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          code,
          style: const TextStyle(
            fontFamily: 'Courier',
            fontSize: 10,
            letterSpacing: 2.0,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class BarcodePainter extends CustomPainter {
  final String code;

  BarcodePainter({required this.code});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final random = math.Random(code.hashCode);
    double currentX = 10;
    final totalWidth = size.width - 20;

    while (currentX < totalWidth) {
      final barWidth = random.nextDouble() * 3 + 1;
      final gapWidth = random.nextDouble() * 2 + 1;

      canvas.drawRect(
        Rect.fromLTWH(currentX, 0, barWidth, size.height),
        paint,
      );

      currentX += barWidth + gapWidth;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

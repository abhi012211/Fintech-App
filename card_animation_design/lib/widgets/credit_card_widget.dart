import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/payment_card.dart';

class CreditCardWidget extends StatefulWidget {
  final PaymentCard card;
  final bool isSelected;
  final double rotateY;
  final VoidCallback? onTap;

  const CreditCardWidget({
    super.key,
    required this.card,
    this.isSelected = false,
    this.rotateY = 0.0,
    this.onTap,
  });

  @override
  State<CreditCardWidget> createState() => _CreditCardWidgetState();
}

class _CreditCardWidgetState extends State<CreditCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 3D Matrix Perspective Transform
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.0012) // perspective distance
      ..rotateY(widget.rotateY);

    return Transform(
      transform: matrix,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.card.gradientColors,
            ),
            border: Border.all(
              color: widget.isSelected
                  ? widget.card.accentColor.withValues(alpha: 0.95)
                  : Colors.white.withValues(alpha: 0.15),
              width: widget.isSelected ? 2.5 : 1.0,
            ),
            boxShadow: [
              if (widget.isSelected) ...[
                BoxShadow(
                  color: widget.card.accentColor.withValues(alpha: 0.4),
                  blurRadius: 28,
                  spreadRadius: 2,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 18,
                  offset: const Offset(0, 14),
                ),
              ] else ...[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                // Background mesh pattern
                Positioned.fill(
                  child: CustomPaint(
                    painter: CardPatternPainter(
                      accentColor: widget.card.accentColor,
                      brand: widget.card.brand,
                    ),
                  ),
                ),

                // Animated Shimmer Light Beam for Selected Card
                if (widget.isSelected)
                  AnimatedBuilder(
                    animation: _shimmerController,
                    builder: (context, child) {
                      final shimmerPos = _shimmerController.value * 2.5 - 0.8;
                      return Positioned.fill(
                        child: CustomPaint(
                          painter: CardShimmerPainter(progress: shimmerPos),
                        ),
                      );
                    },
                  ),

                // Radial gloss light reflection
                Positioned(
                  top: -80,
                  right: -60,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.22),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),

                // Card Content Padding
                Padding(
                  padding: const EdgeInsets.all(22.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Header Row: Card Name & Contactless / Brand Logo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.card.cardName.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.card.cardType,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.65),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),

                          // Contactless Icon & Brand Logo
                          Row(
                            children: [
                              const ContactlessIcon(),
                              const SizedBox(width: 14),
                              _buildBrandLogo(widget.card.brand),
                            ],
                          ),
                        ],
                      ),

                      // Middle Row: Metallic IC Chip & Active Selection Pill
                      Row(
                        children: [
                          const MetallicChip(),
                          const SizedBox(width: 12),
                          if (widget.isSelected)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: widget.card.accentColor
                                    .withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: widget.card.accentColor
                                      .withValues(alpha: 0.7),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 12,
                                    color: widget.card.accentColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'SELECTED',
                                    style: TextStyle(
                                      color: widget.card.accentColor,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                      // Bottom Row: Card Number, Expiry, Cardholder
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Card Number with metallic shadow
                          Text(
                            widget.card.maskedNumber,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Cardholder & Expiry
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CARDHOLDER',
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.5),
                                      fontSize: 8,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.card.cardHolder,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'EXPIRES',
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.5),
                                      fontSize: 8,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.card.expiryDate,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandLogo(CardBrand brand) {
    switch (brand) {
      case CardBrand.mastercard:
        return SizedBox(
          width: 36,
          height: 24,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEB001B),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF79E1B).withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        );

      case CardBrand.visa:
        return const Text(
          'VISA',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            letterSpacing: 1.5,
          ),
        );

      case CardBrand.amex:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white38),
          ),
          child: const Text(
            'AMEX',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        );

      case CardBrand.metal:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE2E8F0), Color(0xFF94A3B8)],
            ),
            borderRadius: BorderRadius.circular(6),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: const Text(
            'METAL',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        );
    }
  }
}

class CardShimmerPainter extends CustomPainter {
  final double progress;

  CardShimmerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final x = progress * size.width;
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.15),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(
        Rect.fromLTWH(x - 50, 0, 100, size.height),
      );

    final path = Path()
      ..moveTo(x - 50, 0)
      ..lineTo(x + 20, 0)
      ..lineTo(x + 70, size.height)
      ..lineTo(x, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CardShimmerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class MetallicChip extends StatelessWidget {
  const MetallicChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFDE047),
            Color(0xFFEAB308),
            Color(0xFFCA8A04),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 3,
            offset: Offset(0, 1.5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: ChipGridPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class ChipGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(4, 4, size.width - 8, size.height - 8),
      const Radius.circular(3),
    );
    canvas.drawRRect(rect, paint);

    canvas.drawLine(
      Offset(size.width / 2, 4),
      Offset(size.width / 2, size.height - 4),
      paint,
    );

    canvas.drawLine(
      Offset(4, size.height / 2),
      Offset(size.width - 4, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ContactlessIcon extends StatelessWidget {
  const ContactlessIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi / 2,
      child: Icon(
        Icons.wifi,
        color: Colors.white.withValues(alpha: 0.8),
        size: 20,
      ),
    );
  }
}

class CardPatternPainter extends CustomPainter {
  final Color accentColor;
  final CardBrand brand;

  CardPatternPainter({required this.accentColor, required this.brand});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accentColor.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    for (double i = -100; i < size.width + 100; i += 40) {
      path.moveTo(i, 0);
      path.cubicTo(
        i + 60,
        size.height * 0.4,
        i - 30,
        size.height * 0.7,
        i + 80,
        size.height,
      );
    }
    canvas.drawPath(path, paint);

    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    for (double x = 20; x < size.width; x += 25) {
      for (double y = 20; y < size.height; y += 25) {
        canvas.drawCircle(Offset(x, y), 1.2, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

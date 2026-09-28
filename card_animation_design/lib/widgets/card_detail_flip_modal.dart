import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/payment_card.dart';
import 'credit_card_widget.dart';

class CardDetailFlipModal extends StatefulWidget {
  final PaymentCard card;

  const CardDetailFlipModal({
    super.key,
    required this.card,
  });

  static void show(BuildContext context, PaymentCard card) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CardDetailFlipModal(card: card),
    );
  }

  @override
  State<CardDetailFlipModal> createState() => _CardDetailFlipModalState();
}

class _CardDetailFlipModalState extends State<CardDetailFlipModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _showFront = true;
  double _dragStartX = 0.0;
  bool _isFrozen = false;
  bool _showFullDetails = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _flipAnimation = Tween<double>(begin: 0.0, end: math.pi).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutCubic),
    );

    _flipController.addListener(() {
      setState(() {
        _showFront = _flipAnimation.value < (math.pi / 2);
      });
    });
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (_flipController.isAnimating) return;
    if (_flipController.isCompleted) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161A22) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark ? const Color(0xFF2E3646) : const Color(0xFFE2E8F0),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 4.5,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 16),

          // Header Title & Flip Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.card.cardName,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Swipe or tap card to flip side',
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _toggleFlip,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.flip_rounded,
                        size: 14,
                        color: Color(0xFF6366F1),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _showFront ? 'FRONT SIDE' : 'BACK SIDE',
                        style: const TextStyle(
                          color: Color(0xFF6366F1),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 3D Flipping Card Container (GestureDetector for Swipe Left/Right)
          GestureDetector(
            onHorizontalDragStart: (details) {
              _dragStartX = details.globalPosition.dx;
            },
            onHorizontalDragEnd: (details) {
              final dragDistance = details.velocity.pixelsPerSecond.dx;
              if (dragDistance.abs() > 200 ||
                  (details.globalPosition.dx - _dragStartX).abs() > 50) {
                _toggleFlip();
              }
            },
            onTap: _toggleFlip,
            child: AnimatedBuilder(
              animation: _flipAnimation,
              builder: (context, child) {
                final angle = _flipAnimation.value;
                final transform = Matrix4.identity()
                  ..setEntry(3, 2, 0.0015)
                  ..rotateY(angle);

                return Transform(
                  transform: transform,
                  alignment: Alignment.center,
                  child: _showFront
                      ? CreditCardWidget(
                          card: widget.card,
                          isSelected: true,
                        )
                      : Transform(
                          transform: Matrix4.identity()..rotateY(math.pi),
                          alignment: Alignment.center,
                          child: CreditCardBackWidget(
                            card: widget.card,
                            showFullCVV: _showFullDetails,
                          ),
                        ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Interactive Actions (Freeze, Show Details, Copy CVV)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _modalActionTile(
                context,
                icon: _isFrozen
                    ? Icons.lock_open_rounded
                    : Icons.ac_unit_rounded,
                label: _isFrozen ? 'Unfreeze' : 'Freeze Card',
                color: _isFrozen
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
                onTap: () {
                  setState(() => _isFrozen = !_isFrozen);
                  _showToast(
                    context,
                    _isFrozen ? 'Card Frozen' : 'Card Unfrozen',
                  );
                },
              ),
              _modalActionTile(
                context,
                icon: _showFullDetails
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                label: _showFullDetails ? 'Hide CVV' : 'Reveal CVV',
                color: const Color(0xFF6366F1),
                onTap: () {
                  setState(() => _showFullDetails = !_showFullDetails);
                },
              ),
              _modalActionTile(
                context,
                icon: Icons.copy_rounded,
                label: 'Copy CVV',
                color: const Color(0xFF0EA5E9),
                onTap: () {
                  _showToast(context, 'CVV (${widget.card.cvv}) copied!');
                },
              ),
              _modalActionTile(
                context,
                icon: Icons.flip_camera_android_rounded,
                label: 'Flip Card',
                color: const Color(0xFFF59E0B),
                onTap: _toggleFlip,
              ),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _modalActionTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showToast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class CreditCardBackWidget extends StatelessWidget {
  final PaymentCard card;
  final bool showFullCVV;

  const CreditCardBackWidget({
    super.key,
    required this.card,
    this.showFullCVV = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: card.gradientColors,
        ),
        border: Border.all(
          color: card.accentColor.withValues(alpha: 0.8),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: card.accentColor.withValues(alpha: 0.35),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // Black Magnetic Stripe
            Container(
              width: double.infinity,
              height: 42,
              color: const Color(0xFF0D0F12),
            ),

            const SizedBox(height: 18),

            // Signature Strip & CVV Code Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Signature Area with security lines pattern
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF9F6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: SignaturePatternPainter(),
                            ),
                          ),
                          const Center(
                            child: Text(
                              'AUTHORIZED SIGNATURE',
                              style: TextStyle(
                                color: Colors.black38,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // CVV Box
                  Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.black26),
                    ),
                    child: Center(
                      child: Text(
                        showFullCVV ? card.cvv : '•••',
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontFamily: 'Courier',
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Customer Support Hotline & Holographic Badge
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '24/7 CUSTOMER SUPPORT',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '+1 (800) 555-FINPAY • support@finpay.app',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  // Hologram Metallic Security Seal
                  Container(
                    width: 32,
                    height: 22,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF38BDF8),
                          Color(0xFFEC4899),
                          Color(0xFFFDE047),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.security_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SignaturePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..strokeWidth = 1.0;

    for (double i = -size.height; i < size.width; i += 8) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/payment_card.dart';

enum ProcessingStage { connecting, verifying, processing, complete }

class PaymentProcessingOverlay extends StatefulWidget {
  final double amount;
  final PaymentCard selectedCard;
  final VoidCallback onComplete;

  const PaymentProcessingOverlay({
    super.key,
    required this.amount,
    required this.selectedCard,
    required this.onComplete,
  });

  @override
  State<PaymentProcessingOverlay> createState() =>
      _PaymentProcessingOverlayState();
}

class _PaymentProcessingOverlayState extends State<PaymentProcessingOverlay>
    with TickerProviderStateMixin {
  ProcessingStage _currentStage = ProcessingStage.connecting;
  late AnimationController _pulseController;
  late AnimationController _checkController;
  late Animation<double> _checkScaleAnimation;
  double _progressValue = 0.15;
  Timer? _stageTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _checkScaleAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );

    _startFlow();
  }

  void _startFlow() {
    // Stage 1 -> 2 (Verifying)
    _stageTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() {
          _currentStage = ProcessingStage.verifying;
          _progressValue = 0.45;
        });
      }

      // Stage 2 -> 3 (Processing)
      _stageTimer = Timer(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _currentStage = ProcessingStage.processing;
            _progressValue = 0.80;
          });
        }

        // Stage 3 -> 4 (Complete)
        _stageTimer = Timer(const Duration(milliseconds: 1100), () {
          if (mounted) {
            setState(() {
              _currentStage = ProcessingStage.complete;
              _progressValue = 1.0;
            });
            _pulseController.stop();
            _checkController.forward();

            // Callback delay
            _stageTimer = Timer(const Duration(milliseconds: 1000), () {
              if (mounted) {
                widget.onComplete();
              }
            });
          }
        });
      });
    });
  }

  @override
  void dispose() {
    _stageTimer?.cancel();
    _pulseController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Container(
          width: 330,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161A22) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 32,
                spreadRadius: 6,
              ),
            ],
            border: Border.all(
              color: isDark ? const Color(0xFF2E3646) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Central Payment Indicator with Pulsing Ring & Progress
              SizedBox(
                width: 116,
                height: 116,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Pulsing Aura
                    if (_currentStage != ProcessingStage.complete)
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Container(
                            width: 116 * (0.85 + _pulseController.value * 0.15),
                            height:
                                116 * (0.85 + _pulseController.value * 0.15),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getStageColor().withValues(alpha: 0.14),
                            ),
                          );
                        },
                      ),

                    // Smooth Progress Indicator Ring
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeInOut,
                      tween: Tween<double>(begin: 0.0, end: _progressValue),
                      builder: (context, value, child) {
                        return SizedBox(
                          width: 96,
                          height: 96,
                          child: CircularProgressIndicator(
                            value: value,
                            strokeWidth: 4.5,
                            backgroundColor: isDark
                                ? const Color(0xFF2E3646)
                                : const Color(0xFFE2E8F0),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getStageColor(),
                            ),
                          ),
                        );
                      },
                    ),

                    // Central Morphing Icon
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildStageIcon(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Payment Amount (Primary Focus)
              Text(
                '\$${widget.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 6),

              // Selected Card Info
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.credit_card_rounded,
                    size: 14,
                    color: widget.selectedCard.accentColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.selectedCard.cardName} (${widget.selectedCard.lastFour})',
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Divider(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.08),
              ),
              const SizedBox(height: 16),

              // Status Title & Subtitle with smooth fade switcher
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Column(
                  key: ValueKey(_currentStage),
                  children: [
                    Text(
                      _getStageTitle(),
                      style: TextStyle(
                        color: _currentStage == ProcessingStage.complete
                            ? const Color(0xFF10B981)
                            : isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getStageSubtitle(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStageColor() {
    switch (_currentStage) {
      case ProcessingStage.connecting:
        return const Color(0xFF6366F1); // Violet
      case ProcessingStage.verifying:
        return const Color(0xFF0EA5E9); // Sky Blue
      case ProcessingStage.processing:
        return const Color(0xFFF59E0B); // Amber
      case ProcessingStage.complete:
        return const Color(0xFF10B981); // Emerald Green
    }
  }

  Widget _buildStageIcon() {
    switch (_currentStage) {
      case ProcessingStage.connecting:
        return const Icon(
          Icons.wifi_lock_rounded,
          key: ValueKey('conn'),
          color: Color(0xFF6366F1),
          size: 34,
        );

      case ProcessingStage.verifying:
        return const Icon(
          Icons.shield_outlined,
          key: ValueKey('verif'),
          color: Color(0xFF0EA5E9),
          size: 36,
        );

      case ProcessingStage.processing:
        return const Icon(
          Icons.sync_lock_rounded,
          key: ValueKey('proc'),
          color: Color(0xFFF59E0B),
          size: 34,
        );

      case ProcessingStage.complete:
        return ScaleTransition(
          scale: _checkScaleAnimation,
          child: Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF10B981),
                  blurRadius: 18,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 44,
            ),
          ),
        );
    }
  }

  String _getStageTitle() {
    switch (_currentStage) {
      case ProcessingStage.connecting:
        return 'Connecting...';
      case ProcessingStage.verifying:
        return 'Verifying Credentials';
      case ProcessingStage.processing:
        return 'Authorizing Payment';
      case ProcessingStage.complete:
        return 'Payment Complete!';
    }
  }

  String _getStageSubtitle() {
    switch (_currentStage) {
      case ProcessingStage.connecting:
        return 'Securing 256-bit encrypted channel...';
      case ProcessingStage.verifying:
        return 'Authenticating biometrics with bank...';
      case ProcessingStage.processing:
        return 'Reserving funds & issuing token...';
      case ProcessingStage.complete:
        return 'Transaction authorized successfully.';
    }
  }
}

import 'package:flutter/material.dart';

import '../models/transaction_item.dart';
import '../widgets/animated_check_mark.dart';
import '../widgets/confetti_widget.dart';
import 'receipt_screen.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final TransactionModel transaction;

  const PaymentSuccessScreen({
    super.key,
    required this.transaction,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;
  late Animation<double> _amountFade;
  late Animation<Offset> _amountSlide;
  late Animation<double> _detailsFade;
  late Animation<Offset> _detailsSlide;
  late Animation<double> _actionsFade;
  bool _triggerConfetti = false;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _amountFade = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
    );
    _amountSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(_amountFade);

    _detailsFade = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
    );
    _detailsSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(_detailsFade);

    _actionsFade = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );

    _staggerController.forward();

    // Trigger subtle confetti burst
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) {
        setState(() {
          _triggerConfetti = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txn = widget.transaction;

    return Scaffold(
      body: Stack(
        children: [
          // Subtle Confetti Particle Canvas
          Positioned.fill(
            child: ConfettiWidget(isPlaying: _triggerConfetti),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Header Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF10B981).withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_user_rounded,
                          size: 14,
                          color: Color(0xFF10B981),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'PAYMENT CONFIRMED',
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Animated CheckMark Path Drawing
                  const AnimatedCheckMark(
                    size: 96,
                    color: Color(0xFF10B981),
                    strokeColor: Colors.white,
                  ),

                  const SizedBox(height: 24),

                  // Sequential Staggered Amount & Merchant Name
                  FadeTransition(
                    opacity: _amountFade,
                    child: SlideTransition(
                      position: _amountSlide,
                      child: Column(
                        children: [
                          Text(
                            '\$${txn.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.0,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Paid to ${txn.merchantName}',
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Sequential Staggered Transaction Details Card
                  FadeTransition(
                    opacity: _detailsFade,
                    child: SlideTransition(
                      position: _detailsSlide,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF161A22)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF2E3646)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow(
                              context,
                              icon: Icons.storefront_rounded,
                              label: 'Merchant',
                              value: txn.merchantName,
                            ),
                            const Divider(height: 20),
                            _buildDetailRow(
                              context,
                              icon: Icons.numbers_rounded,
                              label: 'Transaction ID',
                              value: txn.id,
                              isCopyable: true,
                            ),
                            const Divider(height: 20),
                            _buildDetailRow(
                              context,
                              icon: Icons.calendar_today_rounded,
                              label: 'Date & Time',
                              value: _formatDate(txn.timestamp),
                            ),
                            const Divider(height: 20),
                            _buildDetailRow(
                              context,
                              icon: Icons.credit_card_rounded,
                              label: 'Payment Method',
                              value:
                                  '${txn.paymentCard.cardName} (${txn.paymentCard.lastFour})',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Sequential Staggered Actions: View Receipt & Done
                  FadeTransition(
                    opacity: _actionsFade,
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, anim1, anim2) =>
                                      ReceiptScreen(transaction: txn),
                                  transitionsBuilder:
                                      (context, anim1, anim2, child) {
                                    return SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0, 1),
                                        end: Offset.zero,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: anim1,
                                          curve: Curves.easeOutCubic,
                                        ),
                                      ),
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              elevation: 6,
                              shadowColor:
                                  const Color(0xFF6366F1).withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.receipt_long_rounded),
                            label: const Text(
                              'View Printable Receipt',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: TextButton(
                            onPressed: () {
                              Navigator.popUntil(
                                  context, (route) => route.isFirst);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Done',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isCopyable = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E2430)
                : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 16,
            color: const Color(0xFF6366F1),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        if (isCopyable) ...[
          const Spacer(),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Copied $value to clipboard'),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(
              Icons.copy_rounded,
              size: 16,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final month = months[dt.month - 1];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$month ${dt.day}, ${dt.year} • $hour:$minute $period';
  }
}

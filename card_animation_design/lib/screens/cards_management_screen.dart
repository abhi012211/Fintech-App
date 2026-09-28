import 'package:flutter/material.dart';
import '../models/payment_card.dart';
import '../widgets/card_detail_flip_modal.dart';
import '../widgets/credit_card_widget.dart';

class CardsManagementScreen extends StatefulWidget {
  const CardsManagementScreen({super.key});

  @override
  State<CardsManagementScreen> createState() => _CardsManagementScreenState();
}

class _CardsManagementScreenState extends State<CardsManagementScreen> {
  final List<PaymentCard> _cards = PaymentCard.sampleCards;
  final Map<String, bool> _frozenState = {};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Cards & Wallet',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Add New Card feature opened'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active Payment Cards (${_cards.length})',
              style: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),

            ..._cards.map((card) {
              final isFrozen = _frozenState[card.id] ?? false;

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161A22) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF2E3646)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  children: [
                    // Card Graphic Widget
                    SizedBox(
                      height: 210,
                      child: CreditCardWidget(
                        card: card,
                        isSelected: !isFrozen,
                        onTap: () => CardDetailFlipModal.show(context, card),
                      ),
                    ),

                    // Quick Card Controls
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _controlTile(
                            context,
                            icon: isFrozen
                                ? Icons.lock_open_rounded
                                : Icons.ac_unit_rounded,
                            label: isFrozen ? 'Unfreeze' : 'Freeze Card',
                            color: isFrozen
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            onTap: () {
                              setState(() {
                                _frozenState[card.id] = !isFrozen;
                              });
                            },
                          ),
                          _controlTile(
                            context,
                            icon: Icons.visibility_outlined,
                            label: 'Details',
                            color: const Color(0xFF6366F1),
                            onTap: () {
                              CardDetailFlipModal.show(context, card);
                            },
                          ),
                          _controlTile(
                            context,
                            icon: Icons.speed_rounded,
                            label: 'Spending Limit',
                            color: const Color(0xFF0EA5E9),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Daily limit for ${card.cardName}: \$5,000.00'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _controlTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
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
}

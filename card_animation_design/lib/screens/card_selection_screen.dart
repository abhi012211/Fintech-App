import 'package:flutter/material.dart';

import '../models/payment_card.dart';
import '../models/transaction_item.dart';
import '../widgets/animated_pay_button.dart';
import '../widgets/card_detail_flip_modal.dart';
import '../widgets/credit_card_widget.dart';
import '../widgets/payment_processing_overlay.dart';
import 'payment_success_screen.dart';

class CardSelectionScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeModeNotifier;

  const CardSelectionScreen({
    super.key,
    required this.themeModeNotifier,
  });

  @override
  State<CardSelectionScreen> createState() => _CardSelectionScreenState();
}

class _CardSelectionScreenState extends State<CardSelectionScreen> {
  late List<PaymentCard> _cards;
  late PageController _pageController;
  int _selectedIndex = 0;
  double _currentPage = 0.0;
  PayButtonState _payButtonState = PayButtonState.idle;
  bool _isProcessingPayment = false;
  final double _paymentAmount = 799.00;

  @override
  void initState() {
    super.initState();
    _cards = PaymentCard.sampleCards;
    _pageController = PageController(
      viewportFraction: 0.84,
      initialPage: _selectedIndex,
    );

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  PaymentCard get _selectedCard => _cards[_selectedIndex];

  void _onCardChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onPayNowPressed() {
    // 1. Morph button to loading
    setState(() {
      _payButtonState = PayButtonState.loading;
    });

    // 2. Open processing overlay after short button morph pause
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() {
          _isProcessingPayment = true;
        });
      }
    });
  }

  void _onPaymentProcessingComplete() {
    // 3. Morph button to success checkmark
    setState(() {
      _isProcessingPayment = false;
      _payButtonState = PayButtonState.success;
    });

    // 4. Navigate to success screen
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        final transaction = TransactionModel.createSample(
          card: _selectedCard,
          totalAmount: _paymentAmount,
        );

        // Reset button state
        setState(() {
          _payButtonState = PayButtonState.idle;
        });

        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, anim1, anim2) =>
                PaymentSuccessScreen(transaction: transaction),
            transitionsBuilder: (context, anim1, anim2, child) {
              return FadeTransition(opacity: anim1, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top App Header (Profile, Theme Switcher)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'AP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'WELCOME BACK',
                                style: TextStyle(
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Alexander Pierce',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Theme Toggle & Security Shield
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              widget.themeModeNotifier.value = isDark
                                  ? ThemeMode.light
                                  : ThemeMode.dark;
                            },
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF161A22)
                                    : const Color(0xFFE2E8F0),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isDark
                                    ? Icons.light_mode_rounded
                                    : Icons.dark_mode_rounded,
                                size: 20,
                                color: isDark
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFF6366F1),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFF10B981).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF10B981).withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  size: 14,
                                  color: Color(0xFF10B981),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '256-BIT',
                                  style: TextStyle(
                                    color: Color(0xFF10B981),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // 2. Section Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Payment Card',
                        style: TextStyle(
                          color:
                              isDark ? Colors.white : const Color(0xFF0F172A),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        '${_selectedIndex + 1} of ${_cards.length}',
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // 3. 3D Parallax Card Carousel
                SizedBox(
                  height: 235,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onCardChanged,
                    itemCount: _cards.length,
                    itemBuilder: (context, index) {
                      final card = _cards[index];

                      // 3D Parallax Tilt Calculation
                      final pageOffset = (_currentPage - index);
                      final rotateY = (pageOffset * 0.22).clamp(-0.45, 0.45);

                      // Scale Calculation
                      final scale =
                          (1.0 - (pageOffset.abs() * 0.14)).clamp(0.86, 1.04);
                      final opacity =
                          (1.0 - (pageOffset.abs() * 0.4)).clamp(0.6, 1.0);

                      final isSelected = index == _selectedIndex;

                      return AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: opacity,
                        child: Transform.scale(
                          scale: scale,
                          child: CreditCardWidget(
                            card: card,
                            isSelected: isSelected,
                            rotateY: rotateY,
                            onTap: () {
                              if (isSelected) {
                                CardDetailFlipModal.show(context, card);
                              } else {
                                _pageController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 350),
                                  curve: Curves.easeOutCubic,
                                );
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Carousel Dots Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_cards.length, (index) {
                    final isSelected = index == _selectedIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isSelected ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF6366F1)
                            : isDark
                                ? const Color(0xFF2E3646)
                                : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 18),

                // 4. Card Balance & Order Details Container
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Balance Card with smooth AnimatedSwitcher
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            key: ValueKey(_selectedCard.id),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF161A22)
                                  : const Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF2E3646)
                                    : const Color(0xFFE2E8F0),
                              ),
                              boxShadow: [
                                if (!isDark)
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: _selectedCard.accentColor,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'AVAILABLE BALANCE',
                                          style: TextStyle(
                                            color: isDark
                                                ? const Color(0xFF94A3B8)
                                                : const Color(0xFF64748B),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '\$${_selectedCard.balance.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF0F172A),
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _selectedCard.accentColor
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _selectedCard.cardName,
                                    style: TextStyle(
                                      color: _selectedCard.accentColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Order Summary Breakdown Container
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF161A22)
                                : const Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF2E3646)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF6366F1)
                                              .withValues(alpha: 0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.shopping_bag_outlined,
                                          color: Color(0xFF6366F1),
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Apple Store (Fifth Ave)',
                                            style: TextStyle(
                                              color: isDark
                                                  ? Colors.white
                                                  : const Color(0xFF0F172A),
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Order #7892-AP',
                                            style: TextStyle(
                                              color: isDark
                                                  ? const Color(0xFF94A3B8)
                                                  : const Color(0xFF64748B),
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '\$${_paymentAmount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF0F172A),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Divider(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.08),
                              ),
                              const SizedBox(height: 10),

                              _summaryRow(
                                isDark,
                                'Apple Watch Ultra 2',
                                '\$749.00',
                              ),
                              const SizedBox(height: 6),
                              _summaryRow(
                                isDark,
                                'Alpine Loop Band (Olive)',
                                '\$50.00',
                              ),
                              const SizedBox(height: 6),
                              _summaryRow(
                                isDark,
                                'Tax & Shipping',
                                'Included',
                                isHighlight: true,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // 5. Interactive Animated "Pay Now" CTA Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  child: AnimatedPayButton(
                    amount: _paymentAmount,
                    currentState: _payButtonState,
                    onPressed: _onPayNowPressed,
                  ),
                ),
              ],
            ),
          ),

          // 6. Payment Processing Modal Overlay
          if (_isProcessingPayment)
            PaymentProcessingOverlay(
              amount: _paymentAmount,
              selectedCard: _selectedCard,
              onComplete: _onPaymentProcessingComplete,
            ),
        ],
      ),
    );
  }

  Widget _summaryRow(bool isDark, String label, String value,
      {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isHighlight
                ? const Color(0xFF10B981)
                : isDark
                    ? Colors.white
                    : const Color(0xFF0F172A),
            fontSize: 12,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

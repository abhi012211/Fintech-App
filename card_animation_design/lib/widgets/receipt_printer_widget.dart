import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/transaction_item.dart';
import 'qr_barcode_widget.dart';

class ReceiptPrinterWidget extends StatefulWidget {
  final TransactionModel transaction;
  final VoidCallback? onDownload;
  final VoidCallback? onShare;

  const ReceiptPrinterWidget({
    super.key,
    required this.transaction,
    this.onDownload,
    this.onShare,
  });

  @override
  State<ReceiptPrinterWidget> createState() => _ReceiptPrinterWidgetState();
}

class _ReceiptPrinterWidgetState extends State<ReceiptPrinterWidget>
    with TickerProviderStateMixin {
  late AnimationController _printController;
  late AnimationController _vibrationController;
  late Animation<double> _paperFeedAnimation;
  late Animation<double> _fadeContentAnimation;
  late Animation<double> _sealScaleAnimation;
  bool _isPrinting = true;
  bool _isPrinted = false;
  String _printingStatusText = 'CONNECTING...';

  @override
  void initState() {
    super.initState();
    _printController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    // Mechanical vibration controller
    _vibrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );

    _paperFeedAnimation = CurvedAnimation(
      parent: _printController,
      curve: Curves.easeOutCubic,
    );

    _fadeContentAnimation = CurvedAnimation(
      parent: _printController,
      curve: const Interval(0.15, 1.0, curve: Curves.easeIn),
    );

    _sealScaleAnimation = CurvedAnimation(
      parent: _printController,
      curve: const Interval(0.85, 1.0, curve: Curves.elasticOut),
    );

    // Start mechanical printer vibration & line status updates
    _vibrationController.repeat(reverse: true);
    _printController.forward();

    _printController.addListener(() {
      final val = _printController.value;
      if (val < 0.25) {
        if (_printingStatusText != 'INITIALIZING FEED...') {
          setState(() => _printingStatusText = 'INITIALIZING FEED...');
        }
      } else if (val < 0.6) {
        if (_printingStatusText != 'PRINTING LINE 1/3...') {
          setState(() => _printingStatusText = 'PRINTING LINE 1/3...');
        }
      } else if (val < 0.85) {
        if (_printingStatusText != 'PRINTING LINE 3/3...') {
          setState(() => _printingStatusText = 'PRINTING LINE 3/3...');
        }
      } else {
        if (_printingStatusText != 'RECEIPT READY') {
          setState(() => _printingStatusText = 'RECEIPT READY');
        }
      }
    });

    _printController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _vibrationController.stop();
        if (mounted) {
          setState(() {
            _isPrinting = false;
            _isPrinted = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _printController.dispose();
    _vibrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // 1. Hardware Printer Slot Header with mechanical shake
        AnimatedBuilder(
          animation: _vibrationController,
          builder: (context, child) {
            final shakeDx = _isPrinting
                ? (math.sin(_vibrationController.value * math.pi * 2) * 0.8)
                : 0.0;
            return Transform.translate(
              offset: Offset(shakeDx, 0),
              child: child,
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2430) : const Color(0xFF1E293B),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Top Bar with Status LED & Dynamic Printing Line Text
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.print_rounded,
                            color: Color(0xFF94A3B8),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'THERMAL PRINTER FX-200',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),

                      // Pulsing LED & Printing Status Text
                      Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isPrinting
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFF10B981),
                              boxShadow: [
                                BoxShadow(
                                  color: _isPrinting
                                      ? const Color(0xFFF59E0B)
                                          .withValues(alpha: 0.8)
                                      : const Color(0xFF10B981)
                                          .withValues(alpha: 0.8),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              _printingStatusText,
                              key: ValueKey(_printingStatusText),
                              style: TextStyle(
                                color: _isPrinting
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFF10B981),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Metallic Printer Slot Mouth
                Container(
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 4,
                        spreadRadius: 1,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ),

        // 2. Animated Paper Feeding Area
        AnimatedBuilder(
          animation: _paperFeedAnimation,
          builder: (context, child) {
            return Align(
              alignment: Alignment.topCenter,
              child: SizeTransition(
                sizeFactor: _paperFeedAnimation,
                axis: Axis.vertical,
                alignment: Alignment.topCenter,
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ClipPath(
              clipper: ReceiptSerratedClipper(),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF9F6), // Thermal Paper Off-White
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: FadeTransition(
                  opacity: _fadeContentAnimation,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Store Header Logo / Title
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF0F172A),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.bolt_rounded,
                                    color: Color(0xFF10B981),
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'FINPAY DIGITAL',
                                  style: TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.transaction.merchantAddress,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 12),

                            const DottedDivider(),
                            const SizedBox(height: 12),

                            // Transaction Info Header
                            _buildReceiptRow(
                              'DATE & TIME',
                              _formatDateTime(widget.transaction.timestamp),
                              isBold: true,
                            ),
                            const SizedBox(height: 6),
                            _buildReceiptRow(
                              'TRANSACTION ID',
                              widget.transaction.id,
                            ),
                            const SizedBox(height: 6),
                            _buildReceiptRow(
                              'PAYMENT METHOD',
                              '${widget.transaction.paymentCard.cardName} (${widget.transaction.paymentCard.lastFour})',
                            ),
                            const SizedBox(height: 6),
                            _buildReceiptRow(
                              'AUTH CODE',
                              widget.transaction.authCode,
                            ),

                            const SizedBox(height: 14),
                            const DottedDivider(),
                            const SizedBox(height: 14),

                            // Itemized Table
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'ITEM DESCRIPTION',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                Text(
                                  'AMOUNT',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            ...widget.transaction.items.map((item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${item.quantity}x ${item.name}',
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '\$${item.total.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),

                            const SizedBox(height: 10),
                            const DottedDivider(),
                            const SizedBox(height: 10),

                            // Totals Summary
                            _buildReceiptRow('Subtotal',
                                '\$${widget.transaction.subtotal.toStringAsFixed(2)}'),
                            const SizedBox(height: 4),
                            _buildReceiptRow('Sales Tax (8.875%)',
                                '\$${widget.transaction.taxAmount.toStringAsFixed(2)}'),
                            const SizedBox(height: 4),
                            _buildReceiptRow('Processing Fee', 'FREE (\$0.00)'),

                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'TOTAL PAID',
                                    style: TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  Text(
                                    '\$${widget.transaction.grandTotal.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Color(0xFF10B981),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Barcode & QR Code Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomQRCodeWidget(
                                  data: widget.transaction.qrData,
                                  size: 70,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      CustomBarcodeWidget(
                                        code: widget.transaction.id
                                            .replaceAll('-', ''),
                                        height: 32,
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'SCAN TO VERIFY RECEIPT',
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),
                            Text(
                              '*** THANK YOU FOR YOUR PAYMENT ***\nFINPAY PROTECTED • ENCRYPTED TRANSACTION',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.4),
                                fontSize: 8,
                                height: 1.4,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Metallic Foil Verified Seal Badge
                      Positioned(
                        top: 24,
                        right: 20,
                        child: ScaleTransition(
                          scale: _sealScaleAnimation,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFDE047), Color(0xFFCA8A04)],
                              ),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.verified_rounded,
                                    size: 10, color: Color(0xFF0F172A)),
                                SizedBox(width: 3),
                                Text(
                                  'VERIFIED',
                                  style: TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // 3. Action Buttons (Download & Share) with tactile ready banner
        AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          opacity: _isPrinted ? 1.0 : 0.3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isPrinted ? widget.onDownload : null,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFCBD5E1),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text(
                      'Download',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isPrinted ? widget.onShare : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 4,
                      shadowColor:
                          const Color(0xFF6366F1).withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: const Text(
                      'Share',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.black54,
            fontSize: 10,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 10,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
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

class ReceiptSerratedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const toothWidth = 8.0;
    const toothHeight = 4.0;

    path.moveTo(0, 0);
    double x = 0;
    bool isUp = false;
    while (x < size.width) {
      x += toothWidth;
      path.lineTo(x, isUp ? 0 : toothHeight);
      isUp = !isUp;
    }

    path.lineTo(size.width, size.height);

    x = size.width;
    isUp = false;
    while (x > 0) {
      x -= toothWidth;
      path.lineTo(x, size.height - (isUp ? 0 : toothHeight));
      isUp = !isUp;
    }

    path.lineTo(0, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class DottedDivider extends StatelessWidget {
  const DottedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.maxWidth;
        const dashWidth = 4.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.black26),
              ),
            );
          }),
        );
      },
    );
  }
}

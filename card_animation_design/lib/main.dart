import 'package:flutter/material.dart';

import 'models/payment_card.dart';
import 'models/transaction_item.dart';
import 'screens/card_selection_screen.dart';
import 'screens/cards_management_screen.dart';
import 'screens/receipt_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const FintechApp());
}

class FintechApp extends StatefulWidget {
  const FintechApp({super.key});

  @override
  State<FintechApp> createState() => _FintechAppState();
}

class _FintechAppState extends State<FintechApp> {
  final ValueNotifier<ThemeMode> _themeModeNotifier =
      ValueNotifier(ThemeMode.dark);

  @override
  void dispose() {
    _themeModeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeModeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: 'FinPay • Premium Payments',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: themeMode,
          home: MainNavigationShell(
            themeModeNotifier: _themeModeNotifier,
          ),
        );
      },
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeModeNotifier;

  const MainNavigationShell({
    super.key,
    required this.themeModeNotifier,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      CardSelectionScreen(themeModeNotifier: widget.themeModeNotifier),
      const CardsManagementScreen(),
      const TransactionHistoryView(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161A22) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF2E3646) : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(
                  index: 0,
                  icon: Icons.payment_rounded,
                  label: 'Pay Now',
                ),
                _navItem(
                  index: 1,
                  icon: Icons.credit_card_rounded,
                  label: 'My Cards',
                ),
                _navItem(
                  index: 2,
                  icon: Icons.history_rounded,
                  label: 'Receipts',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6366F1).withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? const Color(0xFF6366F1)
                  : isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF6366F1),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class TransactionHistoryView extends StatelessWidget {
  const TransactionHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sampleCard = PaymentCard.sampleCards.first;

    final pastTransactions = [
      TransactionModel.createSample(card: sampleCard, totalAmount: 799.00),
      TransactionModel(
        id: 'TXN-9021-4412-8842',
        merchantName: 'Revolut Premium',
        merchantCategory: 'Financial Services',
        merchantAddress: '77 City Road, London EC1Y 1BD',
        amount: 14.99,
        taxAmount: 1.20,
        processingFee: 0.00,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        paymentCard: sampleCard,
        items: [
          const ReceiptItem(
              name: 'Monthly Metal Membership', quantity: 1, price: 14.99)
        ],
        qrData: 'https://pay.fintech.app/receipt?txn=90214412',
        authCode: 'AUTH-902144',
      ),
      TransactionModel(
        id: 'TXN-7192-3301-8842',
        merchantName: 'Uber Black Ride',
        merchantCategory: 'Transport & Travel',
        merchantAddress: 'San Francisco, CA 94103',
        amount: 48.50,
        taxAmount: 3.88,
        processingFee: 0.00,
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        paymentCard: sampleCard,
        items: [
          const ReceiptItem(
              name: 'SFO Airport to Downtown', quantity: 1, price: 48.50)
        ],
        qrData: 'https://pay.fintech.app/receipt?txn=71923301',
        authCode: 'AUTH-719233',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Receipts & History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: pastTransactions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final txn = pastTransactions[index];
          return Material(
            color: isDark ? const Color(0xFF161A22) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF2E3646)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Color(0xFF6366F1),
                  size: 20,
                ),
              ),
              title: Text(
                txn.merchantName,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                '${txn.id} • ${_formatShortDate(txn.timestamp)}',
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                  fontSize: 11,
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${txn.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Tap for Receipt',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReceiptScreen(transaction: txn),
                  ),
                );
              },
            ),
          ),
        );
        },
      ),
    );
  }

  String _formatShortDate(DateTime dt) {
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
    return '${months[dt.month - 1]} ${dt.day}';
  }
}

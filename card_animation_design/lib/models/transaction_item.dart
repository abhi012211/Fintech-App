import 'payment_card.dart';

class ReceiptItem {
  final String name;
  final int quantity;
  final double price;

  const ReceiptItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  double get total => quantity * price;
}

class TransactionModel {
  final String id;
  final String merchantName;
  final String merchantCategory;
  final String merchantAddress;
  final double amount;
  final double taxAmount;
  final double processingFee;
  final DateTime timestamp;
  final PaymentCard paymentCard;
  final List<ReceiptItem> items;
  final String qrData;
  final String authCode;

  const TransactionModel({
    required this.id,
    required this.merchantName,
    required this.merchantCategory,
    required this.merchantAddress,
    required this.amount,
    required this.taxAmount,
    required this.processingFee,
    required this.timestamp,
    required this.paymentCard,
    required this.items,
    required this.qrData,
    required this.authCode,
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.total);
  double get grandTotal => amount;

  static TransactionModel createSample({
    required PaymentCard card,
    double totalAmount = 799.00,
  }) {
    final now = DateTime.now();
    return TransactionModel(
      id: 'TXN-${now.millisecondsSinceEpoch.toString().substring(3, 11)}-${card.lastFour}',
      merchantName: 'Apple Store (Fifth Ave)',
      merchantCategory: 'Electronics & Hardware',
      merchantAddress: '767 5th Ave, New York, NY 10153',
      amount: totalAmount,
      taxAmount: totalAmount * 0.08875,
      processingFee: 0.00,
      timestamp: now,
      paymentCard: card,
      items: [
        const ReceiptItem(
          name: 'Apple Watch Ultra 2 (Titanium)',
          quantity: 1,
          price: 749.00,
        ),
        const ReceiptItem(
          name: 'Alpine Loop Band (Olive)',
          quantity: 1,
          price: 50.00,
        ),
      ],
      qrData: 'https://pay.fintech.app/receipt?txn=${now.millisecondsSinceEpoch}&card=${card.lastFour}',
      authCode: 'AUTH-892419',
    );
  }
}

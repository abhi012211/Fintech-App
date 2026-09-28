import 'package:flutter/material.dart';

enum CardBrand { visa, mastercard, amex, metal }

class PaymentCard {
  final String id;
  final String cardHolder;
  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final double balance;
  final CardBrand brand;
  final List<Color> gradientColors;
  final Color accentColor;
  final String cardName;
  final String cardType;

  const PaymentCard({
    required this.id,
    required this.cardHolder,
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.balance,
    required this.brand,
    required this.gradientColors,
    required this.accentColor,
    required this.cardName,
    required this.cardType,
  });

  String get maskedNumber {
    final clean = cardNumber.replaceAll(' ', '');
    if (clean.length >= 4) {
      final last4 = clean.substring(clean.length - 4);
      return '•••• •••• •••• $last4';
    }
    return cardNumber;
  }

  String get lastFour {
    final clean = cardNumber.replaceAll(' ', '');
    return clean.length >= 4 ? clean.substring(clean.length - 4) : '4242';
  }

  static List<PaymentCard> get sampleCards => [
        const PaymentCard(
          id: 'card_1',
          cardHolder: 'ALEXANDER PIERCE',
          cardNumber: '4532 8912 3456 8842',
          expiryDate: '08/28',
          cvv: '739',
          balance: 14850.50,
          brand: CardBrand.metal,
          gradientColors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
          accentColor: Color(0xFF38BDF8),
          cardName: 'Obsidian Black',
          cardType: 'Metal Founder Edition',
        ),
        const PaymentCard(
          id: 'card_2',
          cardHolder: 'ALEXANDER PIERCE',
          cardNumber: '5412 7534 8901 1290',
          expiryDate: '11/27',
          cvv: '482',
          balance: 6240.00,
          brand: CardBrand.mastercard,
          gradientColors: [Color(0xFF4C1D95), Color(0xFF6D28D9), Color(0xFF8B5CF6)],
          accentColor: Color(0xFFA78BFA),
          cardName: 'Violet Apex',
          cardType: 'World Elite Credit',
        ),
        const PaymentCard(
          id: 'card_3',
          cardHolder: 'ALEXANDER PIERCE',
          cardNumber: '3782 822463 91005',
          expiryDate: '04/29',
          cvv: '1092',
          balance: 28900.75,
          brand: CardBrand.amex,
          gradientColors: [Color(0xFF78350F), Color(0xFFB45309), Color(0xFFD97706)],
          accentColor: Color(0xFFFBBF24),
          cardName: 'Aura Gold',
          cardType: 'Platinum Rewards',
        ),
        const PaymentCard(
          id: 'card_4',
          cardHolder: 'ALEXANDER PIERCE',
          cardNumber: '4000 1234 5678 9010',
          expiryDate: '12/26',
          cvv: '221',
          balance: 1950.25,
          brand: CardBrand.visa,
          gradientColors: [Color(0xFF064E3B), Color(0xFF047857), Color(0xFF10B981)],
          accentColor: Color(0xFF34D399),
          cardName: 'Emerald Pure',
          cardType: 'Cashback Debit',
        ),
      ];
}

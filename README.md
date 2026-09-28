# FinPay • Premium Fintech Payment & 3D Card Animation Experience

A production-ready, ultra-polished **Fintech Mobile Application UI built with Flutter**. Inspired by modern financial platforms like Revolut, Apple Pay, Stripe, and Linear, this app features state-of-the-art 3D card physics, morphing interactive UI controls, multi-stage security verification, and a tactile digital receipt printer interaction.

---

## 🚀 Key Features & Interactive Flows

### 1. 💳 3D Parallax Card Carousel & Interactive Flip Modal
* **3D Matrix Swipe Physics**: Cards tilt dynamically along the Y-axis (`Matrix4.identity()..setEntry(3, 2, 0.0012)..rotateY(angle)`) as you swipe through the carousel.
* **Realistic Fintech Card Details**: Custom metallic gold IC chip (`MetallicChip`), contactless NFC icon, metallic foil shimmer beams (`CardShimmerPainter`), card number masking, and card brand badges (*Obsidian Metal, World Elite Mastercard, Visa, Amex*).
* **3D Card Flip Modal**: Tapping any card or swiping left/right opens a 3D flip card view showing:
  * **Front Side**: Cardholder, expiry, card type, balance, active glowing selection ring.
  * **Back Side**: Black magnetic stripe, security signature panel, CVV code box with hide/reveal toggle, customer support hotline, and rainbow holographic security seal.

### 2. ⚡ Morphing Interactive Pay Button
* **Spring Scale-Down**: Tapping the "Pay Now" button scales down to $0.96\times$ on press with tactile spring feedback.
* **Smooth Button Morphing**:
  $$\text{Idle ("Pay Now \$799.00")} \xrightarrow{\quad\text{Tap}\quad} \text{Compact Loading Pill} \xrightarrow{\quad\text{Authorized}\quad} \text{Emerald Green Checkmark}$$

### 3. 🛡️ 4-Stage Payment Processing Experience
* **Sequential Security Flow**:
  $$\text{Connecting} \xrightarrow{\quad\text{256-Bit Channel}\quad} \text{Verifying} \xrightarrow{\quad\text{Biometrics}\quad} \text{Processing} \xrightarrow{\quad\text{Funds}\quad} \text{Complete}$$
* **Visual Trust Feedback**: Pulsing aura rings, smooth circular progress arcs ($0\% \rightarrow 45\% \rightarrow 80\% \rightarrow 100\%$), and morphing status icons.

### 4. 🎉 Custom Path-Drawn Payment Success
* **Animated Checkmark Path**: Custom stroke path drawing animation (`AnimatedCheckMark`) rendered on canvas.
* **Sequential Staggered Entrances**: Staggered slide and fade transitions for paid amount, merchant details, transaction ID, and action CTAs.
* **Celebratory Confetti**: Custom canvas particle engine (`ConfettiWidget`) launching soft falling ribbon particles.

### 5. 🖨️ Tactile Thermal Receipt Printer Interaction
* **Mechanical Hardware Fixture**: Features a dark metallic printer header with a pulsing status LED (`PRINTING LINE 1/3...` $\rightarrow$ `RECEIPT READY`).
* **Mechanical Printer Vibration**: High-frequency micro-shake effect (`_vibrationController`) during printing.
* **Realistic Paper Emergence**: Paper feed animation with serrated cut edges (`ReceiptSerratedClipper`), itemized billing table, CustomPainter QR code (`CustomQRCodeWidget`), barcode, and a metallic gold foil seal stamp ("VERIFIED").
* **Actions**: Download PDF toast notification and modal share sheet.

---

## 📁 Project Architecture & Structure

```
lib/
├── main.dart                       # App entry point, Theme state, MainNavigationShell
├── models/
│   ├── payment_card.dart           # PaymentCard data model & sample cards
│   └── transaction_item.dart       # TransactionModel & ReceiptItem schemas
├── theme/
│   └── app_theme.dart              # Light & Dark themes, fintech color tokens
├── widgets/
│   ├── credit_card_widget.dart     # 3D tilted card widget & shimmer painter
│   ├── card_detail_flip_modal.dart # 3D 180° flip modal & card back side view
│   ├── animated_pay_button.dart    # Morphing interactive payment CTA button
│   ├── animated_check_mark.dart    # Custom path-drawn checkmark painter
│   ├── payment_processing_overlay.dart # 4-stage animated security overlay
│   ├── receipt_printer_widget.dart # Virtual thermal receipt printer interaction
│   ├── qr_barcode_widget.dart      # Custom-painted QR Code & Barcode widgets
│   └── confetti_widget.dart        # Canvas particle confetti animation
└── screens/
    ├── card_selection_screen.dart  # Card carousel, balance breakdown, checkout
    ├── payment_success_screen.dart # Payment authorization & transaction details
    ├── receipt_screen.dart         # Fullscreen digital printer receipt viewer
    └── cards_management_screen.dart# Cards overview, unfreeze/freeze, limits
```

---

## 🛠️ Getting Started

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.19 or higher)
* Dart SDK (v3.3 or higher)

### Run the Application

```bash
# Get dependencies
flutter pub get

# Analyze code quality
flutter analyze

# Run unit & widget tests
flutter test

# Launch app in dev mode
flutter run
```

---

## 🎨 Visual Design Philosophy
* **Palette**: Obsidian Dark `#0D0F12`, Emerald Green `#10B981` (reserved for successful transactions), Electric Violet `#6366F1`, Satin Gold `#F59E0B`.
* **Typography**: Clean hierarchy with heavy font weights for amounts and spaced uppercase letter-spacing for card details.
* **Motion Language**: Standard transitions $250\text{--}400\text{ms}$ with `Curves.easeOutCubic`, `Curves.elasticOut`, and spring physics.



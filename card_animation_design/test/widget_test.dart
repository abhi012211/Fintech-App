import 'package:flutter_test/flutter_test.dart';

import 'package:card_animation_design/main.dart';

void main() {
  testWidgets('FintechApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FintechApp());

    // Verify that Pay Now CTA appears
    expect(find.textContaining('Pay Now'), findsWidgets);
  });
}

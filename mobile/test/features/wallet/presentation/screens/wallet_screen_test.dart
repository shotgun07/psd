import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oblns/features/wallet/presentation/screens/wallet_screen.dart';

void main() {
  testWidgets('WalletScreen renders correctly', (WidgetTester tester) async {
    // Build the widget tree with ProviderScope for Riverpod
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: WalletScreen(),
        ),
      ),
    );

    // Verify the app bar title
    expect(find.text('المحفظة'), findsOneWidget);

    // Verify balance card elements (assuming some text is present)
    expect(find.textContaining('الرصيد'), findsOneWidget);

    // Verify quick actions
    expect(find.text('شحن المحفظة'), findsOneWidget);
    expect(find.text('سحب الأموال'), findsOneWidget);

    // Verify transactions section
    expect(find.text('المعاملات الأخيرة'), findsOneWidget);
  });
}

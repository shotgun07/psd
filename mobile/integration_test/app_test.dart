import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:oblns/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Audit Test', () {
    testWidgets('Verify App Launch and Splash Flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify splash screen or initial route
      expect(find.text('oblns'), findsOneWidget);
    });

    // Future: Add mocks for Appwrite to test authenticated flows
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mechanix_messages/main.dart' as app;
import 'package:mechanix_messages/core/utils/icons.dart';
import 'test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Navigation Flow Tests', () {
    final helper = IntegrationTestHelper();

    setUp(() async {
      await helper.setUp();
    });

    tearDown(() async {
      await helper.tearDown();
    });

    testWidgets('Navigate to Compose and Back', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify on Home Screen with "All messages" title
      expect(find.text('All messages'), findsOneWidget);

      // Tap Compose FAB
      final composeBtn = IntegrationTestHelper.findMessageButton(AppIcons.edit);
      expect(composeBtn, findsOneWidget);
      await tester.tap(composeBtn);
      await tester.pumpAndSettle();

      // Verify on Compose Screen with "New message" title
      expect(find.text('New message'), findsOneWidget);

      // Tap Back to Home
      final backBtn = IntegrationTestHelper.findIconButtonWithAsset(AppIcons.arrowLeft);
      expect(backBtn, findsOneWidget);
      await tester.tap(backBtn);
      await tester.pumpAndSettle();

      // Verify back on Home Screen
      expect(find.text('All messages'), findsOneWidget);
    });
  });
}

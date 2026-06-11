import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mechanix_messages/main.dart' as app;
import 'package:mechanix_messages/core/utils/icons.dart';
import 'test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Compose Screen Flow Tests', () {
    final helper = IntegrationTestHelper();

    setUp(() async {
      await helper.setUp();
    });

    tearDown(() async {
      await helper.tearDown();
    });

    testWidgets('Search Contacts and Direct Send', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to compose screen
      final composeBtn = IntegrationTestHelper.findMessageButton(AppIcons.edit);
      await tester.tap(composeBtn);
      await tester.pumpAndSettle();

      // Verify initial list contains seeded contacts
      expect(find.text('Alice Cooper'), findsOneWidget);
      expect(find.text('Bob Smith'), findsOneWidget);
      expect(find.text('Charlie Brown'), findsOneWidget);

      // Search for Alice
      final searchField = IntegrationTestHelper.searchTextField;
      await tester.enterText(searchField, 'Alice');
      await tester.pump(const Duration(milliseconds: 500)); // wait for search debounce
      await tester.pumpAndSettle();

      // Verify filtering works
      expect(find.text('Alice Cooper'), findsOneWidget);
      expect(find.text('Bob Smith'), findsNothing);

      // Clear search
      await tester.enterText(searchField, '');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify list is restored
      expect(find.text('Alice Cooper'), findsOneWidget);
      expect(find.text('Bob Smith'), findsOneWidget);

      // Direct send flow (type unknown number)
      await tester.enterText(searchField, '+999999999');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify "Send message to +999999999" tile is visible
      expect(find.text('Send message to +999999999'), findsOneWidget);

      // Tap on direct send option
      await tester.tap(find.text('Send message to +999999999'));
      await tester.pumpAndSettle();

      // Verify navigated to conversation screen for +999999999
      expect(find.text('+999999999'), findsOneWidget);
    });
  });
}
